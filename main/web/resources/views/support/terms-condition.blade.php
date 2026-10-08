<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ config('settings.application.company_name') }} – Terms & Conditions</title>
    <meta name="description" content="Terms and Conditions for {{ config('settings.application.company_name') }}">
    <link rel="shortcut icon" href="{{ asset(config('settings.application.web_icon') ?? 'favicon.ico') }}" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #f8faf9; color: #1a1f2e; }

        .topbar {
            background: linear-gradient(135deg, #0a2e1e 0%, #1a5c38 100%);
            padding: 14px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 50;
            box-shadow: 0 2px 12px rgba(0,0,0,.25);
        }
        .topbar-brand { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .topbar-logo { height: 36px; width: auto; object-fit: contain; }
        .topbar-name { color: #fff; font-weight: 700; font-size: 1.1rem; letter-spacing: -.01em; }
        .topbar-back {
            color: rgba(255,255,255,.75);
            font-size: .82rem;
            font-weight: 500;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 7px 14px;
            border: 1px solid rgba(255,255,255,.2);
            border-radius: 8px;
            transition: background .15s, color .15s;
        }
        .topbar-back:hover { background: rgba(255,255,255,.1); color: #fff; }

        .hero-strip {
            background: linear-gradient(135deg, #0a2e1e 0%, #1a5c38 60%, #0d3d26 100%);
            padding: 56px 24px 48px;
            text-align: center;
        }
        .hero-strip h1 { color: #fff; font-size: 2rem; font-weight: 800; margin-bottom: 10px; }
        .hero-strip p { color: rgba(255,255,255,.65); font-size: .9rem; }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(212,168,67,.15);
            border: 1px solid rgba(212,168,67,.3);
            color: #d4a843;
            font-size: .75rem;
            font-weight: 600;
            padding: 5px 14px;
            border-radius: 20px;
            margin-bottom: 18px;
        }

        .content-wrap {
            max-width: 820px;
            margin: 0 auto;
            padding: 48px 24px 80px;
        }
        .policy-card {
            background: #fff;
            border-radius: 16px;
            border: 1px solid #e8ecf0;
            padding: 40px 44px;
            box-shadow: 0 2px 16px rgba(0,0,0,.05);
            line-height: 1.8;
            font-size: .95rem;
            color: #374151;
        }
        .policy-card h1, .policy-card h2, .policy-card h3 {
            color: #0a2e1e;
            margin-top: 1.6em;
            margin-bottom: .5em;
            line-height: 1.3;
        }
        .policy-card h1 { font-size: 1.5rem; border-bottom: 2px solid #e8ecf0; padding-bottom: .4em; }
        .policy-card h2 { font-size: 1.15rem; font-weight: 700; }
        .policy-card h3 { font-size: 1rem; font-weight: 600; color: #1a5c38; }
        .policy-card p { margin-bottom: .9em; }
        .policy-card ul, .policy-card ol { padding-left: 1.4em; margin-bottom: .9em; }
        .policy-card li { margin-bottom: .3em; }
        .policy-card a { color: #1a5c38; text-decoration: underline; }
        .policy-card strong { color: #1a1f2e; }

        .page-footer {
            background: #0a2e1e;
            padding: 24px;
            text-align: center;
            color: rgba(255,255,255,.45);
            font-size: .8rem;
        }
        .page-footer a { color: rgba(255,255,255,.6); text-decoration: none; margin: 0 8px; }
        .page-footer a:hover { color: #d4a843; }

        @media (max-width: 600px) {
            .policy-card { padding: 24px 20px; }
            .hero-strip h1 { font-size: 1.5rem; }
        }
    </style>
</head>
<body>

    <header class="topbar">
        <a href="{{ url('/') }}" class="topbar-brand">
            @if(config('settings.application.web_logo'))
                <img src="{{ asset(config('settings.application.web_logo')) }}" alt="{{ config('settings.application.company_name') }}" class="topbar-logo">
            @else
                <span class="topbar-name">{{ config('settings.application.company_name') }}</span>
            @endif
        </a>
        <a href="{{ url('/') }}" class="topbar-back">
            ← Back to Home
        </a>
    </header>

    <div class="hero-strip">
        <div class="hero-badge">📋 Legal</div>
        <h1>Terms &amp; Conditions</h1>
        <p>Please read these terms carefully before using our app</p>
    </div>

    <div class="content-wrap">
        <div class="policy-card">
            {!! config('settings.application.terms_and_conditions') !!}
        </div>
    </div>

    <footer class="page-footer">
        <p>© {{ date('Y') }} {{ config('settings.application.company_name') }}. All rights reserved.</p>
        <p style="margin-top:8px;">
            <a href="{{ url('/') }}">Home</a>
            <a href="{{ url('privacy-policy') }}">Privacy Policy</a>
            <a href="{{ url('support') }}">Support</a>
        </p>
    </footer>

</body>
</html>
