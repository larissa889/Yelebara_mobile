#!/usr/bin/env php
<?php
/**
 * Migration des données address1 vers city et quartier
 * Parse le format "Quartier, Ville" et migre les données
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;

echo "═══════════════════════════════════════════════════════════════\n";
echo "   MIGRATION ADDRESS1 → CITY + QUARTIER                        \n";
echo "═══════════════════════════════════════════════════════════════\n\n";

// Récupérer tous les utilisateurs avec address1
$users = User::whereNotNull('address1')->orWhereNotNull('address2')->get();

echo "📊 Utilisateurs trouvés: " . $users->count() . "\n\n";

$migrated = 0;
$skipped = 0;

foreach ($users as $user) {
    echo "─────────────────────────────────────────────────────────────\n";
    echo "👤 {$user->name} (ID: {$user->id})\n";
    echo "   Role: {$user->role}\n";
    echo "   Address1: {$user->address1}\n";
    echo "   Address2: {$user->address2}\n";

    // Parser address1 (format: "Quartier, Ville")
    if ($user->address1) {
        $parts = array_map('trim', explode(',', $user->address1));

        if (count($parts) >= 2) {
            // Format: "Quartier, Ville"
            $quartier = $parts[0];
            $city = $parts[1];
        } elseif (count($parts) == 1) {
            // Un seul mot - on suppose que c'est le quartier
            $quartier = $parts[0];
            $city = 'Ouagadougou'; // Valeur par défaut
        } else {
            $quartier = null;
            $city = null;
        }

        if ($quartier && $city) {
            $user->update([
                'city' => $city,
                'quartier' => $quartier
            ]);

            echo "   ✅ Migré → Ville: {$city} | Quartier: {$quartier}\n";
            $migrated++;
        } else {
            echo "   ⚠️  Format non reconnu, ignoré\n";
            $skipped++;
        }
    } else {
        echo "   ⏭️  Pas de address1, ignoré\n";
        $skipped++;
    }
}

echo "─────────────────────────────────────────────────────────────\n\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "   RÉSUMÉ DE LA MIGRATION                                      \n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "✅ Migrés: {$migrated}\n";
echo "⏭️  Ignorés: {$skipped}\n";
echo "📊 Total: " . ($migrated + $skipped) . "\n\n";

// Afficher les utilisateurs après migration
echo "═══════════════════════════════════════════════════════════════\n";
echo "   VÉRIFICATION POST-MIGRATION                                 \n";
echo "═══════════════════════════════════════════════════════════════\n\n";

$allUsers = User::all();
foreach ($allUsers as $u) {
    echo sprintf(
        "ID:%d | %s (%s)\n  📍 Ville: %s | Quartier: %s\n",
        $u->id,
        $u->name,
        $u->role,
        $u->city ?? '❌ NULL',
        $u->quartier ?? '❌ NULL'
    );
    echo "  ─────────────────────────────────────────────────────────\n";
}

echo "\n✨ Migration terminée!\n";
