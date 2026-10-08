<?php

namespace App\Http\Controllers\Installer;

use App\Exceptions\GeneralException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Installer\DatabaseManagerRequest;
use App\Http\Requests\Installer\EmailSettingRequest;
use App\Services\Installer\DatabaseManagerService;
use App\Services\Installer\EmailSettingService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Password;
use Psr\Container\ContainerExceptionInterface;
use Psr\Container\NotFoundExceptionInterface;

class DatabaseManagerController extends Controller
{

    protected EmailSettingService $emailSettingService;

    public function __construct(DatabaseManagerService $service, EmailSettingService $emailSettingService)
    {
        $this->service = $service;
        $this->emailSettingService = $emailSettingService;
    }

    public function index()
    {
        return view('installer.environment_setup');
    }


    /**
     * @throws ContainerExceptionInterface
     * @throws NotFoundExceptionInterface
     * @throws GeneralException
     */
    public function setConnect(DatabaseManagerRequest $request): \Illuminate\Http\JsonResponse
    {

        $this->service
            ->clearCaches()
            ->setDatabaseConnection()
            ->saveFileWizard()
            ->sessionDestroy();

        return response()->json(['status' => true, 'message' => 'Database configured successfully']);

    }

    public function userInformation()
    {
        return view('installer.user_information');
    }

    public function userStore(Request $request): \Illuminate\Http\JsonResponse
    {
        $request->validate([
            'first_name' => ['required', 'string', 'max:100'],
            'last_name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:100'],
            'password' => ['required', 'min:8', 'max:30']
        ]);

//        ini_set('memory_limit', '256M');
//        set_time_limit(5000);

        $this->service
            ->storageLink()
            ->setMigration()
            ->setDatabaseSeeder()
            ->updateUser();

        return response()->json(['status' => true, 'message' => 'User info setup successfully']);

    }

    public function emailSetup()
    {
        return view('installer.email_setup');
    }

    public function update(EmailSettingRequest $request)
    {
        $context = $request->get('provider');

        foreach ($request->only('from_name', 'from_email') as $key => $value) {

            $this->emailSettingService
                ->update($key, $value, 'default_mail_email_name');
        }

        foreach ($request->except('allowed_resource', 'from_name', 'from_email') as $key => $value) {
            $this->emailSettingService
                ->update($key, $value, $context);
        }

        $this->emailSettingService->setDefaultSettings('default_mail', $context);

        $this->service->setEnvironmentValue()
            ->setEnvironmentAppDebugValue();


        return response()->json(['status' => true, 'message' => trans('default.email_setup_successfully')]);

    }

    public function setupSkip(): \Illuminate\Http\JsonResponse
    {
        $this->service->setEnvironmentValue()
            ->setEnvironmentAppDebugValue();

        return response()->json(['status' => true, 'message' => trans('default.email_setup_successfully')]);
    }
}
