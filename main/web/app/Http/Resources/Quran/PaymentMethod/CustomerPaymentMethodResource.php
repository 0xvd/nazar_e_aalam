<?php

namespace App\Http\Resources\Quran\PaymentMethod;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerPaymentMethodResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'type' => $this->type,
            'api_key' => $this->settings ? $this->settingsManipulation($this->settings, 'api_key') : null,
            'payment_mode' => $this->settings ? $this->settingsManipulation($this->settings, 'payment_mode') : null,
            'api_secret' => $this->settings ? $this->settingsManipulation($this->settings, 'api_secret') : null,
        ];
    }

    private function settingsManipulation($settings, $apiKey = null)
    {
        return $settings->where('name', $apiKey)->first()->value ?? null;
    }
}
