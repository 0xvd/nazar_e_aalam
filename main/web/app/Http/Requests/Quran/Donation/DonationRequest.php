<?php

namespace App\Http\Requests\Quran\Donation;

use Illuminate\Foundation\Http\FormRequest;

class DonationRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'category_id'      => 'required|exists:categories,id',
            'payment_method_id' => 'nullable|exists:payment_methods,id',
            'payment_gateway'  => 'required_without:payment_method_id|nullable|string|in:razorpay,paystack,stripe,paypal,sslcommerz',
            'email'            => 'required|email|max:100',
            'name'             => 'nullable|string|max:100',
            'amount'           => 'required|numeric|min:1',
            'currency'         => 'nullable|string|max:10',
        ];
    }
}
