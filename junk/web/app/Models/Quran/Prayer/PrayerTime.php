<?php

namespace App\Models\Quran\Prayer;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PrayerTime extends Model
{
    use HasFactory;

    protected $fillable = [
        'city',
        'imsak',
        'date',
        'sunrise',
        'sunset',
        'fajr_start',
        'zuhr_start',
        'asr_start',
        'maghrib_start',
        'isha_start',
        'sehri',
        'iftar',
        'iftar_notification',
        'sehri_notification',
        'second',
        'se_notify',
    ];

    protected $casts = [
        'date' => 'date:Y-m-d',          // Example cast for a date column
        'imsak' => 'datetime:H:i',
        'sunrise' => 'datetime:H:i',
        'fajr_start' => 'datetime:H:i',
        'zuhr_start' => 'datetime:H:i',
        'asr_start' => 'datetime:H:i',
        'maghrib_start' => 'datetime:H:i',
        'isha_start' => 'datetime:H:i',
    ];

}
