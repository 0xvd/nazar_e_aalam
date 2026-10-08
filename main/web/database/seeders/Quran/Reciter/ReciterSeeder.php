<?php

namespace Database\Seeders\Quran\Reciter;

use App\Models\Quran\Reciter\Reciter;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class ReciterSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $reciters = [
            [
                'name' => 'Abdul Rahman Al-Sudais',
                'position' => 1,
            ],
            [
                'name' => 'Mishary Rashid Alafasy',
                'position' => 2,
            ],
        ];

        foreach ($reciters as $reciter) {
            Reciter::create($reciter);
        }
    }
}
