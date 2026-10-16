<?php

namespace App\Http\Requests\Quran\Reciter;

use Illuminate\Foundation\Http\FormRequest;

class ReciterRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:30'],
            'profile_picture' => ['nullable', 'image', 'mimes:jpeg,png,jpg,svg', 'max:5000'],
            'position' => ['required', 'integer'],
        ];

    }
}
