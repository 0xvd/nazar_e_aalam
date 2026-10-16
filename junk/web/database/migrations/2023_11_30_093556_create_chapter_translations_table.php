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
        Schema::create('chapter_translations', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(\App\Models\Quran\Chapter\Chapter::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(\App\Models\Quran\Translator\Translator::class)->constrained()->cascadeOnDelete();
            $table->string('translate_name');
            $table->timestamps();

            $table->index(['chapter_id', 'translator_id', 'translate_name'], 'chapter_translation_index');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('chapter_translations');
    }
};
