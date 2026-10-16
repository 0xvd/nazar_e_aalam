<?php

namespace App\Http\Controllers\Role;

use App\Http\Controllers\Controller;
use App\Models\Quran\Permission\Permission;
use Illuminate\Http\Request;

class PermissionController extends Controller
{

    public function index(): \Illuminate\Database\Eloquent\Collection|array
    {
        return Permission::query()
            ->select('id', 'name', 'group_name')
            ->get()
            ->groupBy('group_name');
    }
}
