<?php

namespace App\Http\Resources\Quran\Donation;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DonationResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'category'       => $this->category?->name,
            'payment_method' => $this->paymentMethod?->name ?? $this->payment_gateway,
            'payment_gateway'=> $this->payment_gateway,
            'status'         => $this->status,
            'email'          => $this->email,
            'name'           => $this->name,
            'currency'       => $this->currency ?? 'USD',
            'date'           => $this->transaction
                ? Carbon::parse($this->transaction->date)->timezone(request()->get('timezone', 'UTC'))->format('d M h:i A')
                : null,
            'amount'         => $this->transaction ? floatval($this->transaction->amount) : 0,
        ];
    }
}
