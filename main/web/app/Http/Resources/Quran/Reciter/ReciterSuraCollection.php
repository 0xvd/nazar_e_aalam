<?php

namespace App\Http\Resources\Quran\Reciter;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReciterSuraCollection extends JsonResource
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
            'reciter_id' => $this->reciter_id,
            'reciter_name' => $this->reciter->name,
            'reciter_avatar' => $this->reciter->profile_picture ? secure_asset($this->reciter->profile_picture) : secure_asset('assets/img/avatar.png'),
            'sura_name' => $this->name,
            'number' => $this->number,
            'duration' => $this->duration * 1000,  // Convert duration to milliseconds
            'revealed_place' => $this->revealed_place,
            'path' => secure_asset($this->path),
        ];
    }
}
