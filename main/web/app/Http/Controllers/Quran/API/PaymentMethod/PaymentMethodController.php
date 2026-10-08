<?php

namespace App\Http\Controllers\Quran\API\PaymentMethod;

use App\Http\Controllers\Controller;
use App\Http\Resources\Quran\PaymentMethod\CustomerPaymentMethodResource;
use App\Models\Quran\Payment\PaymentMethod;
use Illuminate\Http\Request;

class PaymentMethodController extends Controller
{
    public function customerPaymentMethod(): \Illuminate\Http\JsonResponse
    {
        $search = request('search');
        $paymentMethods = PaymentMethod::query()
            ->with('settings')
            ->whereIn('type', ['paypal', 'stripe', 'razorpay', 'paystack', 'sslcommerz'])
            ->select(['id', 'name', 'type'])
            ->when($search, function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%');
            })
            ->get();

        $paymentMethodCollection = CustomerPaymentMethodResource::collection($paymentMethods);

        return response()->json([
            'result' => true,
            'message' => 'Data fetched successfully',
            'data' => $paymentMethodCollection
        ]);
    }
}
