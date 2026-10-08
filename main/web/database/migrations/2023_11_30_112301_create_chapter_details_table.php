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
        Schema::create('chapter_details', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(\App\Models\Quran\Chapter\Chapter::class)->constrained()->cascadeOnDelete();
            $table->text('arabic_name');
            $table->text('english_transliteration')->nullable();
            $table->integer('verse_number');
            $table->string('verse_key', 10);
            $table->integer('hizb_number');
            $table->integer('rub_el_hizb_number');
            $table->integer('ruku_number');
            $table->integer('manzil_number');
            $table->integer('sajdah_number');
            $table->integer('page_number');
            $table->integer('juz_number');
            $table->timestamps();

            $table->index(['chapter_id', 'verse_number', 'page_number', 'juz_number'], 'chapter_detail_index');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('chapter_details');
    }
};
