#!/usr/bin/env php
<?php
/**
 * Script de test pour vérifier l'assignation automatique des commandes
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use App\Models\Order;

echo "═══════════════════════════════════════════════════════════════\n";
echo "   TEST D'ASSIGNATION AUTOMATIQUE DES COMMANDES                \n";
echo "═══════════════════════════════════════════════════════════════\n\n";

// 1. Vérifier les presseurs disponibles
echo "📦 PRESSEURS EN LIGNE:\n";
echo "─────────────────────────────────────────────────────────────\n";
$presseurs = User::where('role', 'presseur')
    ->where('is_online', true)
    ->whereNull('current_order_id')
    ->get();

if ($presseurs->isEmpty()) {
    echo "❌ AUCUN PRESSEUR EN LIGNE!\n";
    echo "Veuillez mettre au moins un presseur en ligne pour tester.\n\n";
    exit(1);
}

foreach ($presseurs as $p) {
    echo sprintf(
        "  ✅ ID:%d | %s\n     📍 %s, %s\n     🟢 En ligne | Workload: %d\n",
        $p->id,
        $p->name,
        $p->quartier,
        $p->city,
        Order::where('presseur_id', $p->id)
            ->whereIn('status', ['assigned', 'in_progress'])
            ->count()
    );
    echo "  ─────────────────────────────────────────────────────────\n";
}

echo "\n";

// 2. Vérifier les dernières commandes
echo "📋 DERNIÈRES COMMANDES:\n";
echo "─────────────────────────────────────────────────────────────\n";
$orders = Order::orderBy('created_at', 'desc')->limit(5)->get();

foreach ($orders as $o) {
    $assignedTo = $o->presseur_id ? "Presseur #" . $o->presseur_id : "❌ NON ASSIGNÉE";
    echo sprintf(
        "  ID:%d | Status: %s | Assigné à: %s\n     📍 %s, %s | GPS: %s\n     ⚠️  %s\n",
        $o->id,
        $o->status,
        $assignedTo,
        $o->quartier ?? 'NULL',
        $o->city ?? 'NULL',
        ($o->pickup_latitude && $o->pickup_longitude) ? 'Oui' : 'Non',
        $o->location_warning ?? 'Aucun warning'
    );
    echo "  ─────────────────────────────────────────────────────────\n";
}

echo "\n";

// 3. Test de réassignation manuelle
echo "🔧 TEST DE RÉASSIGNATION:\n";
echo "─────────────────────────────────────────────────────────────\n";

$unassignedOrders = Order::whereNull('presseur_id')
    ->where('status', 'pending')
    ->get();

echo "Commandes non assignées trouvées: " . $unassignedOrders->count() . "\n\n";

if ($unassignedOrders->isEmpty()) {
    echo "✅ Toutes les commandes sont assignées!\n\n";
} else {
    echo "Voulez-vous réessayer l'assignation pour ces commandes? (o/n): ";
    $handle = fopen("php://stdin", "r");
    $response = trim(fgets($handle));

    if (strtolower($response) === 'o') {
        require_once __DIR__ . '/app/Http/Controllers/OrderController.php';

        foreach ($unassignedOrders as $order) {
            echo "\nTentative d'assignation pour commande #" . $order->id . "\n";
            echo "  📍 Localisation: {$order->quartier}, {$order->city}\n";

            // Simuler l'appel à la méthode d'assignation
            // Note: Cela ne fonctionnera pas directement car la méthode est privée
            // Il faudrait créer une route ou commande artisan pour ça

            echo "  ⚠️  Utilisez la route API pour créer de nouvelles commandes\n";
        }
    }

    fclose($handle);
}

echo "\n═══════════════════════════════════════════════════════════════\n";
echo "💡 CONSEILS:\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "1. Le Presseur Test est à Tampouy\n";
echo "2. Créez une commande à Tampouy pour test de quartier\n";
echo "3. Créez une commande dans un autre quartier à Ouagadougou\n";
echo "   pour tester le city-wide broadcast\n";
echo "4. Créez une commande avec GPS valide pour tester GPS matching\n";
echo "═══════════════════════════════════════════════════════════════\n";
