<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    
    public function up()
{
    Schema::create('presseur_profiles', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->onDelete('cascade');

        $table->string('business_name');
        $table->boolean('is_verified')->default(false);
        
        $table->float('rating')->default(0);
        $table->integer('total_reviews')->default(0);
        $table->integer('total_orders')->default(0);
        $table->decimal('total_revenue', 10, 2)->default(0);

        $table->json('schedule')->nullable(); // horaires de travail

        $table->timestamps();
    });
}


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('presseur_profiles');
    }
};
