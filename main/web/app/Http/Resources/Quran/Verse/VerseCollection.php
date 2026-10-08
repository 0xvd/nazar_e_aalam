<?php

namespace App\Http\Resources\Quran\Verse;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Http\Resources\Json\ResourceCollection;

class VerseCollection extends JsonResource
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
            'arabic_name' => $this->arabic_name,
            'chapter_name' => $this->chapter ? $this->chapter->arabic_name : null,
            'translate_name' => $this->chapter && $this->chapter->verseTranslations ? $this->translateName($this->verse_number, $this->chapter->verseTranslations) : null,
            'verse_number' => $this->verse_number,
            'page_number' => $this->page_number
        ];
    }

    public function translateName($verseNumber, $verseTranslations)
    {
        $verseTranslation = $verseTranslations->where('verse_number', $verseNumber)->first();
        return $verseTranslation ? $verseTranslation->translate_name : null;
    }
}
