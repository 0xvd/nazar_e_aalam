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
        Schema::create('bulk_sura_imports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reciter_id')->constrained()->cascadeOnDelete();
            $table->string('zip_path')->nullable();
            $table->string('original_name')->nullable();
            $table->boolean('replace_existing')->default(false);

            // Lifecycle: queued -> extracting -> processing -> completed | failed
            $table->string('status')->default('queued');
            $table->string('current_file')->nullable();

            $table->unsignedInteger('total_files')->default(0);
            $table->unsignedInteger('processed')->default(0);
            $table->unsignedInteger('success_count')->default(0);
            $table->unsignedInteger('failed_count')->default(0);
            $table->unsignedInteger('skipped_count')->default(0);

            $table->text('message')->nullable();
            $table->json('error_log')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bulk_sura_imports');
    }
};
