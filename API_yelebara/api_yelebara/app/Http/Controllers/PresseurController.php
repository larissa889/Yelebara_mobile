<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;


use App\Models\Order;
use Illuminate\Support\Facades\Auth;

class PresseurController extends Controller
{
    public function updateLocation(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = Auth::user();
        $user->update([
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
        ]);

        return response()->json(['success' => true, 'message' => 'Position mise à jour']);
    }

    public function updateStatus(Request $request)
    {
        $request->validate([
            'is_online' => 'required|boolean',
        ]);

        $user = Auth::user();
        $user->update([
            'is_online' => $request->is_online,
        ]);

        return response()->json(['success' => true, 'message' => 'Statut mis à jour']);
    }

    public function currentOrder()
    {
        $user = Auth::user();
        if (!$user->current_order_id) {
            return response()->json(['success' => true, 'order' => null]);
        }

        $order = Order::find($user->current_order_id);

        // Si l'ordre a été supprimé ou autre intégrité corrompue
        if (!$order) {
            $user->update(['current_order_id' => null]);
            return response()->json(['success' => true, 'order' => null]);
        }

        return response()->json(['success' => true, 'order' => $order]);
    }

    public function acceptOrder($id)
    {
        $order = Order::find($id);
        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Commande introuvable'], 404);
        }

        if ($order->presseur_id !== Auth::id()) {
            return response()->json(['success' => false, 'message' => 'Non autorisé'], 403);
        }

        $order->update(['status' => 'processing']);
        return response()->json(['success' => true, 'message' => 'Commande acceptée']);
    }

    public function completeOrder($id)
    {
        $order = Order::find($id);
        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Commande introuvable'], 404);
        }

        if ($order->presseur_id !== Auth::id()) {
            return response()->json(['success' => false, 'message' => 'Non autorisé'], 403);
        }

        $order->update(['status' => 'completed']);

        // Libérer le presseur
        $user = Auth::user();
        $user->update(['current_order_id' => null]);

        // TODO: Vérifier s'il y a des commandes en attente à proximité (Bonus)

        return response()->json(['success' => true, 'message' => 'Commande terminée']);
    }
}
