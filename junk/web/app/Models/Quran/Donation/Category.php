<?php

namespace App\Models\Quran\Donation;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = ['name'];

    public function categorizable()
    {
        return $this->morphTo();
    }
}
