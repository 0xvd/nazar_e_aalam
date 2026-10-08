<?php

namespace App\Http\Controllers\Installer;

use App\Http\Controllers\Controller;
use App\Services\Installer\PurchaseCodeValidatorService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class PurchaseKeyController extends Controller
{
    public function __construct(PurchaseCodeValidatorService $service)
    {
        $this->service = $service;
    }

    public function index()
    {
        return view('installer.purchase_key');
    }

    public function check(Request $request)
    {
        $request->validate([
            'purchase_code' => 'required|min:3|regex:/^[^#]+$/U',
        ]);

        $userInput = $request->all();
        array_walk_recursive($userInput, function (&$userInput) {
            $userInput = strip_tags($userInput);
        });
        $request->merge($userInput);

        $code = trim($request->purchase_code);
        $domainName = request()->getHost();
        $config = config('theme29');
        $url = "{$config['marketplace_url']}/verification/purchases-code/{$config['app_id']}?domain_name={$domainName}&purchase_key={$code}&app_version={$config['app_version']}";
        return [
            'status' => true,
            'message' => 'success',
            'url' => $url
        ];
    }
}
