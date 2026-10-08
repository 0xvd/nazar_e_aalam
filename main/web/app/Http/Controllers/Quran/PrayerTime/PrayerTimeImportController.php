<?php

namespace App\Http\Controllers\Quran\PrayerTime;

use App\Http\Controllers\Controller;
use App\Models\Quran\Prayer\PrayerTime;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Shuchkin\SimpleXLSX;

class PrayerTimeImportController extends Controller
{
    public function index()
    {
    }


    public function import(Request $request)
    {
        try {
            DB::beginTransaction();
            if (!$request->has('file')) {
                return response()->json(['message' => 'Data import failed'], 422);
            }

            $file = $request->file('file');
            $xlsx = SimpleXLSX::parse($file);

            if (!$xlsx) {
                return response()->json(['message' => 'Invalid file format'], 422);
            }

            $rows = $xlsx->rows();
            $headers = array_filter($rows[0] ?? []);
            $data = [];

            foreach (array_slice($rows, 2) as $prayerTimes) {
                foreach (array_chunk($prayerTimes, 10) as $i => $times) {
                    if (count($times) < 10) continue;
                    $city = $i == 0 ? $headers[0] : $headers[10 * $i] ?? 'Unknown';
                    $date = Carbon::parse($times[0])->format('Y-m-d');

                    $record = [
                        'city' => $city,
                        'date' => $date,
                        'imsak' => $this->timeFormat($times[1]),
                        'sunrise' => $this->timeFormat($times[2]),
                        'fajr_start' => $this->timeFormat($times[3]),
                        'zuhr_start' => $this->timeFormat($times[4]),
                        'asr_start' => $this->timeFormat($times[5]),
                        'maghrib_start' => $this->timeFormat($times[6]),
                        'isha_start' => $this->timeFormat($times[7]),
                        'sehri' => $this->timeFormat($times[8]),
                        'iftar' => $this->timeFormat($times[9])
                    ];

                    // Use upsert to avoid duplicates
                    PrayerTime::updateOrCreate(
                        ['city' => $city, 'date' => $date], // Matching condition
                        $record // Data to insert or update
                    );
                }
            }
            DB::commit();

            return response()->json(['message' => 'Data imported successfully'], 201);
        } catch (\Exception $e) {
            dd($e);
            DB::rollBack();
            return response()->json(['message' => 'Data import failed'], 422);
        }
    }


    function timeFormat($input, $format = 'H:i:s')
    {
        if (preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/', $input)) {
            return Carbon::parse($input)->format($format);
        }

        if (preg_match('/^(?:[01]?[0-9]|2[0-3]):[0-5][0-9](?::[0-5][0-9])?(?:\s?[APMapm]{2})?$/', $input)) {
            return Carbon::parse($input)->format($format);
        }

        return null;
    }

}
