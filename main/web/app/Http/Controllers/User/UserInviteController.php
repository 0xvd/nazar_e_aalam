<?php

namespace App\Http\Controllers\User;

use App\Exceptions\GeneralException;
use App\Http\Controllers\Controller;
use App\Services\User\UserInviteService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\Mailer\Exception\TransportException;

class UserInviteController extends Controller
{
    public function __construct(UserInviteService $service)
    {
        $this->service = $service;
    }

    /**
     * @throws GeneralException
     */
    public function invite(Request $request): \Illuminate\Http\JsonResponse
    {
        $request->validate([
            'first_name' => 'required',
            'last_name' => 'required',
            'email' => 'required|email|unique:users,email',
            'role' => 'required',
        ]);

        try {
            DB::transaction(function () use ($request) {
                $this->service
                    ->invite()
                    ->assignRole()
                    ->sendInvitationMail();
            });

            return response()->json([
                'status' => true,
                'message' => 'User Invitation has been sent',
            ]);

        } catch (TransportException $exception) {
            DB::rollBack();
            throw new GeneralException('Email Setup is not correct');
        } catch (\Exception $exception) {
            DB::rollBack();
            if (app()->environment('local')) {
                throw new GeneralException($exception->getMessage);
            }
            throw new GeneralException('User Invitation has been failed');
        }
    }
}
