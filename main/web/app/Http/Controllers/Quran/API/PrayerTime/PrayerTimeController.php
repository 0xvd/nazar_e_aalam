<?php

namespace App\Http\Controllers\Quran\API\PrayerTime;

use App\Http\Controllers\Controller;
use App\Models\Quran\Prayer\PrayerTime;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Vendor\PrayerTimes\PrayerTimes;

class PrayerTimeController extends Controller
{
    /**
     * Retrieve the columns used for prayer times.
     *
     * @return array
     */
    public function columns()
    {
        return [
            'date',
            'imsak',
            'sunrise',
            'fajr_start',
            'zuhr_start',
            'asr_start',
            'maghrib_start',
            'isha_start',
        ];
    }


    public function getPrayerTime(Request $request)
    {
        $request->validate([
            'type' => 'required|in:manual,automatic',
        ]);

        switch ($request->type) {
            case 'manual':
                return $this->getManualPrayerTime($request);
            case 'automatic':
                return $this->getAutomaticPrayerTime($request);
            default:
                return response()->json([
                    'status' => false,
                    'message' => 'Invalid request type',
                    'data' => $this->defaultPrayerTimeResponse(),
                ]);
        }
    }

    /**
     * Fetch prayer time data manually based on the date and city.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getManualPrayerTime(Request $request)
    {
        $request->validate([
            'date' => 'required|date:Y-m-d',
            'city' => 'required|string',
        ]);

        try {
            $data = PrayerTime::query()
                ->where('date', $request->get('date'))
                ->where('city', $request->get('city'))
                ->select($this->columns())
                ->first();

            $data['is_jumma'] = date('l', strtotime($request->get('date'))) === 'Friday';
            $this->fillDefaultPrayerTimeValues($data);

            return response()->json([
                'status' => true,
                'message' => 'Manual prayer time data retrieved successfully.',
                'data' => $data,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Data not found.',
                'data' => $this->defaultPrayerTimeResponse(),
            ]);
        }
    }

    /**
     * Fetch automatic prayer times based on location and calculation methods.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    // public function getAutomaticPrayerTime(Request $request)
    // {
    //     $request->validate([
    //         'lat' => 'required|numeric',
    //         'lng' => 'required|numeric',
    //         'prayer_method' => 'required|in:0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,99',
    //         'school' => 'required|in:HANAFI,STANDARD',
    //         'timezone' => 'required|string',
    //         'date' => 'required|date:Y-m-d',
    //     ]);

    //     try {
    //         $prayerTimes = new PrayerTimes($request->prayer_method, $request->school);
    //         $times = $prayerTimes->getTimesForToday(
    //             $request->date,
    //             $request->lat,
    //             $request->lng,
    //             $request->timezone
    //         );

    //         $data = [
    //             'date' => Carbon::parse($request->date)->format('Y-m-d'),
    //             'is_jumma' => date('l', strtotime($request->get('date'))) === 'Friday',
    //             'imsak' => $times['Imsak'],
    //             'fajr_start' => $times['Fajr'],
    //             'sunrise' => $times['Sunrise'],
    //             'zuhr_start' => $times['Dhuhr'],
    //             'asr_start' => $times['Asr'],
    //             'maghrib_start' => $times['Maghrib'],
    //             'isha_start' => $times['Isha'],
    //             'sehri' => $times['Sehri'],
    //             'iftar' => $times['Iftar']
    //         ];

    //         return response()->json([
    //             'status' => true,
    //             'message' => 'Automatic prayer time data retrieved successfully.',
    //             'data' => $data,
    //         ]);
    //     } catch (\Exception $e) {
    //         return response()->json([
    //             'status' => false,
    //             'message' => 'Failed to fetch prayer times.',
    //             'data' => $this->defaultPrayerTimeResponse(),
    //         ]);
    //     }
    // }

    public function getAutomaticPrayerTime(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'prayer_method' => 'required|in:0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,99',
            'school' => 'required|in:HANAFI,STANDARD',
            'timezone' => 'required|string',
            'date' => 'required|date:Y-m-d',
        ]);

        $start = microtime(true);

        try {
            $prayerTimes = new PrayerTimes(
                $request->prayer_method,
                $request->school
            );

            $afterInit = microtime(true);

            $times = $prayerTimes->getTimesForToday(
                $request->date,
                $request->lat,
                $request->lng,
                $request->timezone
            );

            $afterCalculation = microtime(true);

            $data = [
                'date' => Carbon::parse($request->date)->format('Y-m-d'),
                'is_jumma' => date('l', strtotime($request->date)) === 'Friday',
                'imsak' => $times['Imsak'],
                'fajr_start' => $times['Fajr'],
                'sunrise' => $times['Sunrise'],
                'zuhr_start' => $times['Dhuhr'],
                'asr_start' => $times['Asr'],
                'maghrib_start' => $times['Maghrib'],
                'isha_start' => $times['Isha'],
                'sehri' => $times['Sehri'],
                'iftar' => $times['Iftar'],
            ];

            $response = response()->json([
                'status' => true,
                'message' => 'Automatic prayer time data retrieved successfully.',
                'data' => $data,
            ]);

            logger()->info('Prayer calculation timing', [
                'total_ms' => round((microtime(true) - $start) * 1000, 2),
                'constructor_ms' => round(($afterInit - $start) * 1000, 2),
                'calculation_ms' => round(($afterCalculation - $afterInit) * 1000, 2),
            ]);

            return $response;

        } catch (\Throwable $e) {

            logger()->error('Prayer calculation failed', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);

            return response()->json([
                'status' => false,
                'message' => 'Failed to fetch prayer times.',
                'data' => $this->defaultPrayerTimeResponse(),
            ]);
        }
    }

    /**
     * Provide default prayer time values.
     *
     * @return array
     */
    private function defaultPrayerTimeResponse(): array
    {
        return [
            'date' => '',
            'imsak' => '0:00',
            'fajr_start' => '0:00',
            'sunrise' => '0:00',
            'zuhr_start' => '0:00',
            'asr_start' => '0:00',
            'maghrib_start' => '0:00',
            'isha_start' => '0:00',
        ];
    }

