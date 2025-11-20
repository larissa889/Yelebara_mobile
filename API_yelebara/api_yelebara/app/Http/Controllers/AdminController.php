<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    /**
     * Liste des presseurs en attente de validation
     */
    public function pendingPresseurs()
    {
        $presseurs = User::pendingPresseurs()
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'presseurs' => $presseurs
        ]);
    }

    /**
     * Valider un presseur
     */
    public function validatePresseur(Request $request, $id)
    {
        $presseur = User::findOrFail($id);

        if (!$presseur->isPresseur() || !$presseur->isPending()) {
            return response()->json([
                'success' => false,
                'message' => 'Ce compte ne peut pas être validé'
            ], 400);
        }

        $presseur->update([
            'status' => 'active',
            'validated_at' => now(),
            'validated_by' => $request->user()->id,
        ]);

        // TODO: Envoyer une notification au presseur

        return response()->json([
            'success' => true,
            'message' => 'Presseur validé avec succès',
            'presseur' => $presseur
        ]);
    }

    /**
     * Rejeter un presseur
     */
    public function rejectPresseur(Request $request, $id)
    {
        $validated = $request->validate([
            'reason' => 'nullable|string'
        ]);

        $presseur = User::findOrFail($id);

        if (!$presseur->isPresseur() || !$presseur->isPending()) {
            return response()->json([
                'success' => false,
                'message' => 'Ce compte ne peut pas être rejeté'
            ], 400);
        }

        // Soit supprimer, soit marquer comme rejeté
        $presseur->delete(); // Soft delete

        // TODO: Envoyer une notification au presseur avec la raison

        return response()->json([
            'success' => true,
            'message' => 'Presseur rejeté'
        ]);
    }

    /**
     * Statistiques du dashboard admin
     */
    public function dashboard()
    {
        $stats = [
            'total_clients' => User::where('role', 'client')->count(),
            'total_presseurs' => User::where('role', 'presseur')->where('status', 'active')->count(),
            'pending_presseurs' => User::pendingPresseurs()->count(),
            'total_zones' => \App\Models\Zone::active()->count(),
            // Ajouter d'autres stats selon vos besoins
        ];

        return response()->json([
            'success' => true,
            'stats' => $stats
        ]);
    }
}
