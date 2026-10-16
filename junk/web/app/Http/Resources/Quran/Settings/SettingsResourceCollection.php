<?php

namespace App\Http\Resources\Quran\Settings;

use Illuminate\Contracts\Encryption\DecryptException;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\ResourceCollection;

class SettingsResourceCollection extends ResourceCollection
{
    public function toArray(Request $request): array
    {
        return [
            'mosque_name' => $this->resource['company_name'],
            'mosque_address' => $this->resource['address'],
            'app_logo' => url($this->resource['app_logo']),
            'donation_banner' => url($this->resource['donation_banner']),
            'google_map_key' => $this->safeDecrypt($this->resource['google_map_key']),
            'islamic_name_api_key' => $this->safeDecrypt($this->resource['islamic_name_api_key']),
            'zakat_nisab' => floatval($this->resource['zakat_nisab']),
            'show_donation_banner' => $this->resource['show_donation_banner'] == 1,
            'show_donation_icon' => $this->resource['show_donation_icon'] == 1,
            'ramadan_schedule' => $this->resource['ramadan_schedule'] == 1,
            'currency_symbol' => $this->resource['currency_symbol'],
            'play_store_url' => $this->resource['play_store_url'] ?? null,
            'app_store_url' => $this->resource['app_store_url'] ?? null,
            'zakat_description' => $this->resource['zakat_description'],
            'haram_description' => $this->resource['haram_description'],
            'app_theme' => $this->resource['app_theme'] ?? config('themes.default'),
            'home_layout' => $this->resource['home_layout'] ?? config('home_layouts.default'),
        ];
    }


    protected function safeDecrypt($value)
    {
        try {
            return decrypt($value);
        } catch (DecryptException $e) {
            return $value;
        }
    }

}
