<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('donations', function (Blueprint $table) {
            $table->dropForeign(['payment_method_id']);
            $table->unsignedBigInteger('payment_method_id')->nullable()->change();
            $table->foreign('payment_method_id')
                  ->references('id')->on('payment_methods')
                  ->nullOnDelete();

            $table->string('payment_gateway', 50)->nullable()->after('payment_method_id');
            $table->string('status', 20)->default('pending')->after('payment_gateway');
            $table->string('name', 100)->nullable()->after('email');
            $table->string('currency', 10)->default('USD')->after('name');
        });
    }

    public function down(): void
    {
        Schema::table('donations', function (Blueprint $table) {
            $table->dropForeign(['payment_method_id']);
            $table->unsignedBigInteger('payment_method_id')->nullable(false)->change();
            $table->foreign('payment_method_id')->references('id')->on('payment_methods');

            $table->dropColumn(['payment_gateway', 'status', 'name', 'currency']);
        });
    }
};
