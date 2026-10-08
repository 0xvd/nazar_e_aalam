<?php

namespace App\Models\Quran\Dhikr;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Dhikr extends Model
{
    use HasFactory;

    protected $fillable = ['ar_short_name', 'ar_full_name', 'en_short_name', 'en_full_name','position'];
}
