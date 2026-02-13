<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

// Client Test User
$client = User::updateOrCreate(
    ['phone' => '70000001'],
    [
        'name' => 'Client Test',
        'email' => 'client@test.com',
        'password' => Hash::make('password'),
        'role' => 'client',
        'is_online' => false,
        'latitude' => 12.3714277,
        'longitude' => -1.5196603,
        'current_order_id' => null,
    ]
);

echo "✓ Client créé: {$client->name} (ID: {$client->id}, Tél: {$client->phone})\n";

// Presseur Test User 1
$presseur1 = User::updateOrCreate(
    ['phone' => '70000002'],
    [
        'name' => 'Presseur Test 1',
        'email' => 'presseur1@test.com',
        'password' => Hash::make('password'),
        'role' => 'presseur',
        'is_online' => true,
        'latitude' => 12.3714277,
        'longitude' => -1.5196603,
        'current_order_id' => null,
        'current_zone' => 'Ouaga 2000',
    ]
);

echo "✓ Presseur 1 créé: {$presseur1->name} (ID: {$presseur1->id}, Tél: {$presseur1->phone}, Online: " . ($presseur1->is_online ? 'Oui' : 'Non') . ")\n";

// Presseur Test User 2
$presseur2 = User::updateOrCreate(
    ['phone' => '70000003'],
    [
        'name' => 'Presseur Test 2',
        'email' => 'presseur2@test.com',
        'password' => Hash::make('password'),
        'role' => 'presseur',
        'is_online' => true,
        'latitude' => 12.3650000,
        'longitude' => -1.5250000,
        'current_order_id' => null,
        'current_zone' => 'Zone du Bois',
    ]
);

echo "✓ Presseur 2 créé: {$presseur2->name} (ID: {$presseur2->id}, Tél: {$presseur2->phone}, Online: " . ($presseur2->is_online ? 'Oui' : 'Non') . ")\n";

echo "\n=== Comptes de test créés ===\n";
echo "Client: 70000001 / password\n";
echo "Presseur 1: 70000002 / password (En ligne, Ouaga 2000)\n";
echo "Presseur 2: 70000003 / password (En ligne, Zone du Bois)\n";
