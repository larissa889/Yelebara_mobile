<?php

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name', 'email', 'phone', 'phone2', 'password', 'role', 'status', 'photo_url'
    ];

    protected $hidden = ['password', 'remember_token'];

    public function profile()
    {
        return $this->hasOne(UserProfile::class);
    }

    public function presseurProfile()
    {
        return $this->hasOne(PresseurProfile::class);
    }

    public function zones()
    {
        return $this->belongsToMany(Zone::class, 'presseur_zones');
    }
}
