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
        'name', 'phone', 'email', 'password', 'role', 'status',
        'address1', 'address2', 'phone2', 'zone', 'photo'
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'validated_at' => 'datetime',
        'email_verified_at' => 'datetime',
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
}