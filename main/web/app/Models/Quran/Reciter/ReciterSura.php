<?php

namespace App\Models\Quran\Reciter;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReciterSura extends Model
{
    use HasFactory;

    protected $fillable = [
        'reciter_id',
        'name',
        'number',
        'revealed_place',
        'duration',
        'path'
    ];

    public function reciter(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Reciter::class);
    }
}
