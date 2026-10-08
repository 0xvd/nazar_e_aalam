<?php

namespace App\Http\Resources\Quran\Reciter;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReciterCollection extends JsonResource
{
    /**
     * Transform the resource collection into an array.
     *
     * @return array<int|string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'profile_picture' => $this->profile_picture ? asset($this->profile_picture) : asset('assets/img/avatar.png'),
        ];
    }
}
