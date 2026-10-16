<?php

namespace App\Models\Quran\Payment;

use App\Models\Quran\Settings\Setting;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentMethod extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'type'
    ];

    public function settings(): \Illuminate\Database\Eloquent\Relations\MorphMany
    {
        return $this->morphMany(Setting::class, 'settingable');
    }

}
