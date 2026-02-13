<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'phone',
        'email',
        'password',
        'role',
        'status',
        'phone2',
        'zone',
        'city',
        'quartier',
        'photo',
        'latitude',
        'longitude',
        'is_online',
        'current_order_id'
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'validated_at' => 'datetime',
        'email_verified_at' => 'datetime',
        'is_online' => 'boolean',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    public function isPending()
    {
        return $this->status === 'pending';
    }

    public function isActive()
    {
        return $this->status === 'active';
    }

    public function isPresseur()
    {
        return $this->role === 'presseur';
    }

    public function validator()
    {
        return $this->belongsTo(User::class, 'validated_by');
    }

    public function scopePendingPresseurs($query)
    {
        return $query->where('role', 'presseur')
            ->where('status', 'pending');
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function assignedOrders()
    {
        return $this->hasMany(Order::class, 'presseur_id');
    }
}