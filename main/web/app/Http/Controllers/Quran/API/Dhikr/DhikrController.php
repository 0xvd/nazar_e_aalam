<?php

namespace App\Http\Controllers\Quran\API\Dhikr;

use App\Http\Controllers\Controller;
use App\Http\Resources\Quran\Dua\DuaDhikrCollection;
use App\Models\Quran\Dhikr\Dhikr;

class DhikrController extends Controller
{
    public function dhikrList()
    {
        try {
            $duaList = Dhikr::query()->orderBy('position', 'asc')->get();

            return response()->json([
                'status' => true,
                'message' => 'Data fetched successfully',
                'data' => DuaDhikrCollection::collection($duaList),
            ]);

        } catch (\Exception $exception) {
            return response()->json([
                'status' => false,
                'message' => $exception->getMessage(),
                'data' => [],
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $dua = Dhikr::query()->select('id','ar_short_name', 'ar_full_name', 'en_short_name', 'en_full_name')->find($id);

            return response()->json([
                'status' => true,
                'message' => 'Data fetched successfully',
                'data' => $dua
            ]);

        } catch (\Exception $exception) {
            return response()->json([
                'status' => false,
                'message' => $exception->getMessage(),
                'data' => [],
            ], 500);
        }
    }
}
