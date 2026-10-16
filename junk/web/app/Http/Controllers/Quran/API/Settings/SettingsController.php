<?php

namespace App\Http\Controllers\Quran\API\Settings;

use App\Http\Controllers\Controller;
use App\Http\Resources\Quran\Settings\SettingsResourceCollection;
use App\Models\Quran\DeviceInfo\DeviceInfo;
use App\Services\Setting\SettingService;
use Illuminate\Http\Request;
use Jenssegers\Agent\Facades\Agent;
use Stevebauman\Location\Facades\Location;

class SettingsController extends Controller
{
    public function __construct(SettingService $service)
    {
        $this->service = $service;
    }

    public function index(Request $request)
    {
        try {
            // Get IP address from your source (you mentioned $position)
            $ipAddress = request()->ip();
            $this->getDeviceInfo($ipAddress);

            $data = $this->service->getFormattedSettings();

            return response()->json([
                'status' => true,
                'message' => 'Data fetched successfully',
                'data' => new SettingsResourceCollection($data)
            ]);

        } catch (\Exception $exception) {
            return response()->json([
                'status' => false,
                'message' => $exception->getMessage(),
                'data' => [],
            ], 500);
        }
    }

    public function getDeviceInfo($ipAddress)
    {
        $newIp = env('IS_DEMO_VERSION') ? '103.161.68.149' : $ipAddress;
        // Get device and country information
        $position = Location::get($newIp);

        // Access the device name and country name
        $osType = Agent::platform() == 0 ? 'Android' : Agent::platform();

        // Check if there is a record with the same OS and IP address
        $existingDeviceInfo = DeviceInfo::where('os', $osType)
            ->where('ip_address', $ipAddress)
            ->first();



        // Update or create the record in the DeviceInfo table
        if (!$existingDeviceInfo) {
            DeviceInfo::updateOrCreate(
                ['ip_address' => $ipAddress, 'os' => $osType],
                [
                    'os' => $osType,
                    'country' => $position ? $position->countryName : null,
                    'state' => $position ? $position->cityName : null,
                    'latitude' => $position ? $position->latitude : null,
                    'longitude' => $position ? $position->longitude: null,
                    'count' => 1, // Set count to 1 for new records
                ]
            );
        } else {
            // Update the existing record if IP and OS are different
            if ($existingDeviceInfo->ip_address != $ipAddress || $existingDeviceInfo->os != $osType) {
                $existingDeviceInfo->update([
                    'country' => $position->countryName,
                    'state' => $position->cityName,
                    'latitude' => $position->latitude,
                    'longitude' => $position->longitude,
                    'count' => $existingDeviceInfo->count + 1, // Increment count
                ]);
            }
        }
        return $this;
    }


}
