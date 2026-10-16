<?php

namespace App\Models\Quran\Settings;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    protected $fillable = [
        'name', 'value', 'context', 'settingable_type', 'settingable_id'
    ];

}
