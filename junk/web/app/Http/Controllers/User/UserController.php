<?php

namespace App\Http\Controllers\User;

use App\Exceptions\GeneralException;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(): \Illuminate\Contracts\Pagination\LengthAwarePaginator
    {
        $search = request('search');
        return User::query()
            ->when($search, fn($query) => $query->where('first_name', 'LIKE', "%$search%")
                ->orWhere('last_name', 'LIKE', "%{$search}%")
                ->orWhere('email', 'LIKE', "%{$search}%")
                ->orWhereRaw("CONCAT(first_name, ' ', last_name) LIKE ?", ['%' . $search . '%'])
            )->with('role:id,name','profile')
            ->orderByDesc('id')
            ->paginate(10);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     * @throws GeneralException
     */
    public function destroy(User $user)
    {
        if ($user->is_admin) {
            throw new GeneralException('Action not allowed');
        }

        if ($user->id == auth()->id()) {
            throw new GeneralException('Cant delete own account');
        }

        $user->delete();

        return response()->json([
            'status' => true,
            'message' => 'User has been deleted',
        ]);
    }
}
