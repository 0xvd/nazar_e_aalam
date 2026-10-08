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
            ->where('name', 'home_layout')
            ->where('context', 'app')
            ->exists();

        if (!$exists) {
            DB::table('settings')->insert([
                'name' => 'home_layout',
                'value' => config('home_layouts.default', 'modern'),
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
            ->where('name', 'home_layout')
            ->where('context', 'app')
            ->delete();
    }
};
