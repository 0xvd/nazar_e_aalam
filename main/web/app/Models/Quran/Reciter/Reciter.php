<?php

namespace App\Models\Quran\Reciter;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Reciter extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'profile_picture',
        'position',
    ];

    public function suras(): HasMany
    {
        return $this->hasMany(ReciterSura::class, 'reciter_id', 'id');
    }

}
