<?php

namespace Database\Seeders\User;

use App\Models\Quran\Role\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $roles = [
            [
                'name' => 'Administrator',
                'alias' => 'administrator',
                'is_admin' => 1,
                'is_default' => 1,
                'created_at' => now(),
                'updated_at' => now()
            ]
        ];

        Role::query()->insert($roles);
    }
}
