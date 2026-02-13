<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        if ($user->role === 'presseur') {
            // Pour les presseurs, retourner les commandes assignées
            $orders = $user->assignedOrders()->with('user')->orderBy('created_at', 'desc')->get();
        } else {
            // Pour les clients, retourner leurs commandes
            $orders = $user->orders()->orderBy('created_at', 'desc')->get();
        }
        return response()->json(['success' => true, 'orders' => $orders]);
    }

    public function show($id)
    {
        $user = Auth::user();
        if ($user->role === 'presseur') {
            $order = $user->assignedOrders()->with('user')->find($id);
        } else {
            $order = $user->orders()->with('presseur')->find($id);
        }

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Commande introuvable'], 404);
        }
        return response()->json(['success' => true, 'order' => $order]);
    }

    public function update(Request $request, $id)
    {
        $user = Auth::user();

        // Trouver la commande (soit du client, soit du presseur)
        $order = Order::find($id);

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Commande introuvable'], 404);
        }

        // Vérifier les droits
        if ($user->role === 'presseur' && $order->presseur_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Non autorisé'], 403);
        }
        if ($user->role === 'client' && $order->user_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Non autorisé'], 403);
        }

        // Validation
        $request->validate([
            'status' => 'nullable|string|in:pending,assigned,in_progress,ready,completed,cancelled',
            'weight' => 'nullable|numeric|min:0',
        ]);

        if ($request->has('status')) {
            $order->status = $request->status;

            // Si la commande est terminée, libérer le presseur
            if (in_array($request->status, ['completed', 'cancelled'])) {
                if ($order->presseur_id) {
                    $presseur = \App\Models\User::find($order->presseur_id);
                    if ($presseur) {
                        $presseur->current_order_id = null;
                        $presseur->save();
                    }
                }
            }
        }

        if ($request->has('weight')) {
            $order->weight = $request->weight;

            // Recalculer le montant si nécessaire (Logique métier à définir)
            // Pour l'instant on garde le prix estimé ou on le met à jour
            // $order->amount = $order->weight * $pricePerKg; 
        }

        $order->save();

        return response()->json([
            'success' => true,
            'message' => 'Commande mise à jour',
            'order' => $order->fresh(['user', 'presseur'])
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'service_title' => 'required|string',
            'service_price' => 'required|string',
            'amount' => 'required|numeric',
            'date' => 'required|date',
            'time' => 'required|string', // Format HH:mm
            'pickup_at_home' => 'required|boolean',
            'instructions' => 'nullable|string',
            'service_icon_code' => 'required|integer',
            'service_color_code' => 'required|integer',
            'paymentMethod' => 'nullable|integer',
            'pickup_latitude' => 'nullable|numeric',
            'pickup_longitude' => 'nullable|numeric',
            'city' => 'nullable|string',
            'quartier' => 'nullable|string',
            'items' => 'nullable|array', // Validate items array
        ]);

        $user = Auth::user();

        // Use provided city/quartier or fall back to user's location data
        $city = $request->city ?? $user->city;
        $quartier = $request->quartier ?? $user->quartier;

        // 1. Créer la commande
        $order = new Order([
            'service_title' => $request->service_title,
            'service_price' => $request->service_price,
            'amount' => $request->amount,
            'date' => $request->date,
            'time' => $request->time,
            'pickup_at_home' => $request->pickup_at_home,
            'instructions' => $request->instructions,
            'service_icon_code' => $request->service_icon_code,
            'service_color_code' => $request->service_color_code,
            'paymentMethod' => $request->paymentMethod,
            'status' => 'pending',
            'pickup_latitude' => $request->pickup_latitude,
            'pickup_longitude' => $request->pickup_longitude,
            'city' => $city,
            'quartier' => $quartier,
            'items' => $request->items, // Save items
        ]);

        $user->orders()->save($order);

        // 2. Trouver un presseur disponible (dispatch logic)
        $this->assignPresseurToOrder($order);

        return response()->json([
            'success' => true,
            'message' => 'Commande créée avec succès',
            'order' => $order->fresh(['presseur']),
        ], 201);
    }

    /**
     * Assign a presser to an order using three-tier fallback strategy
     * Attempt 1: GPS-based precision matching (5km radius)
     * Attempt 2: Neighborhood matching (city + quartier)
     * Attempt 3: City-wide broadcast (lowest workload)
     */
    private function assignPresseurToOrder(Order $order)
    {
        // Get base query for available pressers
        $baseQuery = \App\Models\User::where('role', 'presseur')
            ->where('is_online', true)
            ->whereNull('current_order_id');

        $presseur = null;
        $assignmentMethod = null;

        // ===== ATTEMPT 1: GPS Precision Matching =====
        if ($this->isValidCoordinate($order->pickup_latitude, $order->pickup_longitude)) {
            $presseur = $this->findPresserByGPS(
                $order->pickup_latitude,
                $order->pickup_longitude,
                $baseQuery
            );
            if ($presseur) {
                $assignmentMethod = 'gps';
            }
        }

        // ===== ATTEMPT 2: Neighborhood Matching =====
        if (!$presseur && $order->city && $order->quartier) {
            $presseur = $this->findPresserByNeighborhood(
                $order->city,
                $order->quartier,
                $baseQuery
            );
            if ($presseur) {
                $assignmentMethod = 'neighborhood';
            }
        }

        // ===== ATTEMPT 3: City-Wide Broadcast =====
        if (!$presseur && $order->city) {
            $presseur = $this->findPresserByCity(
                $order->city,
                $baseQuery
            );
            if ($presseur) {
                $assignmentMethod = 'city_broadcast';
                // Flag order with location warning
                $order->location_warning = 'Location approximate - Check with client';
            }
        }

        // Assign presseur if found
        if ($presseur) {
            $order->presseur_id = $presseur->id;
            $order->status = 'assigned';
            $order->save();

            // Lock presser
            $presseur->current_order_id = $order->id;
            $presseur->save();

            // TODO: Send notification to presser
            // Include location_warning in notification if present

            \Log::info("Order #{$order->id} assigned to Presser #{$presseur->id} via {$assignmentMethod}");
        } else {
            \Log::warning("Order #{$order->id} could not be assigned - no available pressers found");
        }
    }

    /**
     * Find presser using GPS coordinates (within 5km)
     */
    private function findPresserByGPS($lat, $lon, $baseQuery)
    {
        $searchRadiusKm = 5;

        // Clone the base query
        $query = clone $baseQuery;

        // Haversine formula for distance calculation
        $presseurs = $query
            ->select('*')
            ->selectRaw(
                "(6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) AS distance",
                [$lat, $lon, $lat]
            )
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->having('distance', '<=', $searchRadiusKm)
            ->orderBy('distance')
            ->first();

        return $presseurs;
    }

    /**
     * Find presser by city and neighborhood (quartier)
     */
    private function findPresserByNeighborhood($city, $quartier, $baseQuery)
    {
        // Clone the base query
        $query = clone $baseQuery;

        // Case-insensitive exact match on city and quartier
        $presseurs = $query
            ->whereRaw('LOWER(city) = ?', [strtolower($city)])
            ->whereRaw('LOWER(quartier) = ?', [strtolower($quartier)])
            ->get();

        if ($presseurs->isEmpty()) {
            return null;
        }

        // If multiple pressers, select one with lowest workload
        return $this->selectPresserByWorkload($presseurs);
    }

    /**
     * Find presser by city only (last resort)
     */
    private function findPresserByCity($city, $baseQuery)
    {
        // Clone the base query
        $query = clone $baseQuery;

        // Case-insensitive match on city
        $presseurs = $query
            ->whereRaw('LOWER(city) = ?', [strtolower($city)])
            ->get();

        if ($presseurs->isEmpty()) {
            return null;
        }

        // Select presser with lowest workload
        return $this->selectPresserByWorkload($presseurs);
    }

    /**
     * Select presser with lowest current workload
     */
    private function selectPresserByWorkload($presseurs)
    {
        $lowestWorkload = null;
        $selectedPresser = null;

        foreach ($presseurs as $presser) {
            $workload = $this->getPresserWorkload($presser->id);

            if ($lowestWorkload === null || $workload < $lowestWorkload) {
                $lowestWorkload = $workload;
                $selectedPresser = $presser;
            }
        }

        return $selectedPresser;
    }

    /**
     * Get presser's current workload (number of assigned/in-progress orders)
     */
    private function getPresserWorkload($presserId)
    {
        return Order::where('presseur_id', $presserId)
            ->whereIn('status', ['assigned', 'in_progress'])
            ->count();
    }

    /**
     * Validate that coordinates are not null and within valid ranges
     */
    private function isValidCoordinate($lat, $lon)
    {
        if ($lat === null || $lon === null) {
            return false;
        }

        // Basic validation: latitude between -90 and 90, longitude between -180 and 180
        if ($lat < -90 || $lat > 90 || $lon < -180 || $lon > 180) {
            return false;
        }

        // Check for zero coordinates (often indicates invalid/default data)
        if ($lat == 0 && $lon == 0) {
            return false;
        }

        return true;
    }

    // ... show, update methods ...
}
