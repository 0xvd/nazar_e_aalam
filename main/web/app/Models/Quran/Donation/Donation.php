<?php

namespace App\Models\Quran\Donation;

use App\Models\Quran\Payment\PaymentMethod;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Donation extends Model
{
    use HasFactory;

    protected $fillable = ['category_id', 'email', 'name', 'payment_method_id', 'payment_gateway', 'status', 'currency'];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function paymentMethod(): BelongsTo
    {
        return $this->belongsTo(PaymentMethod::class);
    }

    public function transaction(): HasOne
    {
        return $this->hasOne(Transaction::class, 'donation_id', 'id');
    }
}
