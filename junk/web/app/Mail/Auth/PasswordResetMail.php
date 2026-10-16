<?php

namespace App\Mail\Auth;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class PasswordResetMail extends Mailable
{
    use Queueable, SerializesModels;

    protected $token = '';
    protected $user;

    public function __construct($user, $token)
    {
        $this->user = $user;
        $this->token = $token;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Password Reset Mail',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'mail.forgot-password',
            with: [
                'user' => $this->user,
                'resetLink' => url('password/reset') . '?email=' . $this->user->email . '&token=' . $this->token,
            ]
        );
    }

    public function attachments(): array
    {
        return [];
    }
}
