<?php

namespace App\Http\Middleware;

use App\Exceptions\GeneralException;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class DemoMode
{
    /**
     * Blocks any write request (POST/PUT/PATCH/DELETE) in the admin panel
     * when IS_DEMO is enabled. Read requests (GET/HEAD) are left untouched.
     *
     * @throws GeneralException
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (env('IS_DEMO') && !$request->isMethodSafe()) {
            throw new GeneralException('In demo version not available');
        }

        return $next($request);
    }
}
