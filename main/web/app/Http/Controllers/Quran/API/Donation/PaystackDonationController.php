<?php

namespace App\Http\Controllers\Quran\API\Donation;

use App\Http\Controllers\Controller;
use App\Models\Quran\Donation\Donation;
use App\Models\Quran\Payment\PaymentMethod;
use GuzzleHttp\Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PaystackDonationController extends Controller
{
    private function credentials(): ?array
    {
        $method = PaymentMethod::query()
            ->where('type', 'paystack')
            ->with('settings')
            ->first();

        if (! $method) return null;

        $publicKey = $method->settings->where('name', 'api_key')->first()?->value;
        $secretKey = $method->settings->where('name', 'api_secret')->first()?->value;

        if (! $publicKey || ! $secretKey) return null;

        return ['public_key' => $publicKey, 'secret_key' => $secretKey];
    }

    public function publicKey()
    {
        $creds = $this->credentials();
        if (! $creds) {
            return response()->json(['status' => false, 'message' => 'Paystack not configured.'], 422);
        }
        return response()->json(['status' => true, 'public_key' => $creds['public_key']]);
    }

    public function initialize(Request $request)
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
            return response()->json(['status' => false, 'message' => 'Paystack is not configured.'], 422);
        }

        try {
            DB::beginTransaction();

            $currency     = strtoupper($request->currency ?? 'NGN');
            $amountInKobo = (int) round($request->amount * 100);
            $reference    = 'donation_' . now()->timestamp . '_' . Str::random(8);

            $donation = Donation::query()->create([
                'category_id'     => $request->category_id,
                'email'           => $request->email,
                'name'            => $request->name,
                'payment_gateway' => 'paystack',
                'currency'        => $currency,
                'status'          => 'pending',
            ]);

            $donation->transaction()->create([
                'amount' => $request->amount,
                'date'   => now(),
            ]);

            DB::commit();

            return response()->json([
                'status'      => true,
                'public_key'  => $creds['public_key'],
                'reference'   => $reference,
                'donation_id' => $donation->id,
                'amount'      => $amountInKobo,
                'currency'    => $currency,
                'email'       => $request->email,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function verify(Request $request)
    {
        $request->validate([
            'reference'   => 'required|string',
            'donation_id' => 'required|integer',
        ]);

        $creds = $this->credentials();
        if (! $creds) {
            return response()->json(['status' => false, 'message' => 'Paystack not configured.'], 422);
        }

        try {
            $http = new Client(['timeout' => 30]);
            $response = $http->get('https://api.paystack.co/transaction/verify/' . rawurlencode($request->reference), [
                'headers' => [
                    'Authorization' => 'Bearer ' . $creds['secret_key'],
                    'Accept'        => 'application/json',
                ],
            ]);

            $result = json_decode($response->getBody(), true);

            if (($result['data']['status'] ?? '') === 'success') {
                Donation::query()
                    ->where('id', $request->donation_id)
                    ->update(['status' => 'completed']);

                return response()->json(['status' => true, 'message' => 'Payment verified successfully.']);
            }

            return response()->json(['status' => false, 'message' => 'Payment not completed.']);
        } catch (\Exception $e) {
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
