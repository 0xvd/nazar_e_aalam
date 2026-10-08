<?php

namespace Database\Seeders;

use Database\Seeders\Quran\Chapter\ChapterDetailSeeder;
use Database\Seeders\Quran\Chapter\ChapterDetailSeeder2;
use Database\Seeders\Quran\Chapter\ChapterDetailSeeder3;
use Database\Seeders\Quran\Chapter\ChapterDetailSeeder4;
use Database\Seeders\Quran\Chapter\ChapterDetailSeeder5;
use Database\Seeders\Quran\Chapter\ChapterDetailSeeder6;
use Database\Seeders\Quran\Chapter\ChapterSeeder;
use Database\Seeders\Quran\Chapter\ChapterTranslationSeeder;
use Database\Seeders\Quran\Chapter\ChapterTranslationSeederAr;
use Database\Seeders\Quran\Chapter\ChapterTranslationSeederBangla;
use Database\Seeders\Quran\Chapter\ChapterTranslationSeederSp;
use Database\Seeders\Quran\Chapter\Verse\Arabic\JalalSeeder;
use Database\Seeders\Quran\Chapter\Verse\Bangla\VerseBanglaZohurulHoqueSeeder;
use Database\Seeders\Quran\Chapter\Verse\Bangla\VerseBanglaZohurulHoqueSeeder2;
use Database\Seeders\Quran\Chapter\Verse\Bangla\VerseBanglaZohurulHoqueSeeder3;
use Database\Seeders\Quran\Chapter\Verse\Bangla\VerseBanglaZohurulHoqueSeeder4;
use Database\Seeders\Quran\Chapter\Verse\English\VerseEnglishAhmedAliSeeder;
use Database\Seeders\Quran\Chapter\Verse\English\VerseEnglishAhmedAliSeeder2;
use Database\Seeders\Quran\Chapter\Verse\English\VerseEnglishAhmedAliSeeder3;
use Database\Seeders\Quran\Chapter\Verse\English\VerseEnglishAhmedAliSeeder4;
use Database\Seeders\Quran\Chapter\Verse\Spanish\VerseSpanishBornezSeeder;
use Database\Seeders\Quran\Dhikr\DhikrSeeder;
use Database\Seeders\Quran\Dua\DuaSeeder;
use Database\Seeders\Quran\HaramCode\HaramCodeSeeder;
use Database\Seeders\Quran\PrayerTime\PrayerTimesTableSeeder;
use Database\Seeders\Quran\SifatName\SifatNameSeeder;
use Database\Seeders\Quran\Translation\TranslatorSeeder;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DefaultSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
      $this->call([
          TranslatorSeeder::class,
          ChapterSeeder::class,
          ChapterTranslationSeeder::class,
          ChapterTranslationSeederBangla::class,
          ChapterTranslationSeederSp::class,
          ChapterTranslationSeederAr::class,
          ChapterDetailSeeder::class,
          ChapterDetailSeeder2::class,
          ChapterDetailSeeder3::class,
          ChapterDetailSeeder4::class,
          ChapterDetailSeeder5::class,
          ChapterDetailSeeder6::class,

          VerseEnglishAhmedAliSeeder::class,
          VerseEnglishAhmedAliSeeder2::class,
          VerseEnglishAhmedAliSeeder3::class,
          VerseEnglishAhmedAliSeeder4::class,

          VerseBanglaZohurulHoqueSeeder::class,
          VerseBanglaZohurulHoqueSeeder2::class,
          VerseBanglaZohurulHoqueSeeder3::class,
          VerseBanglaZohurulHoqueSeeder4::class,

          VerseSpanishBornezSeeder::class,
          JalalSeeder::class,

          DhikrSeeder::class,
          DuaSeeder::class,
          SifatNameSeeder::class,
          HaramCodeSeeder::class,
          PrayerTimesTableSeeder::class,
      ]);
    }
}
