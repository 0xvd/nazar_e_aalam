<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reciter_suras', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reciter_id')->constrained()->cascadeOnDelete();
            $table->string('name', 100);
            $table->integer('number');
            $table->integer('duration')->nullable();
            $table->enum('revealed_place', ['Makka', 'Madina']);
            $table->string('path');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reciter_suras');
    }
};
