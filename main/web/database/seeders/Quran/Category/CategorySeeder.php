<?php

namespace Database\Seeders\Quran\Category;

use App\Models\Quran\Donation\Category;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = ['Zakat', 'Sadaqah', 'Lillah', 'Fitrana', 'Qurbani', 'Kaffarah','Waqf','Fidyah'];

        foreach ($categories as $category) {
            Category::query()->create(['name' => $category]);
        }
    }
}
