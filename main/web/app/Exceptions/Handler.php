<?php

namespace App\Exceptions;

use App\Exceptions\Concerns\ExceptionHelper;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Session\TokenMismatchException;
use Throwable;
use Illuminate\Auth\AuthenticationException;

class Handler extends ExceptionHandler
{
    use ExceptionHelper;

    /**
     * The list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    public function render($request, Throwable $e)
    {
        if ($this->apiFailResponse($request, $e))
            return $this->apiFailResponse($request, $e);

        // for custom error page
        if (!$request->expectsJson() && app()->environment('production')) {
            $statusCode = $e->getCode();

            if (view()->exists('custom_errors.' . $statusCode)) {
                $message = $e->getMessage();

                if ($e instanceof QueryException) {
                    $message = trans('default.failed_response');
                }

                if ($e instanceof ModelNotFoundException) {
                    $message = trans('default.resource_not_found', ['resource' => trans('default.resource')]);
                }

                if (view()->exists('custom_errors.' . $statusCode)) {
                    return response()->view('custom_errors.' . $statusCode, [
                        'message' => $message
                    ]);
                }
            }
        }

        if ($this->isHttpException($e)) {
            if ($e->getStatusCode() == 404) {
                return response()->view('custom_errors.404', [
                    'message' => trans('default.resource_not_found_app')
                ]);
            }
        }

        if (!$request->expectsJson() && $e instanceof ModelNotFoundException) {
            return response()->view('custom_errors.404', [
                'message' => trans('default.resource_not_found', ['resource' => trans('default.resource')])
            ]);
        }

        if (!$request->expectsJson() && $e instanceof AuthorizationException) {
            return response()->view('custom_errors.403', [
                'message' => $e->getMessage()
            ]);
        }

        if ($request->expectsJson() && $e instanceof TokenMismatchException) {
            $message = trans('default.csrf_token_mismatch_message') == 'default.csrf_token_mismatch_message' ?
                'CSRF token mismatch.' : trans('default.csrf_token_mismatch_message');

            return response()->json(['status' => false, 'message' => $message], 419);
        }

        return parent::render($request, $e);
    }

    function unauthenticated($request, AuthenticationException $exception): \Illuminate\Http\Response|\Illuminate\Http\JsonResponse|\Illuminate\Http\RedirectResponse
    {
        return $request->expectsJson()
            ? response()->json(['message' => 'Unauthenticated.'], 401)
            : redirect()->guest(route('login'));

    }

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });
    }
}
