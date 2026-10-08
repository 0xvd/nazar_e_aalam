<?php

namespace Database\Seeders;

use Database\Seeders\Quran\Settings\LandingSettingSeeder;
use Database\Seeders\Quran\Settings\SettingsSeeder;
use Database\Seeders\User\PermissionSeeder;
use Database\Seeders\User\RoleSeeder;
use Database\Seeders\User\RoleUserSeeder;
use Database\Seeders\User\UserSeeder;
use Illuminate\Database\Seeder;

class InstallSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            PermissionSeeder::class,
            RoleSeeder::class,
            RoleUserSeeder::class,
            SettingsSeeder::class,
            LandingSettingSeeder::class,
        ]);
    }
}
