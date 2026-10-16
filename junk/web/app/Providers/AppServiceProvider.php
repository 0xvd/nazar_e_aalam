<?php

namespace App\Providers;

use App\Config\SetEmailConfig;
use App\Services\Setting\SettingService;
use Exception;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Paginator::useBootstrap();

        try {
            $settings = resolve(SettingService::class)->getFormattedSettings('app');
            View::composer('*', function ($view) use ($settings) {
                $view->with('settings', $settings);
            });

            foreach ($settings as $key => $setting) {
                if ($key == 'company_name') {
                    config()->set('app.name', $setting);
                }
                config()->set('settings.application.' . $key, $setting);
            }
        } catch (Exception $exception) {
        }


        try {
            SetEmailConfig::new(true)
                ->clear()
                ->set();
        } catch (Exception $exception) {
        }

    }
}
