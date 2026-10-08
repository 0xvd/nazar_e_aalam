<?php

namespace App\Models\Quran\Chapter;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChapterTranslation extends Model
{
    protected $fillable = [
        'chapter_id', 'translator_id', 'translate_name'
    ];

    protected $casts = [
        'chapter_id' => 'integer',
        'translator_id' => 'integer',
    ];
}
