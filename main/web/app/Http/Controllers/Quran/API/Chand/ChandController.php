<?php

namespace App\Http\Controllers\Quran\API\Chand;

use App\Http\Controllers\Controller;
use Exception;
use Illuminate\Support\Facades\Http;

class ChandController extends Controller
{
    public function getChand()
    {
        try {
            $response = Http::timeout(10)->get('https://gujchand.com');
            if (!$response->successful()) {
                throw new Exception("HTTP {$response->status()}");
            }

            $html = $response->body();

            preg_match(
                '/<div[^>]+footer[^>]*>\s*(\d{1,2})\s*([A-Za-z-]+)\s*(\d{1,4})\s*\w+[^<]+</i',
                $html,
                $matches
            );

            if (!$matches) {
                throw new Exception('Chand data not found');
            }

            return response()->json([
                'chand' => $matches[1],
                'month' => $matches[2],
                'year' => $matches[3],
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
                'status' => false,
            ], 500);
        }
    }
}