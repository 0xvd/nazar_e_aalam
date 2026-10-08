<?php

namespace App\Http\Controllers;
 
use Illuminate\Support\Facades\Artisan; 

class InstallDemoDataController extends Controller
{

    public function run()
    {
        if (env('INSTALL_DEMO_DATA')) {

            config()->set('database.connections.mysql.strict', false);
            define('STDIN', fopen("php://stdin", "r"));

            Artisan::call('optimize:clear');

            Artisan::call('clear-compiled');
            Artisan::call('view:clear');

            Artisan::call('config:clear');
            Artisan::call('cache:clear');

            Artisan::call('migrate:fresh --seed --force');

            Artisan::call('queue:restart');

            config()->set('database.connections.mysql.strict', true);

            $this->symlink();
        }

        return true;
    }

    public function symlink()
    {
        return Artisan::call('storage:link');
        // $target = storage_path("app/public");
        // $explode_base_path = explode(DIRECTORY_SEPARATOR, base_path());
        // array_pop($explode_base_path);
        // array_push($explode_base_path, 'storage');
        // $path = implode(DIRECTORY_SEPARATOR, $explode_base_path);
        // symlink($target, $path);
        // return true;
    }


}
