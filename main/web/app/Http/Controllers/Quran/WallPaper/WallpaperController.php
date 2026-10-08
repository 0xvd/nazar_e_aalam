<?php

namespace App\Http\Controllers\Quran\WallPaper;

use App\Concerns\FileHandler;
use App\Http\Controllers\Controller;
use App\Models\Quran\WallPaper\WallPaper;
use App\Models\Quran\WallPaper\WallpaperCategory;
use Illuminate\Http\Request;

class WallpaperController extends Controller
{
    use FileHandler;

    public function index()
    {
        $search = request('search');
        return WallPaper::query()
            ->with('category')
            ->when($search, function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%')
                    ->orWhereHas('category', function ($q) use ($search) {
                        $q->where('name', 'like', '%' . $search . '%');
                    });
            })
            ->orderBy('category_id', 'asc')
            ->paginate(12);
    }


    public function store(Request $request)
    {
        $request->validate([
            'category_id' => 'required|exists:wallpaper_categories,id',
            'name' => 'required|string|max:150',
            'image' => $request->hasFile('image') ? 'nullable|image|mimes:jpeg,png,jpg,gif|max:5000' : '',
        ]);

        WallPaper::query()->create([
            'category_id' => $request->category_id,
            'name' => $request->name,
            'image' => $this->uploadImage($request->file('image'), 'wallpaper'),
        ]);


        return response()->json(['message' => 'Wallpaper created successfully']);
    }

    public function show(WallPaper $wallpaper)
    {
        return $wallpaper;
    }

    public function update(Request $request, WallPaper $wallpaper)
    {
        $request->validate([
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string|max:150',
            'image' => $request->hasFile('image') ? 'nullable|image|mimes:jpeg,png,jpg,gif|max:5000' : '',
        ]);

        $wallpaper->update([
            'category_id' => $request->category_id,
            'name' => $request->name,
            'image' => $request->hasFile('image') ? $this->uploadImage($request->file('image'), 'wallpaper') : $wallpaper->image,
        ]);

        return response()->json(['message' => 'Wallpaper updated successfully']);
    }

    public function destroy(WallPaper $wallpaper)
    {
        $wallpaper->delete();
        return response()->json([
            'status' => true,
            'message' => 'Wallpaper deleted successfully',
            'data' => [],
        ]);
    }


}
