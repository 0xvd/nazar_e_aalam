<?php

namespace App\Http\Controllers\Quran\API\Reciter;

use App\Http\Controllers\Controller;
use App\Http\Resources\Quran\Reciter\ReciterCollection;
use App\Http\Resources\Quran\Reciter\ReciterSuraCollection;
use App\Models\Quran\Reciter\Reciter;
use Illuminate\Http\Request;

class ReciterController extends Controller
{

    public function index()
    {
        $reciters = Reciter::query()->get();

        $reciterCollection = ReciterCollection::collection($reciters);

        return response()->json([
            'result' => true,
            'message' => 'Data fetched successfully',
            'data' => $reciterCollection
        ]);
    }

    public function reciterSuraList(Reciter $reciter)
    {
        $reciterSuraCollection = ReciterSuraCollection::collection($reciter->suras()->orderBy('number', 'ASC')->get());

        return response()->json([
            'result' => true,
            'message' => 'Data fetched successfully',
            'data' => $reciterSuraCollection
        ]);
    }

}
