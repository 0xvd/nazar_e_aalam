<?php

namespace App\Models\Quran\Chapter;

use App\Models\Quran\Verse\VerseTranslation;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChapterDetail extends Model
{
    protected $fillable = [
        'chapter_id',
        'verse_number',
        'verse_key',
        'hizb_number',
        'rub_el_hizb_number',
        'ruku_number',
        'manzil_number',
        'sajdah_number',
        'page_number',
        'juz_number',
        'english_transliteration'
    ];

    protected $casts = [
        'chapter_id' => 'integer',
    ];

    public function chapter(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Chapter::class, 'chapter_id', 'id');
    }

    public function translators(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(VerseTranslation::class, 'chapter_detail_id', 'id');
    }

}
