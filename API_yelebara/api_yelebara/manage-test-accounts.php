#!/usr/bin/env php
<?php
/**
 * Script pour gérer les comptes de test Yelebara
 * Usage: php manage-test-accounts.php
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;

echo "═══════════════════════════════════════════════════════════════\n";
echo "        COMPTES DE TEST YELEBARA - GESTION                     \n";
echo "═══════════════════════════════════════════════════════════════\n\n";

// Afficher les Presseurs
echo "📦 PRESSEURS ENREGISTRÉS:\n";
echo "─────────────────────────────────────────────────────────────\n";
$presseurs = User::where('role', 'presseur')->get();

if ($presseurs->isEmpty()) {
    echo "  ⚠️  Aucun presseur trouvé\n";
} else {
    foreach ($presseurs as $p) {
        echo sprintf(
            "  ID: %d | %s\n  📞 %s\n  📍 Ville: %s | Quartier: %s\n  🟢 En ligne: %s | Status: %s\n",
            $p->id,
            $p->name,
            $p->phone,
            $p->city ?? '❌ MANQUANT',
            $p->quartier ?? '❌ MANQUANT',
            $p->is_online ? 'OUI' : 'NON',
            $p->status
        );
        echo "  ─────────────────────────────────────────────────────────\n";
    }
}

echo "\n";

// Afficher les Clients
echo "👤 CLIENTS ENREGISTRÉS:\n";
echo "─────────────────────────────────────────────────────────────\n";
$clients = User::where('role', 'client')->get();

if ($clients->isEmpty()) {
    echo "  ⚠️  Aucun client trouvé\n";
} else {
    foreach ($clients as $c) {
        echo sprintf(
            "  ID: %d | %s\n  📞 %s\n  📍 Ville: %s | Quartier: %s\n",
            $c->id,
            $c->name,
            $c->phone,
            $c->city ?? '❌ MANQUANT',
            $c->quartier ?? '❌ MANQUANT'
        );
        echo "  ─────────────────────────────────────────────────────────\n";
    }
}

echo "\n═══════════════════════════════════════════════════════════════\n";
echo "💡 ACTIONS RAPIDES:\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

// Proposer de mettre à jour les comptes
echo "Voulez-vous mettre à jour les comptes de test? (o/n): ";
$handle = fopen("php://stdin", "r");
$response = trim(fgets($handle));

if (strtolower($response) === 'o') {
    echo "\n🔧 Mise à jour des comptes...\n\n";

    // Mettre à jour le presseur ID 2
    $presseur = User::find(2);
    if ($presseur) {
        $presseur->update([
            'city' => 'Ouagadougou',
            'quartier' => 'Zone 1',
            'is_online' => true,
            'status' => 'active'
        ]);
        echo "✅ Presseur '{$presseur->name}' (ID: 2) mis à jour:\n";
        echo "   - Ville: Ouagadougou\n";
        echo "   - Quartier: Zone 1\n";
        echo "   - En ligne: OUI\n";
        echo "   - Status: active\n\n";
    }

    // Mettre à jour le presseur ID 5
    $presseur5 = User::find(5);
    if ($presseur5) {
        $presseur5->update([
            'city' => 'Ouagadougou',
            'quartier' => 'Tampouy',
            'is_online' => true,
            'status' => 'active'
        ]);
        echo "✅ Presseur '{$presseur5->name}' (ID: 5) mis à jour:\n";
        echo "   - Ville: Ouagadougou\n";
        echo "   - Quartier: Tampouy\n";
        echo "   - En ligne: OUI\n";
        echo "   - Status: active\n\n";
    }

    // Mettre à jour le client ID 1
    $client = User::find(1);
    if ($client) {
        $client->update([
            'city' => 'Ouagadougou',
            'quartier' => 'Zone 1'
        ]);
        echo "✅ Client '{$client->name}' (ID: 1) mis à jour:\n";
        echo "   - Ville: Ouagadougou\n";
        echo "   - Quartier: Zone 1\n\n";
    }

    // Mettre à jour le client ID 4
    $client4 = User::find(4);
    if ($client4) {
        $client4->update([
            'city' => 'Ouagadougou',
            'quartier' => 'Tampouy'
        ]);
        echo "✅ Client '{$client4->name}' (ID: 4) mis à jour:\n";
        echo "   - Ville: Ouagadougou\n";
        echo "   - Quartier: Tampouy\n\n";
    }

    echo "🎉 Mise à jour terminée!\n";
    echo "Vous pouvez maintenant tester le système d'assignation.\n\n";
}

fclose($handle);

echo "\n═══════════════════════════════════════════════════════════════\n";
echo "📝 POUR CONSULTER LA BASE DE DONNÉES:\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "1. Méthode SQLite (ligne de commande):\n";
echo "   sqlite3 database\\database.sqlite\n";
echo "   SELECT * FROM users;\n\n";
echo "2. Méthode Laravel Tinker:\n";
echo "   php artisan tinker\n";
echo "   >>> User::all();\n\n";
echo "3. Outil Graphique (recommandé):\n";
echo "   - Télécharger 'DB Browser for SQLite'\n";
echo "   - Ouvrir: database\\database.sqlite\n";
echo "═══════════════════════════════════════════════════════════════\n";
