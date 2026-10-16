<?php

namespace App\Http\Controllers\Quran\API\HomeLayout;

use App\Http\Controllers\Controller;
use App\Repositories\Setting\SettingRepository;

class HomeLayoutController extends Controller
{
    public function __construct(protected SettingRepository $repository)
    {
    }

    public function index()
    {
        try {
            $presets = config('home_layouts.presets');
            $defaultKey = config('home_layouts.default');

            $setting = $this->repository->findAppSettingWithName('home_layout');
            $activeKey = $setting->value ?? $defaultKey;

            if (!array_key_exists($activeKey, $presets)) {
                $activeKey = $defaultKey;
            }

            $preset = $presets[$activeKey];

            return response()->json([
                'status' => true,
                'message' => 'Home layout fetched successfully',
                'data' => [
                    'active_layout' => $activeKey,
                    'name' => $preset['name'],
                    'sections' => $preset['sections'],
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
