<?php

namespace App\Http\Middleware;

use App\Models\Quran\Role\Role;
use App\Models\User;
use App\Repositories\User\UserRepository;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\UnauthorizedException;
use Symfony\Component\HttpFoundation\Response;

class AuthorizeMiddleware
{

    public function __construct(protected UserRepository $user)
    {
    }


    public function handle(Request $request, Closure $next)
    {
        if (auth()->user()->isAppAdmin())
            return $next($request);

        $user = $this->user->getCachedAuthUserWithRoleAndPermissions();

        optional($user->roles)->map(function (Role $role) {
            optional($role->permissions)->map(function ($permission) {
                Gate::define($permission->name, function (User $user) {
                    return true;
                });
            });
        });


        Gate::define('manage_dashboard', function (User $user) {
            return true;
        });

        return $next($request);
    }
}
