<?php

namespace App\Http\Controllers\Quran\HarmCode;

use App\Http\Controllers\Controller;
use App\Models\Quran\HaramCode\HaramCode;
use Illuminate\Http\Request;

class HaramCodeController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $search = request('search');
        return HaramCode::query()
            ->when($search, function ($query) use ($search) {
                $query->where('code', 'like', '%' . $search . '%')
                    ->orWhere('name', 'like', '%' . $search . '%')
                    ->orWhere('description', 'like', '%' . $search . '%');
            })
            ->latest()
            ->paginate(10);

    }


    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'code' => ['required', 'string', 'max:10'],
            'name' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'status_info' => ['nullable', 'string'],
        ]);

        HaramCode::query()->create($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Haram code created successfully',
            'data' => [],
        ]);
    }

    /**
     * Display the specified resource.
     */
    public function show(HaramCode $haram_code)
    {
        return $haram_code;
    }


    public function update(Request $request, HaramCode $haram_code)
    {
        $request->validate([
            'code' => ['required', 'string', 'max:10'],
            'name' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'status_info' => ['nullable', 'string'],
        ]);

        $haram_code->update($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Haram code updated successfully',
            'data' => [],
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(HaramCode $haram_code)
    {
        $haram_code->delete();

        return response()->json([
            'status' => true,
            'message' => 'Haram code deleted successfully',
            'data' => [],
        ]);
    }
}
