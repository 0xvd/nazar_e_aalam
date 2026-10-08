<?php

namespace App\Http\Resources\Quran\Chapter;

use App\Models\Quran\Translator\Translator;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Http\Resources\Json\ResourceCollection;

class ChapterCollection extends JsonResource
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
            'serial_number' => translateToLanguage($this->id, $this->getTranslator()),
            'arabic_name' => $this->arabic_name,
            'translate_name' => $this->translateChapters ? $this->translateChapters->translate_name : null,
            'verses_translate_name' => translateToLanguage('verses',$this->getTranslator()),
            'verses_count' => translateToLanguage($this->verses_count,$this->getTranslator()),
        ];
    }

    private function getTranslator()
    {
        return Translator::query()
            ->where('id', \request()->get('translator_id'))
            ->select('language_code')
            ->first()
            ->language_code;
    }
}
