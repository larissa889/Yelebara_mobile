<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Client de test
        User::updateOrCreate(
            ['email' => 'client@test.com'],
            [
                'name' => 'Client Test',
                'phone' => '+22670000001', // Numéro valide commençant par 7
                'password' => bcrypt('password'),
                'role' => 'client',
                'status' => 'active',
            ]
        );

        // 2. Presseur de test (disponible et proche de Tanghin)
        User::updateOrCreate(
            ['email' => 'presseur@test.com'],
            [
                'name' => 'Presseur Test',
                'phone' => '+22670000002', // Numéro valide commençant par 7
                'password' => bcrypt('password'),
                'role' => 'presseur',
                'status' => 'active',
                'is_online' => true,
                'current_order_id' => null,
                'latitude' => 12.3957, // Lat approximative de Tanghin/Ouaga
                'longitude' => -1.5003, // Long approximative de Tanghin/Ouaga
            ]
        );
    }
}
