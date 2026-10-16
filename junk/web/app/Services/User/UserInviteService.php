<?php

namespace App\Services\User;

use App\Mail\User\UserInvitationMail;
use App\Models\User;
use App\Services\BaseService;
use Illuminate\Support\Facades\Mail;

class UserInviteService extends BaseService
{
    public function __construct(User $model)
    {
        $this->model = $model;
    }

    public function invite(): static
    {
        $this->model->fill([
            'first_name' => request()->get('first_name'),
            'last_name' => request()->get('last_name'),
            'email' => request()->get('email'),
            'invitation_token' => base64_encode(request()->get('email') . '-invitation-from-token')
        ])->save();

        return $this;
    }

    public function assignRole(): static
    {
        $this->model->roles()->attach(request()->get('role'));
        return $this;
    }

    public function sendInvitationMail(): static
    {
        Mail::to($this->model->email)
            ->send(new UserInvitationMail($this->model));

        return $this;
    }
}
