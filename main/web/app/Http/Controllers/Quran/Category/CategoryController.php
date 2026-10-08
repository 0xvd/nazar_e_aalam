<?php

namespace App\Http\Controllers\Quran\Category;

use App\Http\Controllers\Controller;
use App\Models\Quran\Donation\Category;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    public function index()
    {
        $search = request('search');
        return Category::query()
            ->when($search, function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%');
            })
            ->paginate(10);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required:max:50|unique:categories,name',
        ]);

        Category::query()->create($request->only('name'));

        return response()->json([
            'status' => true,
            'message' => 'Category created successfully',
            'data' => []
        ]);

    }

    public function show(Category $category)
    {
        return $category;
    }

    public function update(Request $request, Category $donationCategory)
    {
        $request->validate([
            'name' => [
                'required',
                'max:50',
                Rule::unique('categories', 'name')->ignore($request->id),
            ],
        ]);

        $donationCategory->update($request->only('name'));

        return response()->json([
            'status' => true,
            'message' => 'Category updated successfully',
            'data' => [],
        ]);
    }

    public function destroy(Category $category)
    {
        $category->delete();

        return response()->json([
            'status' => true,
            'message' => 'Category deleted successfully',
            'data' => [],
        ]);
    }
}
