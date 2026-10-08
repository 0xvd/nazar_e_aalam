<?php

namespace App\Http\Requests\Quran\PaymentMethod;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class PaymentMethodRequest extends FormRequest
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
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array|string>
     */
    public function rules(): array
    {

        return [
            'name' => ['required', 'string'],
            'type' => ['required', 'in:paystack,paypal,stripe,razorpay,sslcommerz',
                Rule::when(in_array(request('type'), ['stripe', 'paypal', 'razorpay', 'paystack', 'sslcommerz']),
                    Rule::unique('payment_methods')->ignore($this->payment_method))
            ],
            'api_key'    => [Rule::when(in_array(request('type'), ['stripe', 'paypal', 'razorpay', 'paystack', 'sslcommerz']), ['required'])],
            'api_secret' => [Rule::when(in_array(request('type'), ['stripe', 'paypal', 'razorpay', 'paystack', 'sslcommerz']), ['required'])],
        ];
    }

    public function messages(): array
    {
        return [
            'type.in' => 'The selected type must be one of: paypal, stripe, razorpay, paystack, sslcommerz.',
        ];
    }
}
