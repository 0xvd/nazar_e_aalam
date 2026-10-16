<?php

namespace Database\Seeders\Quran\Settings;

use App\Models\Quran\Settings\Setting;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        foreach (config('settings.app') as $setting) {
            Setting::query()->firstOrCreate(
                ['name' => $setting['name'], 'context' => $setting['context']],
                ['value' => $setting['value']]
            );
        }
    }
}
