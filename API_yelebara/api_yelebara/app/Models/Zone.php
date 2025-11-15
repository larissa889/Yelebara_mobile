<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Zone extends Model
{
    public function presseurs() { return $this->belongsToMany(User::class, 'presseur_zones'); }
}
