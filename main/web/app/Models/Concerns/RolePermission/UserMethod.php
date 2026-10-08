<?php

namespace App\Models\Concerns\RolePermission;

use App\Models\Quran\Role\Role;

trait UserMethod
{
    public function isAdmin(): bool
    {
        return $this->hasRole(config('access.users.app_admin_role'));
    }

    public function assignRole($role): ?bool
    {
        if ($this->hasRole($role)) {
            return true;
        }

        if (is_string($role)) {
            return $this->roles()->attach(
                Role::findByName($role)->id
            );
        }

        return $this->roles()->attach($role instanceof Role ? $role->id : $role);
    }

    public function isAppAdmin(): bool
    {
        return $this->admin();
    }

    /*
    * @param string $type
    * @param null $brand_id
    * @return mixed
    * @throws \Exception
    *
    * Basically the result is cached. it will be deleted if any updated is happening in user model
    */
    public function admin(): bool
    {
        return $this->roles()
            ->where('is_admin', 1)
            ->where('is_default', 1)
            ->exists();
    }
}
