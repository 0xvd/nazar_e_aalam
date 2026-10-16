<?php

namespace Database\Seeders\Quran\PaymentMethod;

use App\Models\Quran\Payment\PaymentMethod;
use Illuminate\Database\Seeder;

class PaymentMethodSeeder extends Seeder
{


    public function run(): void
    {

        $paymentMethods = [
            [
                'name' => 'Paypal',
                'type' => 'paypal'
            ],
            [
                'name' => 'Stripe',
                'type' => 'stripe'
            ],
            [
                'name' => 'Paystack',
                'type' => 'paystack'
            ],
            [
                'name' => 'Razorpay',
                'type' => 'razorpay'
            ],
        ];

        PaymentMethod::query()->insert($paymentMethods);
    }
}
