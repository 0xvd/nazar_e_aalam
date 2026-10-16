<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('permission_role', function (Blueprint $table) {
            $table->foreignIdFor(App\Models\Quran\Role\Role::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(\App\Models\Quran\Permission\Permission::class)->constrained()->cascadeOnDelete();
            $table->primary(['permission_id', 'role_id']);
            $table->index(['role_id', 'permission_id'], 'role_permission_index');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('permission_role');
    }
};
