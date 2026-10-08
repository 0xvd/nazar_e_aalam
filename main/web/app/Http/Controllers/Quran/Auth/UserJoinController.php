<?php

namespace App\Http\Controllers\Quran\Auth;

use App\Exceptions\GeneralException;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Rules\Password;

class UserJoinController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'invitation_token' => 'required|exists:users,invitation_token',
        ], [
            'email.exists' => 'Invalid email address.',
            'invitation_token.exists' => 'Invalid invitation token.',
        ]);

        $user = User::query()
            ->where([
                'email' => $request->email,
                'invitation_token' => $request->invitation_token
            ])
            ->first();

        if (!$user) {
            return abort(403, 'Unauthorized action.');
        }

        if (Carbon::parse($user->created_at)->diffInMinutes(Carbon::now()) >= 20) {
            return abort(403, 'Unauthorized action.');
        }

        return view('auth.join-user', compact('user'));
    }


    public function store(Request $request)
    {
        $request->validate([
            'email' => 'required|max:50|email',
            'invitation_token' => 'required|exists:users,invitation_token',
            'password' => ['required', Password::min(8)
                ->letters()
                ->mixedCase()
                ->numbers()
                ->symbols()
                ->uncompromised()
            ],
            'confirm_password' => 'required_with:password|same:password'
        ]);

        // Validation passed, proceed to create the user
        $user = User::where('email', $request->input('email'))
            ->where('invitation_token', $request->input('invitation_token'))
            ->first();

        if ($user) {
            // Update user information
            $user->password = $request->password;
            $user->invitation_token = null; // Mark invitation token as used
            $user->save();

            return response()->json([
                'status' => true,
                'message' => 'User profile completed successfully.',
            ]);
        } else {
            return response()->json([
                'status' => false,
                'message' => 'Invalid email or invitation token.',
            ], 401);
        }
    }
}
