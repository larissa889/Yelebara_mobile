<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Zone;
use Illuminate\Http\Request;

class ZoneController extends Controller
{
    public function index()
    {
        $zones = Zone::active()->get();

        return response()->json([
            'success' => true,
            'zones' => $zones
        ]);
    }
}