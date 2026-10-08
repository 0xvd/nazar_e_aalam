<?php

namespace Database\Seeders\User;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RoleUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $user = User::query()->find(1);
        $user->roles()->attach(1);

        $users = User::query()
            ->where('is_admin', '<>', 1)
            ->get();

        $users->each(function ($item) {
            $item->roles()->attach(3);
        });
    }
}
