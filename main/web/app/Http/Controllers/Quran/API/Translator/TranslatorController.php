<?php

namespace App\Http\Controllers\Quran\API\Translator;

use App\Http\Controllers\Controller;
use App\Models\Quran\Translator\Translator;

class TranslatorController extends Controller
{
    public function index()
    {
        $translators = Translator::query()
            ->select('id', 'full_name', 'short_name', 'language', 'language_code')
            ->get();

        return response()->json([
            'status' => true,
            'message' => 'Data fetched successfully',
            'data' => $translators
        ]);
    }
}
