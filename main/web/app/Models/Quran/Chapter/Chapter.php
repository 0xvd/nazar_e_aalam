<?php

namespace App\Models\Quran\Chapter;

use App\Models\Quran\Verse\VerseTranslation;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Chapter extends Model
{

    protected $fillable = [
        'arabic_name', 'verses_count', 'revelation_place', 'revelation_order', 'bismillah_pre'
    ];

    protected $casts = [
        'bismillah_pre' => 'boolean',
        'verses_count' => 'integer',
    ];

    public function translations(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(ChapterTranslation::class, 'chapter_id', 'id');
    }
    public function translateChapters(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(ChapterTranslation::class, 'chapter_id', 'id');
    }

    public function verseTranslations(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(VerseTranslation::class, 'chapter_id', 'id');
    }
}
