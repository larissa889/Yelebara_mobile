<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\UserProfile;
use App\Models\PresseurProfile;
use App\Models\Zone;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20|unique:users',
            'password' => 'required|string|min:6|confirmed',
            'role' => 'required|in:client,presseur',
            'address' => 'required_if:role,client|string|max:500',
            'zone_id' => 'required_if:role,presseur|exists:zones,id',
            'business_name' => 'required_if:role,presseur|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Create user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'role' => $request->role,
                'status' => $request->role === 'presseur' ? 'pending' : 'active',
            ]);

            // Create user profile
            $profileData = [];
            
            if ($request->role === 'client') {
                $profileData = [
                    'address1' => $request->address,
                    'latitude' => $request->latitude,
                    'longitude' => $request->longitude,
                ];
            }

            $user->profile()->create($profileData);

            // Create presseur profile if role is presseur
            if ($request->role === 'presseur') {
                $presseurProfile = $user->presseurProfile()->create([
                    'business_name' => $request->business_name,
                    'is_verified' => false,
                ]);

                // Attach zone
                if ($request->zone_id) {
                    $user->zones()->attach($request->zone_id);
                }
            }

            // Create token
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Inscription réussie',
                'data' => [
                    'user' => $this->getUserData($user),
                    'token' => $token,
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Une erreur est survenue lors de l\'inscription',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Login user
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email ou mot de passe incorrect'
            ], 401);
        }

        if ($user->status === 'suspended') {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte a été suspendu. Contactez l\'administration.'
            ], 403);
        }

        if ($user->role === 'presseur' && $user->status === 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte presseur est en attente de validation par l\'administration.'
            ], 403);
        }

        if ($user->role === 'presseur' && $user->status === 'rejected') {
            return response()->json([
                'success' => false,
                'message' => 'Votre demande de compte presseur a été rejetée.'
            ], 403);
        }

        // Revoke all tokens
        $user->tokens()->delete();

        // Create new token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'data' => [
                'user' => $this->getUserData($user),
                'token' => $token,
            ]
        ]);
    }

    /**
     * Logout user
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
     * Get authenticated user
     */
    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $this->getUserData($request->user())
        ]);
    }

    /**
     * Send password reset link
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {
            return response()->json([
                'success' => true,
                'message' => 'Un lien de réinitialisation a été envoyé à votre email'
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Impossible d\'envoyer le lien de réinitialisation'
        ], 500);
    }

    /**
     * Reset password
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ])->setRememberToken(Str::random(60));

                $user->save();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return response()->json([
                'success' => true,
                'message' => 'Votre mot de passe a été réinitialisé avec succès'
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Le lien de réinitialisation est invalide ou a expiré'
        ], 400);
    }

    /**
     * Format user data for response
     */
    private function getUserData($user)
    {
        $userData = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'phone2' => $user->phone2,
            'role' => $user->role,
            'status' => $user->status,
            'photo_url' => $user->photo_url,
            'created_at' => $user->created_at,
        ];

        // Add profile data
        if ($user->profile) {
            $userData['profile'] = [
                'address1' => $user->profile->address1,
                'address2' => $user->profile->address2,
                'latitude' => $user->profile->latitude,
                'longitude' => $user->profile->longitude,
            ];
        }

        // Add presseur specific data
        if ($user->role === 'presseur' && $user->presseurProfile) {
            $userData['presseur'] = [
                'business_name' => $user->presseurProfile->business_name,
                'is_verified' => $user->presseurProfile->is_verified,
                'rating' => $user->presseurProfile->rating,
                'total_reviews' => $user->presseurProfile->total_reviews,
                'total_orders' => $user->presseurProfile->total_orders,
                'total_revenue' => $user->presseurProfile->total_revenue,
                'schedule' => $user->presseurProfile->schedule,
                'zones' => $user->zones->map(function($zone) {
                    return [
                        'id' => $zone->id,
                        'name' => $zone->name,
                        'city' => $zone->city,
                    ];
                }),
            ];
        }

        return $userData;
    }
}