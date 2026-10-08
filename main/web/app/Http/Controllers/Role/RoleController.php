<?php

namespace App\Http\Controllers\Role;

use App\Http\Controllers\Controller;
use App\Models\Quran\Role\Role;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(): \Illuminate\Database\Eloquent\Collection|array
    {
        $search = request('search');
        return Role::query()
            ->when($search, fn($query) => $query->where('name', 'like', "%{$search}%"))
            ->orderByDesc('id')
            ->get();
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
        $request->validate([
            'name' => ['required', 'max:50'],
            'permissions' => ['array', 'min:1'],
        ]);

        $role = Role::query()->create($request->only('name'));

        $role->permissions()->sync($request->permissions);

        return response()->json([
            'status' => true,
            'message' => 'Role created successfully',
        ]);
    }

    /**
     * Display the specified resource.
     */
    public function show(Role $role)
    {
        return $role->load('permissions');
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
    public function update(Request $request, Role $role)
    {
        $request->validate([
            'name' => ['required', 'max:50'],
            'permissions' => ['array', 'min:1'],
        ]);

        $role->update($request->only('name'));

        $role->permissions()->sync($request->permissions);

        return response()->json([
            'status' => true,
            'message' => 'Role updated successfully',
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Role $role)
    {
        if ($role->is_admin || $role->is_default) {
            return response()->json([
                'status' => false,
                'message' => 'Action not allowed',
            ], 403);
        }

        $role->delete();

        return response()->json([
            'status' => true,
            'message' => 'Role deleted successfully',
        ]);
    }
}
