<?php

namespace App\Http\Controllers;

use App\Services\BaseService;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;

class Controller extends BaseController
{
    protected BaseService $service;

    use AuthorizesRequests, ValidatesRequests;
}
