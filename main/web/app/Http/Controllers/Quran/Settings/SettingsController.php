<?php

namespace App\Http\Controllers\Quran\Settings;

use App\Http\Controllers\Controller;
use App\Services\Setting\SettingService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class SettingsController extends Controller
{
    public function __construct(SettingService $service)
    {
        $this->service = $service;
    }

    public function index()
    {
        $data = $this->service->getFormattedSettings();
        $values = [];
        foreach ($data as $key => $value) {
            if ($key === 'google_map_key' || $key === 'islamic_name_api_key') {
                $values[$key] = encrypt($value);
            } else {
                $values[$key] = $value;
            }
        }

        return $values;
    }

    public function update(Request $request)
    {
        $request->validate([
            'company_name' => ['required', 'string'],
            'play_store_url' => 'nullable|url:https',
            'app_store_url' => 'nullable|url:https',
            'address' => ['required', 'string', 'max:50'],
            'app_theme' => ['nullable', 'string', Rule::in(array_keys(config('themes.presets')))],
            'theme_use_custom' => ['nullable', Rule::in(['0', '1', 0, 1])],
            'theme_c_mode' => ['nullable', Rule::in(['', 'light', 'dark'])],
            'theme_c_primary' => ['nullable', 'string', 'regex:/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/'],
            'theme_c_secondary' => ['nullable', 'string', 'regex:/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/'],
            'theme_c_accent' => ['nullable', 'string', 'regex:/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/'],
            'theme_c_background' => ['nullable', 'string', 'regex:/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/'],
            'theme_c_surface' => ['nullable', 'string', 'regex:/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/'],
            'theme_c_text_primary' => ['nullable', 'string', 'regex:/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/'],
            'theme_c_text_secondary' => ['nullable', 'string', 'regex:/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/'],
            'theme_c_error' => ['nullable', 'string', 'regex:/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/'],
        ]);


        $this->service->update();

        return response()->json([
            'success' => true,
            'message' => 'Settings updated successfully',
        ]);
    }

    public function themePresets()
    {
        return response()->json(config('themes.presets'));
    }

    public function privacySupportUpdate(Request $request)
    {

        $this->service->update();

        return response()->json([
            'success' => true,
            'message' => 'Information updated successfully',
        ]);
    }

    public function homeLayoutUpdate(Request $request)
    {
        $request->validate([
            'home_layout' => ['required', 'string', Rule::in(array_keys(config('home_layouts.presets')))],
        ]);

        $this->service->update();

        return response()->json([
            'success' => true,
            'message' => 'Home screen layout updated successfully',
        ]);
    }

    public function homeLayoutPresets()
    {
        return response()->json(config('home_layouts.presets'));
    }

}
