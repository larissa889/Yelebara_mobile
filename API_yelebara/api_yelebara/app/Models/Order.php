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
        'presseur_id',
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
        'pickup_latitude',
        'pickup_longitude',
        'city',
        'quartier',
        'location_warning',
        'items',
        'weight',
    ];

    protected $casts = [
        'pickup_at_home' => 'boolean',
        'date' => 'date',
        // 'time' => 'datetime:H:i', // Format time if needed
        'pickup_latitude' => 'float',
        'pickup_longitude' => 'float',
        'items' => 'array',
        'weight' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function presseur()
    {
        return $this->belongsTo(User::class, 'presseur_id');
    }
}
