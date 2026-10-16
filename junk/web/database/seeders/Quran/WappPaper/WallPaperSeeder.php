<?php

namespace Database\Seeders\Quran\WappPaper;

use App\Models\Quran\WallPaper\WallPaper;
use App\Models\Quran\WallPaper\WallpaperCategory;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class WallPaperSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = ['Nature', 'Islamic','Abstract', 'Architecture', 'Historical', 'Sports', 'Travel'];

        foreach ($categories as $category) {
            WallpaperCategory::query()->create(['name' => $category]);
        }
        $wallpapers = [
            [
                'category_id' => 1,
                'name' => 'Nature',
                'image' => 'assets/img/wallpaper/1.jpeg',
            ],
            [
                'category_id' => 1,
                'name' => 'Nature',
                'image' => 'assets/img/wallpaper/2.jpeg'
            ],
            [
                'category_id' => 1,
                'name' => 'Nature',
                'image' => 'assets/img/wallpaper/3.jpeg'
            ],
            [
                'category_id' => 2,
                'name' => 'Islamic',
                'image' => 'assets/img/wallpaper/4.jpeg'
            ],
            [
                'category_id' => 2,
                'name' => 'Islamic',
                'image' => 'assets/img/wallpaper/5.jpeg'
            ],
            [
                'category_id' => 2,
                'name' => 'Islamic',
                'image' => 'assets/img/wallpaper/6.jpeg'
            ],
            [
                'category_id' => 2,
                'name' => 'Islamic',
                'image' => 'assets/img/wallpaper/7.jpeg'
            ],
            [
                'category_id' => 2,
                'name' => 'Islamic',
                'image' => 'assets/img/wallpaper/8.jpeg'
            ],
            [
                'category_id' => 2,
                'name' => 'Islamic',
                'image' => 'assets/img/wallpaper/9.jpeg'
            ],
            [
                'category_id' => 2,
                'name' => 'Islamic',
                'image' => 'assets/img/wallpaper/10.jpeg'
            ],
            [
                'category_id' => 2,
                'name' => 'Islamic',
                'image' => 'assets/img/wallpaper/11.jpeg'
            ],
            [
                'category_id' => 3,
                'name' => 'Abstract',
                'image' => 'assets/img/wallpaper/12.jpeg',
            ],
            [
                'category_id' => 3,
                'name' => 'Abstract',
                'image' => 'assets/img/wallpaper/13.jpeg',
            ],
            [
                'category_id' => 5,
                'name' => 'Historical',
                'image' => 'assets/img/wallpaper/14.jpeg',
            ],
            [
                'category_id' => 5,
                'name' => 'Historical',
                'image' => 'assets/img/wallpaper/15.jpeg',
            ],
            [
                'category_id' => 5,
                'name' => 'Historical',
                'image' => 'assets/img/wallpaper/16.jpeg',
            ]
        ];


        WallPaper::query()->insert($wallpapers);

    }
}
