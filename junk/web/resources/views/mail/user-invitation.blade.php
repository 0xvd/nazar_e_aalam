<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>You're Invited</title>
    <link href="https://fonts.googleapis.com/css2?family=Amiri&display=swap" rel="stylesheet">
    <style>
        body, table, td, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { -ms-interpolation-mode: bicubic; border: 0; outline: none; text-decoration: none; }
        body { margin: 0; padding: 0; background-color: #eef3f0; }
        @media only screen and (max-width: 620px) {
            .email-container { width: 100% !important; }
            .content-pad { padding: 28px 20px !important; }
        }
    </style>
</head>
<body style="margin:0;padding:0;background-color:#eef3f0;">

<!-- Outer wrapper -->
<table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0"
       style="background-color:#eef3f0;">
    <tr>
        <td align="center" style="padding:32px 16px;">

            <!-- Email card -->
            <table class="email-container" role="presentation" width="600" cellspacing="0" cellpadding="0" border="0"
                   style="max-width:600px;width:100%;background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(10,46,30,0.12);">

                <!-- ── HEADER ── -->
                <tr>
                    <td style="background-color:#0d3a22;padding:0;">
                        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">

                            <!-- Bismillah -->
                            <tr>
                                <td align="center" style="padding:22px 32px 0;background-color:#0d3a22;">
                                    <p style="margin:0;font-family:'Amiri',Georgia,serif;font-size:17px;color:#d4a843;letter-spacing:0.04em;line-height:1.4;">
                                        بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ
                                    </p>
                                </td>
                            </tr>

                            <!-- Logo -->
                            <tr>
                                <td align="center" style="padding:16px 32px 0;background-color:#0d3a22;">
                                    <img src="{{ asset(config('settings.application.web_logo')) }}"
                                         alt="{{ config('settings.application.company_name') }}"
                                         height="44" style="display:block;height:44px;width:auto;">
                                </td>
                            </tr>

                            <!-- Gold divider -->
                            <tr>
                                <td align="center" style="padding:16px 32px 0;background-color:#0d3a22;">
                                    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
                                        <tr>
                                            <td style="height:1px;background:linear-gradient(90deg,transparent,#d4a843,transparent);font-size:0;line-height:0;">&nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <!-- Icon + Title -->
                            <tr>
                                <td align="center" style="padding:20px 32px 26px;background-color:#0d3a22;">
                                    <div style="display:inline-block;width:52px;height:52px;background-color:rgba(212,168,67,0.18);border-radius:50%;border:1px solid rgba(212,168,67,0.35);text-align:center;line-height:52px;margin-bottom:14px;">
                                        <img src="https://img.icons8.com/ios/50/d4a843/email-open--v1.png"
                                             width="24" height="24" alt="invitation"
                                             style="vertical-align:middle;margin-top:14px;display:inline-block;">
                                    </div>
                                    <p style="margin:0 0 4px;font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:700;color:#ffffff;letter-spacing:-0.01em;">
                                        You're Invited! 🎉
                                    </p>
                                    <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:13px;color:rgba(255,255,255,0.55);">
                                        {{ config('settings.application.company_name') }}
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <!-- ── BODY ── -->
                <tr>
                    <td class="content-pad" style="padding:36px 40px;background-color:#ffffff;">

                        <p style="margin:0 0 8px;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#1c2b24;font-weight:700;">
                            Assalamu Alaikum, {{ $user->full_name }} 👋
                        </p>

                        <p style="margin:0 0 20px;font-family:Arial,Helvetica,sans-serif;font-size:14px;color:#5a6e64;line-height:1.7;">
                            You have been invited to join
                            <strong style="color:#1c2b24;">{{ @$companyName->value ?? config('settings.application.company_name') }}</strong>
                            as a team member. Click the button below to accept your invitation and set up your account.
                        </p>

                        <!-- Highlight box -->
                        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0"
                               style="background-color:#f7fdf9;border-radius:10px;border-left:4px solid #1a5c38;margin-bottom:28px;">
                            <tr>
                                <td style="padding:14px 18px;">
                                    <p style="margin:0 0 3px;font-family:Arial,Helvetica,sans-serif;font-size:12px;font-weight:700;color:#1a5c38;text-transform:uppercase;letter-spacing:0.06em;">
                                        Invitation Details
                                    </p>
                                    <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:13px;color:#3d6b52;line-height:1.6;">
                                        Email: <strong style="color:#1c2b24;">{{ $user->email }}</strong>
                                    </p>
                                </td>
                            </tr>
                        </table>

                        <!-- CTA Button -->
                        <table role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin:0 0 28px;">
                            <tr>
                                <td style="border-radius:10px;background-color:#1a5c38;">
                                    <a href="{{ $invitationLink }}"
                                       style="display:inline-block;padding:13px 32px;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;color:#ffffff;text-decoration:none;border-radius:10px;letter-spacing:0.02em;">
                                        Accept Invitation &rarr;
                                    </a>
                                </td>
                            </tr>
                        </table>

                        <!-- Warning note -->
                        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0"
                               style="background-color:#fffbf0;border-radius:10px;border:1px solid rgba(212,168,67,0.3);margin-bottom:24px;">
                            <tr>
                                <td style="padding:12px 16px;">
                                    <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#7a5a0a;line-height:1.6;">
                                        &#9888;&nbsp; This invitation link is valid for a limited time.
                                        If you did not expect this invitation, please ignore this email or contact support.
                                    </p>
                                </td>
                            </tr>
                        </table>

                        <!-- Fallback URL -->
                        <p style="margin:0 0 6px;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#9cb8ac;">
                            If the button doesn't work, copy and paste this link into your browser:
                        </p>
                        <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:11px;color:#9cb8ac;word-break:break-all;">
                            <a href="{{ $invitationLink }}" style="color:#1a5c38;text-decoration:underline;">{{ $invitationLink }}</a>
                        </p>

                    </td>
                </tr>

                <!-- ── DIVIDER ── -->
                <tr>
                    <td style="padding:0 40px;">
                        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
                            <tr>
                                <td style="height:1px;background-color:rgba(26,92,56,0.1);font-size:0;line-height:0;">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <!-- ── FOOTER ── -->
                <tr>
                    <td style="background-color:#f7fbf8;padding:24px 40px;border-bottom-left-radius:16px;border-bottom-right-radius:16px;">
                        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
                            <tr>
                                <td align="center">
                                    <p style="margin:0 0 6px;font-family:Arial,Helvetica,sans-serif;font-size:13px;font-weight:700;color:#1c2b24;">
                                        {{ config('settings.application.company_name') }}
                                    </p>
                                    <p style="margin:0 0 10px;font-family:Arial,Helvetica,sans-serif;font-size:11px;color:#9cb8ac;">
                                        This is an automated email. Please do not reply.
                                    </p>
                                    <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:11px;color:#b8cfc5;">
                                        &copy; {{ date('Y') }} {{ config('settings.application.company_name') }}. All rights reserved.
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

            </table>
            <!-- End email card -->

        </td>
    </tr>
</table>

</body>
</html>
