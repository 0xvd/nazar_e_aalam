<?php

namespace App\Http\Controllers\Installer;

use App\Helpers\Installer\PermissionHelper;
use App\Helpers\Installer\RequirementsHelper;
use App\Http\Controllers\Controller;

class InstallerController extends Controller
{
    protected RequirementsHelper $requirements;
    protected PermissionHelper $permission;

    public function __construct(RequirementsHelper $requirements, PermissionHelper $permission)
    {
        $this->requirements = $requirements;
        $this->permission = $permission;

    }

    public function index(): array
    {
        $checkPhpVersion = $this->requirements->checkPHPVersion(
            config('installer.core.minPhpVersion')
        );
        $checkMysqlVersion = $this->requirements->checkMysqlVersion(
            config('installer.core.minMysqlVersion')
        );

        $requirements = $this->requirements->checkRequirement(
            config('installer.requirements')
        );

        $permissions = $this->permission->check(
            config('installer.permissions'));



        return [
            'checkPhpVersion' => $checkPhpVersion,
            'mysqlVersion' => $checkMysqlVersion,
            'requirements' => $requirements,
            'permissions' => $permissions
        ];
    }

    public function installation()
    {
        return view('installer.index');
    }
}
