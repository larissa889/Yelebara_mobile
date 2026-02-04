<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    public function index()
    {
        // Retourne les commandes de l'utilisateur connecté
        $orders = Auth::user()->orders()->orderBy('created_at', 'desc')->get();
        return response()->json(['success' => true, 'orders' => $orders]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'service_title' => 'required|string',
            'amount' => 'required|numeric',
            'date' => 'required|date',
            'pickup_at_home' => 'boolean',
        ]);

        $order = Order::create([
            'user_id' => Auth::id(),
            'service_title' => $request->service_title,
            'service_price' => $request->service_price ?? '0 F',
            'amount' => $request->amount,
            'date' => $request->date,
            'time_slot' => $request->time_slot,
            'pickup_at_home' => $request->pickup_at_home ?? true,
            'instructions' => $request->instructions,
            'service_icon_code' => $request->service_icon_code,
            'service_color_code' => $request->service_color_code,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Commande créée avec succès',
            'order' => $order
        ], 201);
    }

    public function show($id)
    {
        $order = Auth::user()->orders()->find($id);
        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Commande introuvable'], 404);
        }
        return response()->json(['success' => true, 'order' => $order]);
    }
}
