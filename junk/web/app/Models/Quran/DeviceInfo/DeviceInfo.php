<?php

namespace App\Models\Quran\DeviceInfo;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeviceInfo extends Model
{
    use HasFactory;

    protected $fillable = [
        'ip_address',
        'os',
        'country',
        'state',
        'count',
        'latitude',
        'longitude',
        'count',
    ];
}
