<?php

namespace App\Helpers\General;

use App\Exceptions\GeneralException;
use App\Repositories\User\UserRepository;

class AuthorizeHelper
{
    public function __construct(protected UserRepository $user)
    {

    }

    /**
     * @throws GeneralException
     */
    public function authorize($actions): bool
    {
        if (is_array($actions)) {

            if (in_array(0, $this->arrayAuthorizer($actions))) {
                throw new GeneralException('Permission denied');
            }

            return true;
        }

        if (is_string($actions)) {
            if (auth()->user()->can($actions)) {
                return true;
            }
        }

        throw new GeneralException('Permission denied');
    }

    /**
     * @throws GeneralException
     */
    public function getAuthorized($action)
    {
        $this->authorize($action);
        $permissions = $this->user->findAuthUserPermission($action);
        if (!empty($permissions['pivot'])) {
            return $permissions['pivot'];
        }
        return [];
    }

    /**
     * @throws GeneralException
     */
    public function isAuthorizedSpecific($action, $payload): bool
    {
        $authorized = $this->getAuthorized($action);

        if (count($authorized) > 0) {
            if (!in_array($payload, $authorized)) {
                throw new GeneralException('Permission denied');
            }
        }

        return true;
    }

    public function authorizeMultiple(array $actions): bool
    {
        return in_array(0, $this->arrayAuthorizer($actions));
    }

    public function authorizeAny(array $actions): bool
    {
        return in_array(1, $this->arrayAuthorizer($actions));
    }

    public function arrayAuthorizer(array $actions): array
    {
        return collect($actions)->map(function ($action) {
            return auth()->user()->can($action) ? 1 : 0;
        })->toArray();
    }
}
