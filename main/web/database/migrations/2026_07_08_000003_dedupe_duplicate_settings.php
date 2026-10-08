<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    /**
     * Run the migrations.
     *
     * Collapses duplicate (name, context) rows in the settings table down to
     * one, keeping the lowest id — the same row createSettingInstance() and
     * findAppSettingWithName() already resolve to, so reads and writes agree.
     */
    public function up(): void
    {
        $duplicates = DB::table('settings')
            ->select('name', 'context')
            ->selectRaw('MIN(id) as keep_id')
            ->groupBy('name', 'context')
            ->havingRaw('COUNT(*) > 1')
            ->get();

        foreach ($duplicates as $duplicate) {
            DB::table('settings')
                ->where('name', $duplicate->name)
                ->where('context', $duplicate->context)
                ->where('id', '!=', $duplicate->keep_id)
                ->delete();
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Not reversible — duplicate rows are intentionally discarded.
    }
};
