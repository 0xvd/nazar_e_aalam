<?php

namespace App\Http\Controllers\Quran\API\Donation;

use App\Http\Controllers\Controller;
use App\Models\Quran\Donation\Donation;
use App\Models\Quran\Payment\PaymentMethod;
use GuzzleHttp\Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaypalDonationController extends Controller
{
    private function credentials(): ?array
    {
        $method = PaymentMethod::query()
            ->where('type', 'paypal')
            ->with('settings')
            ->first();

        if (! $method) return null;

        $clientId  = $method->settings->where('name', 'api_key')->first()?->value;
        $secret    = $method->settings->where('name', 'api_secret')->first()?->value;
        $mode      = $method->settings->where('name', 'payment_mode')->first()?->value ?? 'sandbox';

        if (! $clientId || ! $secret) return null;

        return ['client_id' => $clientId, 'secret' => $secret, 'mode' => $mode];
    }

    private function baseUrl(string $mode): string
    {
        return $mode === 'live'
            ? 'https://api-m.paypal.com'
            : 'https://api-m.sandbox.paypal.com';
    }

    private function accessToken(Client $http, string $base, string $clientId, string $secret): string
    {
        $response = $http->post("$base/v1/oauth2/token", [
            'auth'        => [$clientId, $secret],
            'form_params' => ['grant_type' => 'client_credentials'],
        ]);
        $data = json_decode($response->getBody(), true);
        return $data['access_token'];
    }

    public function clientId()
    {
        $creds = $this->credentials();
        if (! $creds) {
            return response()->json(['status' => false, 'message' => 'PayPal not configured.'], 422);
        }
        return response()->json(['status' => true, 'client_id' => $creds['client_id'], 'mode' => $creds['mode']]);
    }

    public function createOrder(Request $request)
    {
        $request->validate([
            'amount'      => 'required|numeric|min:1',
            'category_id' => 'required|exists:categories,id',
            'email'       => 'required|email',
            'name'        => 'nullable|string|max:100',
            'currency'    => 'nullable|string|max:10',
        ]);

        $creds = $this->credentials();
        if (! $creds) {
            return response()->json(['status' => false, 'message' => 'PayPal is not configured.'], 422);
        }

        try {
            DB::beginTransaction();

            $donation = Donation::query()->create([
                'category_id'     => $request->category_id,
                'email'           => $request->email,
                'name'            => $request->name,
                'payment_gateway' => 'paypal',
                'currency'        => strtoupper($request->currency ?? 'USD'),
                'status'          => 'pending',
            ]);

            $donation->transaction()->create([
                'amount' => $request->amount,
                'date'   => now(),
            ]);

            $base  = $this->baseUrl($creds['mode']);
            $http  = new Client(['timeout' => 30]);
            $token = $this->accessToken($http, $base, $creds['client_id'], $creds['secret']);
            $currency = strtoupper($request->currency ?? 'USD');

            $response = $http->post("$base/v2/checkout/orders", [
                'headers' => [
                    'Authorization' => "Bearer $token",
                    'Content-Type'  => 'application/json',
                ],
                'json' => [
                    'intent'         => 'CAPTURE',
                    'purchase_units' => [[
                        'amount'      => ['currency_code' => $currency, 'value' => number_format($request->amount, 2, '.', '')],
                        'description' => 'Donation',
                        'custom_id'   => (string) $donation->id,
                    ]],
                ],
            ]);

            $order = json_decode($response->getBody(), true);

            DB::commit();

            return response()->json([
                'status'      => true,
                'order_id'    => $order['id'],
                'donation_id' => $donation->id,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function captureOrder(Request $request)
    {
        $request->validate([
            'order_id'    => 'required|string',
            'donation_id' => 'required|integer',
        ]);

        $creds = $this->credentials();
        if (! $creds) {
            return response()->json(['status' => false, 'message' => 'PayPal not configured.'], 422);
        }

        try {
            $base  = $this->baseUrl($creds['mode']);
            $http  = new Client(['timeout' => 30]);
            $token = $this->accessToken($http, $base, $creds['client_id'], $creds['secret']);
            $orderId = $request->order_id;

            $response = $http->post("$base/v2/checkout/orders/$orderId/capture", [
                'headers' => [
                    'Authorization' => "Bearer $token",
                    'Content-Type'  => 'application/json',
                ],
            ]);

            $result = json_decode($response->getBody(), true);

            if (($result['status'] ?? '') === 'COMPLETED') {
                Donation::query()
                    ->where('id', $request->donation_id)
                    ->update(['status' => 'completed']);

                return response()->json(['status' => true, 'message' => 'Payment captured successfully.']);
            }

            return response()->json(['status' => false, 'message' => 'Payment not completed.']);
        } catch (\Exception $e) {
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
