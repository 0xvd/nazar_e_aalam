<?php

namespace Database\Seeders\User;

use App\Models\Quran\Permission\Permission;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class PermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $permissions = [

            //dhikrs module
            [
                'name' => 'view_dhikrs',
                'group_name' => 'dhikrs',
            ],
            [
                'name' => 'create_dhikrs',
                'group_name' => 'dhikrs',
            ],
            [
                'name' => 'update_dhikrs',
                'group_name' => 'dhikrs',
            ],
            [
                'name' => 'delete_dhikrs',
                'group_name' => 'dhikrs',
            ],
            //dua module
            [
                'name' => 'view_dua',
                'group_name' => 'dua',
            ],
            [
                'name' => 'create_dua',
                'group_name' => 'dua',
            ],
            [
                'name' => 'update_dua',
                'group_name' => 'dua',
            ],
            [
                'name' => 'delete_dua',
                'group_name' => 'dua',
            ],
            //sifat name module
            [
                'name' => 'view_sifats',
                'group_name' => 'sifats',
            ],
            [
                'name' => 'create_sifats',
                'group_name' => 'sifats',
            ],
            [
                'name' => 'update_sifats',
                'group_name' => 'sifats',
            ],
            [
                'name' => 'delete_sifats',
                'group_name' => 'sifats',
            ],
            //haram code module
            [
                'name' => 'view_haram_codes',
                'group_name' => 'haram_code',
            ],
            [
                'name' => 'create_haram_codes',
                'group_name' => 'haram_code',
            ],
            [
                'name' => 'update_haram_codes',
                'group_name' => 'haram_code',
            ],
            [
                'name' => 'delete_haram_codes',
                'group_name' => 'haram_code',
            ],
            //prayer time module
            [
                'name' => 'view_prayer_times',
                'group_name' => 'prayer_time',
            ],
            [
                'name' => 'create_prayer_times',
                'group_name' => 'prayer_time',
            ],
            [
                'name' => 'update_prayer_times',
                'group_name' => 'prayer_time',
            ],
            [
                'name' => 'delete_prayer_times',
                'group_name' => 'prayer_time',
            ],
            [
                'name' => 'import_prayer_times',
                'group_name' => 'prayer_time',
            ],
            //roles module
            [
                'name' => 'view_roles',
                'group_name' => 'role',
            ],
            [
                'name' => 'create_roles',
                'group_name' => 'role',
            ],
            [
                'name' => 'update_roles',
                'group_name' => 'role',
            ],
            [
                'name' => 'delete_roles',
                'group_name' => 'role',
            ],
            //user module

            [
                'name' => 'view_users',
                'group_name' => 'user',
            ],
            [
                'name' => 'delete_users',
                'group_name' => 'user',
            ],
            [
                'name' => 'invite_user',
                'group_name' => 'user',
            ],
            [
                'name' => 'view_setting',
                'group_name' => 'setting',
            ],
            [
                'name' => 'update_setting',
                'group_name' => 'setting',
            ],
            [
                'name' => 'view_email_setting',
                'group_name' => 'setting',
            ],
            [
                'name' => 'update_email_setting',
                'group_name' => 'setting',
            ],
            //category module
            [
                'name' => 'view_category',
                'group_name' => 'category',
            ],
            [
                'name' => 'create_category',
                'group_name' => 'category',
            ],
            [
                'name' => 'update_category',
                'group_name' => 'category',
            ],
            [
                'name' => 'delete_category',
                'group_name' => 'category',
            ],
            //donation module
            [
                'name' => 'view_donation',
                'group_name' => 'donation',
            ],
            //Payment Method module
            [
                'name' => 'view_payment_method',
                'group_name' => 'payment_method',
            ],
            [
                'name' => 'create_payment_method',
                'group_name' => 'payment_method',
            ],
            [
                'name' => 'update_payment_method',
                'group_name' => 'payment_method',
            ],
            [
                'name' => 'delete_payment_method',
                'group_name' => 'payment_method',
            ],
            //audio quran module
            [
                'name' => 'view_reciter',
                'group_name' => 'reciter',
            ],
            [
                'name' => 'create_reciter',
                'group_name' => 'reciter',
            ],
            [
                'name' => 'update_reciter',
                'group_name' => 'reciter',
            ],
            [
                'name' => 'delete_reciter',
                'group_name' => 'reciter',
            ],
            [
                'name' => 'view_reciter_sura',
                'group_name' => 'reciter_sura',
            ],
            [
                'name' => 'create_reciter_sura',
                'group_name' => 'reciter_sura',
            ],
            [
                'name' => 'update_reciter_sura',
                'group_name' => 'reciter_sura',
            ],
            [
                'name' => 'delete_reciter_sura',
                'group_name' => 'reciter_sura',
            ],
            [
                'name' => 'import_reciter_sura',
                'group_name' => 'reciter_sura',
            ],

            //wallpaper module
            [
                'name' => 'view_wallpaper',
                'group_name' => 'wallpaper',
            ],
            [
                'name' => 'create_wallpaper',
                'group_name' => 'wallpaper',
            ],
            [
                'name' => 'update_wallpaper',
                'group_name' => 'wallpaper',
            ],
            [
                'name' => 'delete_wallpaper',
                'group_name' => 'wallpaper',
            ],

            //wallpaper category module
            [
                'name' => 'view_wallpaper_category',
                'group_name' => 'wallpaper_category',
            ],
            [
                'name' => 'create_wallpaper_category',
                'group_name' => 'wallpaper_category',
            ],
            [
                'name' => 'update_wallpaper_category',
                'group_name' => 'wallpaper_category',
            ],
            [
                'name' => 'delete_wallpaper_category',
                'group_name' => 'wallpaper_category',
            ],

        ];

        Permission::query()->insert($permissions);
    }
}
