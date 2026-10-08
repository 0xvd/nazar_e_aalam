<?php

namespace App\Http\Resources\Quran\Dua;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Http\Resources\Json\ResourceCollection;

class DuaDhikrCollection extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'en_short_name' => $this->en_short_name,
            'ar_short_name' => $this->ar_short_name,
        ];
    }
}
