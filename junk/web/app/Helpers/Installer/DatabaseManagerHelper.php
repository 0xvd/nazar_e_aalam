<?php

namespace App\Helpers\Installer;

use App\Exceptions\GeneralException;
use Database\Seeders\InstallSeeder;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Psr\Container\ContainerExceptionInterface;
use Psr\Container\NotFoundExceptionInterface;

class DatabaseManagerHelper
{
    /**
     * @throws ContainerExceptionInterface
     * @throws NotFoundExceptionInterface
     * @throws GeneralException
     */
    public function setDatabaseConfig(): void
    {
        config()->set('database.default', request()->get('database_connection'));
        config()->set('database.connections.' . request()->get('database_connection') . '.host', request()->database_hostname);
        config()->set('database.connections.' . request()->get('database_connection') . '.port', request()->database_port);
        config()->set('database.connections.' . request()->get('database_connection') . '.database', request()->database_name);
        config()->set('database.connections.' . request()->get('database_connection') . '.username', request()->database_username);
        config()->set('database.connections.' . request()->get('database_connection') . '.password', request()->database_password);

        DB::purge(request()->get('database_connection'));

        DB::reconnect(request()->get('database_connection'));

        try {
            DB::connection()->getPdo();
        } catch (\Exception $e) {
            throw new GeneralException('Database credential error');
        }

    }

    public function copyEnv(): bool
    {
        if (!file_exists($this->getEnvPath())) {
            return copy(base_path('.env.example'), $this->getEnvPath());
        }
        return true;
    }

    public function saveFileWizard(Request $request): bool|int
    {

        $envFileData =
            'APP_NAME=\'' . $request->get('app_name') . "'\n" .
            'APP_ENV=' . $request->get('environment', 'production') . "\n" .
            'APP_KEY=' . 'base64:' . base64_encode(Str::random(32)) . "\n" .
            'APP_DEBUG=' . $request->get('app_debug', 'true') . "\n" .
            'APP_URL=' . $request->get('app_url', 'http://corevue3.test') . "\n\n" .
            'APP_LOCALE=' . $request->get('app_locale', 'en') . "\n" .
            'APP_FALLBACK_LOCALE=' . $request->get('app_locale', 'en') . "\n" .
            'APP_LOCALE_PHP=' . $request->get('app_locale_php', 'en_US') . "\n" .
            'APP_TIMEZONE=' . $request->get('app_timezone', 'UTC') . "\n" .
            'LOG_CHANNEL=' . $request->get('log_channel', 'daily') . "\n\n" .
            'TELESCOPE_ENABLED=' . 'false' . "\n\n" .
            'APP_INSTALLED=false' . "\n" .
            'IS_DEMO_VERSION=false' . "\n" .
            'PURCHASE_CODE=' . $request->get('purchase_code') . "\n" .
            'DB_CONNECTION=' . $request->get('database_connection') . "\n" .
            'DB_HOST=' . $request->get('database_hostname') . "\n" .
            'DB_PORT=' . $request->get('database_port') . "\n" .
            'DB_DATABASE=' . $request->get('database_name') . "\n" .
            'DB_USERNAME=' . $request->get('database_username') . "\n" .
            'DB_PASSWORD=' . $request->get('database_password') . "\n\n" .
            'BROADCAST_DRIVER=' . $request->get('broadcast_driver', 'log') . "\n" .
            'CACHE_DRIVER=' . $request->get('cache_driver', 'file') . "\n" .
            'FILESYSTEM_DISK=' . 'public' . "\n" .
            'QUEUE_CONNECTION=' . $request->get('queue_connection', 'sync') . "\n" .
            'SESSION_DRIVER=' . $request->get('session_driver', 'cookie') . "\n" .
            'SESSION_LIFETIME=' . $request->get('session_lifetime', '120') . "\n" .
            'SESSION_ENCRYPT=' . $request->get('session_encrypt', 'false') . "\n\n" .
            'REDIS_HOST=' . $request->get('redis_hostname', '127.0.0.1') . "\n" .
            'REDIS_PASSWORD=' . $request->get('redis_password', 'null') . "\n" .
            'REDIS_PORT=' . $request->get('redis_port', '6379') . "\n\n";

        if ($this->copyEnv()) {
            return file_put_contents($this->getEnvPath(), $envFileData);
        }

        return true;
    }

    public function setEnvironmentValue($envKey, $envValue): bool
    {
        list($fileContents, $foundValue) = $this->serEnvFileContent($envKey);

        // Handle boolean values
        if (gettype($foundValue) == 'boolean') {
            $foundValue = $foundValue ? 'true' : 'false';
        }

        // Replace the old value with the new value in the file contents
        $updatedContents = str_replace(
            "$envKey=$foundValue",
            "$envKey=$envValue",
            $fileContents
        );

        file_put_contents($this->getEnvPath(), $updatedContents);

        return true;
    }

    public function setEnvironmentValueSet($envKey, $envValue): bool
    {
        list($fileContents, $foundValue) = $this->serEnvFileContent($envKey);

        // Handle boolean values
        if (gettype($foundValue) == 'boolean') {
            $foundValue = $foundValue ? 'false' : 'true';
        }

        // Replace the old value with the new value in the file contents
        $updatedContents = str_replace(
            "$envKey=$foundValue",
            "$envKey=$envValue",
            $fileContents
        );

        file_put_contents($this->getEnvPath(), $updatedContents);

        return true;
    }


    public function getEnvPath(): string
    {
        return base_path('.env');
    }


    public function migration(): bool
    {
        Artisan::call('migrate:fresh', ['--force' => true]);

        return true;
    }

    public function seed(): bool
    {

        Artisan::call('db:seed', [
            '--class' => InstallSeeder::class,
            '--force' => true
        ]);


        return true;
    }

    /**
     * @param $envKey
     * @return array
     */
    public function serEnvFileContent($envKey): array
    {
        $fileContents = file_get_contents($this->getEnvPath());

        // Initialize tokenization with the string and delimiter
        $value = strtok($fileContents, "\n");
        $foundValue = '';

        // Iterate over the tokens to find the line containing the $envKey
        while ($value !== false) {
            if (str_starts_with($value, "$envKey=")) {
                $foundValue = substr($value, strlen("$envKey="));
                break;
            }
            $value = strtok("\n");
        }
        return array($fileContents, $foundValue);
    }
}
