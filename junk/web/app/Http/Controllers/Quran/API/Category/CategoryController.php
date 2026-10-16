<?php

namespace App\Http\Controllers\Quran\API\Category;

use App\Http\Controllers\Controller;
use App\Models\Quran\Donation\Category;

class CategoryController extends Controller
{
    public function index()
    {
        $categories = Category::query()->select('id','name')->get();

        return response()->json([
            'result' => true,
            'message' => 'Data fetched successfully',
            'data' => $categories
        ]);
    }
}
