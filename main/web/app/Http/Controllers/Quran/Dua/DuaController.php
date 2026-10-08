<?php

namespace App\Http\Controllers\Quran\Dua;

use App\Http\Controllers\Controller;
use App\Models\Quran\Dua\Dua;
use Illuminate\Http\Request;

class DuaController extends Controller
{
    public function index()
    {
        $search = request('search');
        return Dua::query()
            ->when($search, function ($query) use ($search) {
                $query->where('en_short_name', 'like', '%' . $search . '%')
                ->orWhere('en_full_name', 'like', '%' . $search . '%');
            })
            ->orderBy('position', 'asc')
            ->paginate(10);
    }


    public function store(Request $request)
    {
        $request->validate([
            'en_short_name' => ['required', 'string', 'max:50'],
            'en_full_name' => ['required', 'string'],
            'ar_short_name' => ['required', 'string', 'max:50'],
            'ar_full_name' => ['required', 'string'],
            'position' => ['nullable', 'integer'],
        ]);


        Dua::query()->create($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Dua created successfully',
            'data' => []
        ]);
    }

    public function show(Dua $dua)
    {
        return $dua;
    }

    public function update(Request $request, Dua $dua)
    {
        $request->validate([
            'en_short_name' => ['required', 'string', 'max:50'],
            'en_full_name' => ['required', 'string'],
            'ar_short_name' => ['required', 'string', 'max:50'],
            'ar_full_name' => ['required', 'string'],
            'position' => ['nullable', 'integer'],
        ]);

        $dua->update($request->all());

        return response()->json([
            'status' => true,
            'message' => 'Dua updated successfully',
            'data' => []
        ]);
    }

    public function destroy(Dua $dua)
    {
        $dua->delete();
        return response()->json([
            'status' => true,
            'message' => 'Dua deleted successfully',
            'data' => [],
        ]);
    }


}
