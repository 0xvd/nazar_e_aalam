<?php

namespace Database\Seeders;

use Database\Seeders\Quran\Category\CategorySeeder;
use Database\Seeders\Quran\PaymentMethod\PaymentMethodSeeder;
use Database\Seeders\Quran\Reciter\ReciterSeeder;
use Database\Seeders\Quran\Settings\LandingSettingSeeder;
use Database\Seeders\Quran\Settings\SettingsSeeder;
use Database\Seeders\Quran\WappPaper\WallPaperSeeder;
use Database\Seeders\User\PermissionSeeder;
use Database\Seeders\User\RoleSeeder;
use Database\Seeders\User\RoleUserSeeder;
use Database\Seeders\User\UserSeeder;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
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
            CategorySeeder::class,
            PaymentMethodSeeder::class,
            ReciterSeeder::class,
            WallPaperSeeder::class,
            LandingSettingSeeder::class,
        ]);
    }
}
