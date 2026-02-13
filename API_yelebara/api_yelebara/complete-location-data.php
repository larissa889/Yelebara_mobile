#!/usr/bin/env php
<?php
/**
 * Compléter les données manquantes pour city et quartier
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;

echo "═══════════════════════════════════════════════════════════════\n";
echo "   COMPLÉTER LES DONNÉES DE LOCALISATION MANQUANTES            \n";
echo "═══════════════════════════════════════════════════════════════\n\n";

// Valeurs par défaut pour les utilisateurs sans localisation
$defaults = [
    'Ouagadougou', // Ville par défaut
    'Zone 1'       // Quartier par défaut
];

// Trouver les utilisateurs sans city ou quartier
$usersWithoutLocation = User::where(function ($query) {
    $query->whereNull('city')->orWhereNull('quartier');
})->get();

echo "📊 Utilisateurs sans localisation complète: " . $usersWithoutLocation->count() . "\n\n";

foreach ($usersWithoutLocation as $user) {
    echo "─────────────────────────────────────────────────────────────\n";
    echo "👤 {$user->name} (ID: {$user->id}) - Role: {$user->role}\n";

    $updated = [];

    if (!$user->city) {
        $user->city = $defaults[0];
        $updated[] = "Ville: {$defaults[0]}";
    }

    if (!$user->quartier) {
        // Différencier les quartiers pour tester les scénarios
        if ($user->role === 'presseur') {
            // Alterner entre différents quartiers pour les presseurs
            $quartiers = ['Zone 1', 'Tampouy', 'Cissin', 'Patte d\'Oie'];
            $user->quartier = $quartiers[$user->id % count($quartiers)];
        } else {
            $user->quartier = $defaults[1];
        }
        $updated[] = "Quartier: {$user->quartier}";
    }

    $user->save();

    echo "   ✅ Mis à jour: " . implode(' | ', $updated) . "\n";
}

echo "─────────────────────────────────────────────────────────────\n\n";

// Afficher tous les utilisateurs après mise à jour
echo "═══════════════════════════════════════════════════════════════\n";
echo "   ÉTAT FINAL - TOUS LES UTILISATEURS                         \n";
echo "═══════════════════════════════════════════════════════════════\n\n";

$allUsers = User::all();
foreach ($allUsers as $u) {
    $online = $u->is_online ? '🟢' : '🔴';
    echo sprintf(
        "%s ID:%d | %s (%s)\n   📍 %s, %s\n",
        $online,
        $u->id,
        $u->name,
        $u->role,
        $u->quartier,
        $u->city
    );
    echo "   ─────────────────────────────────────────────────────────\n";
}

echo "\n✨ Tous les utilisateurs ont maintenant city et quartier!\n";
echo "✅ Prêt pour supprimer les colonnes address1 et address2\n";
