<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        try {
            // Aggressively clean up using direct DB calls (hard delete)
            \Illuminate\Support\Facades\DB::table('users')->where('phone', '+22670000000')->delete();
            \Illuminate\Support\Facades\DB::table('users')->where('email', 'admin@yelebara.com')->delete();

            // Create fresh admin user via DB facade to bypass model issues
            \Illuminate\Support\Facades\DB::table('users')->insert([
                'name' => 'Administrateur',
                'phone' => '+22670000000',
                'email' => 'admin@yelebara.com',
                'password' => Hash::make('password'),
                'role' => 'admin',
                'status' => 'active',
                'address1' => 'Siège Yelebara',
                'email_verified_at' => now(),
                'remember_token' => Str::random(10),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $this->command->info('Admin user created successfully.');
            $this->command->info('Login: 70000000');
            $this->command->info('Password: password');
        } catch (\Exception $e) {
            $this->command->error('Error creating admin: ' . $e->getMessage());
        }
    }
}
