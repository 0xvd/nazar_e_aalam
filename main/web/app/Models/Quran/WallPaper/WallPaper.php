<?php

namespace App\Models\Quran\WallPaper;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WallPaper extends Model
{
    use HasFactory;

    protected $fillable = ['category_id','name', 'image'];

    public function category() :BelongsTo
    {
        return $this->belongsTo(WallpaperCategory::class);
    }
}
