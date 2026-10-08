<?php

namespace App\Repositories\User;

use App\Models\Quran\Role\Role;
use App\Models\User;
use App\Repositories\BaseRepository;

class UserRepository extends BaseRepository
{

    public function __construct(User $user)
    {
        $this->model = $user;
    }

    public function findByEmail(string $email): object|null
    {
        return $this->model::query()->where('email', $email)->first();
    }

    public function getCachedAuthUserWithRoleAndPermissions()
    {
        return auth()->user()->load('role:id', 'role.permissions');
    }


    public function getAuthUserPermissions()
    {
        $user = $this->getCachedAuthUserWithRoleAndPermissions();
        return optional($user->roles)->map(function (Role $role) {
            return collect($role->permissions)->toArray();
        })->flatten(1);
    }

    public function findAuthUserPermission($permission)
    {
        return $this->getAuthUserPermissions()->where('name', $permission)->first();
    }

    public function getCachedRolesUser()
    {
        $user = auth()->user()->load('role');
        return $user->role;
    }

    public function getPermissionsForFrontEnd()
    {
        $permissions = resolve(UserRepository::class)
            ->getAuthUserPermissions();

        return $permissions->map(function ($permission) {
            return [
                $permission['name'] => true
            ];
        })->reduce(function ($pre, $permission) {
            return array_merge($pre, $permission);
        }, []);
    }
}
