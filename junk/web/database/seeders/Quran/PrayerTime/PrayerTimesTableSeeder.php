<?php

namespace Database\Seeders\Quran\PrayerTime;

use App\Models\Quran\Prayer\PrayerTime;
use Illuminate\Database\Seeder;

class PrayerTimesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
    {
        $startDate = now()->startOfYear();
        $numberOfDays = $this->isLeapYear($startDate->year) ? 366 : 365;

        for ($i = 0; $i < $numberOfDays; $i++) {
            $date = $startDate->copy()->addDays($i);

            // Set specific prayer times for each day
            $prayerTimes = [
                'imsak' => '4:00',
                'sunrise' => '06:50',
                'fajr_azan' => '05:30',
            ];

            // Create a prayer time record for each day
            PrayerTime::create([
                'date' => $date,
                'imsak' => $prayerTimes['imsak'],
                'city' => 'Makkah',
                'sunrise' => $prayerTimes['sunrise'],
                'fajr_start' => $prayerTimes['fajr_azan'],
                'zuhr_start' => $this->generateRandomTime(),
                'asr_start' => $this->generateRandomTime(),
                'maghrib_start' => $this->generateRandomTime(),
                'isha_start' => $this->generateRandomTime(),
                'sehri' => $this->generateRandomTime(),
                'iftar' => $this->generateRandomTime(),
                'iftar_notification' => false,
                'sehri_notification' => false,
                'second' => $this->generateRandomTime(),
                'se_notify' => $this->generateRandomTime(),
            ]);
        }
    }

    // Helper method to generate a random time in HH:MM format
    private function generateRandomTime()
    {
        $hour = rand(0, 23);
        $minute = rand(0, 59);

        return sprintf('%02d:%02d', $hour, $minute);
    }

    // Helper method to check if the given year is a leap year
    private function isLeapYear($year)
    {
        return ($year % 4 === 0 && $year % 100 !== 0) || ($year % 400 === 0);
    }

}
