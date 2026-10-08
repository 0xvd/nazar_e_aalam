<?php

namespace App\Http\Controllers\Quran\Reciter;

use App\Concerns\FileHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Quran\Reciter\ReciterRequest;
use App\Models\Quran\Reciter\Reciter;
use Illuminate\Http\Request;

class ReciterController extends Controller
{
    use FileHandler;

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $search = request('search');
        return Reciter::query()
            ->withCount('suras')
            ->when($search, function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%');
            })
            ->orderBy('position', 'ASC')
            ->paginate(10);
    }


    /**
     * Store a newly created resource in storage.
     */
    public function store(ReciterRequest $request)
    {
        $reciter = new Reciter([
            'name' => $request->name,
            'position' => $request->position,
        ]);

        if ($request->hasFile('profile_picture')) {
            $reciter->profile_picture = $this->uploadImage($request->file('profile_picture'));
        }

        $reciter->save();

        return response()->json([
            'status' => true,
            'message' => 'Reciter created successfully',
            'data' => []
        ]);

    }

    /**
     * Display the specified resource.
     */
    public function show(Reciter $reciter)
    {
        return $reciter;
    }


    /**
     * Update the specified resource in storage.
     */
    public function update(ReciterRequest $request, Reciter $reciter)
    {
        if ($request->hasFile('profile_picture')) {
            $reciter->profile_picture = $this->uploadImage($request->file('profile_picture'));
        }

        $reciter->name = $request->name;
        $reciter->position = $request->position;
        $reciter->save();

        return response()->json([
            'status' => true,
            'message' => 'Reciter updated successfully',
            'data' => [],
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Reciter $reciter)
    {
        $reciter->delete();

        return response()->json([
            'status' => true,
            'message' => 'Reciter deleted successfully',
            'data' => [],
        ]);
    }
}
