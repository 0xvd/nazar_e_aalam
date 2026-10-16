<?php

namespace App\Http\Controllers\Quran\API\HaramCode;

use App\Http\Controllers\Controller;
use App\Models\Quran\HaramCode\HaramCode;

class HaramCodeController extends Controller
{
    public function haramCodeList()
    {
        try {
            $haramCodeList = HaramCode::query()->select('id', 'code', 'name', 'description', 'status_info')->get();

            return response()->json([
                'status' => true,
                'message' => 'Data fetched successfully',
                'data' => $haramCodeList
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
            $dua = HaramCode::query()->select('id', 'code', 'name', 'status_info', 'description')->find($id);
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
