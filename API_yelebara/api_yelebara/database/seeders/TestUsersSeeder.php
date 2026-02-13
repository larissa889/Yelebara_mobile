<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class TestUsersSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Client Test User
        User::updateOrCreate(
            ['phone' => '70000001'],
            [
                'name' => 'Client Test',
                'email' => 'client@test.com',
                'password' => Hash::make('password'),
                'role' => 'client',
                'is_online' => false,
                'latitude' => 12.3714277, // Ouagadougou
                'longitude' => -1.5196603,
                'current_order_id' => null,
            ]
        );

        // Presseur Test User 1
        User::updateOrCreate(
            ['phone' => '70000002'],
            [
                'name' => 'Presseur Test 1',
                'email' => 'presseur1@test.com',
                'password' => Hash::make('password'),
                'role' => 'presseur',
                'is_online' => true,
                'latitude' => 12.3714277, // Ouagadougou - same location
                'longitude' => -1.5196603,
                'current_order_id' => null,
                'current_zone' => 'Ouaga 2000',
            ]
        );

        // Presseur Test User 2
        User::updateOrCreate(
            ['phone' => '70000003'],
            [
                'name' => 'Presseur Test 2',
                'email' => 'presseur2@test.com',
                'password' => Hash::make('password'),
                'role' => 'presseur',
                'is_online' => true,
                'latitude' => 12.3650000, // Slightly different location (nearby)
                'longitude' => -1.5250000,
                'current_order_id' => null,
                'current_zone' => 'Zone du Bois',
            ]
        );

        $this->command->info('Test users created/updated successfully!');
        $this->command->info('Client: 70000001 / password');
        $this->command->info('Presseur 1: 70000002 / password');
        $this->command->info('Presseur 2: 70000003 / password');
    }
}
