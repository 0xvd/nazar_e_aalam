<?php

namespace App\Http\Requests\Installer;

use Illuminate\Foundation\Http\FormRequest;

class EmailSettingRequest extends FormRequest
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

        $rules['provider'] = 'required';
        $rules['from_name'] = 'required';
        $rules['from_email'] = 'required|email';

        if (request()->get('provider') === 'smtp') {
            $rules['smtp_host'] = 'required';
            $rules['smtp_port'] = 'required|numeric';
            $rules['smtp_username'] = 'required';
            $rules['email_password'] = 'required';
            $rules['encryption_type'] = 'required';

        }

        return $rules;

    }
}
