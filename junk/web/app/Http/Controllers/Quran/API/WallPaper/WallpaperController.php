<?php

namespace App\Http\Controllers\Quran\API\WallPaper;

use App\Http\Controllers\Controller;
use App\Http\Resources\Quran\WallPaper\WallpaperResourceCollection;
use App\Models\Quran\WallPaper\WallPaper;
use Illuminate\Http\Request;

class WallpaperController extends Controller
{
    public function index(Request $request)
    {
        $wallpapers = WallPaper::with('category')->get();

        $grouped = $wallpapers->groupBy(fn($item) => $item->category->name ?? 'Uncategorized');

        $formatted = $grouped->map(function ($items, $categoryName) {
            return [
                'category' => $categoryName,
                'wallpapers' => WallpaperResourceCollection::collection($items),
            ];
        })->values(); // Reset keys to numeric

        return response()->json([
            'status' => true,
            'message' => 'Data fetched successfully',
            'data' => $formatted
        ]);
    }

}
