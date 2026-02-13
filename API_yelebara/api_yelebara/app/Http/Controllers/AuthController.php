<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Inscription d'un nouvel utilisateur
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|unique:users,phone',
            'email' => 'nullable|email|unique:users,email',
            'password' => 'required|string|min:6',
            'role' => 'required|in:client,presseur',
            'phone2' => 'nullable|string',
            'zone' => 'required_if:role,presseur|string|nullable',
            'city' => 'required|string',
            'quartier' => 'required|string',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'phone' => $validated['phone'],
            'email' => $validated['email'] ?? null,
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'status' => $validated['role'] === 'presseur' ? 'pending' : 'active',
            'phone2' => $validated['phone2'] ?? null,
            'zone' => $validated['zone'] ?? null,
            'city' => $validated['city'],
            'quartier' => $validated['quartier'],
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => $validated['role'] === 'presseur'
                ? 'Inscription réussie. En attente de validation par un administrateur.'
                : 'Inscription réussie !',
            'user' => $user,
            'token' => $token,
            'requires_validation' => $validated['role'] === 'presseur',
        ], 201);
    }

    /**
     * Connexion
     */
    public function login(Request $request)
    {
        $validated = $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('phone', $validated['phone'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'phone' => ['Identifiants incorrects.'],
            ]);
        }

        // Vérifier le statut si c'est un presseur
        if ($user->isPresseur() && $user->isPending()) {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte est en attente de validation par un administrateur.',
                'status' => 'pending'
            ], 403);
        }

        if ($user->status === 'suspended') {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte a été suspendu. Contactez le support.',
                'status' => 'suspended'
            ], 403);
        }

        // Révoquer les anciens tokens
        $user->tokens()->delete();

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'user' => $user,
            'token' => $token,
        ]);
    }

    /**
     * Déconnexion
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Déconnexion réussie'
        ]);
    }

    /**
     * Obtenir l'utilisateur connecté
     */
    public function user(Request $request)
    {
        return response()->json([
            'success' => true,
            'user' => $request->user()
        ]);
    }

    /**
     * Mise à jour du profil
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'email' => 'nullable|email|unique:users,email,' . $user->id,
            'phone2' => 'nullable|string',
            'city' => 'nullable|string',
            'quartier' => 'nullable|string',
            // 'photo' => 'nullable|image', // Si envoi fichier
            // Pour l'instant on accepte juste update texte ou URL si géré autrement
        ]);

        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profil mis à jour avec succès',
            'user' => $user
        ]);
    }

    /**
     * Réinitialisation de mot de passe (envoi du code)
     */
    public function sendResetCode(Request $request)
    {
        $validated = $request->validate([
            'phone' => 'required|string|exists:users,phone',
        ]);

        $user = User::where('phone', $validated['phone'])->first();

        // TODO: Implémenter l'envoi du code par SMS
        $resetCode = rand(100000, 999999);

        // Stocker temporairement (utiliser cache en production)
        cache()->put("reset_code_{$user->phone}", $resetCode, now()->addMinutes(10));

        return response()->json([
            'success' => true,
            'message' => 'Code de réinitialisation envoyé',
            'code' => $resetCode // À retirer en production
        ]);
    }

    /**
     * Vérifier le code et réinitialiser le mot de passe
     */
    public function resetPassword(Request $request)
    {
        $validated = $request->validate([
            'phone' => 'required|string|exists:users,phone',
            'code' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $storedCode = cache()->get("reset_code_{$validated['phone']}");

        if (!$storedCode || $storedCode != $validated['code']) {
            return response()->json([
                'success' => false,
                'message' => 'Code invalide ou expiré'
            ], 400);
        }

        $user = User::where('phone', $validated['phone'])->first();
        $user->update(['password' => Hash::make($validated['password'])]);

        cache()->forget("reset_code_{$validated['phone']}");

        return response()->json([
            'success' => true,
            'message' => 'Mot de passe réinitialisé avec succès'
        ]);
    }
}