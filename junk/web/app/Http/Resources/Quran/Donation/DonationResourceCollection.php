<?php

namespace App\Http\Resources\Quran\Donation;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\ResourceCollection;

class DonationResourceCollection extends ResourceCollection
{
    /**
     * Transform the resource collection into an array.
     *
     * @return array<int|string, mixed>
     */
    public function toArray(Request $request): array
    {
        return $this->collection->map(function ($donation) {
            return new DonationResource($donation);
        })->toArray();
    }
}
