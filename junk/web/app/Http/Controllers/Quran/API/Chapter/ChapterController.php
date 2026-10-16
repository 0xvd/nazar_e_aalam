<?php

namespace App\Http\Controllers\Quran\API\Chapter;

use App\Http\Controllers\Controller;
use App\Http\Resources\Quran\Chapter\ChapterCollection;
use App\Models\Quran\Chapter\Chapter;

class ChapterController extends Controller
{

    public function index()
    {
        try {
            $chapters = Chapter::query()
                ->select(['id', 'arabic_name', 'verses_count'])
                ->with('translateChapters',function ($query) {
                    $query->where('translator_id', request()->get('translator_id'));
                })
                ->get();

            return response()->json([
                'status' => true,
                'message' => 'Data fetched successfully',
                'data' => ChapterCollection::collection($chapters),
            ]);

        }catch (\Exception $exception){
            return response()->json([
                'status' => false,
                'message' => $exception->getMessage(),
                'data' => [],
            ],500);
        }
    }
}
