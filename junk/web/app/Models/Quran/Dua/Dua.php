<?php

namespace App\Models\Quran\Dua;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Dua extends Model
{
    use HasFactory;

    protected $fillable = ['position', 'ar_short_name', 'ar_full_name', 'en_short_name', 'en_full_name'];

}
