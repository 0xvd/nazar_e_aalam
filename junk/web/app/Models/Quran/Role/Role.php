<?php

namespace App\Models\Quran\Role;

use App\Models\Concerns\RolePermission\RoleMethod;
use App\Models\Quran\Permission\Permission;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use RoleMethod;

    protected $fillable = [
        'name', 'alias', 'is_admin', 'is_default'
    ];

    protected $casts = [
        'is_admin' => 'boolean',
        'is_default' => 'boolean'
    ];

    public function users(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
    {
        return $this->belongsToMany(User::class);
    }

    public function permissions(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
    {
        return $this->belongsToMany(Permission::class);
    }
}
