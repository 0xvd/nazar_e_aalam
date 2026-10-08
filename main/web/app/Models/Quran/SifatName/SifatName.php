<?php

namespace App\Models\Quran\SifatName;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SifatName extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'ar_name', 'translated_name', 'meaning', 'name_benefits', 'position'];
}

