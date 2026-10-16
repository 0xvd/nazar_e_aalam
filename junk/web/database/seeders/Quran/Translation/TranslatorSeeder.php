<?php

namespace Database\Seeders\Quran\Translation;

use App\Models\Quran\Translator\Translator;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class TranslatorSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Translator::query()->insert([
            [
                'full_name' => 'Ahmed Ali',
                'short_name' => 'Ahmed Ali *',
                'language' => 'English',
                'language_code' => 'en',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'full_name' => 'জহুরুল হক',
                'short_name' => 'Hoque',
                'language' => 'Bengali',
                'language_code' => 'bn',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'full_name' => 'Bornez',
                'short_name' => 'Bornez',
                'language' => 'Spanish',
                'language_code' => 'sp',
                'created_at' => now(),
                'updated_at' => now(),
            ],  [
                'full_name' => 'تفسير الجلالين',
                'short_name' => 'تفسير الجلالين',
                'language' => 'Arabic',
                'language_code' => 'ar',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
