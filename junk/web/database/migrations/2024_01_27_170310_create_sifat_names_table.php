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
        Schema::create('sifat_names', function (Blueprint $table) {
            $table->id();
            $table->integer('position')->nullable();
            $table->string('name')->nullable();
            $table->string('ar_name')->nullable();
            $table->text('translated_name')->nullable();
            $table->text('meaning')->nullable();
            $table->text('name_benefits')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sifat_names');
    }
};
