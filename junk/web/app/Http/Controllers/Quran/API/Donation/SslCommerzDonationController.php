<?php

namespace App\Http\Controllers\Quran\API\Donation;

use App\Http\Controllers\Controller;
use App\Models\Quran\Donation\Donation;
use App\Models\Quran\Payment\PaymentMethod;
use GuzzleHttp\Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SslCommerzDonationController extends Controller
{
    private function credentials(): ?array
    {
        $method = PaymentMethod::query()
            ->where('type', 'sslcommerz')
            ->with('settings')
            ->first();

        if (! $method) return null;

        $storeId   = $method->settings->where('name', 'api_key')->first()?->value;
        $storePass = $method->settings->where('name', 'api_secret')->first()?->value;
        $mode      = $method->settings->where('name', 'payment_mode')->first()?->value ?? 'sandbox';

        if (! $storeId || ! $storePass) return null;

        return ['store_id' => $storeId, 'store_password' => $storePass, 'mode' => $mode];
    }

    private function initUrl(string $mode): string
    {
        return $mode === 'live'
            ? 'https://securepay.sslcommerz.com/gwprocess/v4/api.php'
            : 'https://sandbox.sslcommerz.com/gwprocess/v4/api.php';
    }

    public function initiate(Request $request)
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
            return response()->json(['status' => false, 'message' => 'SSLCommerz is not configured.'], 422);
        }

        try {
            DB::beginTransaction();

            $currency = strtoupper($request->currency ?? 'BDT');

            $donation = Donation::query()->create([
                'category_id'     => $request->category_id,
                'email'           => $request->email,
                'name'            => $request->name,
                'payment_gateway' => 'sslcommerz',
                'currency'        => $currency,
                'status'          => 'pending',
            ]);

            $donation->transaction()->create([
                'amount' => $request->amount,
                'date'   => now(),
            ]);

            $transId = 'don' . $donation->id . '_' . now()->timestamp;
            $baseUrl = url('');

            $http = new Client(['timeout' => 30, 'verify' => false]);
            $response = $http->post($this->initUrl($creds['mode']), [
                'form_params' => [
                    'store_id'         => $creds['store_id'],
                    'store_passwd'     => $creds['store_password'],
                    'total_amount'     => $request->amount,
                    'currency'         => $currency,
                    'tran_id'          => $transId,
                    'success_url'      => $baseUrl . '/api/donation/sslcommerz/success',
                    'fail_url'         => $baseUrl . '/api/donation/sslcommerz/fail',
                    'cancel_url'       => $baseUrl . '/api/donation/sslcommerz/cancel',
                    'ipn_url'          => $baseUrl . '/api/donation/sslcommerz/ipn',
                    'cus_name'         => $request->name ?? 'Donor',
                    'cus_email'        => $request->email,
                    'cus_add1'         => 'N/A',
                    'cus_city'         => 'N/A',
                    'cus_country'      => 'Bangladesh',
                    'cus_phone'        => '0000000000',
                    'product_name'     => 'Donation',
                    'product_category' => 'Donation',
                    'product_profile'  => 'general',
                    'value_a'          => $donation->id,
                ],
            ]);

            $result = json_decode($response->getBody(), true);

            DB::commit();

            if (($result['status'] ?? '') === 'SUCCESS' && ! empty($result['GatewayPageURL'])) {
                return response()->json([
                    'status'      => true,
                    'gateway_url' => $result['GatewayPageURL'],
                    'donation_id' => $donation->id,
                ]);
            }

            return response()->json([
                'status'  => false,
                'message' => $result['failedreason'] ?? 'SSLCommerz initialization failed.',
            ], 422);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function success(Request $request)
    {
        $donationId = $request->value_a;
        $status     = $request->status;

        if (in_array($status, ['VALID', 'VALIDATED']) && $donationId) {
            Donation::query()->where('id', $donationId)->update(['status' => 'completed']);
            return redirect('/?donation=ssl_success&donation_id=' . $donationId);
        }

        return redirect('/?donation=ssl_fail');
    }

    public function fail(Request $request)
    {
        $donationId = $request->value_a;
        if ($donationId) {
            Donation::query()->where('id', $donationId)->update(['status' => 'cancelled']);
        }
        return redirect('/?donation=cancelled');
    }

    public function cancel(Request $request)
    {
        $donationId = $request->value_a;
        if ($donationId) {
            Donation::query()->where('id', $donationId)->update(['status' => 'cancelled']);
        }
        return redirect('/?donation=cancelled');
    }

    public function ipn(Request $request)
    {
        $donationId = $request->value_a;
        $status     = $request->status;

        if (in_array($status, ['VALID', 'VALIDATED']) && $donationId) {
            Donation::query()->where('id', $donationId)->update(['status' => 'completed']);
        }

        return response()->json(['status' => true]);
    }
}
