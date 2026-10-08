<?php

namespace App\Http\Requests\Quran\Reciter;

use Illuminate\Foundation\Http\FormRequest;

class ReciterSuraRequest extends FormRequest
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
            'reciter_id' => 'required|exists:reciters,id',
            'name' => 'required|string',
            'number' => 'required|integer',
            'revealed_place' => 'required|string',
            'audio_file' => 'required',
            'duration' => 'required|numeric|min:1'
        ];
    }

}
