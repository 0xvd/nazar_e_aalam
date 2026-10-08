<?php

namespace App\Http\Controllers\Quran\API\Verse;

use App\Http\Controllers\Controller;
use App\Models\Quran\Chapter\Chapter;
use App\Models\Quran\Chapter\ChapterDetail;
use App\Models\Quran\Translator\Translator;

class VerseController extends Controller
{

    public function index(Chapter $chapter)
    {
        $translatorId = request('translator_id');

        try {

            $chapterData = $this->getChapterInfo($chapter, $translatorId);

            if (!$chapterData) {
                return response()->json([
                    'status' => true,
                    'message' => 'Data fetched successfully'
                ]);
            }

            $chapterInfo = $this->getChapterDetails($chapter, $translatorId);

            $output = [
                'chapter' => $this->formatChapterInfo($chapterData, $translatorId),
                'chapter_info' => $this->formatChapterDetails($chapterInfo, $translatorId),
            ];

            return response()->json([
                'status' => true,
                'message' => 'Data fetched successfully',
                'data' => $output
            ]);

        } catch (\Exception $exception) {
            return response()->json([
                'status' => false,
                'message' => $exception->getMessage(),
            ], 500);
        }
    }

    private function getChapterInfo(Chapter $chapter, $translatorId): null|object
    {
        return Chapter::query()
            ->withWhereHas('translateChapters', fn($builder) => $builder->where([
                ['translator_id', $translatorId],
                ['chapter_id', $chapter->id]
            ]))
            ->first();
    }

    private function getChapterDetails(Chapter $chapter, $translatorId): \Illuminate\Database\Eloquent\Collection|array
    {
        return ChapterDetail::query()
            ->withWhereHas('translators', fn($builder) => $builder->where('translator_id', $translatorId))
            ->where('chapter_id', $chapter->id)
            ->get()
            ->groupBy('page_number');
    }

    private function formatChapterInfo($chapter, $translatorId): array
    {
        return [
            'id' => $chapter->id,
            'serial_number' => translateToLanguage($chapter->id, $this->getTranslator($translatorId)),
            'arabic_name' => $chapter->arabic_name,
            'translated_name' => $chapter->translateChapters ? $chapter->translateChapters->translate_name : '',
            'verses_translate_name' => translateToLanguage('verses', $this->getTranslator($translatorId)),
            'verses_count' => translateToLanguage($chapter->verses_count, $this->getTranslator($translatorId)),
        ];
    }

    private function formatChapterDetails($chapterDetails, $translatorId): array
    {
        $chapterInfo = [];
        $number = 0;
        foreach ($chapterDetails as $pageNumber => $pageDetails) {
            $pageVerses = [];
            $concatenatedAyah = '';
            foreach ($pageDetails as $detail) {
                $translatedName = $detail->translators && isset($detail->translators[0]) ? $detail->translators[0]->translate_name : '';
                $concatenatedAyah .= $detail['arabic_name'] . ' (' . translateToLanguage($detail['verse_number'], 'ar') . ')' . '  ';
                $pageVerses[] = [
                    'id' => $detail->id,
                    'chapter_id' => $detail->chapter_id,
                    'verses_translate_name' => translateToLanguage('verses', $this->getTranslator($translatorId)),
                    // 'verses_number' => translateToLanguage($detail->verse_number, $this->getTranslator($translatorId)),
                    'verses_number' => strval($detail->verse_number),
                    'arabic_name' => $detail->arabic_name,
                    'translated_name' => $translatedName,
                    'english_transliteration' => $detail->english_transliteration
                ];
            }

            $chapterInfo[] = [
                'eng_page_number' => $pageNumber,
                'page_key' => $number++, // Add index key
                'page_number' => translateToLanguage($pageNumber, $this->getTranslator($translatorId)),
                'page_verses' => $pageVerses,
                'page_arabic_ayah' => trim($concatenatedAyah)
            ];
        }

        return $chapterInfo;
    }


    private function getTranslator($translatorId)
    {
        $translator = Translator::query()
            ->where('id', $translatorId)
            ->select('language_code')
            ->first();

        return $translator?->language_code;
    }

}
