<?php

namespace App\Http\Controllers\Quran\WallPaper;

use App\Http\Controllers\Controller;
use App\Models\Quran\WallPaper\WallpaperCategory;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class WallpaperCategoryController extends Controller
{
    public function index()
    {
        $search = request('search');
        return WallpaperCategory::query()
            ->withCount('wallpapers')
            ->when($search, function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%');
            })
            ->orderBy('name', 'asc')
            ->paginate(12);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required:max:50|unique:wallpaper_categories,name',
        ]);

        WallpaperCategory::query()->create($request->only('name'));

        return response()->json([
            'status' => true,
            'message' => 'Category created successfully',
            'data' => []
        ]);

    }

    public function show(WallpaperCategory $wallpaper_category)
    {
        return $wallpaper_category;
    }

    public function update(Request $request, WallpaperCategory $wallpaper_category)
    {
        $request->validate([
            'name' => [
                'required',
                'max:50',
                Rule::unique('wallpaper_categories', 'name')->ignore($request->id),
            ],
        ]);

        $wallpaper_category->update($request->only('name'));

        return response()->json([
            'status' => true,
            'message' => 'Category updated successfully',
            'data' => [],
        ]);
    }

    public function destroy(WallpaperCategory $wallpaper_category)
    {
        $wallpaper_category->delete();

        return response()->json([
            'status' => true,
            'message' => 'Category deleted successfully',
            'data' => [],
        ]);
    }

    public function wallpaperCategory()
    {
        return WallpaperCategory::query()->get();
    }
}