    /**
     * Fill default values for nullable prayer time fields.
     *
     * @param array $data
     */
    private function fillDefaultPrayerTimeValues($data)
    {
        $fields = ['date', 'imsak', 'sunrise', 'fajr_start', 'zuhr_start', 'asr_start', 'maghrib_start', 'isha_start', 'sehri', 'iftar'];
        foreach ($fields as $field) {
            $data[$field] = $data[$field] ?? '0:00';
        }
        return $this;
    }

    public function prayerByLocation(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'timezone' => 'required|string',
        ]);

        $lat = $request->lat;
        $lng = $request->lng;
        $timezone = $request->timezone;
        $date = now($timezone)->format('Y-m-d');

        // Reverse geocode to get city name
        $city = 'Your Location';
        try {
            $geo = Http::timeout(5)
                ->withHeaders(['User-Agent' => 'ZabiApp/1.0 (contact@zabi.app)'])
                ->get('https://nominatim.openstreetmap.org/reverse', [
                    'lat' => $lat,
                    'lon' => $lng,
                    'format' => 'json',
                ])->json();

            $addr = $geo['address'] ?? [];
            $cityName = $addr['city'] ?? $addr['town'] ?? $addr['village'] ?? $addr['county'] ?? 'Unknown';
            $country = $addr['country'] ?? '';
            $city = $country ? "{$cityName}, {$country}" : $cityName;
        } catch (\Throwable) {
        }

        // Calculate prayer times (method 2 = ISNA, widely compatible)
        try {
            $pt = new PrayerTimes(2, PrayerTimes::SCHOOL_STANDARD);
            $times = $pt->getTimesForToday($date, $lat, $lng, $timezone);
        } catch (\Throwable $e) {
            return response()->json(['status' => false, 'message' => 'Failed to calculate prayer times.'], 500);
        }

        $now = Carbon::now($timezone);
        $nextMarked = false;
        $prayers = [];

        foreach ([
            ['Fajr', 'Fajr'],
            ['Sunrise', 'Sunrise'],
            ['Dhuhr', 'Dhuhr'],
            ['Asr', 'Asr'],
            ['Maghrib', 'Maghrib'],
            ['Isha', 'Isha'],
        ] as [$label, $key]) {
            $raw = $times[$key] ?? null;
            $isNext = false;

            if (!$nextMarked && $raw && $raw !== PrayerTimes::INVALID_TIME) {
                $carbon = Carbon::createFromFormat('H:i', $raw, $timezone);
                if ($now->lt($carbon)) {
                    $isNext = true;
                    $nextMarked = true;
                }
            }

            $prayers[] = [
                'name' => $label,
                'time' => ($raw && $raw !== PrayerTimes::INVALID_TIME)
                    ? Carbon::createFromFormat('H:i', $raw, $timezone)->format('h:i A')
                    : '—',
                'is_next' => $isNext,
            ];
        }

        return response()->json([
            'status' => true,
            'city' => $city,
            'prayers' => $prayers,
        ]);
    }

    public function getCities()
    {
        $cities = PrayerTime::select('city')->distinct()->orderBy('city', 'ASC')->pluck('city')->toArray();

        return response()->json([
            'status' => true,
            'message' => 'Data fetched successfully',
            'data' => $cities,
        ]);
    }


}
