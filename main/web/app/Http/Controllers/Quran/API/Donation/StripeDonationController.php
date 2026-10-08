<?php

namespace App\Http\Controllers\Quran\API\Donation;

use App\Http\Controllers\Controller;
use App\Models\Quran\Donation\Donation;
use App\Models\Quran\Payment\PaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Stripe\StripeClient;

class StripeDonationController extends Controller
{
    private function stripeClient(): ?StripeClient
    {
        $method = PaymentMethod::query()
            ->where('type', 'stripe')
            ->with('settings')
            ->first();

        if (! $method) return null;

        $secret = $method->settings->where('name', 'api_secret')->first()?->value;

        return $secret ? new StripeClient($secret) : null;
    }

    public function createCheckout(Request $request)
    {
        $request->validate([
            'amount'      => 'required|numeric|min:1',
            'category_id' => 'required|exists:categories,id',
            'email'       => 'required|email',
            'name'        => 'nullable|string|max:100',
            'currency'    => 'nullable|string|max:10',
        ]);

        $stripe = $this->stripeClient();
        if (! $stripe) {
            return response()->json(['status' => false, 'message' => 'Stripe is not configured.'], 422);
        }

        try {
            DB::beginTransaction();

            $donation = Donation::query()->create([
                'category_id'     => $request->category_id,
                'email'           => $request->email,
                'name'            => $request->name,
                'payment_gateway' => 'stripe',
                'currency'        => strtoupper($request->currency ?? 'USD'),
                'status'          => 'pending',
            ]);

            $donation->transaction()->create([
                'amount' => $request->amount,
                'date'   => now(),
            ]);

            $currency = strtolower($request->currency ?? 'usd');
            $amountInCents = (int) round($request->amount * 100);

            $session = $stripe->checkout->sessions->create([
                'payment_method_types' => ['card'],
                'mode'                 => 'payment',
                'customer_email'       => $request->email,
                'line_items'           => [[
                    'price_data' => [
                        'currency'     => $currency,
                        'unit_amount'  => $amountInCents,
                        'product_data' => ['name' => 'Donation — ' . ($request->name ?? $request->email)],
                    ],
                    'quantity' => 1,
                ]],
                'success_url' => url('/') . '?donation=success&donation_id=' . $donation->id . '&session_id={CHECKOUT_SESSION_ID}',
                'cancel_url'  => url('/') . '?donation=cancelled',
                'metadata'    => ['donation_id' => $donation->id],
            ]);

            DB::commit();

            return response()->json([
                'status'      => true,
                'checkout_url' => $session->url,
                'donation_id'  => $donation->id,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function verifySession(Request $request)
    {
        $request->validate([
            'session_id'  => 'required|string',
            'donation_id' => 'required|integer',
        ]);

        $stripe = $this->stripeClient();
        if (! $stripe) {
            return response()->json(['status' => false, 'message' => 'Stripe not configured.'], 422);
        }

        try {
            $session = $stripe->checkout->sessions->retrieve($request->session_id);

            if ($session->payment_status === 'paid') {
                Donation::query()
                    ->where('id', $request->donation_id)
                    ->update(['status' => 'completed']);

                return response()->json(['status' => true, 'message' => 'Payment verified.']);
            }

            return response()->json(['status' => false, 'message' => 'Payment not completed.']);
        } catch (\Exception $e) {
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
