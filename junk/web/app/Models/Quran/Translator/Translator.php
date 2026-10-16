<?php

namespace App\Models\Quran\Translator;

use Illuminate\Database\Eloquent\Model;

class Translator extends Model
{
    protected $fillable = [
        'full_name', 'short_name', 'language', 'language_code'
    ];
}
