<?php

namespace App\Models\Quran\Profile;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Profile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'gender', 'date_of_birth', 'user_id', 'phone_number', 'profile_picture'
    ];

    protected $dates = [
        'date_of_birth'
    ];
}
