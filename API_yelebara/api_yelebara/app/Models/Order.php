<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Order extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'service_title',
        'service_price',
        'amount',
        'date',
        'time_slot',
        'pickup_at_home',
        'instructions',
        'status',
        'service_icon_code',
        'service_color_code',
    ];

    protected $casts = [
        'date' => 'datetime',
        'pickup_at_home' => 'boolean',
        'amount' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
