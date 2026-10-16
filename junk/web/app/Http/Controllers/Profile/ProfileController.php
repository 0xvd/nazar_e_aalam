<?php

namespace App\Http\Controllers\Profile;

use App\Concerns\FileHandler;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;

class ProfileController extends Controller
{
    use FileHandler;

    public function index()
    {
        return auth()->user()->load('profile');
    }

    public function update(Request $request)
    {
        if (env('IS_DEMO')){
            return response()->json([
                'status' => true,
                'message' => 'In demo version not available'
            ],403);
        }

        $request->validate([
            'first_name' => ['required', 'max:100', 'string'],
            'last_name' => ['required', 'max:100', 'string'],
            'date_of_birth' => ['required', 'date', 'before:today'],
            'email' => ['required', 'email', 'max:100', Rule::unique('users')->ignore(auth()->user())],
            'profile_picture' => ['nullable', 'image', 'mimes:jpeg,png,jpg', 'max:1024'],
        ]);
        auth()->user()->update(
            $request->only('first_name', 'last_name', 'email')
        );


        if (request()->file('profile_picture')) {
            $file_path = $this->uploadImage(
                request()->file('profile_picture'),
                'profile',
                null
            );

            auth()->user()->profile()->updateOrCreate(
                ['user_id' => auth()->id()],
                array_merge(
                    ['user_id' => auth()->id(), 'profile_picture' => $file_path],
                    $request->only(
                        'gender', 'date_of_birth', 'user_id', 'phone_number'
                    )
                )
            );
        } else {
            auth()->user()->profile()->updateOrCreate(
                ['user_id' => auth()->id()],
                array_merge(
                    ['user_id' => auth()->id()],
                    $request->only(
                        'gender', 'date_of_birth', 'user_id', 'phone_number'
                    )
                )
            );
        }

        return response()->json([
            'status' => true,
            'message' => 'Profile updated successfully'
        ]);

    }

    /**
     * @throws ValidationException
     */
    public function passwordChange(Request $request)
    {

        if (env('IS_DEMO')){
            return response()->json([
                'status' => true,
                'message' => 'In demo version not available'
            ],403);
        }

        $this->validate($request, [
            'current_password' => ['required'],
            'password' => ['required',  Password::min(8)
                ->letters()
                ->mixedCase()
                ->numbers()
                ->symbols()
                ->uncompromised()
            ],
            'confirm_password' => 'required_with:password|same:password'
        ]);



        if (Hash::check($request->get('current_password'), auth()->user()->password)) {
            auth()->user()->update([
                'password' => $request->get('password')
            ]);
            return response()->json([
                'status' => true,
                'message' => 'Password Changed Successfully'
            ]);
        }

        throw ValidationException::withMessages([
            'current_password' => 'The current password is incorrect'
        ]);
    }
}
