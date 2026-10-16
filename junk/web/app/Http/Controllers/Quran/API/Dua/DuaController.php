<?php

namespace App\Http\Controllers\Quran\API\Dua;

use App\Http\Controllers\Controller;
use App\Http\Resources\Quran\Dua\DuaDhikrCollection;
use App\Models\Quran\Dua\Dua;
use Illuminate\Http\Request;

class DuaController extends Controller
{

    public function index()
    {
        try {
            $duaList = Dua::query()->orderBy('position', 'asc')->get();

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
            $dua = Dua::query()->select('id', 'ar_short_name', 'ar_full_name', 'en_short_name', 'en_full_name')->find($id);
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
