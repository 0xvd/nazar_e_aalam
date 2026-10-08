<?php

namespace App\Http\Controllers\Quran\API\Donation;

use App\Http\Controllers\Controller;
use App\Models\Quran\Donation\Donation;
use App\Models\Quran\Payment\PaymentMethod;
use GuzzleHttp\Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RazorpayDonationController extends Controller
{
    private function credentials(): ?array
    {
        $method = PaymentMethod::query()
            ->where('type', 'razorpay')
            ->with('settings')
            ->first();

        if (! $method) return null;

        $keyId     = $method->settings->where('name', 'api_key')->first()?->value;
        $keySecret = $method->settings->where('name', 'api_secret')->first()?->value;

        if (! $keyId || ! $keySecret) return null;

        return ['key_id' => $keyId, 'key_secret' => $keySecret];
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
            return response()->json(['status' => false, 'message' => 'Razorpay is not configured.'], 422);
        }

        try {
            DB::beginTransaction();

            $currency      = strtoupper($request->currency ?? 'INR');
            $amountInPaise = (int) round($request->amount * 100);

            $donation = Donation::query()->create([
                'category_id'     => $request->category_id,
                'email'           => $request->email,
                'name'            => $request->name,
                'payment_gateway' => 'razorpay',
                'currency'        => $currency,
                'status'          => 'pending',
            ]);

            $donation->transaction()->create([
                'amount' => $request->amount,
                'date'   => now(),
            ]);

            $http = new Client(['timeout' => 30]);
            $response = $http->post('https://api.razorpay.com/v1/orders', [
                'auth' => [$creds['key_id'], $creds['key_secret']],
                'json' => [
                    'amount'   => $amountInPaise,
                    'currency' => $currency,
                    'receipt'  => 'donation_' . $donation->id,
                ],
            ]);

            $order = json_decode($response->getBody(), true);

            DB::commit();

            return response()->json([
                'status'      => true,
                'key_id'      => $creds['key_id'],
                'order_id'    => $order['id'],
                'donation_id' => $donation->id,
                'amount'      => $amountInPaise,
                'currency'    => $currency,
                'name'        => $request->name ?? '',
                'email'       => $request->email,
                'description' => 'Donation — ' . ($request->name ?? $request->email),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function verifyPayment(Request $request)
    {
        $request->validate([
            'razorpay_payment_id' => 'required|string',
            'razorpay_order_id'   => 'required|string',
            'razorpay_signature'  => 'required|string',
            'donation_id'         => 'required|integer',
        ]);

        $creds = $this->credentials();
        if (! $creds) {
            return response()->json(['status' => false, 'message' => 'Razorpay not configured.'], 422);
        }

        try {
            $payload  = $request->razorpay_order_id . '|' . $request->razorpay_payment_id;
            $expected = hash_hmac('sha256', $payload, $creds['key_secret']);

            if (! hash_equals($expected, $request->razorpay_signature)) {
                return response()->json(['status' => false, 'message' => 'Invalid payment signature.'], 422);
            }

            Donation::query()
                ->where('id', $request->donation_id)
                ->update(['status' => 'completed']);

            return response()->json(['status' => true, 'message' => 'Payment verified successfully.']);
        } catch (\Exception $e) {
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
