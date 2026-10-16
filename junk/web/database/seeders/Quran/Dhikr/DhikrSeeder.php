<?php

namespace Database\Seeders\Quran\Dhikr;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DhikrSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $enShortName = [
            "Subhan Allah",
            "Al-hamdulillah",
            "Allāhu Akbar",
            "La ilaha illallah",
            "Astaghfirullah",
            "Darood Sharif"
        ];
        $enFullName = [
            "Subhan Allah",
            "Al-hamdulillah",
            "Allāhu Akbar",
            "La ilaha illallah",
            "Astaghfirullah",
            "Allaahumma salli alaa Muhammadinw wa alaa aali Muhammad kamaa sallayta alaa Ibraaheema wa alaa aali Ibraaheem, innaka Hameedum Majeed.Allaahumma baarik alaa Muhammadinw wa alaa aali Muhammadin, kamaa baarakta alaa Ibraaheema wa alaa aali Ibraaheema, innaka Hameedum Majeed."
        ];
        $arShortName = [
            "سُبْحَانَ ٱللَّٰهِ",
            "ٱلْحَمْدُ لِلَّٰهِ",
            "ٱللَّٰهُ أَكْبَرُ",
            "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
            "ٱسْتِغْفَار",
            "دارود شريف"
        ];
        $arFullName = [
            "سُبْحَانَ ٱللَّٰهِ",
            "ٱلْحَمْدُ لِلَّٰهِ",
            "ٱللَّٰهُ أَكْبَرُ",
            "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ",
            "ٱسْتِغْفَار",
            "اَللّٰھُمَّ صَلِّ عَلٰی مُحَمَّدٍ وَّعَلٰٓی اٰلِ مُحَمَّدٍ کَمَا صَلَّیْتَ عَلٰٓی اِبْرَاھِیْمَ وَعَلٰٓی اٰلِ اِبْرَاھِیْمَ اِنَّکَ حَمِیْدٌ مَّجِیْدٌ اَللّٰھُمَّ بَارِکْ عَلٰی مُحَمَّدٍ وَّعَلٰٓی اٰلِ مُحَمَّدٍ کَمَا بَارَکْتَ عَلٰٓی اِبْرَاھِیْمَ وَعَلٰٓی اٰلِ اِبْرَاھِیْمَ اِنَّکَ حَمِیْدٌ مَّجِیْد"
        ];

        foreach ($enShortName as $key => $item) {
            \App\Models\Quran\Dhikr\Dhikr::create([
                'position' => $key+1,
                'en_short_name' => $enShortName[$key],
                'en_full_name' => $enFullName[$key],
                'ar_short_name' => $arShortName[$key],
                'ar_full_name' => $arFullName[$key],
            ]);
        }

    }
}
