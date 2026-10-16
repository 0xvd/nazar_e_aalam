<?php

namespace App\Http\Controllers\Quran\Dhikr;

use App\Http\Controllers\Controller;
use App\Models\Quran\Dhikr\Dhikr;
use Illuminate\Http\Request;

class DhikrController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $search = request('search');
        return Dhikr::query()
            ->when($search, function ($query) use ($search) {
                $query->where('en_short_name', 'like', '%' . $search . '%')
                    ->orWhere('en_full_name', 'like', '%' . $search . '%');
            })
            ->orderBy('position', 'asc')
            ->paginate(10);
    }


    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'en_short_name' => ['required', 'string', 'max:50'],
            'en_full_name' => ['required', 'string', 'max:255'],
            'ar_short_name' => ['required', 'string', 'max:50'],
            'ar_full_name' => ['required', 'string', 'max:255'],
            'position' => ['nullable', 'integer'],
        ]);

        Dhikr::query()->create($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Dhikr created successfully',
            'data' => []
        ]);

    }

    /**
     * Display the specified resource.
     */
    public function show(Dhikr $dhikr)
    {
        return $dhikr;
    }


    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Dhikr $dhikr)
    {
        $request->validate([
            'en_short_name' => ['required', 'string', 'max:50'],
            'en_full_name' => ['required', 'string'],
            'ar_short_name' => ['required', 'string', 'max:50'],
            'ar_full_name' => ['required', 'string'],
            'position' => ['nullable', 'integer'],
        ]);

        $dhikr->update($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Dhikr updated successfully',
            'data' => [],
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Dhikr $dhikr)
    {
        $dhikr->delete();

        return response()->json([
            'status' => true,
            'message' => 'Dhikr deleted successfully',
            'data' => [],
        ]);
    }
}
