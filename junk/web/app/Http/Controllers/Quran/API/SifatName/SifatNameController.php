<?php

namespace App\Http\Controllers\Quran\API\SifatName;

use App\Http\Controllers\Controller;
use App\Models\Quran\SifatName\SifatName;

class SifatNameController extends Controller
{
    public function dhikrList()
    {
        try {
            $sifatNameList = SifatName::query()->orderBy('position', 'asc')->select('id','name as en_name', 'ar_name')->get();

            return response()->json([
                'status' => true,
                'message' => 'Data fetched successfully',
                'data' => $sifatNameList
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
            $dua = SifatName::query()->select('id','name as en_name', 'ar_name', 'translated_name', 'meaning','name_benefits')->find($id);
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
