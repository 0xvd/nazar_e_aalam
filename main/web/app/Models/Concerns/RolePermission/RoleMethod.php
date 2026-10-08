<?php

namespace App\Models\Concerns\RolePermission;

trait RoleMethod
{
    public function isDefault()
    {
        return $this->is_default;
    }

    public function isAdmin()
    {
        return $this->is_admin;
    }

    public static function findByName(string $role_name)
    {
        return self::query()->whereName($role_name)->first();
    }
}
