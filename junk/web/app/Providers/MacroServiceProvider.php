<?php

namespace App\Providers;

use App\Models\Macro\BelongsToOne;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\ServiceProvider;

class MacroServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        BelongsToMany::macro('toOne', function () {
            return new BelongsToOne(
                $this->related->newQuery(),
                $this->parent,
                $this->table,
                $this->foreignPivotKey,
                $this->relatedPivotKey,
                $this->parentKey,
                $this->relatedKey,
                $this->relationName
            );
        });
    }
}
