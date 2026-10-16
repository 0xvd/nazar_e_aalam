<?php

namespace App\Http\Controllers\Quran\PrayerTime;

use App\Http\Controllers\Controller;
use App\Models\Quran\Prayer\PrayerTime;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PrayerTimeController extends Controller
{
    public function columns(): array
    {
        return [
            'id',
            'city',
            'date',
            'imsak',
            'sunrise',
            'fajr_start',
            'zuhr_start',
            'asr_start',
            'maghrib_start',
            'isha_start',
            'sehri',
            'iftar'
        ];
    }

    public function index(Request $request)
    {
        // Fetch records filtered by the selected city
        $prayerTime = PrayerTime::query()
            ->select($this->columns())
            ->when($request->filled('city'), function ($query) use ($request) {
                return $query->where('city', $request->city);
            })
            ->orderBy('date', 'ASC')
            ->get();

        // Create a collection of all months in the desired format
        $allMonths = collect(range(1, 12))->mapWithKeys(function ($month) {
            return [Carbon::create(null, $month, 1)->format('F') => []];
        });

        // Group the records by month
        $groupedData = $prayerTime->groupBy(function ($item) {
            return date('F', strtotime($item->date));
        });

        // Convert the grouped data to array and sort by month
        $groupedDataArray = $groupedData->toArray();
        ksort($groupedDataArray);

        // Merge the grouped data with the all months collection
        return $allMonths->merge($groupedDataArray)->all();
    }


    public function validation(): array
    {
        $currentYear = now()->year;

        return \request()->validate([
            'city' => ['required', 'string', Rule::in($this->getCities())],
            'date' => [
                'required',
                'date',
                "after_or_equal:{$currentYear}-01-01",
                "before_or_equal:{$currentYear}-12-31"
            ],
            'imsak' => ['required', 'date_format:H:i'],
            'sunrise' => ['required', 'date_format:H:i'],
            'fajr_start' => ['required', 'date_format:H:i'],
            'zuhr_start' => ['required', 'date_format:H:i'],
            'asr_start' => ['required', 'date_format:H:i'],
            'maghrib_start' => ['required', 'date_format:H:i'],
            'isha_start' => ['required', 'date_format:H:i'],
            'iftar' => ['required', 'date_format:H:i'],
            'sehri' => ['required', 'date_format:H:i'],
        ], [
            'date.after_or_equal' => 'The date must be on or after January 1, ' . $currentYear,
            'date.before_or_equal' => 'The date must be on or before December 31, ' . $currentYear,
        ]);
    }

    public function store(Request $request)
    {
        $this->validation();

        PrayerTime::query()->updateOrCreate(
            ['city' => $request->city,
                'date' => $request->date
            ],
            [
                'city' => $request['city'],
                'imsak' => $request['imsak'],
                'sunrise' => $request['sunrise'],
                'fajr_start' => $request['fajr_start'],
                'zuhr_start' => $request['zuhr_start'],
                'asr_start' => $request['asr_start'],
                'maghrib_start' => $request['maghrib_start'],
                'isha_start' => $request['isha_start'],
                'iftar_start' => $request['iftar_start'],
                'sehri_start' => $request['sehri_start']
            ]
        );

        return response()->json([
            'status' => true,
            'message' => 'Prayer time created successfully',
        ]);
    }


    public function show(PrayerTime $prayer_time)
    {
        return $prayer_time;
    }

    public function update(Request $request, PrayerTime $prayerTime)
    {
        $this->validation();


        PrayerTime::query()->updateOrCreate(
            ['city' => $request->city,
                'date' => $request->date
            ],
            [
                'imsak' => $request['imsak'],
                'sunrise' => $request['sunrise'],
                'fajr_start' => $request['fajr_start'],
                'zuhr_start' => $request['zuhr_start'],
                'asr_start' => $request['asr_start'],
                'maghrib_start' => $request['maghrib_start'],
                'isha_start' => $request['isha_start'],
                'iftar_start' => $request['iftar_start'],
                'sehri_start' => $request['sehri_start']
            ]
        );

        return response()->json([
            'status' => true,
            'message' => 'Prayer time updated successfully',
        ]);
    }

    public function destroy(PrayerTime $prayerTime)
    {
        $prayerTime->delete();

        return response()->json([
            'status' => true,
            'message' => 'Prayer time deleted successfully',
        ]);
    }

    public function getCities()
    {
        return PrayerTime::select('city')->distinct()->orderBy('city', 'ASC')->get()->pluck('city');
    }

    public function deleteCityPrayerTimes(Request $request)
    {
        $city = $request->city;
        PrayerTime::where('city', $city)->delete();
        return response()->json([
            'status' => true,
            'message' => 'Prayer time deleted successfully',
        ]);
    }

}
