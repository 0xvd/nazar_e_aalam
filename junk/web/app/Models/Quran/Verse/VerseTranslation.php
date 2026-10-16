<?php

namespace App\Models\Quran\Verse;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VerseTranslation extends Model
{
    use HasFactory;

    protected $fillable = [
        'verse_number',
        'translate_name',
        'chapter_id',
        'chapter_detail_id',
        'translator_id',
    ];
}
