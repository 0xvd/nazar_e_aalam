<?php

namespace App\Http\Controllers\Quran\SifatName;

use App\Http\Controllers\Controller;
use App\Models\Quran\SifatName\SifatName;
use Illuminate\Http\Request;

class SifatNameController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $search = request('search');
        return SifatName::query()
            ->when($search, function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%')
                    ->orWhere('translated_name', 'like', '%' . $search . '%')
                    ->orWhere('meaning', 'like', '%' . $search . '%')
                    ->orWhere('name_benefits', 'like', '%' . $search . '%');
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
            'name' => ['required', 'string', 'max:50'],
            'ar_name' => ['required', 'string', 'max:255'],
            'translated_name' => ['required', 'string', 'max:255'],
            'meaning' => ['nullable', 'string'],
            'name_benefits' => ['nullable', 'string'],
            'position' => ['nullable', 'integer'],
        ]);

        SifatName::query()->create($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Sifat name created successfully',
            'data' => [],
        ]);
    }

    /**
     * Display the specified resource.
     */
    public function show(SifatName $sifat)
    {
        return $sifat;
    }


    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, SifatName $sifat)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:50'],
            'ar_name' => ['required', 'string', 'max:255'],
            'translated_name' => ['required', 'string', 'max:255'],
            'meaning' => ['nullable', 'string'],
            'name_benefits' => ['nullable', 'string'],
            'position' => ['nullable', 'integer'],
        ]);

        $sifat->update($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Sifat name updated successfully',
            'data' => [],
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(SifatName $sifat)
    {
        $sifat->delete();
        return response()->json([
            'status' => true,
            'message' => 'Sifat Name deleted successfully',
            'data' => [],
        ]);
    }
}
