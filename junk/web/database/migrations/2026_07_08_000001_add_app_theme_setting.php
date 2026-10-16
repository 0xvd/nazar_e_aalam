<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $exists = DB::table('settings')
            ->where('name', 'app_theme')
            ->where('context', 'app')
            ->exists();

        if (!$exists) {
            DB::table('settings')->insert([
                'name' => 'app_theme',
                'value' => config('themes.default', 'emerald'),
                'context' => 'app',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('settings')
            ->where('name', 'app_theme')
            ->where('context', 'app')
            ->delete();
    }
};
