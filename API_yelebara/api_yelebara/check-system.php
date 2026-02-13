#!/usr/bin/env php
<?php
/**
 * Script de test - Créer une commande et vérifier l'assignation
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use App\Models\Order;

echo "═══════════════════════════════════════════════════════════════\n";
echo "   ÉTAT ACTUEL DU SYSTÈME                                      \n";
echo "═══════════════════════════════════════════════════════════════\n\n";

// Vérifier presseurs disponibles
$availablePressers = User::where('role', 'presseur')
    ->where('is_online', true)
    ->whereNull('current_order_id')
    ->get();

echo "📦 PRESSEURS DISPONIBLES: " . $availablePressers->count() . "\n";
foreach ($availablePressers as $p) {
    echo sprintf(
        "  ✅ %s (ID:%d) - 📍 %s, %s\n",
        $p->name,
        $p->id,
        $p->quartier,
        $p->city
    );
}
echo "\n";

// Afficher les dernières commandes
$recentOrders = Order::orderBy('created_at', 'desc')->limit(3)->get();
echo "📋 DERNIÈRES COMMANDES:\n";
foreach ($recentOrders as $o) {
    $status = $o->presseur_id ? "✅ Assignée à presseur #{$o->presseur_id}" : "❌ NON ASSIGNÉE";
    echo sprintf(
        "  ID:%d | %s | Status: %s\n     📍 %s, %s | GPS: %s\n",
        $o->id,
        $status,
        $o->status,
        $o->quartier ?? 'NULL',
        $o->city ?? 'NULL',
        ($o->pickup_latitude && $o->pickup_longitude) ? "({$o->pickup_latitude}, {$o->pickup_longitude})" : 'Non'
    );
    if ($o->location_warning) {
        echo "     ⚠️  {$o->location_warning}\n";
    }
    echo "\n";
}

echo "═══════════════════════════════════════════════════════════════\n";
echo "🔍 DIAGNOSTIC:\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

if ($availablePressers->isEmpty()) {
    echo "❌ PROBLÈME: Aucun presseur disponible!\n";
    echo "\nSOLUTIONS:\n";
    echo "1. Mettez un presseur en ligne dans l'application\n";
    echo "2. OU exécutez cette commande SQL:\n";
    echo "   UPDATE users SET is_online = 1, current_order_id = NULL WHERE id = 5;\n\n";
} else {
    echo "✅ Des presseurs sont disponibles\n\n";

    $unassigned = Order::whereNull('presseur_id')->where('status', 'pending')->count();
    if ($unassigned > 0) {
        echo "⚠️  Il y a {$unassigned} commande(s) non assignée(s)\n";
        echo "\nPOSSIBLES RAISONS:\n";
        echo "1. Le presseur a maintenant un current_order_id (vérifié: NON)\n";
        echo "2. La ville/quartier ne correspond pas\n";
        echo "3. Le GPS est invalide et pas de city/quartier défini\n\n";

        $pendingOrders = Order::whereNull('presseur_id')->where('status', 'pending')->get();
        foreach ($pendingOrders as $order) {
            echo "Commande #{$order->id}:\n";
            echo "  📍 Quartier: " . ($order->quartier ?? '❌ NULL') . "\n";
            echo "  📍 Ville: " . ($order->city ?? '❌ NULL') . "\n";
            echo "  🗺️  GPS: " . ($order->pickup_latitude && $order->pickup_longitude ? 'Oui' : '❌ Non') . "\n\n";

            // Vérifier si un presseur correspond au quartier
            if ($order->city && $order->quartier) {
                $matchingPresser = User::where('role', 'presseur')
                    ->whereRaw('LOWER(city) = ?', [strtolower($order->city)])
                    ->whereRaw('LOWER(quartier) = ?', [strtolower($order->quartier)])
                    ->first();

                if ($matchingPresser) {
                    echo "  ✅ Presseur correspondant trouvé: {$matchingPresser->name}\n";
                    echo "     Mais is_online={$matchingPresser->is_online}, current_order_id=" . ($matchingPresser->current_order_id ?? 'NULL') . "\n";
                } else {
                    echo "  ❌ Aucun presseur dans ce quartier\n";
                    echo "     Le système devrait utiliser city-wide broadcast...\n";
                }
            }
            echo "\n";
        }
    } else {
        echo "✅ Toutes les commandes sont assignées!\n\n";
    }
}

echo "═══════════════════════════════════════════════════════════════\n";
echo "💡 POUR TESTER:\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "1. Connectez-vous avec un compte CLIENT\n";
echo "2. Créez une nouvelle commande\n";
echo "3. La commande devrait être automatiquement assignée!\n";
echo "═══════════════════════════════════════════════════════════════\n";
