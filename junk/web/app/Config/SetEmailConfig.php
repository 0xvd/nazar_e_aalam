<?php

namespace App\Config;

use App\Concerns\InstanceCreator;
use App\Repositories\Setting\SettingRepository;
use App\Services\Setting\EmailSettingService;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Config;

class SetEmailConfig
{
    use InstanceCreator;

    public function clear(): static
    {
        Artisan::call('config:clear');
        return $this;
    }

    public function set(): void
    {
        $mailSettings = resolve(SettingRepository::class)
            ->getDeliverySettingLists([
                optional(resolve(EmailSettingService::class)
                    ->getDefaultSettings('default_mail'))->value,
                'default_mail_email_name'
            ]);



        if ($mailSettings) {
            Config::set('mail.default', $mailSettings['provider']);
            Config::set('mail.from.address', $mailSettings['from_email']);
            Config::set('mail.from.name', $mailSettings['from_name']);

            if ($mailSettings['provider'] == 'smtp') {
                Config::set('mail.mailers.smtp.host', $mailSettings['smtp_host']);
                Config::set('mail.mailers.smtp.port', $mailSettings['smtp_port']);
                Config::set('mail.mailers.smtp.encryption', $mailSettings['encryption_type']);
                Config::set('mail.mailers.smtp.username', $mailSettings['smtp_username']);
                Config::set('mail.mailers.smtp.password', $mailSettings['email_password']);
            }
        }
    }
}
