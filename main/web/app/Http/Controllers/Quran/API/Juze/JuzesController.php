<?php

namespace App\Http\Controllers\Quran\API\Juze;

use App\Http\Controllers\Controller;
use App\Models\Quran\Chapter\ChapterDetail;
use App\Models\Quran\Translator\Translator;
use Illuminate\Support\Facades\DB;

class JuzesController extends Controller
{

    public function index()
    {
        $translatorId = request('translator_id');

        $chapterDetails = ChapterDetail::query()
            ->whereHas('translators', fn($query) => $query->where('translator_id', $translatorId))
            ->select('chapter_id', 'juz_number', DB::raw('MIN(verse_number) as min_verse_number'), DB::raw('MAX(verse_number) as max_verse_number'))
            ->with(['chapter' => function ($query) use ($translatorId) {
                $query->select('id', 'arabic_name')
                    ->withWhereHas('translations', fn($query) => $query->where('translator_id', $translatorId)->select('id', 'chapter_id', 'translate_name'));
            }])
            ->groupBy('chapter_id', 'juz_number')
            ->get();

        $juzList = collect($chapterDetails)->groupBy('juz_number')->map(function ($chapter) use ($translatorId) {
            $juzNumber = $chapter->first()->juz_number;

            return [
                'juz_number' => translateToLanguage($juzNumber, $this->getTranslator($translatorId)),
                'juz_translate_name' => translateToLanguage('juz', $this->getTranslator($translatorId)),
                'chapter_list' => $chapter->map(function ($chapter) use ($translatorId) {
                    return [
                        'chapter_id' => $chapter->chapter_id,
                        'serial_number' => translateToLanguage($chapter->chapter_id, $this->getTranslator($translatorId)),
                        'arabic_name' => $chapter->chapter ? $chapter->chapter->arabic_name : '',
                        'translated_name' => $chapter->chapter && $chapter->chapter->translations ? $chapter->chapter->translations->translate_name : '',
                        'verses_translate_name' => translateToLanguage('verses', $this->getTranslator($translatorId)),
                        'verse_number' => translateToLanguage($chapter->min_verse_number, $this->getTranslator($translatorId)) . '-' . translateToLanguage($chapter->max_verse_number, $this->getTranslator($translatorId)),
                    ];
                })->values()->toArray()
            ];
        })->values()->toArray();

        $juzList = array_slice($juzList, 0, 30); // Take the first 30 juz
        return response()->json([
            'status' => true,
            'message' => 'Data fetched successfully',
            'data' => $juzList,
        ]);


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
