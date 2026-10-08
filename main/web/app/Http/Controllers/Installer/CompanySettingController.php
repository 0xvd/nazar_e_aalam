<?php

namespace App\Http\Controllers\Installer;

use App\Http\Controllers\Controller;
use App\Services\Setting\SettingService;
use Illuminate\Http\Request;

class CompanySettingController extends Controller
{
    public function __construct(SettingService $setting)
    {
        $this->service = $setting;
    }

    public function index()
    {
        return view('installer.company_setup');
    }

    public function update(Request $request)
    {

        $request->validate([
            'company_name' => ['required', 'string', 'max:100'],
            'zakat_nisab' => ['required', 'numeric'],
            'currency_symbol' => ['required'],
        ]);

        $this->service->update();

        return response()->json([
            'status' => true,
            'message' => 'Company information updated successfully',
        ]);

    }
}
