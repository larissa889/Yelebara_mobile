<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('service_title');
            $table->string('service_price');
            $table->decimal('amount', 10, 2);
            $table->dateTime('date'); // Date + heure
            $table->string('time_slot')->nullable(); // Heure textuelle "14:00"
            $table->boolean('pickup_at_home')->default(true);
            $table->text('instructions')->nullable();
            $table->string('status')->default('pending'); // pending, assigned, processing, completed, cancelled
            $table->string('service_icon_code')->nullable(); // For Mobile UI
            $table->string('service_color_code')->nullable(); // For Mobile UI
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
