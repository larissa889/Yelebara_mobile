<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('ensure:admin', function () {
    $this->info("Checking for admin user...");

    // Check conflicts
    $conflicts = \App\Models\User::withTrashed()
        ->where('phone', '+22670000000')
        ->orWhere('email', 'admin@yelebara.com')
        ->get();

    if ($conflicts->count() > 0) {
        $this->warn("Found {$conflicts->count()} conflicting users.");
        foreach ($conflicts as $u) {
            $this->line(" - Deleting user ID: {$u->id}, Phone: {$u->phone}, Email: {$u->email}");
            $u->forceDelete();
        }
        $this->info("Conflicts deleted.");
    } else {
        $this->info("No conflicts found.");
    }

    // Create new admin
    try {
        $user = \App\Models\User::create([
            'name' => 'Administrateur',
            'phone' => '+22670000000',
            'email' => 'admin@yelebara.com',
            'password' => \Illuminate\Support\Facades\Hash::make('password'),
            'role' => 'admin',
            'status' => 'active',
            'address1' => 'Siège Yelebara',
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->info("----------------------------------------");
        $this->info("SUCCESS! Admin user created.");
        $this->info("ID: " . $user->id);
        $this->info("Phone: " . $user->phone);
        $this->info("Password: password");
        $this->info("Role: " . $user->role);
        $this->info("----------------------------------------");
    } catch (\Exception $e) {
        $this->error("FAILED to create admin: " . $e->getMessage());
    }
})->purpose('Force create admin user');
