<?php

namespace App\Services\Installer;

use App\Repositories\Setting\SettingRepository;
use App\Services\BaseService;

class EmailSettingService extends BaseService
{
    public function update($key, $value, $context = null): void
    {
        $setting = resolve(SettingRepository::class)
            ->createSettingInstance($key, $context);


        $setting->fill([
            'name' => $key,
            'value' => encrypt($value),
            'context' => $context,
        ]);

        $setting->save();

    }

    public function setDefaultSettings($key, $value,  $context='mail')
    {
        $setting = resolve(SettingRepository::class)
            ->createSettingInstance($key, $context);

        $setting->fill([
            'name' => $key,
            'value' => $value,
            'context' => $context,
        ]);

        return $setting->save();
    }

    public function getFormattedDeliverySettings($context)
    {
        return resolve(SettingRepository::class)->getDeliverySettingLists(
            $context
        );
    }

    public function getDefaultSettings($key = 'default_mail')
    {
        return resolve(SettingRepository::class)
            ->getDefaultMailKey($key);
    }

    public function getDefaultSmsSettings($key = 'default_sms')
    {
        return resolve(SettingRepository::class)
            ->getDefaultSmsKey($key);
    }
}
