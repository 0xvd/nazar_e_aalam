<?php

namespace App\Http\Controllers\Quran\Auth;

use App\Exceptions\GeneralException;
use App\Http\Controllers\Controller;
use App\Mail\Auth\PasswordResetMail;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Symfony\Component\Mailer\Exception\TransportException;

class ForgotPasswordController extends Controller
{
    public function index()
    {
        return view('auth.forgot-password');
    }

    /**
     * @throws GeneralException
     */
    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        if (env('IS_DEMO')){
            return response()->json([
                'status' => true,
                'message' => 'In demo version not available'
            ],403);
        }

        $request->validate([
            'email' => 'required|email|exists:users,email'
        ]);

        try {
            DB::beginTransaction();

            $user = User::query()->where('email', $request->email)->first();

            if (!$user) {
                return response()->json([
                    'status' => false,
                    'message' => 'Selected email is not valid'
                ], 404);
            }

            $existingToken = DB::table('password_reset_tokens')
                ->where('email', $user->email)
                ->first();

            if ($existingToken) {
                $createdAt = Carbon::parse($existingToken->created_at);
                $currentTime = Carbon::now();

                $secondsRemaining = $createdAt->addMinutes(15)->diffInSeconds($currentTime);

                if ($currentTime->lessThan($createdAt)) {
                    $minutesRemaining = ceil($secondsRemaining / 60); // Convert seconds to minutes
                    return response()->json([
                        'status' => false,
                        'message' => "Password reset email has already been sent. Please try after {$minutesRemaining} minutes."
                    ]);
                }
            }

            $createToken = base64_encode(microtime(true));

            DB::table('password_reset_tokens')->updateOrInsert(
                ['email' => $request->get('email')],
                [
                    'token' => $createToken,
                    'created_at' => Carbon::now()
                ]
            );

            Mail::to($user->email)
                ->send(
                    (new PasswordResetMail($user, $createToken))
                        ->onQueue('high')
                        ->delay(5)
                );

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Password link sent to your mail successfully'
            ]);

        } catch (TransportException $exception) {
            DB::rollBack();
            throw new GeneralException('Email setup has been incorrect! Please contact with admin');
        } catch (\Exception $exception) {
            DB::rollBack();
            throw new GeneralException('Forgot password send has been failed!');
        }
    }


}
