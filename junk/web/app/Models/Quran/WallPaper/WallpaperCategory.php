<?php

namespace App\Models\Quran\WallPaper;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WallpaperCategory extends Model
{
    use HasFactory;

    protected $fillable = [
        'name'
    ];

    public function wallpapers() : \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(WallPaper::class, 'category_id');
    }
}
