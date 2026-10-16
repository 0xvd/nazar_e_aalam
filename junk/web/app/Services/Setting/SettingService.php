<?php

namespace App\Services\Setting;


use App\Concerns\FileHandler;
use App\Repositories\Setting\SettingRepository;
use App\Services\BaseService;

class SettingService extends BaseService
{
    use FileHandler;

    public function update(): \Illuminate\Support\Collection
    {
        $settings = request()->except('allowed_resource', 'permissions', '_token');

        return collect(array_keys($settings))->map(function ($key) use ($settings) {

            $setting = resolve(SettingRepository::class)
                ->createSettingInstance($key, 'app');

            if (request()->file($key)) {
                $this->deleteImage(optional($setting)->value);
                $settings[$key] = $this->uploadImage(request()
                    ->file($key), 'setting');
            }

            $this->setModel($setting);


                if (request()->has('google_map_key') && !request()->has('is_typed_g_map')) {
                $settings['google_map_key'] = decrypt($settings['google_map_key']);
            }

            if (request()->has('is_typed_g_map')) {
                $settings['google_map_key'] = encrypt($settings[$key]);
            }

            if (request()->has('islamic_name_api_key') && !request()->has('is_typed_islamic_name')) {
                $settings['islamic_name_api_key'] = decrypt($settings['islamic_name_api_key']);
            }

            if (request()->has('is_typed_islamic_name')) {
                $settings['islamic_name_api_key'] = encrypt($settings[$key]);
            }

            return parent::save([
                'name' => $key,
                'value' => $settings[$key],
                'context' => 'app'
            ]);
        });
    }

    public function getFormattedSettings($context = 'app')
    {
        return resolve(SettingRepository::class)
            ->getFormattedSettings($context);
    }

    public function getCachedFormattedSettings()
    {
        return resolve(SettingRepository::class)
            ->getFormattedSettings('app');
    }

    public function setDefaultSettings($key, $value, $context = 'mail', $settingable_type = null, $settingable_id = null)
    {
        $setting = resolve(SettingRepository::class)
            ->createSettingInstance($key, $context, $settingable_type, $settingable_id);

        $setting->fill([
            'name' => $key,
            'value' => $value,
            'context' => $context,
            'settingable_type' => $settingable_type,
            'settingable_id' => $settingable_id
        ]);

        return $setting->save();
    }
}
