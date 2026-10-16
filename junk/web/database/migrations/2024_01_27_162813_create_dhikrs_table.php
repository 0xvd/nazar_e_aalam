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
        Schema::create('dhikrs', function (Blueprint $table) {
            $table->id();
            $table->integer('position')->nullable();
            $table->string('en_short_name')->nullable();
            $table->longText('en_full_name')->nullable();
            $table->string('ar_short_name')->nullable();
            $table->longText('ar_full_name')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('dhikrs');
    }
};
