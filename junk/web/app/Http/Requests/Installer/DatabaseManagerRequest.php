<?php

namespace App\Http\Requests\Installer;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class DatabaseManagerRequest extends FormRequest
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
     * @return array<string, ValidationRule|array|string>
     */
    public function rules(): array
    {
        return [
            'database_connection' => ['required', 'string', 'in:mysql,pgsql,sqlite'],
            'database_hostname' => ['required', 'string', 'regex:/^[^#]+$/U'],
            'database_port' => ['required', 'string', 'regex:/^[^#]+$/U'],
            'database_name' => ['required', 'string', 'regex:/^[^#]+$/U'],
            'database_username' => ['required', 'string', 'regex:/^[^#]+$/U'],
            'database_password' => ['required', 'string'],
        ];
    }

    public function attributes(): array
    {
        return [
            'database_connection' => 'driver',
        ];
    }
}
