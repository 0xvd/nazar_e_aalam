<?php

namespace App\Models\Quran\HaramCode;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HaramCode extends Model
{
    use HasFactory;

    protected $fillable = ['code', 'name', 'description', 'status_info'];

}
