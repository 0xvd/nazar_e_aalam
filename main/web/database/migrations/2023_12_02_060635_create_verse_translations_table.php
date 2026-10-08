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
        Schema::create('verse_translations', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(\App\Models\Quran\Chapter\Chapter::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(\App\Models\Quran\Chapter\ChapterDetail::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(\App\Models\Quran\Translator\Translator::class)->constrained()->cascadeOnDelete();
            $table->integer('verse_number');
            $table->text('translate_name');
            $table->timestamps();
            $table->index(['chapter_id', 'translator_id', 'verse_number'], 'verse_translation_index');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('verse_translations');
    }
};
