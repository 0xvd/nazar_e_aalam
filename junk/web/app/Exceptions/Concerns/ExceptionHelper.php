<?php

namespace App\Exceptions\Concerns;

use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Database\QueryException;
use Throwable;

trait ExceptionHelper
{
    public function apiFailResponse($request, Throwable $exception): bool|\Illuminate\Http\JsonResponse
    {
        if ($request->expectsJson() && app()->environment('production')) {
            $message = trans($exception->getMessage());
            $methodName = 'whenItIs' . $exception->getCode();

            if (method_exists($this, $methodName)) {
                $message = $this->{$methodName}($request, $exception);
            }

            if ($exception instanceof QueryException) {
                return response()->json(['status' => false, 'message' => $message], 424);
            }

            if ($exception instanceof ModelNotFoundException) {
                $message = trans('default.resource_not_found', ['resource' => trans('default.resource')]);
                return response()->json(['status' => false, 'message' => $message], 404);
            }
        }
        return false;
    }


    public function whenItIs23000($request, Throwable $exception): \Illuminate\Foundation\Application|array|string|\Illuminate\Contracts\Translation\Translator|\Illuminate\Contracts\Foundation\Application|null
    {
        return trans('default.this_resource_already_referenced_message');
    }
}
