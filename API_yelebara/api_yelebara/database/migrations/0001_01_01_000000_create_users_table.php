<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone')->unique();
            $table->string('phone2')->nullable();
            $table->string('password');
            $table->enum('role', ['client', 'presseur', 'admin'])->default('client');
            $table->enum('status', ['active', 'pending', 'rejected', 'suspended'])->default('active');
            $table->string('photo_url')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
