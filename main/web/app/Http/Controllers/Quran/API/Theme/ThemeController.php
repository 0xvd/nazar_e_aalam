<?php

namespace App\Http\Controllers\Quran\API\Theme;

use App\Http\Controllers\Controller;
use App\Repositories\Setting\SettingRepository;

class ThemeController extends Controller
{
    public function __construct(protected SettingRepository $repository)
    {
    }

    public function index()
    {
        try {
            $presets = config('themes.presets');
            $defaultKey = config('themes.default');

            $setting = $this->repository->findAppSettingWithName('app_theme');
            $activeKey = $setting->value ?? $defaultKey;

            if (!array_key_exists($activeKey, $presets)) {
                $activeKey = $defaultKey;
            }

            $preset = $presets[$activeKey];

            return response()->json([
                'status' => true,
                'message' => 'Theme fetched successfully',
                'data' => [
                    'active_theme' => $activeKey,
                    'name' => $preset['name'],
                    'mode' => $preset['mode'],
                    'colors' => $preset['colors'],
                ],
            ]);
        } catch (\Exception $exception) {
            return response()->json([
                'status' => false,
                'message' => $exception->getMessage(),
                'data' => [],
            ], 500);
        }
    }
}
