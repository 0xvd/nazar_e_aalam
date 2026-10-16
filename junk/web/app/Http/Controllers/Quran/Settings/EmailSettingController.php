<?php

namespace App\Http\Controllers\Quran\Settings;

use App\Http\Controllers\Controller;
use App\Services\Setting\EmailSettingService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class EmailSettingController extends Controller
{
    public function __construct(EmailSettingService $service)
    {
        $this->service = $service;
    }

    public function index()
    {
        $default = $this->service->getDefaultSettings();


        return $this->service
            ->getFormattedDeliverySettings([optional($default)->value, 'default_mail_email_name']);
    }

    public function update(Request $request)
    {
        $request->validate([
            'provider' => ['required', 'string'],
            'from_name' => ['required', 'string'],
            'from_email' => ['required'],
            'smtp_host' => ['required', 'string'],
            'smtp_port' => ['required', 'numeric'],
            'smtp_username' => ['required', 'string'],
            'email_password' => ['required'],
            'encryption_type' => ['required', 'string', Rule::in(['ssl', 'tls'])],
        ]);

        $context = $request->get('provider');

        foreach ($request->only('from_name', 'from_email') as $key => $value) {

            $this->service
                ->update($key, $value, 'default_mail_email_name');
        }

        foreach ($request->except('allowed_resource', 'from_name', 'from_email') as $key => $value) {

            $this->service
                ->update($key, $value, $context);
        }

        $this->service->setDefaultSettings('default_mail', $context);


        return response()->json([
            'status' => true,
            'message' => 'Email settings updated successfully',
            'data' => []
        ]);
    }
}
