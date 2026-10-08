<?php

namespace App\Http\Controllers\Quran\Auth;

use App\Exceptions\GeneralException;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rules\Password;

class ResetPasswordController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'token' => 'required|min:10',
            'email' => 'required|email'
        ]);

        ['user' => $user, 'token' => $token] = $this->getUserAndToken($request->get('email'), $request->get('token'));

        throw_if(!($token && $user), new GeneralException('Invalid token'));

        if (Carbon::parse($token->created_at)->diffInMinutes(Carbon::now()) >= 20) {
            throw_if(!($token && $user), new GeneralException('Token has been expired'));
        }


        return view('auth.reset-password', compact('token'));

    }

    public function update(Request $request): \Illuminate\Http\JsonResponse
    {
        $this->validate($request, [
            'password' => ['required', Password::min(8)
                ->letters()
                ->mixedCase()
                ->numbers()
                ->symbols()
                ->uncompromised()
            ],
            'confirm_password' => 'required_with:password|same:password'
        ]);

        ['user' => $user, 'token' => $token] = $this->getUserAndToken($request->get('email'), $request->get('token'));

        throw_if(!($token && $user), new GeneralException('Invalid email or token'));

        if (Carbon::parse($token->created_at)->diffInMinutes(Carbon::now()) >= 20) {
            throw_if(!($token && $user), new GeneralException('Token has been expired'));
        }

        $user->update([
            'password' => $request->get('password')
        ]);

        DB::table('password_reset_tokens')
            ->where('email', $user->email)
            ->delete();

        auth()->login($user);

        return response()->json([
            'status' => true,
            'message' => 'Password has been reset successfully',
            'redirectUrl' => route('dashboard')
        ]);
    }

    public function getUserAndToken($email, $token = null): array
    {
        $user = User::where('email', $email)
            ->first();

        $reset = null;

        if ($token) {
            $reset = DB::table('password_reset_tokens')
                ->where('token', $token)
                ->where('email', $email)
                ->first();
        }

        return ['user' => $user, 'token' => $reset];
    }

}
