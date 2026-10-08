<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    {{-- Light/dark follows the theme preset selected in the admin panel. --}}
    <script>
        (function () {
            if ('{{ active_theme()['mode'] }}' === 'dark') document.documentElement.classList.add('dark');
        })();
    </script>

    @php
        $seoTitle   = !empty($s['seo_title'])       ? $s['seo_title']       : (($s['app_name'] ?? 'Zabi') . ' - ' . ($s['hero_title'] ?? 'Your Complete') . ' ' . ($s['hero_subtitle'] ?? 'Islamic Companion'));
        $seoDesc    = !empty($s['seo_description'])  ? $s['seo_description']  : Str::limit($s['hero_description'] ?? '', 160);
        $ogTitle    = !empty($s['seo_og_title'])     ? $s['seo_og_title']     : $seoTitle;
        $ogDesc     = !empty($s['seo_og_description'])  ? $s['seo_og_description']  : $seoDesc;
        $twTitle    = !empty($s['seo_twitter_title']) ? $s['seo_twitter_title'] : $ogTitle;
        $twDesc     = !empty($s['seo_twitter_description']) ? $s['seo_twitter_description'] : $ogDesc;
        $ogImage    = !empty($s['seo_og_image']) ? asset($s['seo_og_image']) : (!empty($s['web_logo']) ? asset($s['web_logo']) : null);
    @endphp

    <title>{{ $seoTitle }}</title>
    <meta name="description" content="{{ $seoDesc }}">
    @if(!empty($s['seo_keywords']))<meta name="keywords" content="{{ $s['seo_keywords'] }}">@endif
    <meta name="robots" content="{{ $s['seo_robots'] ?? 'index,follow' }}">
    @if(!empty($s['seo_canonical_url']))<link rel="canonical" href="{{ $s['seo_canonical_url'] }}">@endif
    @if(!empty($s['seo_google_verification']))<meta name="google-site-verification" content="{{ $s['seo_google_verification'] }}">@endif

    <meta property="og:type" content="website">
    <meta property="og:site_name" content="{{ $s['app_name'] ?? 'Zabi' }}">
    <meta property="og:title" content="{{ $ogTitle }}">
    <meta property="og:description" content="{{ $ogDesc }}">
    @if($ogImage)<meta property="og:image" content="{{ $ogImage }}">@endif
    @if(!empty($s['seo_canonical_url']))<meta property="og:url" content="{{ $s['seo_canonical_url'] }}">@endif

    <meta name="twitter:card" content="{{ $s['seo_twitter_card'] ?? 'summary_large_image' }}">
    <meta name="twitter:title" content="{{ $twTitle }}">
    <meta name="twitter:description" content="{{ $twDesc }}">
    @if($ogImage)<meta name="twitter:image" content="{{ $ogImage }}">@endif

    <link rel="icon" href="{{ asset('favicon.ico') }}">

    @if(!empty($s['seo_google_analytics']))
    <script async src="https://www.googletagmanager.com/gtag/js?id={{ $s['seo_google_analytics'] }}"></script>
    <script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','{{ $s['seo_google_analytics'] }}');</script>
    @endif

    <!-- Fonts: Inter, Amiri (Quran), Cairo (Arabic UI), Noto Sans Bengali, Noto Sans Devanagari (Hindi) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&family=Cairo:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600;700;800;900&family=Noto+Sans+Bengali:wght@300;400;500;600;700&family=Noto+Sans+Devanagari:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://t.contentsquare.net/uxa/2fd348fa4e3b8.js"></script>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        // Brand shades pull from the active theme (see partials/theme-vars).
                        emerald: {
                            950: 'var(--theme-primary)',
                            900: 'var(--theme-primary)',
                            800: 'var(--theme-secondary)',
                            700: 'var(--theme-secondary)',
                            600: 'var(--theme-secondary)',
                            500: 'var(--theme-secondary)',
                            400: 'var(--theme-secondary)',
                        },
                        green: {
                            500: 'var(--theme-secondary)',
                            400: 'var(--theme-secondary)',
                        },
                        gold: {
                            300: 'var(--theme-accent)',
                            400: 'var(--theme-accent)',
                            500: 'var(--theme-accent)',
                            600: 'var(--theme-accent)',
                        }
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        arabic: ['Amiri', 'serif'],
                    }
                }
            }
        }
    </script>

    <style>
        :root {
            --green-dark: #0a2e1e;
            --green-mid: #1a5c38;
            --green-light: #2d7a50;
            --gold: #d4a843;
            --gold-light: #f0c060;

            /* Light-mode tokens for content sections that support dark mode */
            --lp-border: #f0f0f0;
            --lp-surface: #ffffff;
            --lp-input-bg: #f9fafb;
            --lp-track: #f0f0f0;
            --lp-accent: var(--green-mid);
            --lp-text-soft: #6b7280;
            --lp-flash-bg: #d4edda;
        }

        html.dark {
            --lp-border: rgba(255,255,255,0.09);
            --lp-surface: var(--theme-card);
            /* A tone between page and card so alternating sections don't merge into one flat slab */
            --lp-section-alt: color-mix(in srgb, var(--theme-card) 55%, var(--theme-page));
            --lp-input-bg: var(--theme-muted-bg);
            --lp-track: rgba(255,255,255,0.14);
            --lp-accent: var(--gold);
            --lp-text-soft: #b6c2cf;
            --lp-text-faint: #8b97a4;
            --lp-flash-bg: rgba(var(--theme-accent-rgb),0.22);
        }

        /* Landing-only: when the on-page toggle turns dark mode on over a LIGHT preset,
           the preset's --theme-* colors are still light, so supply real dark surfaces
           here. A dark preset (data-theme-mode="dark") keeps its own hand-picked colors.
           This rule lives in the landing page's <style>, so the admin panel is unaffected. */
        html.dark[data-theme-mode="light"] {
            --theme-text: #f1f5f9;
            --theme-text-muted: #aeb9c4;
            --theme-text-faint: #8b97a4;
            --theme-card: #141c19;
            --theme-muted-bg: #0f1613;
            --theme-page: #0c1211;
            --theme-border: rgba(255,255,255,0.10);
        }

        html { scroll-behavior: smooth; }

        body { font-family: 'Inter', sans-serif; }

        html.dark body { background-color: var(--theme-page); color: #f1f5f9; }

        /* ── Dark mode: content sections (brand sections like Hero/Donation/AI stay dark always) ── */
        html.dark section.lp-theme { background-color: var(--theme-page); color: #e6ebf2; }

        /* Section rhythm: alternate elevation so consecutive sections read as distinct bands */
        html.dark section.lp-theme.bg-white  { background-color: var(--lp-section-alt) !important; }
        html.dark section.lp-theme.bg-gray-50 { background-color: var(--theme-page) !important; }

        /* Surfaces / cards */
        html.dark section.lp-theme .bg-white { background-color: var(--lp-surface) !important; }
        html.dark section.lp-theme .bg-gray-50 { background-color: var(--theme-page) !important; }
        html.dark section.lp-theme .bg-gray-100 { background-color: rgba(255,255,255,0.06) !important; }
        html.dark section.lp-theme .bg-gray-200 { background-color: rgba(255,255,255,0.12) !important; }

        /* Depth: cards get a subtle top highlight, a defined border and a real drop shadow
           so they lift off the page instead of blending into one flat surface. */
        html.dark section.lp-theme .card-hover,
        html.dark section.lp-theme #prayer-card,
        html.dark section.lp-theme .shadow-lg,
        html.dark section.lp-theme .shadow-xl,
        html.dark section.lp-theme .shadow-2xl {
            border-color: var(--lp-border) !important;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.05), 0 10px 30px rgba(0,0,0,0.45) !important;
        }
        html.dark section.lp-theme .card-hover:hover {
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.07), 0 22px 48px rgba(0,0,0,0.6) !important;
        }

        /* Icon tiles: pale pastel gradients look washed-out on dark, so swap them for a
           consistent frosted tile. Emoji glyphs keep their own color. */
        html.dark section.lp-theme .feature-icon,
        html.dark section.lp-theme .lp-tile {
            background: rgba(255,255,255,0.06) !important;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.08) !important;
        }

        /* Text contrast */
        html.dark section.lp-theme .text-gray-900,
        html.dark section.lp-theme h1,
        html.dark section.lp-theme h2,
        html.dark section.lp-theme h3,
        html.dark section.lp-theme h4 { color: #f5f8fc !important; }
        html.dark section.lp-theme .text-gray-700,
        html.dark section.lp-theme .text-gray-600,
        html.dark section.lp-theme .text-gray-500 { color: var(--lp-text-soft) !important; }
        html.dark section.lp-theme .text-gray-400,
        html.dark section.lp-theme .text-gray-300 { color: var(--lp-text-faint) !important; }
        html.dark section.lp-theme .text-emerald-700 { color: #34d399 !important; }
        html.dark section.lp-theme .border-gray-50,
        html.dark section.lp-theme .border-gray-100,
        html.dark section.lp-theme .border-gray-200 { border-color: var(--lp-border) !important; }
        html.dark section.lp-theme .hover\:bg-gray-100:hover { background-color: rgba(255,255,255,0.08) !important; }

        /* Light pastel chip → theme-tinted so it doesn't glow against the dark panel */
        html.dark #qa-surah-place { background: rgba(52,211,153,0.16) !important; color: #6ee7b7 !important; }

        html.dark #ng-error { background: rgba(239,68,68,0.15) !important; color: #fca5a5 !important; }
        html.dark #qa-progress-track { background-color: var(--lp-track) !important; }
        html.dark .wave-fill { fill: var(--theme-page); }

        /* Islamic geometric pattern background */
        .pattern-bg {
            background-color: var(--green-dark);
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='80' viewBox='0 0 80 80'%3E%3Cg fill='none' stroke='%23ffffff08' stroke-width='1'%3E%3Cpath d='M40 0 L80 40 L40 80 L0 40 Z'/%3E%3Cpath d='M40 10 L70 40 L40 70 L10 40 Z'/%3E%3Cpath d='M40 20 L60 40 L40 60 L20 40 Z'/%3E%3Ccircle cx='40' cy='40' r='20'/%3E%3Ccircle cx='0' cy='0' r='15'/%3E%3Ccircle cx='80' cy='0' r='15'/%3E%3Ccircle cx='0' cy='80' r='15'/%3E%3Ccircle cx='80' cy='80' r='15'/%3E%3C/g%3E%3C/svg%3E");
        }

        .hero-gradient {
            background: linear-gradient(135deg, var(--green-dark) 0%, var(--green-mid) 50%, var(--green-dark) 100%);
        }

        .gold-gradient {
            background: linear-gradient(135deg, var(--gold), var(--gold-light), var(--gold));
        }

        .card-hover {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card-hover:hover {
            transform: translateY(-6px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.12);
        }

        .feature-icon {
            width: 64px;
            height: 64px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 16px;
        }

        /* Phone mockup */
        .phone-mockup {
            width: 240px;
            height: 480px;
            background: linear-gradient(145deg, #1a1a2e, #16213e);
            border-radius: 40px;
            border: 8px solid #2d3748;
            box-shadow: 0 40px 80px rgba(0,0,0,0.5), inset 0 0 0 1px rgba(255,255,255,0.1);
            position: relative;
            overflow: hidden;
        }

        .phone-mockup::before {
            content: '';
            position: absolute;
            top: 14px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 6px;
            background: #4a5568;
            border-radius: 3px;
        }

        .phone-screen {
            position: absolute;
            inset: 0;
            background: linear-gradient(160deg, var(--green-dark) 0%, var(--green-mid) 100%);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .stat-counter {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--gold), var(--gold-light));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Animate on scroll */
        .reveal {
            opacity: 0;
            transform: translateY(30px);
            transition: opacity 0.6s ease, transform 0.6s ease;
        }
        .reveal.visible {
            opacity: 1;
            transform: translateY(0);
        }

        /* Navbar */
        .navbar-scrolled {
            background: rgba(var(--theme-primary-rgb), 0.95) !important;
            backdrop-filter: blur(12px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }

        /* Pulse animation for download buttons */
        @keyframes pulse-gold {
            0%, 100% { box-shadow: 0 0 0 0 rgba(var(--theme-accent-rgb), 0.4); }
            50% { box-shadow: 0 0 0 12px rgba(var(--theme-accent-rgb), 0); }
        }
        .btn-pulse {
            animation: pulse-gold 2.5s infinite;
        }

        /* Floating particles */
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }
        .float-1 { animation: float 6s ease-in-out infinite; }
        .float-2 { animation: float 8s ease-in-out infinite 1s; }
        .float-3 { animation: float 7s ease-in-out infinite 2s; }

        .section-divider {
            width: 60px;
            height: 4px;
            background: linear-gradient(90deg, var(--gold), var(--gold-light));
            border-radius: 2px;
            margin: 0 auto 24px;
        }

        /* Arabic text glow */
        .arabic-glow {
            text-shadow: 0 0 40px rgba(var(--theme-accent-rgb), 0.3);
        }

        /* Mobile menu */
        #mobile-menu { display: none; }
        #mobile-menu.open { display: block; }

        /* ── Language switcher ── */
        #lang-menu { display: none; }
        #lang-menu.open { display: block; }
        .lang-option { text-align: left; background: none; border: none; cursor: pointer; }
        .lang-option.active-lang { background: rgba(255,255,255,0.12) !important; }
        [dir="rtl"] .lang-option { text-align: right; }

        /* ── Donation Form ───────────────────────────────────── */
        .donate-label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 6px;
            letter-spacing: 0.2px;
        }

        .donate-input {
            width: 100%;
            padding: 10px 14px;
            border: 1.5px solid #e5e7eb;
            border-radius: 10px;
            font-size: 13px;
            color: #111827;
            background: #f9fafb;
            outline: none;
            transition: border-color .15s, box-shadow .15s;
            appearance: none;
            -webkit-appearance: none;
        }
        .donate-input:focus {
            border-color: var(--gold);
            box-shadow: 0 0 0 3px rgba(var(--theme-accent-rgb),.12);
            background: #fff;
        }
        .donate-input::placeholder { color: #9ca3af; }

        /* remove browser number-input arrows & red validation ring */
        .donate-input[type=number]::-webkit-inner-spin-button,
        .donate-input[type=number]::-webkit-outer-spin-button { -webkit-appearance: none; margin: 0; }
        .donate-input[type=number] { -moz-appearance: textfield; }
        .donate-input:invalid { box-shadow: none; }

        .donate-input-wrap { position: relative; }
        .donate-input-prefix {
            position: absolute; left: 13px; top: 50%; transform: translateY(-50%);
            font-size: 13px; color: #6b7280; pointer-events: none; font-weight: 500;
        }
        .donate-input-suffix {
            position: absolute; right: 12px; top: 50%; transform: translateY(-50%);
            pointer-events: none; display: flex; align-items: center;
        }
        .donate-input-prefixed  { padding-left: 26px; }
        .donate-select          { padding-right: 32px; cursor: pointer; }

        /* Preset amount buttons */
        .donate-preset-btn {
            padding: 9px 4px;
            border-radius: 10px;
            border: 1.5px solid #e5e7eb;
            background: #f9fafb;
            color: #374151;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all .15s;
        }
        .donate-preset-btn:hover { border-color: var(--gold); color: #92400e; }

        /* Payment method cards */
        .donate-payment-card {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            padding: 10px 4px;
            border: 1.5px solid #e5e7eb;
            border-radius: 12px;
            background: #fff;
            cursor: pointer;
            transition: all .15s;
        }
        .donate-payment-card:hover { border-color: var(--gold); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,.06); }
        .donate-gw-icon {
            width: 34px; height: 34px;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .donate-gw-label {
            font-size: 10px;
            font-weight: 600;
            color: #6b7280;
            text-align: center;
            line-height: 1.2;
        }
        .donate-check {
            display: none;
            position: absolute;
            top: -5px; right: -5px;
            width: 16px; height: 16px;
            border-radius: 50%;
            background: var(--gold);
            align-items: center; justify-content: center;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── AI Chat scrollbar ── */
        #ai-chat-messages::-webkit-scrollbar { width: 4px; }
        #ai-chat-messages::-webkit-scrollbar-track { background: transparent; }
        #ai-chat-messages::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.08); border-radius: 2px; }

        /* ── RTL overrides ── */
        [dir="rtl"] body { font-family: 'Cairo', sans-serif; }
        [dir="rtl"] .section-divider.ltr-left { margin-right: 0; margin-left: auto; }
        [dir="rtl"] #navbar > div { flex-direction: row-reverse; }
        [dir="rtl"] .lp-ltr-only { direction: ltr; }
        [dir="rtl"] .footer-brand { direction: rtl; }
    </style>

    {{-- Active theme colors + light/dark mode (overrides the fallbacks above) --}}
    @include('partials.theme-vars')
</head>

<body class="bg-white text-gray-900">

    <!-- ===================== NAVBAR ===================== -->
    <nav id="navbar" class="fixed top-0 left-0 right-0 z-50 transition-all duration-300 py-4 px-6">
        <div class="max-w-7xl mx-auto flex items-center justify-between">
            <!-- Logo -->
            <a href="{{ url('/') }}" class="flex items-center gap-3">
                @if(!empty($s['web_logo']))
                    <img src="{{ asset($s['web_logo']) }}" alt="{{ $s['app_name'] }}" class="h-10 w-auto max-w-[160px] object-contain" />
                @else
                    <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">
                        <span class="text-xl">🕌</span>
                    </div>
                @endif
                {{-- <span class="text-white font-bold text-2xl tracking-tight">{{ $s['app_name'] }}</span> --}}
            </a>

            <!-- Desktop Nav -->
            <div class="hidden md:flex items-center gap-8">
                <a href="#features" class="text-white/80 hover:text-white transition-colors text-sm font-medium" data-i18n="nav.features">Features</a>
                <a href="#quran" class="text-white/80 hover:text-white transition-colors text-sm font-medium" data-i18n="nav.quran">Quran</a>
                <a href="#quran-audio" class="text-white/80 hover:text-white transition-colors text-sm font-medium" data-i18n="nav.listen">Listen</a>
                <a href="#prayer" class="text-white/80 hover:text-white transition-colors text-sm font-medium" data-i18n="nav.prayer">Prayer</a>
                <a href="#ai" class="text-white/80 hover:text-white transition-colors text-sm font-medium" data-i18n="nav.ai">AI</a>
                <a href="#download" class="text-white/80 hover:text-white transition-colors text-sm font-medium" data-i18n="nav.download">Download</a>
                <a href="#donate" class="text-white/80 hover:text-white transition-colors text-sm font-medium" data-i18n="nav.donate">Donate</a>
            </div>

            <!-- CTA + Language Switcher -->
            <div class="hidden md:flex items-center gap-3">
                <!-- Language switcher -->
                <div class="relative" id="lang-dropdown">
                    <button onclick="toggleLangDropdown(event)" class="flex items-center gap-1.5 text-white/70 hover:text-white text-xs font-semibold transition-colors px-3 py-2 rounded-lg hover:bg-white/10 border border-white/20">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        <span id="current-lang-label">EN</span>
                        <svg class="w-2.5 h-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7"/></svg>
                    </button>
                    <div id="lang-menu" class="absolute top-full right-0 mt-2 py-1.5 w-44 rounded-2xl shadow-2xl z-50" style="background: rgba(8,38,24,0.98); backdrop-filter: blur(16px); border: 1px solid rgba(255,255,255,0.12);">
                        <button onclick="setLanguage('en')" class="lang-option w-full flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-white/10 transition-colors" data-lang="en">
                            <span>🇬🇧</span><span class="text-white/90">English</span>
                        </button>
                        <button onclick="setLanguage('ar')" class="lang-option w-full flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-white/10 transition-colors" data-lang="ar">
                            <span>🇸🇦</span><span class="text-white/90">العربية</span>
                        </button>
                        <button onclick="setLanguage('bn')" class="lang-option w-full flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-white/10 transition-colors" data-lang="bn">
                            <span>🇧🇩</span><span class="text-white/90">বাংলা</span>
                        </button>
                        <button onclick="setLanguage('hi')" class="lang-option w-full flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-white/10 transition-colors" data-lang="hi">
                            <span>🇮🇳</span><span class="text-white/90">हिंदी</span>
                        </button>
                        <button onclick="setLanguage('es')" class="lang-option w-full flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-white/10 transition-colors" data-lang="es">
                            <span>🇪🇸</span><span class="text-white/90">Español</span>
                        </button>
                        <button onclick="setLanguage('fr')" class="lang-option w-full flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-white/10 transition-colors" data-lang="fr">
                            <span>🇫🇷</span><span class="text-white/90">Français</span>
                        </button>
                    </div>
                </div>
                <!-- Theme toggle -->
                <button onclick="toggleTheme()" class="flex items-center justify-center w-9 h-9 rounded-lg text-white/70 hover:text-white transition-colors hover:bg-white/10 border border-white/20" title="Toggle theme" aria-label="Toggle theme">
                    <svg class="theme-icon-sun hidden w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
                    <svg class="theme-icon-moon w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/></svg>
                </button>
                @if($showAdminLogin)
                <a href="{{ route('login') }}" class="text-white/80 hover:text-white text-sm font-medium transition-colors" data-i18n="nav.admin">Admin Login</a>
                @endif
                <a href="#download" class="px-5 py-2.5 rounded-full text-sm font-semibold text-gray-900 transition-all hover:scale-105"
                   style="background: linear-gradient(135deg, var(--gold), var(--gold-light));" data-i18n="nav.download_btn">
                    Download Free
                </a>
            </div>

            <!-- Mobile hamburger -->
            <button id="menu-btn" class="md:hidden text-white" onclick="toggleMenu()">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                </svg>
            </button>
        </div>

        <!-- Mobile Menu -->
        <div id="mobile-menu" class="md:hidden mt-4 rounded-2xl p-4" style="background: rgba(var(--theme-primary-rgb),0.95); backdrop-filter: blur(12px);">
            <a href="#features" class="block py-2 px-4 text-white/80 hover:text-white" onclick="toggleMenu()" data-i18n="nav.features">Features</a>
            <a href="#quran" class="block py-2 px-4 text-white/80 hover:text-white" onclick="toggleMenu()" data-i18n="nav.quran">Quran</a>
            <a href="#quran-audio" class="block py-2 px-4 text-white/80 hover:text-white" onclick="toggleMenu()" data-i18n="nav.listen">Listen</a>
            <a href="#prayer" class="block py-2 px-4 text-white/80 hover:text-white" onclick="toggleMenu()" data-i18n="nav.prayer">Prayer</a>
            <a href="#ai" class="block py-2 px-4 text-white/80 hover:text-white" onclick="toggleMenu()" data-i18n="nav.ai">AI</a>
            <a href="#download" class="block py-2 px-4 text-white/80 hover:text-white" onclick="toggleMenu()" data-i18n="nav.download">Download</a>
            <a href="#donate" class="block py-2 px-4 text-white/80 hover:text-white" onclick="toggleMenu()" data-i18n="nav.donate">Donate</a>
            <!-- Mobile language grid -->
            <div class="mt-3 pt-3 border-t border-white/10">
                <p class="text-white/40 text-xs px-4 mb-2 uppercase tracking-wider">Language</p>
                <div class="grid grid-cols-3 gap-1 px-2">
                    <button onclick="setLanguage('en');toggleMenu()" class="lang-option flex items-center gap-1.5 px-2 py-2 rounded-lg text-xs text-white/80 hover:bg-white/10" data-lang="en">🇬🇧 EN</button>
                    <button onclick="setLanguage('ar');toggleMenu()" class="lang-option flex items-center gap-1.5 px-2 py-2 rounded-lg text-xs text-white/80 hover:bg-white/10" data-lang="ar">🇸🇦 AR</button>
                    <button onclick="setLanguage('bn');toggleMenu()" class="lang-option flex items-center gap-1.5 px-2 py-2 rounded-lg text-xs text-white/80 hover:bg-white/10" data-lang="bn">🇧🇩 BN</button>
                    <button onclick="setLanguage('hi');toggleMenu()" class="lang-option flex items-center gap-1.5 px-2 py-2 rounded-lg text-xs text-white/80 hover:bg-white/10" data-lang="hi">🇮🇳 HI</button>
                    <button onclick="setLanguage('es');toggleMenu()" class="lang-option flex items-center gap-1.5 px-2 py-2 rounded-lg text-xs text-white/80 hover:bg-white/10" data-lang="es">🇪🇸 ES</button>
                    <button onclick="setLanguage('fr');toggleMenu()" class="lang-option flex items-center gap-1.5 px-2 py-2 rounded-lg text-xs text-white/80 hover:bg-white/10" data-lang="fr">🇫🇷 FR</button>
                </div>
            </div>
            <div class="mt-3 pt-3 border-t border-white/10">
                <button onclick="toggleTheme()" class="w-full flex items-center justify-between py-2 px-4 text-white/80 hover:text-white">
                    <span class="text-sm font-medium">Theme</span>
                    <span class="flex items-center gap-1.5">
                        <svg class="theme-icon-sun hidden w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
                        <svg class="theme-icon-moon w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/></svg>
                    </span>
                </button>
            </div>
            <div class="mt-3 pt-3 border-t border-white/10 flex gap-3">
                @if($showAdminLogin)
                <a href="{{ route('login') }}" class="flex-1 text-center py-2 rounded-full text-white/80 border border-white/20 text-sm" data-i18n="nav.admin">Admin Login</a>
                @endif
                <a href="#download" class="flex-1 text-center py-2 rounded-full text-gray-900 text-sm font-semibold" style="background: linear-gradient(135deg, var(--gold), var(--gold-light));" data-i18n="nav.download_btn">Download</a>
            </div>
        </div>
    </nav>

    <!-- ===================== HERO ===================== -->
    <section class="hero-gradient pattern-bg min-h-screen flex items-center relative overflow-hidden">
        <!-- Decorative circles -->
        <div class="absolute top-32 right-16 w-64 h-64 rounded-full opacity-10 float-1" style="background: radial-gradient(circle, var(--gold), transparent);"></div>
        <div class="absolute bottom-32 left-8 w-48 h-48 rounded-full opacity-10 float-2" style="background: radial-gradient(circle, var(--gold), transparent);"></div>
        <div class="absolute top-1/2 left-1/3 w-32 h-32 rounded-full opacity-5 float-3" style="background: radial-gradient(circle, #ffffff, transparent);"></div>

        <div class="max-w-7xl mx-auto px-6 py-32 grid lg:grid-cols-2 gap-16 items-center w-full">
            <!-- Text content -->
            <div>
                <!-- Bismillah -->
                <div class="font-arabic text-gold-400 text-3xl mb-6 arabic-glow" style="color: var(--gold);">
                    بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ
                </div>

                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-semibold mb-6" style="background: rgba(var(--theme-accent-rgb),0.15); color: var(--gold); border: 1px solid rgba(var(--theme-accent-rgb),0.3);">
                    <span class="w-2 h-2 rounded-full bg-green-400 animate-pulse"></span>
                    <span data-i18n="hero.badge" data-i18n-en="{{ $s['hero_badge_text'] }}">{{ $s['hero_badge_text'] }}</span>
                </div>

                <h1 class="text-5xl lg:text-6xl font-black text-white leading-tight mb-6">
                    <span data-i18n="hero.title" data-i18n-en="{{ $s['hero_title'] }}">{{ $s['hero_title'] }}</span>
                    <span class="block" style="background: linear-gradient(135deg, var(--gold), var(--gold-light)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">
                        <span data-i18n="hero.subtitle" data-i18n-en="{{ $s['hero_subtitle'] }}">{{ $s['hero_subtitle'] }}</span>
                    </span>
                </h1>

                <p class="text-white/70 text-lg leading-relaxed mb-10 max-w-xl" data-i18n="hero.description" data-i18n-en="{{ $s['hero_description'] }}">
                    {{ $s['hero_description'] }}
                </p>

                <!-- CTA Buttons -->
                <div class="flex flex-wrap gap-4 mb-10">
                    <a href="{{ $s['app_store_url'] }}" class="inline-flex items-center gap-3 px-6 py-4 rounded-2xl text-gray-900 font-bold text-base btn-pulse transition-all hover:scale-105"
                       style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">
                        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                        </svg>
                        <span data-i18n="hero.app_store">App Store</span>
                    </a>
                    <a href="{{ $s['play_store_url'] }}" class="inline-flex items-center gap-3 px-6 py-4 rounded-2xl font-bold text-base transition-all hover:scale-105"
                       style="background: rgba(255,255,255,0.1); color: white; border: 1px solid rgba(255,255,255,0.2); backdrop-filter: blur(8px);">
                        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M3.18 23.76c.27.15.58.2.89.13l12.89-7.43-2.77-2.76-11.01 10.06zm-.99-20.29v18.06c0 .36.1.69.28.97l10.32-10.32L2.19 2.5c-.0 .0-.0.0-.0 0zm16.12 6.77l-2.44-1.41-3.08 3.09 3.09 3.09 2.44-1.41c.7-.4 1.12-1.15 1.12-1.68 0-.53-.42-1.27-1.13-1.68zm-14.7-8.47c.04-.01.08-.01.12-.01.31 0 .61.09.87.26l12.01 6.93-2.76 2.76L4.44.73c-.31-.18-.66-.21-.93-.05l-.0-.91z"/>
                        </svg>
                        <span data-i18n="hero.play_store">Google Play</span>
                    </a>
                </div>

                <!-- Trust badges -->
                <div class="flex flex-wrap items-center gap-6 text-white/50 text-sm">
                    <div class="flex items-center gap-2">
                        <span class="text-yellow-400">★★★★★</span>
                        <span>{{ $s['rating'] }} <span data-i18n="hero.rating_label">Rating</span></span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span>📥</span>
                        <span>{{ $s['downloads_count'] }} <span data-i18n="hero.downloads_label">Downloads</span></span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span>🌍</span>
                        <span>{{ $s['languages_count'] }} <span data-i18n="hero.languages_label">Languages</span></span>
                    </div>
                </div>
            </div>

            <!-- Phone Mockups -->
            <div class="hidden lg:flex items-center justify-center gap-6 relative">
                <!-- Main phone -->
                <div class="phone-mockup float-1">
                    <div class="phone-screen">
                        <div class="font-arabic text-center text-gold-400 text-xl mb-4" style="color: var(--gold);">
                            قُلْ هُوَ اللَّهُ أَحَدٌ
                        </div>
                        <div class="text-white/60 text-xs text-center mb-6">Surah Al-Ikhlas • Ayah 1</div>
                        <div class="w-full space-y-2">
                            <div class="h-2 rounded-full bg-white/20 w-3/4 mx-auto"></div>
                            <div class="h-2 rounded-full bg-white/10 w-full mx-auto"></div>
                            <div class="h-2 rounded-full bg-white/15 w-5/6 mx-auto"></div>
                        </div>
                        <div class="mt-8 flex gap-3 justify-center">
                            <div class="w-8 h-8 rounded-full flex items-center justify-center" style="background: rgba(var(--theme-accent-rgb),0.2);">
                                <span class="text-sm">▶</span>
                            </div>
                            <div class="w-8 h-8 rounded-full flex items-center justify-center" style="background: rgba(var(--theme-accent-rgb),0.2);">
                                <span class="text-sm">🔖</span>
                            </div>
                            <div class="w-8 h-8 rounded-full flex items-center justify-center" style="background: rgba(var(--theme-accent-rgb),0.2);">
                                <span class="text-sm">↗</span>
                            </div>
                        </div>
                        <!-- Prayer times mini card -->
                        <div class="mt-6 w-full rounded-xl p-3" style="background: rgba(255,255,255,0.08);">
                            <div class="text-white/60 text-xs mb-2">Next Prayer</div>
                            <div class="flex justify-between items-center">
                                <span class="text-white font-semibold text-sm">Asr</span>
                                <span style="color: var(--gold);" class="font-bold text-sm">04:30 PM</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Second phone (offset) -->
                <div class="phone-mockup float-2" style="width: 200px; height: 400px; margin-top: 60px;">
                    <div class="phone-screen">
                        <div class="text-white/70 text-xs mb-4 text-center">Prayer Times</div>
                        <!-- Clock mockup -->
                        <div class="w-20 h-20 rounded-full flex items-center justify-center relative mx-auto mb-4" style="background: linear-gradient(135deg, rgba(var(--theme-accent-rgb),0.18), rgba(var(--theme-accent-rgb),0.05)); border: 2px solid rgba(var(--theme-accent-rgb),0.3);">
                            <span class="text-3xl">🕌</span>
                        </div>
                        <div class="text-white font-bold text-center mb-1">Makkah</div>
                        <div class="text-white/50 text-xs text-center mb-4">Saturday, June 20</div>
                        <div class="space-y-2">
                            @foreach([['Fajr','05:12',false], ['Dhuhr','12:30',false], ['Asr','04:30',true], ['Maghrib','07:15',false], ['Isha','08:45',false]] as [$name, $time, $isNext])
                            <div class="flex justify-between items-center gap-2 px-3 py-1.5 rounded-lg" style="{{ $isNext ? 'background: rgba(var(--theme-accent-rgb),0.15); border: 1px solid rgba(var(--theme-accent-rgb),0.3);' : '' }}">
                                <span class="text-xs {{ $isNext ? 'text-white font-semibold' : 'text-white/60' }}">{{ $name }}</span>
                                <span class="text-xs font-bold" style="color: {{ $isNext ? 'var(--gold)' : '#fff' }};">{{ $time }}</span>
                            </div>
                            @endforeach
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Wave divider -->
        <div class="absolute bottom-0 left-0 right-0">
            <svg viewBox="0 0 1440 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path class="wave-fill" d="M0 80L48 69.3C96 59 192 37 288 32C384 27 480 37 576 48C672 59 768 69 864 69.3C960 69 1056 59 1152 48C1248 37 1344 27 1392 21.3L1440 16V80H1392C1344 80 1248 80 1152 80C1056 80 960 80 864 80C768 80 672 80 576 80C480 80 384 80 288 80C192 80 96 80 48 80H0Z" fill="white"/>
            </svg>
        </div>
    </section>

    <!-- ===================== STATS ===================== -->
    <section id="stats" class="py-16 bg-white lp-theme">
        <div class="max-w-6xl mx-auto px-6">
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-8 text-center">
                <div class="reveal">
                    <div class="stat-counter">114</div>
                    <p class="text-gray-500 mt-1 font-medium" data-i18n="stats.surahs">Surahs of Quran</p>
                </div>
                <div class="reveal" style="transition-delay: 0.1s;">
                    <div class="stat-counter">{{ $s['languages_count'] }}</div>
                    <p class="text-gray-500 mt-1 font-medium" data-i18n="stats.languages">Languages</p>
                </div>
                <div class="reveal" style="transition-delay: 0.2s;">
                    <div class="stat-counter">{{ $s['rating'] }}</div>
                    <p class="text-gray-500 mt-1 font-medium" data-i18n="stats.rating">App Rating</p>
                </div>
                <div class="reveal" style="transition-delay: 0.3s;">
                    <div class="stat-counter">{{ $s['downloads_count'] }}</div>
                    <p class="text-gray-500 mt-1 font-medium" data-i18n="stats.downloads">Downloads</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ===================== DONATION ===================== -->
    <section id="donate" class="py-14 relative overflow-hidden" style="background: linear-gradient(135deg, var(--green-dark) 0%, var(--green-mid) 100%);">
        <div class="max-w-6xl mx-auto px-6 relative">
            <div class="text-center mb-8 reveal">
                <div class="section-divider"></div>
                <h2 class="text-3xl font-black text-white mb-2" data-i18n="donate.title" data-i18n-en="{{ $s['donation_title'] ?? 'Support Our Mission' }}">{{ $s['donation_title'] ?? 'Support Our Mission' }}</h2>
                <p class="text-white/60 text-sm max-w-xl mx-auto" data-i18n="donate.desc" data-i18n-en="{{ $s['donation_description'] ?? 'Your generosity keeps Zabi free for millions of Muslims worldwide.' }}">{{ $s['donation_description'] ?? 'Your generosity keeps Zabi free for millions of Muslims worldwide.' }}</p>
            </div>

            <div class="grid lg:grid-cols-5 gap-8 items-start">
                <!-- Left: Why Donate -->
                <div class="lg:col-span-2 reveal space-y-4">
                    <div class="rounded-xl p-4" style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.1);">
                        <div class="font-arabic text-center text-white/90 text-lg leading-loose mb-2" dir="rtl" data-i18n-en="{{ $s['donation_verse_arabic'] }}">
                            {{ $s['donation_verse_arabic'] }}
                        </div>
                        <p class="text-white/50 text-center text-xs" data-i18n="donate.verse_trans" data-i18n-en="{{ $s['donation_verse_translation'] }}">{{ $s['donation_verse_translation'] }}</p>
                    </div>

                    <div class="space-y-3">
                        @foreach($s['donation_why'] as $i => $item)
                        <div class="flex items-center gap-3">
                            <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 text-sm" style="background: rgba(var(--theme-accent-rgb),0.2);">{{ $item['icon'] ?? '' }}</div>
                            <div>
                                <h4 class="font-semibold text-white text-xs mb-0.5" data-i18n="donate.why.{{ $i }}.title" data-i18n-en="{{ $item['title'] ?? '' }}">{{ $item['title'] ?? '' }}</h4>
                                <p class="text-white/50 text-xs" data-i18n="donate.why.{{ $i }}.desc" data-i18n-en="{{ $item['description'] ?? '' }}">{{ $item['description'] ?? '' }}</p>
                            </div>
                        </div>
                        @endforeach
                    </div>

                    <div>
                        <p class="text-white/40 text-xs uppercase tracking-wider mb-2" data-i18n="donate.accepted" data-i18n-en="{{ $s['donation_accepted_label'] }}">{{ $s['donation_accepted_label'] }}</p>
                        <div class="flex flex-wrap gap-1.5">
                            @foreach(array_filter(array_map('trim', explode("\n", $s['donation_gateways'] ?? ''))) as $gw)
                            <span class="px-2.5 py-1 rounded-full text-xs font-semibold" style="background:var(--green-mid);color:#fff;border:1px solid rgba(255,255,255,0.18);">{{ $gw }}</span>
                            @endforeach
                        </div>
                    </div>
                </div>

                <!-- Right: Donation Form -->
                <div class="lg:col-span-3 reveal" style="transition-delay:0.2s;">
                    <div class="bg-white rounded-2xl shadow-xl overflow-hidden">

                        <!-- Form header -->
                        <div class="px-6 pt-6 pb-5 border-b" style="border-color:#f3f4f6;">
                            <h3 class="text-gray-900 font-bold text-base mb-0.5" data-i18n="donate.form_title">Make a Donation</h3>
                            <p class="text-gray-400 text-xs" data-i18n="donate.form_subtitle">Every contribution makes a difference</p>
                        </div>

                        <div class="px-6 py-5 space-y-4">

                            <!-- Amount -->
                            <div>
                                <label class="donate-label" data-i18n="donate.amount_label">Select Amount</label>
                                <div class="grid grid-cols-4 gap-2 mb-2">
                                    @foreach([10, 25, 50, 100] as $preset)
                                    <button type="button" onclick="selectDonationAmount({{ $preset }})"
                                        class="donate-preset-btn"
                                        data-amount="{{ $preset }}">${{ $preset }}</button>
                                    @endforeach
                                </div>
                                <div class="donate-input-wrap">
                                    <span class="donate-input-prefix">$</span>
                                    <input type="number" id="donate-amount" min="1"
                                        class="donate-input donate-input-prefixed"
                                        placeholder="Enter custom amount"
                                        oninput="clearDonationPresets()">
                                </div>
                            </div>

                            <!-- Category + Name side by side -->
                            <div class="grid grid-cols-2 gap-3">
                                <div>
                                    <label class="donate-label" data-i18n="donate.category_label">Category</label>
                                    <div class="donate-input-wrap">
                                        <select id="donate-category" class="donate-input donate-select">
                                            <option value="">Select a cause…</option>
                                        </select>
                                        <span class="donate-input-suffix">
                                            <svg class="w-3.5 h-3.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
                                        </span>
                                    </div>
                                </div>
                                <div>
                                    <label class="donate-label" data-i18n="donate.name_label">Your Name</label>
                                    <input type="text" id="donate-name"
                                        class="donate-input"
                                        placeholder="Optional">
                                </div>
                            </div>

                            <!-- Email -->
                            <div>
                                <label class="donate-label"><span data-i18n="donate.email_label" data-i18n-en="Email Address">Email Address</span> <span style="color:#ef4444;">*</span></label>
                                <input type="email" id="donate-email"
                                    class="donate-input"
                                    placeholder="you@example.com">
                            </div>

                            <!-- Payment Method -->
                            <div>
                                <label class="donate-label" data-i18n="donate.payment_label">Payment Method</label>
                                <div id="donate-payment-grid" class="grid grid-cols-5 gap-2">
                                    @foreach([
                                        ['razorpay',   'Razorpay',   '#1a237e'],
                                        ['paystack',   'Paystack',   '#00695c'],
                                        ['stripe',     'Stripe',     '#635BFF'],
                                        ['paypal',     'PayPal',     '#003087'],
                                        ['sslcommerz', 'SSLCommerz', '#c62828'],
                                    ] as $gw)
                                    <button type="button"
                                        class="donate-payment-card"
                                        data-gateway="{{ $gw[0] }}"
                                        onclick="selectPaymentGateway('{{ $gw[0] }}')">
                                        <div class="donate-gw-icon" style="background:{{ $gw[2] }};">
                                            @if($gw[0]==='razorpay')
                                                <svg viewBox="0 0 24 24" fill="white" width="14" height="14"><path d="M21 3L3 10.53v.98l6.84 2.65L21 3zm0 0l-8.16 9.95 3 1.15L21 3z"/></svg>
                                            @elseif($gw[0]==='paystack')
                                                <svg viewBox="0 0 24 24" fill="white" width="14" height="14"><path d="M2 8h20v2.5H2zm0 5h20V15.5H2zm0 5h12V20.5H2z"/></svg>
                                            @elseif($gw[0]==='stripe')
                                                <svg viewBox="0 0 24 24" fill="white" width="14" height="14"><path d="M13.976 9.15c-2.172-.806-3.356-1.426-3.356-2.409 0-.831.683-1.305 1.901-1.305 2.227 0 4.515.858 6.09 1.631l.89-5.494C18.252.975 15.697 0 12.165 0 9.667 0 7.589.654 6.104 1.872 4.56 3.147 3.757 4.992 3.757 7.218c0 4.039 2.467 5.76 6.476 7.219 2.585.92 3.445 1.574 3.445 2.583 0 .98-.84 1.545-2.354 1.545-1.875 0-4.965-.921-6.99-2.109l-.9 5.555C5.175 22.99 8.385 24 11.714 24c2.641 0 4.843-.624 6.328-1.813 1.664-1.305 2.525-3.236 2.525-5.732 0-4.128-2.524-5.851-6.594-7.305h.003z"/></svg>
                                            @elseif($gw[0]==='paypal')
                                                <svg viewBox="0 0 24 24" fill="white" width="14" height="14"><path d="M7.076 21.337H2.47a.641.641 0 0 1-.633-.74L4.944.901C5.026.382 5.474 0 5.998 0h7.46c2.57 0 4.578.543 5.69 1.81 1.01 1.15 1.304 2.42 1.012 4.287-.023.143-.047.288-.077.437-.983 5.05-4.349 6.797-8.647 6.797h-2.19c-.524 0-.968.382-1.05.9l-1.12 7.106zm14.146-14.42a3.35 3.35 0 0 0-.607-.541c-.013.076-.026.175-.041.254-.93 4.778-4.005 7.201-9.138 7.201h-2.19a.563.563 0 0 0-.556.479l-1.187 7.527h-.506l-.24 1.516a.56.56 0 0 0 .554.647h3.882c.46 0 .85-.334.922-.788.06-.26.76-4.852.816-5.09a.932.932 0 0 1 .923-.788h.58c3.76 0 6.705-1.528 7.565-5.946.36-1.847.174-3.388-.777-4.471z"/></svg>
                                            @else
                                                <svg viewBox="0 0 24 24" fill="white" width="14" height="14"><path d="M20 4H4c-1.11 0-2 .89-2 2v12c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4v-6h16v6zm0-10H4V6h16v2z"/></svg>
                                            @endif
                                        </div>
                                        <span class="donate-gw-label">{{ $gw[1] }}</span>
                                        <div class="donate-check">
                                            <svg fill="none" stroke="white" stroke-width="3" viewBox="0 0 24 24" width="8" height="8"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                                        </div>
                                    </button>
                                    @endforeach
                                </div>
                            </div>

                            <!-- PayPal button container -->
                            <div id="paypal-button-container" class="hidden"></div>

                            <!-- Submit -->
                            <button id="donate-submit-btn" onclick="submitDonation()" type="button"
                                class="w-full py-3 rounded-xl font-bold text-gray-900 text-sm transition-all hover:opacity-90 hover:shadow-lg"
                                style="background:linear-gradient(135deg,var(--gold),var(--gold-light));">
                                <span id="donate-btn-text" data-i18n="donate.btn">Donate Now</span>
                                <span id="donate-btn-loader" class="hidden ml-2">
                                    <svg class="inline w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path>
                                    </svg>
                                </span>
                            </button>

                            <div id="donate-feedback" class="hidden px-4 py-3 rounded-xl text-xs font-medium text-center"></div>

                        </div>

                        <!-- Form footer -->
                        <div class="px-6 py-3 border-t text-center" style="border-color:#f3f4f6;background:#fafafa;">
                            <p class="text-gray-400 text-xs" data-i18n="donate.privacy_note">🔒 Secure & encrypted. We never store card details.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ===================== FEATURES GRID ===================== -->
    <section id="features" class="py-24 bg-gray-50 lp-theme">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center mb-16 reveal">
                <div class="section-divider"></div>
                <h2 class="text-4xl font-black text-gray-900 mb-4" data-i18n="features.title" data-i18n-en="{{ $s['features_title'] }}">{{ $s['features_title'] }}</h2>
                <p class="text-gray-500 text-lg max-w-2xl mx-auto" data-i18n="features.desc" data-i18n-en="{{ $s['features_description'] }}">
                    {{ $s['features_description'] }}
                </p>
            </div>

            @php
                $defaultFeatures = [
                    ['icon'=>'📖','title'=>'Quran & Islamic Content','description'=>'Complete Al-Quran reading experience with multi-language translations, audio recitation, transliteration, and ayah sharing.','bullets'=>"4 Language Translations\nAudio Quran Support\nTransliteration Feature\nHadith & Dua Collections\nAllah's 99 Names"],
                    ['icon'=>'🕌','title'=>'Prayer & Worship','description'=>'Accurate prayer times, customizable schedules, Adhan notifications with multiple reciters, and Qibla finder with compass.','bullets'=>"Accurate Prayer Times\nAdhan Notifications\nQibla Finder & Compass\nRamadan Schedule\nMultiple Adhan Reciters"],
                    ['icon'=>'🤖','title'=>'AI-Powered Features','description'=>'Get answers to Islamic questions instantly with our AI Islamic Chat and generate beautiful Islamic names for your family.','bullets'=>"AI Islamic Q&A Chat\nIslamic Name Generator\nSmart Recommendations\nInstant Responses\n24/7 Availability"],
                    ['icon'=>'📍','title'=>'Mosque & Location','description'=>'Find nearby mosques using GPS, get navigation assistance, and manage location permissions easily.','bullets'=>"Nearby Mosque Finder\nGPS Navigation\nReal-time Location\nCity-based Prayer Times"],
                    ['icon'=>'💰','title'=>'Islamic Finance & Charity','description'=>'Calculate your Zakat accurately with customizable Nisab settings and support charitable causes through the donation module.','bullets'=>"Zakat Calculator\nCustomizable Nisab\nDonation Module\nMultiple Currencies"],
                    ['icon'=>'🎨','title'=>'Personalization','description'=>'Make the app yours with dark mode, RTL support, dynamic wallpapers, custom dhikr, dua, and 40+ language options.','bullets'=>"Dark Mode Support\nRTL Language Support\nDynamic Wallpapers\nCustom Dhikr & Dua"],
                ];
                $featureCards = !empty($s['features']) ? $s['features'] : $defaultFeatures;
                $delays = ['0s','0.1s','0.2s','0.1s','0.2s','0.3s'];
                $isDark = fn($i) => $i === 2;
            @endphp
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                @foreach($featureCards as $i => $card)
                    @if($isDark($i))
                        <div class="rounded-3xl p-8 card-hover reveal" style="background: linear-gradient(135deg, var(--green-dark), var(--green-mid)); transition-delay: {{ $delays[$i] ?? '0s' }};">
                            <div class="feature-icon" style="background: rgba(var(--theme-accent-rgb),0.2);">{{ $card['icon'] }}</div>
                            <h3 class="text-xl font-bold text-white mb-3" data-i18n="feature.{{ $i }}.title" data-i18n-en="{{ $card['title'] }}">{{ $card['title'] }}</h3>
                            <p class="text-white/70 text-sm leading-relaxed mb-4" data-i18n="feature.{{ $i }}.desc" data-i18n-en="{{ $card['description'] }}">{{ $card['description'] }}</p>
                            <ul class="space-y-2 text-sm text-white/80" data-feature-bullets="{{ $i }}" data-en-bullets="{{ trim($card['bullets']) }}">
                                @foreach(array_filter(explode("\n", $card['bullets'])) as $bullet)
                                    <li class="flex items-center gap-2"><span style="color: var(--gold);">✓</span> {{ trim($bullet) }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @else
                        <div class="bg-white rounded-3xl p-8 card-hover reveal" style="border: 1px solid var(--lp-border); transition-delay: {{ $delays[$i] ?? '0s' }};">
                            <div class="feature-icon" style="background: linear-gradient(135deg, #f0f4ff, #e0e7ff);">{{ $card['icon'] }}</div>
                            <h3 class="text-xl font-bold text-gray-900 mb-3" data-i18n="feature.{{ $i }}.title" data-i18n-en="{{ $card['title'] }}">{{ $card['title'] }}</h3>
                            <p class="text-gray-500 text-sm leading-relaxed mb-4" data-i18n="feature.{{ $i }}.desc" data-i18n-en="{{ $card['description'] }}">{{ $card['description'] }}</p>
                            <ul class="space-y-2 text-sm text-gray-600" data-feature-bullets="{{ $i }}" data-en-bullets="{{ trim($card['bullets']) }}">
                                @foreach(array_filter(explode("\n", $card['bullets'])) as $bullet)
                                    <li class="flex items-center gap-2"><span style="color: var(--lp-accent);">✓</span> {{ trim($bullet) }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @endif
                @endforeach
            </div>
        </div>
    </section>

    <!-- ===================== QURAN HIGHLIGHT ===================== -->
    <section id="quran" class="py-24 bg-white overflow-hidden lp-theme">
        <div class="max-w-7xl mx-auto px-6">
            <div class="grid lg:grid-cols-2 gap-16 items-center">

                <!-- Visual -->
                <div class="reveal order-2 lg:order-1">
                    <div class="rounded-3xl p-8 relative overflow-hidden" style="background: linear-gradient(135deg, var(--green-dark), var(--green-mid));">
                        <!-- Decorative Arabic text -->
                        <div class="font-arabic text-white/10 text-7xl absolute -top-4 -right-4 select-none">ق</div>

                        <div class="font-arabic text-center text-white/90 text-2xl leading-loose mb-6" dir="rtl">
                            وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ فَهَلْ مِن مُّدَّكِرٍ
                        </div>
                        <p class="text-white/60 text-center text-sm mb-8" data-i18n="quran.verse_trans">
                            "And We have certainly made the Quran easy for remembrance, so is there any who will remember?" — Al-Qamar 54:17
                        </p>

                        <!-- Feature pills -->
                        <div class="flex flex-wrap gap-2 justify-center">
                            @foreach(['English', 'Bangla', 'Arabic', 'Spanish', 'Transliteration', 'Audio'] as $lang)
                            <span class="px-3 py-1.5 rounded-full text-xs font-medium" style="background: rgba(var(--theme-accent-rgb),0.2); color: var(--gold); border: 1px solid rgba(var(--theme-accent-rgb),0.3);">
                                {{ $lang }}
                            </span>
                            @endforeach
                        </div>

                        <!-- Divider -->
                        <div class="my-6 border-t border-white/10"></div>

                        <!-- Progress bar mockup -->
                        <div class="space-y-3">
                            <div class="flex justify-between text-xs text-white/50">
                                <span>Reading Progress</span>
                                <span>Juz 12 / 30</span>
                            </div>
                            <div class="h-2 rounded-full bg-white/10">
                                <div class="h-2 rounded-full" style="width: 40%; background: linear-gradient(90deg, var(--gold), var(--gold-light));"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Text -->
                <div class="reveal order-1 lg:order-2" style="transition-delay: 0.2s;">
                    <div class="section-divider" style="margin-left: 0;"></div>
                    <h2 class="text-4xl font-black text-gray-900 mb-6">
                        <span data-i18n="quran.title" data-i18n-en="{{ $s['quran_title'] }}">{{ $s['quran_title'] }}</span><br>
                        <span style="color: var(--lp-accent);" data-i18n="quran.highlight" data-i18n-en="{{ $s['quran_title_highlight'] }}">{{ $s['quran_title_highlight'] }}</span>
                    </h2>
                    <p class="text-gray-500 text-lg leading-relaxed mb-8" data-i18n="quran.description" data-i18n-en="{{ $s['quran_description'] }}">
                        {{ $s['quran_description'] }}
                    </p>

                    <div class="space-y-4">
                        <div class="flex items-start gap-4">
                            <div class="lp-tile w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 text-lg" style="background: linear-gradient(135deg, #d4edda, #a8e6cf);">📗</div>
                            <div>
                                <h4 class="font-semibold text-gray-900 mb-1" data-i18n="quran.surah_title">Complete 114 Surahs</h4>
                                <p class="text-gray-500 text-sm" data-i18n="quran.surah_desc">All 6,236 ayahs with multiple recitation styles and verse-by-verse audio.</p>
                            </div>
                        </div>
                        <div class="flex items-start gap-4">
                            <div class="lp-tile w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 text-lg" style="background: linear-gradient(135deg, #fef3c7, #fde68a);">🔊</div>
                            <div>
                                <h4 class="font-semibold text-gray-900 mb-1" data-i18n="quran.audio_title">Audio Quran</h4>
                                <p class="text-gray-500 text-sm" data-i18n="quran.audio_desc">Listen to world-renowned reciters with offline support and background play.</p>
                            </div>
                        </div>
                        <div class="flex items-start gap-4">
                            <div class="lp-tile w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 text-lg" style="background: linear-gradient(135deg, #dbeafe, #bfdbfe);">🔖</div>
                            <div>
                                <h4 class="font-semibold text-gray-900 mb-1" data-i18n="quran.bookmark_title">Bookmarks & History</h4>
                                <p class="text-gray-500 text-sm" data-i18n="quran.bookmark_desc">Save your place, bookmark favorite verses, and continue where you left off.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ===================== QURAN AUDIO PLAYER ===================== -->
    <section id="quran-audio" class="py-12 lg:py-24 bg-gray-50 lp-theme">
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
            <div class="text-center mb-8 lg:mb-12 reveal">
                <div class="section-divider"></div>
                <h2 class="text-3xl lg:text-4xl font-black text-gray-900 mb-3">
                    <span data-i18n="quran_audio.title">Read &amp; Listen </span><span style="color: var(--lp-accent);" data-i18n="quran_audio.highlight">Together</span>
                </h2>
                <p class="text-gray-500 text-base lg:text-lg max-w-2xl mx-auto" data-i18n="quran_audio.desc">
                    Follow along with Arabic text while listening to world-renowned reciters — verse by verse.
                </p>
            </div>

            <div class="rounded-2xl lg:rounded-3xl overflow-hidden shadow-2xl reveal" style="border: 1px solid var(--lp-border);">

                <!-- Top bar -->
                <div class="px-4 py-3 lg:px-5 lg:py-4" style="background: linear-gradient(135deg, var(--green-dark), var(--green-mid));">
                    <!-- Row 1 on mobile / single row on desktop: selects side by side -->
                    <div class="flex gap-2 mb-2">
                        <div class="flex-1 relative">
                            <select id="qa-surah-select"
                                class="w-full appearance-none rounded-xl px-3 py-2.5 text-sm font-medium outline-none pr-8"
                                style="background: rgba(255,255,255,0.12); color: white; border: 1px solid rgba(255,255,255,0.2);"
                                onchange="qaLoadSurah(this.value)">
                                <option value="" disabled selected style="background:var(--green-dark);">Select a Surah…</option>
                            </select>
                            <svg class="absolute right-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-white/60 pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
                        </div>
                        <div class="flex-1 relative">
                            <select id="qa-reciter-select"
                                class="w-full appearance-none rounded-xl px-3 py-2.5 text-sm font-medium outline-none pr-8"
                                style="background: rgba(255,255,255,0.12); color: white; border: 1px solid rgba(255,255,255,0.2);"
                                onchange="qaLoadAudio()">
                                <option value="" disabled selected style="background:var(--green-dark);">Select a Reciter…</option>
                            </select>
                            <svg class="absolute right-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-white/60 pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
                        </div>
                    </div>
                    <!-- Row 2: Translator tabs -->
                    <div id="qa-translator-tabs"
                        class="flex gap-1.5 overflow-x-auto mb-2"
                        style="-webkit-overflow-scrolling: touch; scrollbar-width: none;">
                        <span class="text-white/30 text-xs py-1.5 flex-shrink-0">Loading translators…</span>
                    </div>

                    <!-- Row 3: action buttons -->
                    <div class="flex gap-2">
                        <button id="qa-trans-toggle" onclick="qaToggleTranslation()"
                            class="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all"
                            style="background: rgba(var(--theme-accent-rgb),0.2); color: var(--gold); border: 1px solid rgba(var(--theme-accent-rgb),0.3);">
                            <svg class="w-3.5 h-3.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129"/></svg>
                            Translation
                        </button>
                        <!-- Mobile-only: toggle verse index panel -->
                        <button id="qa-idx-toggle" onclick="qaToggleIndex()"
                            class="lg:hidden flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all"
                            style="background: rgba(255,255,255,0.1); color: rgba(255,255,255,0.8); border: 1px solid rgba(255,255,255,0.2);">
                            <svg class="w-3.5 h-3.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
                            Verse List
                        </button>
                    </div>
                </div>

                <!-- Main body -->
                <div class="flex flex-col lg:grid lg:grid-cols-3">

                    <!-- Left: verse index — hidden on mobile, collapsible via "Verse List" button -->
                    <div id="qa-index-container"
                        class="hidden lg:block lg:col-span-1 overflow-y-auto border-b lg:border-b-0 lg:border-r"
                        style="max-height: 260px; border-color: var(--lp-border); background: var(--lp-input-bg);">
                        <div id="qa-surah-header" class="px-4 py-3 border-b sticky top-0 z-10" style="border-color: var(--lp-border); background: var(--lp-surface);">
                            <div id="qa-surah-arabic" class="font-arabic text-xl text-gray-900 text-right mb-0.5 leading-relaxed" dir="rtl">—</div>
                            <div id="qa-surah-english" class="text-gray-400 text-xs">Select a surah to begin</div>
                            <div class="flex items-center gap-2 mt-1.5">
                                <span id="qa-surah-place" class="text-xs px-2 py-0.5 rounded-full" style="background:#d4edda; color:var(--green-mid);"></span>
                                <span id="qa-surah-count" class="text-xs text-gray-400"></span>
                            </div>
                        </div>
                        <div id="qa-verse-index" class="divide-y" style="divide-color: #f5f5f5;">
                            <div class="p-6 text-center text-gray-300 text-sm">Verses will appear here</div>
                        </div>
                    </div>

                    <!-- Right: verse reading + player (always visible) -->
                    <div class="lg:col-span-2 flex flex-col">
                        <!-- Bismillah -->
                        <div id="qa-bismillah" class="hidden text-center py-4 border-b" style="border-color: var(--lp-border);">
                            <span class="font-arabic text-xl lg:text-2xl" style="color: var(--lp-accent);">بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ</span>
                        </div>

                        <!-- Verses scroll area -->
                        <div id="qa-verses" class="overflow-y-auto px-4 py-4 lg:p-6 space-y-4 lg:space-y-5"
                            style="min-height: 200px; max-height: 300px; background: var(--lp-surface);">
                            <div id="qa-placeholder" class="flex flex-col items-center justify-center py-10 text-center">
                                <div class="font-arabic text-4xl mb-3" style="color: var(--gold);">﷽</div>
                                <p class="text-gray-400 text-sm max-w-xs">Choose a Surah and a Reciter to start reading and listening.</p>
                            </div>
                            <div id="qa-loading" class="hidden flex-col items-center justify-center py-10">
                                <svg class="w-7 h-7 animate-spin mb-3" style="color:var(--lp-accent);" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path></svg>
                                <p class="text-gray-400 text-sm">Loading verses…</p>
                            </div>
                        </div>

                        <!-- Audio player -->
                        <div id="qa-player" class="border-t px-4 pt-3 pb-4 lg:px-5" style="border-color: var(--lp-border); background: var(--lp-surface);">
                            <audio id="qa-audio" preload="none" onended="qaOnAudioEnded()" onloadedmetadata="qaOnMetadata()"></audio>

                            <!-- Visualizer canvas -->
                            <canvas id="qa-canvas" class="w-full mb-2.5 rounded-xl"
                                style="display:none; height:56px; background: linear-gradient(135deg, #0d2618 0%, #0a1e12 100%); box-shadow: inset 0 1px 0 rgba(255,255,255,0.04), 0 1px 3px rgba(0,0,0,0.12);"></canvas>

                            <!-- Progress bar — always full width -->
                            <div class="mb-2.5">
                                <div id="qa-progress-track" class="relative h-2 rounded-full cursor-pointer" style="background: #f0f0f0;" onclick="qaSeek(event, this)">
                                    <div id="qa-progress-bar" class="h-2 rounded-full" style="width:0%; background: linear-gradient(90deg, var(--lp-accent), var(--gold-light));"></div>
                                </div>
                                <div class="flex justify-between items-center text-xs text-gray-400 mt-1">
                                    <span id="qa-current-time">0:00</span>
                                    <span id="qa-no-audio" class="italic text-center px-2">Select reciter for audio</span>
                                    <span id="qa-duration">0:00</span>
                                </div>
                            </div>

                            <!-- Controls row -->
                            <div class="flex items-center gap-2">
                                <!-- Avatar (sm+) -->
                                <img id="qa-reciter-avatar" src="" alt=""
                                    class="hidden sm:block w-8 h-8 rounded-full object-cover flex-shrink-0"
                                    style="border: 2px solid var(--gold);">

                                <!-- Playback buttons — centered -->
                                <div class="flex items-center gap-1 mx-auto">
                                    <button onclick="qaPrevSurah()" class="w-8 h-8 rounded-full flex items-center justify-center hover:bg-gray-100 transition-all" title="Previous Surah">
                                        <svg class="w-4 h-4 text-gray-500" fill="currentColor" viewBox="0 0 24 24"><path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/></svg>
                                    </button>
                                    <button onclick="qaSkipBackward()" class="w-7 h-7 rounded-full flex items-center justify-center hover:bg-gray-100 transition-all" title="−10s">
                                        <svg class="w-3.5 h-3.5 text-gray-400" fill="currentColor" viewBox="0 0 24 24"><path d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/></svg>
                                    </button>
                                    <button id="qa-play-btn" onclick="qaTogglePlay()"
                                        class="w-11 h-11 rounded-full flex items-center justify-center flex-shrink-0 mx-1 hover:scale-105 transition-all"
                                        style="background: linear-gradient(135deg, var(--green-dark), var(--green-mid));" disabled>
                                        <svg id="qa-icon-play" class="w-4 h-4 text-white ml-0.5" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                                        <svg id="qa-icon-pause" class="hidden w-4 h-4 text-white" fill="currentColor" viewBox="0 0 24 24"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
                                        <svg id="qa-icon-loading" class="hidden w-4 h-4 text-white animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path></svg>
                                    </button>
                                    <button onclick="qaSkipForward()" class="w-7 h-7 rounded-full flex items-center justify-center hover:bg-gray-100 transition-all" title="+10s">
                                        <svg class="w-3.5 h-3.5 text-gray-400" fill="currentColor" viewBox="0 0 24 24"><path d="M12 5V1l5 5-5 5V7c-3.31 0-6 2.69-6 6s2.69 6 6 6 6-2.69 6-6h2c0 4.42-3.58 8-8 8s-8-3.58-8-8 3.58-8 8-8z"/></svg>
                                    </button>
                                    <button onclick="qaNextSurah()" class="w-8 h-8 rounded-full flex items-center justify-center hover:bg-gray-100 transition-all" title="Next Surah">
                                        <svg class="w-4 h-4 text-gray-500" fill="currentColor" viewBox="0 0 24 24"><path d="M6 18l8.5-6L6 6v12zm2-8.14L11.03 12 8 14.14V9.86zM16 6h2v12h-2z"/></svg>
                                    </button>
                                </div>

                                <!-- Volume — hidden on mobile -->
                                <div class="hidden sm:flex items-center gap-1.5 flex-shrink-0">
                                    <svg class="w-4 h-4 text-gray-400 flex-shrink-0" fill="currentColor" viewBox="0 0 24 24"><path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/></svg>
                                    <input type="range" id="qa-volume" min="0" max="100" value="80"
                                        class="w-16 h-1.5 rounded-full appearance-none cursor-pointer"
                                        style="accent-color: var(--lp-accent);"
                                        oninput="qaSetVolume(this.value)">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <p class="text-center text-gray-400 text-sm mt-5" data-i18n="quran.offline_note" data-i18n-en="{{ $s['quran_offline_note'] }}">
                {{ $s['quran_offline_note'] }}
            </p>
        </div>
    </section>

    <!-- ===================== PRAYER TIMES HIGHLIGHT ===================== -->
    <section id="prayer" class="py-24 bg-gray-50 lp-theme">
        <div class="max-w-7xl mx-auto px-6">
            <div class="grid lg:grid-cols-2 gap-16 items-center">

                <!-- Text -->
                <div class="reveal">
                    <div class="section-divider" style="margin-left: 0;"></div>
                    <h2 class="text-4xl font-black text-gray-900 mb-6">
                        <span data-i18n="prayer.title" data-i18n-en="{{ $s['prayer_title'] }}">{{ $s['prayer_title'] }}</span><br>
                        <span style="color: var(--lp-accent);" data-i18n="prayer.highlight" data-i18n-en="{{ $s['prayer_title_highlight'] }}">{{ $s['prayer_title_highlight'] }}</span>
                    </h2>
                    <p class="text-gray-500 text-lg leading-relaxed mb-8" data-i18n="prayer.description" data-i18n-en="{{ $s['prayer_description'] }}">
                        {{ $s['prayer_description'] }}
                    </p>

                    <div class="grid grid-cols-2 gap-4">
                        <div class="bg-white rounded-2xl p-4 card-hover" style="border: 1px solid var(--lp-border);">
                            <div class="text-2xl mb-2">🧭</div>
                            <h4 class="font-semibold text-gray-900 text-sm mb-1" data-i18n="prayer.qibla_title">Qibla Finder</h4>
                            <p class="text-gray-500 text-xs" data-i18n="prayer.qibla_desc">Accurate compass with improved precision</p>
                        </div>
                        <div class="bg-white rounded-2xl p-4 card-hover" style="border: 1px solid var(--lp-border);">
                            <div class="text-2xl mb-2">🔔</div>
                            <h4 class="font-semibold text-gray-900 text-sm mb-1" data-i18n="prayer.adhan_title">Adhan Alerts</h4>
                            <p class="text-gray-500 text-xs" data-i18n="prayer.adhan_desc">Multiple beautiful reciters to choose from</p>
                        </div>
                        <div class="bg-white rounded-2xl p-4 card-hover" style="border: 1px solid var(--lp-border);">
                            <div class="text-2xl mb-2">🌙</div>
                            <h4 class="font-semibold text-gray-900 text-sm mb-1" data-i18n="prayer.ramadan_title">Ramadan Mode</h4>
                            <p class="text-gray-500 text-xs" data-i18n="prayer.ramadan_desc">Iftar & Sehri times for your city</p>
                        </div>
                        <div class="bg-white rounded-2xl p-4 card-hover" style="border: 1px solid var(--lp-border);">
                            <div class="text-2xl mb-2">⚙️</div>
                            <h4 class="font-semibold text-gray-900 text-sm mb-1" data-i18n="prayer.custom_title">Customizable</h4>
                            <p class="text-gray-500 text-xs" data-i18n="prayer.custom_desc">Manual adjustments & AM/PM format</p>
                        </div>
                    </div>
                </div>

                <!-- Prayer times visual -->
                <div class="reveal" style="transition-delay: 0.2s;">
                    <div id="prayer-card" class="bg-white rounded-3xl p-6 shadow-xl max-w-sm mx-auto" style="border: 1px solid var(--lp-border);">
                        <div class="flex items-center justify-between mb-6">
                            <div>
                                <p class="text-gray-400 text-xs" data-i18n="prayer.card_label">Today's Prayer Times</p>
                                <p id="prayer-city" class="font-bold text-gray-900">Detecting location…</p>
                            </div>
                            <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background: linear-gradient(135deg, var(--green-dark), var(--green-mid));">
                                <span class="text-lg">🌙</span>
                            </div>
                        </div>
                        <div id="prayer-rows"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ===================== AI FEATURES ===================== -->
    <section id="ai" class="py-24 overflow-hidden" style="background: linear-gradient(135deg, var(--green-dark), var(--green-mid));">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center mb-16 reveal">
                <div class="section-divider"></div>
                <h2 class="text-4xl font-black text-white mb-4" data-i18n="ai.title" data-i18n-en="{{ $s['ai_title'] }}">{{ $s['ai_title'] }}</h2>
                <p class="text-white/60 text-lg max-w-2xl mx-auto" data-i18n="ai.description" data-i18n-en="{{ $s['ai_description'] }}">
                    {{ $s['ai_description'] }}
                </p>
            </div>

            <div class="grid md:grid-cols-2 gap-8">
                <!-- AI Chat -->
                <div class="rounded-3xl p-8 reveal" style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.1);">
                    <div class="feature-icon" style="background: rgba(var(--theme-accent-rgb),0.2);">💬</div>
                    <h3 class="text-2xl font-bold text-white mb-4" data-i18n="ai.chat_title" data-i18n-en="{{ $s['ai_chat_card_title'] }}">{{ $s['ai_chat_card_title'] }}</h3>
                    <p class="text-white/60 leading-relaxed mb-6" data-i18n="ai.chat_desc" data-i18n-en="{{ $s['ai_chat_card_description'] }}">
                        {{ $s['ai_chat_card_description'] }}
                    </p>

                    <!-- Chat mockup -->
                    <div class="rounded-2xl p-4 space-y-3" style="background: rgba(0,0,0,0.2);">
                        <div class="flex gap-3">
                            <div class="w-7 h-7 rounded-full flex-shrink-0 flex items-center justify-center text-xs" style="background: rgba(var(--theme-accent-rgb),0.3);">👤</div>
                            <div class="rounded-xl rounded-tl-none px-3 py-2 text-sm text-white/80" style="background: rgba(255,255,255,0.1);">
                                <span data-i18n="ai.chat_q">What is the dua before eating?</span>
                            </div>
                        </div>
                        <div class="flex gap-3 justify-end">
                            <div class="rounded-xl rounded-tr-none px-3 py-2 text-sm text-gray-900 max-w-xs" style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">
                                <div class="font-arabic text-base mb-1">بِسْمِ اللَّهِ</div>
                                <span data-i18n="ai.chat_a">"Bismillah" — In the name of Allah. (Bukhari & Muslim)</span>
                            </div>
                            <div class="w-7 h-7 rounded-full flex-shrink-0 flex items-center justify-center text-xs" style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">🤖</div>
                        </div>
                    </div>
                </div>

                <!-- AI Name Generator -->
                <div class="rounded-3xl p-8 reveal" style="background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.1); transition-delay: 0.2s;">
                    <div class="feature-icon" style="background: rgba(var(--theme-accent-rgb),0.2);">✨</div>
                    <h3 class="text-2xl font-bold text-white mb-4" data-i18n="ai.name_title" data-i18n-en="{{ $s['ai_name_card_title'] }}">{{ $s['ai_name_card_title'] }}</h3>
                    <p class="text-white/60 leading-relaxed mb-6" data-i18n="ai.name_desc" data-i18n-en="{{ $s['ai_name_card_description'] }}">
                        {{ $s['ai_name_card_description'] }}
                    </p>

                    <!-- Name generator mockup -->
                    <div class="rounded-2xl p-4" style="background: rgba(0,0,0,0.2);">
                        <div class="mb-3">
                            <p class="text-white/40 text-xs mb-2" data-i18n="ai.name_label">Generated Names for Boys</p>
                        </div>
                        @foreach([
                            ['عبد الله', 'Abdullah', 'Servant of Allah'],
                            ['يوسف', 'Yusuf', 'To increase, God increases'],
                            ['إبراهيم', 'Ibrahim', 'Father of nations'],
                        ] as $name)
                        <div class="flex items-center justify-between py-2 border-b border-white/5 last:border-0">
                            <div>
                                <span class="font-arabic text-white text-lg">{{ $name[0] }}</span>
                                <span class="text-white/60 text-sm ml-2">{{ $name[1] }}</span>
                            </div>
                            <span class="text-white/40 text-xs">{{ $name[2] }}</span>
                        </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ===================== AI CHAT (LIVE) ===================== -->
    <section id="ai-chat" class="py-24" style="background: #040d06;">
        <div class="max-w-7xl mx-auto px-6">
            <div class="grid lg:grid-cols-2 gap-16 items-start">

                <!-- Left: Description -->
                <div class="reveal">
                    <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-semibold mb-6" style="background: rgba(var(--theme-accent-rgb),0.1); color: var(--gold); border: 1px solid rgba(var(--theme-accent-rgb),0.2);">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse inline-block"></span>
                        <span data-i18n="ai_chat.badge" data-i18n-en="{{ $s['ai_chat_badge'] }}">{{ $s['ai_chat_badge'] }}</span>
                    </div>
                    <h2 class="text-4xl font-black text-white mb-6 leading-tight">
                        <span data-i18n="ai_chat.title_line1" data-i18n-en="{{ $s['ai_chat_title_line1'] }}">{{ $s['ai_chat_title_line1'] }}</span><br>
                        <span style="background: linear-gradient(135deg, var(--gold), var(--gold-light)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;" data-i18n="ai_chat.title_line2" data-i18n-en="{{ $s['ai_chat_title_line2'] }}">{{ $s['ai_chat_title_line2'] }}</span>
                    </h2>
                    <p class="text-white/50 text-lg leading-relaxed mb-8" data-i18n="ai_chat.desc" data-i18n-en="{{ $s['ai_chat_description'] }}">
                        {{ $s['ai_chat_description'] }}
                    </p>

                    <div class="space-y-4 mb-8">
                        @foreach($s['ai_chat_features'] as $i => $feat)
                        <div class="flex items-start gap-3">
                            <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 text-sm mt-0.5" style="background: rgba(var(--theme-accent-rgb),0.12);">{{ $feat['icon'] ?? '' }}</div>
                            <div>
                                <p class="text-white font-semibold text-sm" data-i18n="ai_chat.feature.{{ $i }}.title" data-i18n-en="{{ $feat['title'] ?? '' }}">{{ $feat['title'] ?? '' }}</p>
                                <p class="text-white/40 text-xs mt-0.5" data-i18n="ai_chat.feature.{{ $i }}.desc" data-i18n-en="{{ $feat['description'] ?? '' }}">{{ $feat['description'] ?? '' }}</p>
                            </div>
                        </div>
                        @endforeach
                    </div>

                    <p class="text-white/30 text-xs uppercase tracking-wider mb-3" data-i18n="ai_chat.try_asking" data-i18n-en="{{ $s['ai_chat_try_label'] }}">{{ $s['ai_chat_try_label'] }}</p>
                    <div class="flex flex-wrap gap-2">
                        @foreach($s['ai_chat_suggestions'] as $sugg)
                        <button type="button" onclick="sendQuickChatQuestion(this.dataset.question)" data-question="{{ $sugg['question'] ?? '' }}" class="ai-quick-pill px-3 py-1.5 rounded-full text-xs border transition-all hover:border-yellow-500/50 hover:text-white/90" style="border-color: rgba(255,255,255,0.1); color: rgba(255,255,255,0.55);">{{ $sugg['label'] ?? '' }}</button>
                        @endforeach
                    </div>
                </div>

                <!-- Right: Chat Terminal -->
                <div class="reveal" style="transition-delay: 0.2s;">
                    <div class="rounded-2xl overflow-hidden" style="background: #0d1f14; border: 1px solid rgba(255,255,255,0.07);">
                        <!-- Window chrome -->
                        <div class="px-5 py-3.5 flex items-center gap-3" style="border-bottom: 1px solid rgba(255,255,255,0.06); background: rgba(255,255,255,0.02);">
                            <div class="flex items-center gap-1.5">
                                <div class="w-3 h-3 rounded-full bg-red-500/70"></div>
                                <div class="w-3 h-3 rounded-full bg-yellow-500/70"></div>
                                <div class="w-3 h-3 rounded-full bg-green-500/70"></div>
                            </div>
                            <div class="flex items-center gap-2 ml-2">
                                <div class="w-6 h-6 rounded-lg flex items-center justify-center text-xs" style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">🤖</div>
                                <span class="text-white/70 text-sm font-medium">Zabi AI</span>
                            </div>
                            <div class="ml-auto flex items-center gap-1.5">
                                <span class="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse inline-block"></span>
                                <span class="text-green-400 text-xs">Online</span>
                            </div>
                        </div>

                        <!-- Messages area -->
                        <div id="ai-chat-messages" class="p-5 space-y-4 overflow-y-auto" style="height: 360px; scrollbar-width: thin; scrollbar-color: rgba(255,255,255,0.08) transparent;">
                            <div class="flex gap-2.5">
                                <div class="w-6 h-6 rounded-lg flex-shrink-0 flex items-center justify-center text-xs mt-0.5" style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">🤖</div>
                                <div class="rounded-xl rounded-tl-none px-4 py-3 text-sm max-w-xs leading-relaxed" style="background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.80);">
                                    <span class="font-arabic text-base block mb-1" style="color:var(--gold);">السلام عليكم ورحمة الله</span>
                                    I'm Zabi AI. Ask me anything about Islam — Quran, Hadith, prayer, fiqh, duas, or Islamic lifestyle!
                                </div>
                            </div>
                        </div>

                        <!-- Input bar -->
                        <div class="p-4" style="border-top: 1px solid rgba(255,255,255,0.06);">
                            <div class="flex gap-2 items-end">
                                <textarea id="ai-chat-input" rows="1"
                                    placeholder="Ask an Islamic question…"
                                    class="flex-1 rounded-xl px-4 py-3 text-sm resize-none outline-none"
                                    style="background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.09); color: rgba(255,255,255,0.9); max-height: 100px; scrollbar-width: none;"
                                    onkeydown="handleAIChatKeydown(event)"
                                    oninput="this.style.height='auto';this.style.height=Math.min(this.scrollHeight,100)+'px'"></textarea>
                                <button id="ai-chat-send" onclick="sendAIChatMessage()"
                                    class="flex-shrink-0 w-10 h-10 rounded-xl flex items-center justify-center transition-all hover:scale-105 hover:shadow-lg"
                                    style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">
                                    <svg class="w-4 h-4 text-gray-900" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5"/></svg>
                                </button>
                            </div>
                        </div>
                    </div>
                    <p class="text-center text-white/20 text-xs mt-3">Responses are AI-generated for reference only • Always verify with a qualified scholar</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ===================== ISLAMIC NAME GENERATOR ===================== -->
    <section id="name-generator" class="py-24 bg-gray-50 lp-theme">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center mb-12 reveal">
                <div class="section-divider"></div>
                <h2 class="text-4xl font-black text-gray-900 mb-4">
                    <span data-i18n="name_gen.title" data-i18n-en="{{ $s['name_gen_title'] }} ">{{ $s['name_gen_title'] }} </span><span style="color: var(--lp-accent);" data-i18n="name_gen.highlight" data-i18n-en="{{ $s['name_gen_title_highlight'] }}">{{ $s['name_gen_title_highlight'] }}</span>
                </h2>
                <p class="text-gray-500 text-lg max-w-2xl mx-auto" data-i18n="name_gen.desc" data-i18n-en="{{ $s['name_gen_description'] }}">
                    {{ $s['name_gen_description'] }}
                </p>
            </div>

            <!-- Generator form -->
            <div class="max-w-lg mx-auto mb-10 reveal">
                <div class="bg-white rounded-2xl p-6 shadow-lg" style="border: 1px solid var(--lp-border);">
                    <div class="mb-5">
                        <label class="block text-sm font-semibold text-gray-700 mb-3" data-i18n="name_gen.label">Generate names for a</label>
                        <div class="grid grid-cols-2 gap-2">
                            <button type="button" onclick="selectNameGender('boy')" id="ng-btn-boy"
                                class="py-3 px-4 rounded-xl font-semibold text-sm transition-all border-2"
                                style="border-color: var(--green-mid); background: var(--green-mid); color: white;">
                                👦 Boy
                            </button>
                            <button type="button" onclick="selectNameGender('girl')" id="ng-btn-girl"
                                class="py-3 px-4 rounded-xl font-semibold text-sm transition-all border-2"
                                style="border-color: var(--lp-border); background: var(--lp-surface); color: var(--lp-text-soft);">
                                👧 Girl
                            </button>
                        </div>
                    </div>
                    <div class="mb-5">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">
                            <span data-i18n="name_gen.theme">Meaning Theme</span>
                            <span class="font-normal text-gray-400 ml-1" data-i18n="name_gen.optional">(optional)</span>
                        </label>
                        <input id="ng-theme" type="text"
                            placeholder="e.g. light, strength, wisdom, beauty…"
                            class="w-full px-4 py-3 rounded-xl text-sm outline-none transition-all"
                            style="border: 1.5px solid var(--lp-border); background: var(--lp-input-bg); color: var(--lp-text-soft);"
                            onfocus="this.style.borderColor='var(--lp-accent)';this.style.background='var(--lp-surface)'"
                            onblur="this.style.borderColor='var(--lp-border)';this.style.background='var(--lp-input-bg)'"
                            onkeydown="if(event.key==='Enter')generateIslamicNames()">
                    </div>
                    <button onclick="generateIslamicNames()" id="ng-generate-btn"
                        class="w-full py-3.5 rounded-xl font-bold text-sm transition-all flex items-center justify-center gap-2 hover:opacity-90 hover:shadow-lg"
                        style="background: linear-gradient(135deg, var(--green-dark), var(--green-mid)); color: white;">
                        <span id="ng-btn-text" data-i18n="name_gen.btn">✨ Generate Names</span>
                        <span id="ng-btn-loader" class="hidden">
                            <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path></svg>
                        </span>
                    </button>
                    <div id="ng-error" class="hidden mt-3 px-4 py-2.5 rounded-xl text-xs font-medium text-center" style="background: #fee2e2; color: #991b1b;"></div>
                </div>
            </div>

            <!-- Results -->
            <div id="ng-results-wrap" class="hidden reveal">
                <p class="text-center text-gray-400 text-sm mb-6" id="ng-results-label"></p>
                <div id="ng-names-grid" class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 max-w-5xl mx-auto"></div>
            </div>

            <!-- Static placeholder cards (shown before first generation) -->
            <div id="ng-placeholder" class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 max-w-5xl mx-auto reveal" style="transition-delay: 0.15s;">
                @foreach([
                    ['عبد الله','Abdullah','Servant of Allah','Arabic','boy'],
                    ['يوسف','Yusuf','God increases','Arabic','boy'],
                    ['إبراهيم','Ibrahim','Father of nations','Arabic','boy'],
                    ['فاطمة','Fatima','One who abstains','Arabic','girl'],
                    ['مريم','Maryam','Beloved, wished-for child','Arabic','girl'],
                    ['زينب','Zaynab','Fragrant flower','Arabic','girl'],
                ] as $pn)
                <div class="bg-white rounded-2xl p-5 card-hover" style="border: 1px solid var(--lp-border);">
                    <div class="flex items-start justify-between mb-3">
                        <span class="font-arabic text-2xl leading-none" style="color: var(--lp-accent);">{{ $pn[0] }}</span>
                        <span class="text-xs px-2 py-0.5 rounded-full font-medium" style="background: {{ $pn[4]==='boy' ? '#dbeafe' : '#fce7f3' }}; color: {{ $pn[4]==='boy' ? '#1d4ed8' : '#be185d' }};">{{ ucfirst($pn[4]) }}</span>
                    </div>
                    <p class="font-bold text-gray-900 text-base mb-1">{{ $pn[1] }}</p>
                    <p class="text-gray-500 text-sm leading-relaxed mb-2">{{ $pn[2] }}</p>
                    <p class="text-gray-400 text-xs">Origin: {{ $pn[3] }}</p>
                </div>
                @endforeach
            </div>
        </div>
    </section>

    <!-- ===================== DHIKR & DUA ===================== -->
    <section id="dhikr" class="py-24 bg-white lp-theme">
        <div class="max-w-7xl mx-auto px-6">
            <div class="text-center mb-16 reveal">
                <div class="section-divider"></div>
                <h2 class="text-4xl font-black text-gray-900 mb-4" data-i18n="dhikr.title" data-i18n-en="{{ $s['dhikr_title'] }}">{{ $s['dhikr_title'] }}</h2>
                <p class="text-gray-500 text-lg max-w-2xl mx-auto" data-i18n="dhikr.description" data-i18n-en="{{ $s['dhikr_description'] }}">
                    {{ $s['dhikr_description'] }}
                </p>
            </div>

            <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
                @foreach([
                    ['📿', 'Tasbih Counter', 'Digital dhikr counter with customizable phrases and haptic feedback.', '#d4edda', '#1a5c38', 'dhikr.tasbih', 'dhikr.tasbih_desc'],
                    ['🤲', 'Dua Collection', 'Comprehensive duas for morning, evening, travel, eating, and special occasions.', '#fef3c7', '#92400e', 'dhikr.dua', 'dhikr.dua_desc'],
                    ['💎', '99 Names of Allah', 'All Asma ul Husna with meanings, transliteration, and virtues.', '#ede9fe', '#6d28d9', 'dhikr.names', 'dhikr.names_desc'],
                    ['📜', 'Haram Code', 'Islamic guidance system to help you navigate everyday decisions.', '#fce7f3', '#9d174d', 'dhikr.haram', 'dhikr.haram_desc'],
                ] as $item)
                <div class="rounded-2xl p-6 card-hover reveal" style="background: {{ $item[3] }}20; border: 1px solid {{ $item[3] }}40;">
                    <div class="text-4xl mb-4">{{ $item[0] }}</div>
                    <h3 class="font-bold text-gray-900 mb-2" data-i18n="{{ $item[5] }}">{{ $item[1] }}</h3>
                    <p class="text-gray-500 text-sm leading-relaxed" data-i18n="{{ $item[6] }}">{{ $item[2] }}</p>
                </div>
                @endforeach
            </div>
        </div>
    </section>

    <!-- ===================== TECH SPECS ===================== -->
    <section id="tech-specs" class="py-20 bg-gray-50 lp-theme">
        <div class="max-w-6xl mx-auto px-6">
            <div class="text-center mb-12 reveal">
                <h2 class="text-3xl font-black text-gray-900 mb-3" data-i18n="tech.title" data-i18n-en="{{ $s['tech_title'] }}">{{ $s['tech_title'] }}</h2>
                <p class="text-gray-500" data-i18n="tech.subtitle" data-i18n-en="{{ $s['tech_subtitle'] }}">{{ $s['tech_subtitle'] }}</p>
            </div>
            <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
                @foreach($s['tech_specs'] as $i => $spec)
                <div class="bg-white rounded-2xl p-6 text-center card-hover reveal" style="border: 1px solid var(--lp-border);">
                    <div class="text-3xl mb-3">{{ $spec['icon'] ?? '' }}</div>
                    <h3 class="font-bold text-gray-900 mb-2 text-sm" data-i18n="tech.spec.{{ $i }}.title" data-i18n-en="{{ $spec['title'] ?? '' }}">{{ $spec['title'] ?? '' }}</h3>
                    <p class="text-gray-500 text-xs leading-relaxed" data-i18n="tech.spec.{{ $i }}.desc" data-i18n-en="{{ $spec['description'] ?? '' }}">{{ $spec['description'] ?? '' }}</p>
                </div>
                @endforeach
            </div>
        </div>
    </section>

    <!-- ===================== DOWNLOAD CTA ===================== -->
    <section id="download" class="py-24 hero-gradient pattern-bg relative overflow-hidden">
        <div class="absolute top-10 right-20 w-72 h-72 rounded-full opacity-5" style="background: radial-gradient(circle, var(--gold), transparent);"></div>
        <div class="absolute bottom-10 left-10 w-48 h-48 rounded-full opacity-5" style="background: radial-gradient(circle, #ffffff, transparent);"></div>

        <div class="max-w-4xl mx-auto px-6 text-center relative">
            <div class="reveal">
                <div class="font-arabic text-gold-400 text-3xl mb-6 arabic-glow" style="color: var(--gold);">
                    الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ
                </div>
                <h2 class="text-4xl lg:text-5xl font-black text-white mb-6">
                    <span data-i18n="download.title" data-i18n-en="{{ $s['download_title'] }}">{{ $s['download_title'] }}</span><br>
                    <span style="background: linear-gradient(135deg, var(--gold), var(--gold-light)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">
                        <span data-i18n="download.highlight" data-i18n-en="{{ $s['download_title_highlight'] }}">{{ $s['download_title_highlight'] }}</span>
                    </span>
                </h2>
                <p class="text-white/70 text-lg mb-10 max-w-2xl mx-auto" data-i18n="download.description" data-i18n-en="{{ $s['download_description'] }}">
                    {{ $s['download_description'] }}
                </p>

                <div class="flex flex-wrap justify-center gap-4 mb-12">
                    <!-- App Store button -->
                    <a href="{{ $s['app_store_url'] }}" class="inline-flex items-center gap-4 px-8 py-4 rounded-2xl transition-all hover:scale-105 btn-pulse"
                       style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">
                        <svg class="w-8 h-8 text-gray-900" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                        </svg>
                        <div class="text-left">
                            <div class="text-gray-900 text-xs" data-i18n="download.app_store_top">Download on the</div>
                            <div class="text-gray-900 font-bold text-lg leading-tight" data-i18n="download.app_store">App Store</div>
                        </div>
                    </a>

                    <!-- Google Play button -->
                    <a href="{{ $s['play_store_url'] }}" class="inline-flex items-center gap-4 px-8 py-4 rounded-2xl transition-all hover:scale-105"
                       style="background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25); backdrop-filter: blur(8px);">
                        <svg class="w-8 h-8 text-white" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M3.18 23.76c.27.15.58.2.89.13l12.89-7.43-2.77-2.76-11.01 10.06zm-.99-20.29v18.06c0 .36.1.69.28.97l10.32-10.32L2.19 2.5c-.0 .0-.0.0-.0 0zm16.12 6.77l-2.44-1.41-3.08 3.09 3.09 3.09 2.44-1.41c.7-.4 1.12-1.15 1.12-1.68 0-.53-.42-1.27-1.13-1.68zm-14.7-8.47c.04-.01.08-.01.12-.01.31 0 .61.09.87.26l12.01 6.93-2.76 2.76L4.44.73c-.31-.18-.66-.21-.93-.05l-.0-.91z"/>
                        </svg>
                        <div class="text-left">
                            <div class="text-white/80 text-xs" data-i18n="download.play_top">Get it on</div>
                            <div class="text-white font-bold text-lg leading-tight" data-i18n="download.play">Google Play</div>
                        </div>
                    </a>
                </div>

                <!-- Also on CodeCanyon -->
                @if(($s['show_codecanyon_link'] ?? '1') != '0')
                <p class="text-white/50 text-sm">
                    <span data-i18n="download.codecanyon" data-i18n-en="{{ $s['codecanyon_prompt_text'] }}">{{ $s['codecanyon_prompt_text'] }}</span>
                    <a href="{{ $s['codecanyon_url'] }}" target="_blank"
                       class="underline transition-colors" style="color: var(--gold);" data-i18n="download.codecanyon_link" data-i18n-en="{{ $s['codecanyon_link_text'] }}">
                        {{ $s['codecanyon_link_text'] }}
                    </a>
                </p>
                @endif
            </div>
        </div>
    </section>

    <!-- ===================== FOOTER ===================== -->
    <footer class="bg-gray-950 text-white py-16">
        <div class="max-w-7xl mx-auto px-6">
            <div class="grid md:grid-cols-4 gap-10 mb-12">
                <!-- Brand -->
                <div class="md:col-span-2">
                    <div class="flex items-center gap-3 mb-4">
                        <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background: linear-gradient(135deg, var(--gold), var(--gold-light));">
                            <span class="text-xl">🕌</span>
                        </div>
                        <span class="text-white font-bold text-2xl">{{ $s['app_name'] }}</span>
                    </div>
                    <p class="text-gray-400 text-sm leading-relaxed mb-4 max-w-xs" data-i18n="footer.description" data-i18n-en="{{ $s['footer_description'] }}">
                        {{ $s['footer_description'] }}
                    </p>
                    <div class="font-arabic text-gray-600 text-lg">
                        بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ
                    </div>
                </div>

                <!-- Features -->
                <div>
                    <h4 class="font-semibold text-white mb-4" data-i18n="footer.features">Features</h4>
                    <ul class="space-y-2 text-sm text-gray-400">
                        <li><a href="#quran" class="hover:text-white transition-colors" data-i18n="footer.holy_quran">Holy Quran</a></li>
                        <li><a href="#prayer" class="hover:text-white transition-colors" data-i18n="footer.prayer_times">Prayer Times</a></li>
                        <li><a href="#ai" class="hover:text-white transition-colors" data-i18n="footer.ai_chat">AI Chat</a></li>
                        <li><a href="#features" class="hover:text-white transition-colors" data-i18n="footer.qibla">Qibla Finder</a></li>
                        <li><a href="#features" class="hover:text-white transition-colors" data-i18n="footer.zakat">Zakat Calculator</a></li>
                        <li><a href="#features" class="hover:text-white transition-colors" data-i18n="footer.mosque">Mosque Finder</a></li>
                    </ul>
                </div>

                <!-- Links -->
                <div>
                    <h4 class="font-semibold text-white mb-4" data-i18n="footer.links">Links</h4>
                    <ul class="space-y-2 text-sm text-gray-400">
                        <li><a href="{{ route('blog.index') }}" class="hover:text-white transition-colors">Blog</a></li>
                        <li><a href="{{ url('privacy-policy') }}" class="hover:text-white transition-colors" data-i18n="footer.privacy">Privacy Policy</a></li>
                        <li><a href="{{ url('terms-and-conditions') }}" class="hover:text-white transition-colors" data-i18n="footer.terms">Terms & Conditions</a></li>
                        <li><a href="{{ url('support') }}" class="hover:text-white transition-colors" data-i18n="footer.support">Support</a></li>
                        <li><a href="{{ route('login') }}" class="hover:text-white transition-colors" data-i18n="footer.admin">Admin Panel</a></li>
                    </ul>
                </div>
            </div>

            <div class="border-t border-gray-800 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4">
                <p class="text-gray-500 text-sm">
                    © {{ date('Y') }} {{ $s['app_name'] }} — <span data-i18n="footer.copyright">Islamic App. All rights reserved.</span>
                </p>
                <p class="text-gray-600 text-sm" data-i18n="footer.built">Built with Flutter • Laravel • Love ❤️</p>
            </div>
        </div>
    </footer>

    <!-- ===================== SCRIPTS ===================== -->
    <script>
        // ── Navbar scroll ────────────────────────────────────────
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => {
            navbar.classList.toggle('navbar-scrolled', window.scrollY > 50);
        });

        // ── Mobile menu ──────────────────────────────────────────
        function toggleMenu() {
            document.getElementById('mobile-menu').classList.toggle('open');
        }

        // ── Reveal on scroll ─────────────────────────────────────
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
        }, { threshold: 0.1 });
        document.querySelectorAll('.reveal').forEach(el => observer.observe(el));

        // ── Smooth scroll ────────────────────────────────────────
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                const target = document.querySelector(this.getAttribute('href'));
                if (target) { e.preventDefault(); target.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
            });
        });

        // ════════════════════════════════════════════════════════
        // I18N — Translations
        // ════════════════════════════════════════════════════════
        const TRANSLATIONS = {
            en: {
                'nav.features':'Features','nav.quran':'Quran','nav.prayer':'Prayer','nav.ai':'AI','nav.download':'Download','nav.admin':'Admin Login','nav.buy_btn':'Buy Now','nav.download_btn':'Download Free',
                'hero.app_store':'App Store','hero.play_store':'Google Play','hero.rating_label':'Rating','hero.downloads_label':'Downloads','hero.languages_label':'Languages',
                'stats.surahs':'Surahs of Quran','stats.languages':'Languages','stats.rating':'App Rating','stats.downloads':'Downloads',
                'quran.verse_trans':'"And We have certainly made the Quran easy for remembrance, so is there any who will remember?" — Al-Qamar 54:17',
                'quran.surah_title':'Complete 114 Surahs','quran.surah_desc':'All 6,236 ayahs with multiple recitation styles and verse-by-verse audio.',
                'quran.audio_title':'Audio Quran','quran.audio_desc':'Listen to world-renowned reciters with offline support and background play.',
                'quran.bookmark_title':'Bookmarks & History','quran.bookmark_desc':'Save your place, bookmark favorite verses, and continue where you left off.',
                'prayer.qibla_title':'Qibla Finder','prayer.qibla_desc':'Accurate compass with improved precision',
                'prayer.adhan_title':'Adhan Alerts','prayer.adhan_desc':'Multiple beautiful reciters to choose from',
                'prayer.ramadan_title':'Ramadan Mode','prayer.ramadan_desc':'Iftar & Sehri times for your city',
                'prayer.custom_title':'Customizable','prayer.custom_desc':'Manual adjustments & AM/PM format',
                'prayer.card_label':"Today's Prayer Times",
                'ai.chat_title':'AI Islamic Chat','ai.chat_desc':'Ask any Islamic question and receive knowledgeable, accurate answers instantly. From fiqh rulings to daily duas, our AI assistant is always ready to guide you.',
                'ai.chat_q':'What is the dua before eating?','ai.chat_a':'"Bismillah" — In the name of Allah. (Bukhari & Muslim)',
                'ai.name_title':'Islamic Name Generator','ai.name_desc':'Find the perfect Islamic name for your child. Our AI generates beautiful, meaningful names with their Arabic origin, meaning, and pronunciation.','ai.name_label':'Generated Names for Boys',
                'dhikr.tasbih':'Tasbih Counter','dhikr.tasbih_desc':'Digital dhikr counter with customizable phrases and haptic feedback.',
                'dhikr.dua':'Dua Collection','dhikr.dua_desc':'Comprehensive duas for morning, evening, travel, eating, and special occasions.',
                'dhikr.names':'99 Names of Allah','dhikr.names_desc':'All Asma ul Husna with meanings, transliteration, and virtues.',
                'dhikr.haram':'Haram Code','dhikr.haram_desc':'Islamic guidance system to help you navigate everyday decisions.',
                'tech.title':'Built for Performance','tech.subtitle':'Modern, fast, and cross-platform',
                'tech.flutter':'Flutter Framework','tech.flutter_desc':'Built with Flutter & Dart 3.1.5 for smooth 60fps performance',
                'tech.cross':'Cross-Platform','tech.cross_desc':'One codebase, native performance on both iOS and Android',
                'tech.updates':'Free Updates','tech.updates_desc':'Regular feature updates and bug fixes at no extra cost',
                'tech.privacy':'Privacy First','tech.privacy_desc':'Your data stays private with minimal permissions required',
                'download.app_store_top':'Download on the','download.app_store':'App Store','download.play_top':'Get it on','download.play':'Google Play',
                'download.codecanyon':'Want to resell or customize?','download.codecanyon_link':'Get the source code on CodeCanyon →',
                'footer.features':'Features','footer.links':'Links','footer.holy_quran':'Holy Quran','footer.prayer_times':'Prayer Times','footer.ai_chat':'AI Chat',
                'footer.qibla':'Qibla Finder','footer.zakat':'Zakat Calculator','footer.mosque':'Mosque Finder',
                'footer.privacy':'Privacy Policy','footer.terms':'Terms & Conditions','footer.support':'Support','footer.admin':'Admin Panel',
                'footer.copyright':'Islamic App. All rights reserved.','footer.built':'Built with Flutter • Laravel • Love ❤️',
                // Default dynamic content (DB values override these in English via data-i18n-en)
                'hero.badge':'Available on iOS & Android','hero.title':'Your Complete','hero.subtitle':'Islamic Companion',
                'hero.description':'Zabi brings you the full Quran, prayer times, hadith, dua, Qibla, Zakat calculator, AI Islamic chat, and 40+ languages — everything you need for your daily Islamic life in one beautiful app.',
                'features.title':'Everything You Need','features.desc':'A complete Islamic lifestyle companion packed with features that help you stay connected to your faith every day.',
                'quran.title':'Full Quran Reading','quran.highlight':'Experience','quran.description':'Read, listen, and understand the Holy Quran with multi-language translations, phonetic transliteration, and beautiful Arabic typography.',
                'prayer.title':'Never Miss','prayer.highlight':'A Prayer','prayer.description':'Get accurate prayer times for your location with beautiful Adhan notifications. Find the Qibla direction with an improved compass.',
                'ai.title':'Powered by Artificial Intelligence','ai.description':'Get intelligent Islamic guidance at your fingertips — anytime, anywhere.',
                'dhikr.title':'Dhikr, Dua & Remembrance','dhikr.description':'Stay connected to Allah with our comprehensive collection of duas and dhikr for every occasion.',
                'download.title':'Start Your Islamic','download.highlight':'Journey Today','download.description':'Join hundreds of thousands of Muslims worldwide who use Zabi for their daily Islamic needs. Download for free today.',
                'footer.description':'Your complete Islamic companion app. Bringing the beauty of Islam to your fingertips with modern technology.',
                'nav.donate':'Donate',
                'donate.title':'Support Our Mission','donate.desc':'Your generosity keeps Zabi free for millions of Muslims worldwide. Every contribution helps us maintain, improve, and expand Islamic knowledge.',
                'donate.verse_trans':'"The example of those who spend in the way of Allah is like a grain that sprouts seven ears" — Al-Baqarah 2:261',
                'donate.why1_title':'Free App Forever','donate.why1_desc':'Keeps the app free for millions of Muslims globally.',
                'donate.why2_title':'Global Infrastructure','donate.why2_desc':'Funds servers, CDN, and 24/7 uptime for all users.',
                'donate.why3_title':'New Features','donate.why3_desc':'Enables development of new Islamic tools and content.',
                'donate.why4_title':'Privacy & Security','donate.why4_desc':'Maintains privacy-first infrastructure with no ads.',
                'donate.accepted':'Accepted via',
                'donate.amount_label':'Select Amount','donate.custom_placeholder':'Custom amount (USD)',
                'donate.category_label':'Donation Category','donate.category_placeholder':'Select a cause...',
                'donate.email_label':'Your Email',
                'donate.payment_label':'Payment Method',
                'donate.btn':'Donate Now',
                'donate.name_label':'Your Name','donate.privacy_note':'🔒 Secure & encrypted. We never store card details.',
                'feature.0.title':'Quran & Islamic Content','feature.0.desc':'Complete Al-Quran reading experience with multi-language translations, audio recitation, transliteration, and ayah sharing.',
                'feature.1.title':'Prayer & Worship','feature.1.desc':'Accurate prayer times, customizable schedules, Adhan notifications with multiple reciters, and Qibla finder with compass.',
                'feature.2.title':'AI-Powered Features','feature.2.desc':'Get answers to Islamic questions instantly with our AI Islamic Chat and generate beautiful Islamic names for your family.',
                'feature.3.title':'Mosque & Location','feature.3.desc':'Find nearby mosques using GPS, get navigation assistance, and manage location permissions easily.',
                'feature.4.title':'Islamic Finance & Charity','feature.4.desc':'Calculate your Zakat accurately with customizable Nisab settings and support charitable causes through the donation module.',
                'feature.5.title':'Personalization','feature.5.desc':'Make the app yours with dark mode, RTL support, dynamic wallpapers, custom dhikr, dua, and 40+ language options.',
                'feature.0.bullets':"4 Language Translations\nAudio Quran Support\nTransliteration Feature\nHadith & Dua Collections\nAllah's 99 Names",
                'feature.1.bullets':'Accurate Prayer Times\nAdhan Notifications\nQibla Finder & Compass\nRamadan Schedule\nMultiple Adhan Reciters',
                'feature.2.bullets':'AI Islamic Q&A Chat\nIslamic Name Generator\nSmart Recommendations\nInstant Responses\n24/7 Availability',
                'feature.3.bullets':'Nearby Mosque Finder\nGPS Navigation\nReal-time Location\nCity-based Prayer Times',
                'feature.4.bullets':'Zakat Calculator\nCustomizable Nisab\nDonation Module\nMultiple Currencies',
                'feature.5.bullets':'Dark Mode Support\nRTL Language Support\nDynamic Wallpapers\nCustom Dhikr & Dua',
                'nav.listen':'Listen',
                'donate.form_title':'Make a Donation','donate.form_subtitle':'Every contribution makes a difference',
                'quran_audio.title':'Read & Listen ','quran_audio.highlight':'Together','quran_audio.desc':'Follow along with Arabic text while listening to world-renowned reciters — verse by verse.',
                'ai_chat.badge':'Live Demo • Powered by Groq','ai_chat.title_line1':'Ask Any','ai_chat.title_line2':'Islamic Question',
                'ai_chat.desc':'Get instant, knowledgeable answers about Islam — from Quran & Hadith to prayer, fiqh, and daily Muslim life. Lightning-fast AI, right here on the page.',
                'ai_chat.sub_title':'Sub-second Responses','ai_chat.sub_desc':'Groq LPU technology delivers answers in milliseconds',
                'ai_chat.hadith_title':'Quran & Hadith Referenced','ai_chat.hadith_desc':'Answers include Arabic text and authentic source citations',
                'ai_chat.app_title':'Full Experience in the App','ai_chat.app_desc':'Chat history, offline access, and more inside Zabi',
                'ai_chat.try_asking':'Try asking:',
                'name_gen.title':'Islamic Name ','name_gen.highlight':'Generator','name_gen.desc':'Discover beautiful, meaningful Islamic names with Arabic script, English transliteration, and origins — powered by AI.',
                'name_gen.label':'Generate names for a','name_gen.theme':'Meaning Theme','name_gen.optional':'(optional)','name_gen.btn':'✨ Generate Names',
            },
            ar: {
                'nav.features':'الميزات','nav.quran':'القرآن','nav.prayer':'الصلاة','nav.ai':'الذكاء الاصطناعي','nav.download':'تحميل','nav.admin':'تسجيل دخول الإدارة','nav.buy_btn':'اشتري الآن','nav.download_btn':'تحميل مجاناً',
                'hero.app_store':'آب ستور','hero.play_store':'جوجل بلاي','hero.rating_label':'التقييم','hero.downloads_label':'التحميلات','hero.languages_label':'لغة',
                'stats.surahs':'سورة قرآنية','stats.languages':'لغة','stats.rating':'تقييم التطبيق','stats.downloads':'تحميل',
                'quran.verse_trans':'"وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ فَهَلْ مِن مُّدَّكِرٍ" — سورة القمر ٥٤:١٧',
                'quran.surah_title':'١١٤ سورة كاملة','quran.surah_desc':'جميع ٦٢٣٦ آية مع أساليب تلاوة متعددة وصوت آية بآية.',
                'quran.audio_title':'القرآن الصوتي','quran.audio_desc':'استمع إلى قراء عالميين مع دعم التشغيل دون اتصال.',
                'quran.bookmark_title':'الإشارات المرجعية','quran.bookmark_desc':'احفظ موضعك وضع إشارات على آياتك المفضلة.',
                'prayer.qibla_title':'اتجاه القبلة','prayer.qibla_desc':'بوصلة دقيقة بدقة محسّنة',
                'prayer.adhan_title':'تنبيهات الأذان','prayer.adhan_desc':'مقرئون جميلون متعددون للاختيار',
                'prayer.ramadan_title':'وضع رمضان','prayer.ramadan_desc':'أوقات الإفطار والسحور لمدينتك',
                'prayer.custom_title':'قابل للتخصيص','prayer.custom_desc':'تعديلات يدوية وتنسيق ١٢/٢٤ ساعة',
                'prayer.card_label':'مواقيت الصلاة اليوم',
                'ai.chat_title':'محادثة إسلامية ذكية','ai.chat_desc':'اطرح أي سؤال إسلامي واحصل على إجابات دقيقة وموثوقة فوراً. من أحكام الفقه إلى الأدعية اليومية.',
                'ai.chat_q':'ما هو الدعاء قبل الأكل؟','ai.chat_a':'"بِسْمِ اللَّهِ" — باسم الله. (البخاري ومسلم)',
                'ai.name_title':'مولد الأسماء الإسلامية','ai.name_desc':'اعثر على الاسم الإسلامي المثالي لطفلك. يقترح الذكاء الاصطناعي أسماء جميلة وذات معنى مع أصلها العربي.','ai.name_label':'أسماء مقترحة للأولاد',
                'dhikr.tasbih':'عداد التسبيح','dhikr.tasbih_desc':'عداد ذكر رقمي مع صيغ قابلة للتخصيص وتغذية راجعة.',
                'dhikr.dua':'مجموعة الأدعية','dhikr.dua_desc':'أدعية شاملة للصباح والمساء والسفر والطعام والمناسبات.',
                'dhikr.names':'أسماء الله الحسنى','dhikr.names_desc':'جميع الأسماء الحسنى مع معانيها وفضائلها.',
                'dhikr.haram':'دليل الحلال والحرام','dhikr.haram_desc':'نظام توجيه إسلامي يساعدك في قراراتك اليومية.',
                'tech.title':'مبني للأداء','tech.subtitle':'حديث وسريع ومتعدد المنصات',
                'tech.flutter':'إطار فلاتر','tech.flutter_desc':'مبني بـ Flutter و Dart 3.1.5 لأداء سلس بـ 60 إطار/ث',
                'tech.cross':'متعدد المنصات','tech.cross_desc':'قاعدة كود واحدة وأداء أصلي على iOS و Android',
                'tech.updates':'تحديثات مجانية','tech.updates_desc':'تحديثات منتظمة للميزات وإصلاح الأخطاء',
                'tech.privacy':'الخصوصية أولاً','tech.privacy_desc':'بياناتك تبقى خاصة مع الحد الأدنى من الأذونات',
                'download.app_store_top':'حمّل من','download.app_store':'آب ستور','download.play_top':'احصل عليه من','download.play':'جوجل بلاي',
                'download.codecanyon':'تريد إعادة البيع أو التخصيص؟','download.codecanyon_link':'احصل على كود المصدر من CodeCanyon ←',
                'footer.features':'الميزات','footer.links':'روابط','footer.holy_quran':'القرآن الكريم','footer.prayer_times':'مواقيت الصلاة','footer.ai_chat':'محادثة ذكية',
                'footer.qibla':'اتجاه القبلة','footer.zakat':'حاسبة الزكاة','footer.mosque':'البحث عن مسجد',
                'footer.privacy':'سياسة الخصوصية','footer.terms':'الشروط والأحكام','footer.support':'الدعم','footer.admin':'لوحة الإدارة',
                'footer.copyright':'تطبيق إسلامي. جميع الحقوق محفوظة.','footer.built':'مبني بـ Flutter • Laravel • محبة ❤️',
                'hero.badge':'متاح على iOS و Android','hero.title':'رفيقك الإسلامي','hero.subtitle':'الشامل',
                'hero.description':'زابي يقدم لك القرآن الكريم كاملاً، مواقيت الصلاة، الأحاديث، الأدعية، القبلة، حاسبة الزكاة، المحادثة الإسلامية الذكية، وأكثر من ٤٠ لغة — كل ما تحتاجه في حياتك الإسلامية اليومية في تطبيق واحد جميل.',
                'features.title':'كل ما تحتاجه','features.desc':'رفيق شامل للحياة الإسلامية مليء بالميزات التي تساعدك على البقاء متصلاً بدينك كل يوم.',
                'quran.title':'قراءة القرآن الكريم','quran.highlight':'الكاملة','quran.description':'اقرأ واستمع وافهم القرآن الكريم مع ترجمات متعددة اللغات والتلاوة الصوتية والخط العربي الجميل.',
                'prayer.title':'لا تفوت','prayer.highlight':'صلاة','prayer.description':'احصل على مواقيت الصلاة الدقيقة مع إشعارات أذان جميلة. اعثر على اتجاه القبلة بالبوصلة المحسّنة.',
                'ai.title':'مدعوم بالذكاء الاصطناعي','ai.description':'احصل على إرشاد إسلامي ذكي في متناول يدك — في أي وقت وأي مكان.',
                'dhikr.title':'الذكر، الدعاء والتذكر','dhikr.description':'ابقَ متصلاً بالله تعالى بمجموعتنا الشاملة من الأدعية والأذكار لكل مناسبة.',
                'download.title':'ابدأ رحلتك الإسلامية','download.highlight':'اليوم','download.description':'انضم إلى مئات الآلاف من المسلمين حول العالم. حمّله مجاناً اليوم.',
                'footer.description':'رفيقك الإسلامي الشامل. نجلب لك جمال الإسلام بين يديك بالتكنولوجيا الحديثة.',
                'nav.donate':'تبرع',
                'donate.title':'ادعم مهمتنا','donate.desc':'كرمك يبقي زابي مجانياً لملايين المسلمين حول العالم. كل مساهمة تساعدنا على الصيانة والتطوير.',
                'donate.verse_trans':'"مَّثَلُ الَّذِينَ يُنفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ" — البقرة 2:261',
                'donate.why1_title':'التطبيق مجاناً دائماً','donate.why1_desc':'يبقي التطبيق مجانياً لملايين المسلمين.',
                'donate.why2_title':'البنية التحتية العالمية','donate.why2_desc':'يموّل الخوادم والشبكة والتوفر المستمر.',
                'donate.why3_title':'ميزات جديدة','donate.why3_desc':'يتيح تطوير أدوات وأدوات إسلامية جديدة.',
                'donate.why4_title':'الخصوصية والأمان','donate.why4_desc':'يحافظ على الخصوصية دون إعلانات.',
                'donate.accepted':'مقبول عبر',
                'donate.amount_label':'اختر المبلغ','donate.custom_placeholder':'مبلغ مخصص (دولار)',
                'donate.category_label':'فئة التبرع','donate.category_placeholder':'اختر قضية...',
                'donate.email_label':'بريدك الإلكتروني',
                'donate.payment_label':'طريقة الدفع',
                'donate.btn':'تبرع الآن',
                'donate.name_label':'اسمك','donate.privacy_note':'🔒 آمن ومشفر. نحن لا نخزن تفاصيل البطاقة.',
                'feature.0.title':'القرآن والمحتوى الإسلامي','feature.0.desc':'تجربة قراءة كاملة للقرآن الكريم مع ترجمات متعددة اللغات والتلاوة الصوتية.',
                'feature.1.title':'الصلاة والعبادة','feature.1.desc':'مواقيت صلاة دقيقة وجداول قابلة للتخصيص وإشعارات الأذان وإيجاد اتجاه القبلة.',
                'feature.2.title':'ميزات الذكاء الاصطناعي','feature.2.desc':'احصل على إجابات فورية للأسئلة الإسلامية وولّد أسماء إسلامية جميلة لعائلتك.',
                'feature.3.title':'المسجد والموقع','feature.3.desc':'اعثر على المساجد القريبة باستخدام GPS واحصل على المساعدة في التنقل.',
                'feature.4.title':'المالية الإسلامية والخير','feature.4.desc':'احسب زكاتك بدقة مع إعدادات النصاب القابلة للتخصيص.',
                'feature.5.title':'التخصيص','feature.5.desc':'اجعل التطبيق مناسباً لك مع الوضع الليلي ودعم RTL وخلفيات ديناميكية.',
                'feature.0.bullets':'ترجمات بـ٤ لغات\nدعم القرآن الصوتي\nميزة التحويل الصوتي\nمجموعات الحديث والأدعية\nأسماء الله الحسنى التسعة والتسعون',
                'feature.1.bullets':'أوقات صلاة دقيقة\nإشعارات الأذان\nإيجاد القبلة والبوصلة\nجدول رمضان\nمقرئون متعددون',
                'feature.2.bullets':'محادثة إسلامية ذكية\nمولد الأسماء الإسلامية\nتوصيات ذكية\nردود فورية\nمتاح ٢٤/٧',
                'feature.3.bullets':'البحث عن المساجد القريبة\nالملاحة GPS\nالموقع في الوقت الفعلي\nأوقات الصلاة حسب المدينة',
                'feature.4.bullets':'حاسبة الزكاة\nإعدادات النصاب القابلة للتخصيص\nوحدة التبرع\nعملات متعددة',
                'feature.5.bullets':'دعم الوضع الليلي\nدعم اللغة من اليمين لليسار\nخلفيات ديناميكية\nتخصيص الذكر والأدعية',
                'nav.listen':'استمع',
                'donate.form_title':'قدّم تبرعاً','donate.form_subtitle':'كل مساهمة تُحدث فرقاً',
                'quran_audio.title':'اقرأ واستمع ','quran_audio.highlight':'معاً','quran_audio.desc':'تابع النص العربي بينما تستمع إلى قراء عالميين — آية بآية.',
                'ai_chat.badge':'عرض تجريبي حي • مدعوم بـ Groq','ai_chat.title_line1':'اسأل أي','ai_chat.title_line2':'سؤال إسلامي',
                'ai_chat.desc':'احصل على إجابات فورية وموثوقة حول الإسلام — من القرآن والحديث إلى الصلاة والفقه والحياة اليومية للمسلم. ذكاء اصطناعي فائق السرعة هنا على الصفحة.',
                'ai_chat.sub_title':'ردود أقل من ثانية','ai_chat.sub_desc':'تقنية Groq LPU تقدم إجابات في أجزاء من الثانية',
                'ai_chat.hadith_title':'القرآن والحديث مرجعاً','ai_chat.hadith_desc':'تتضمن الإجابات النص العربي ومصادر موثقة',
                'ai_chat.app_title':'التجربة الكاملة في التطبيق','ai_chat.app_desc':'سجل المحادثات والوصول دون إنترنت والمزيد داخل زابي',
                'ai_chat.try_asking':'جرب السؤال:',
                'name_gen.title':'مولد الأسماء ','name_gen.highlight':'الإسلامية','name_gen.desc':'اكتشف أسماء إسلامية جميلة وذات معنى مع الكتابة العربية والتحويل الصوتي والأصول — بدعم الذكاء الاصطناعي.',
                'name_gen.label':'إنشاء أسماء لـ','name_gen.theme':'موضوع المعنى','name_gen.optional':'(اختياري)','name_gen.btn':'✨ إنشاء أسماء',
            },
            bn: {
                'nav.features':'বৈশিষ্ট্যসমূহ','nav.quran':'কুরআন','nav.prayer':'নামাজ','nav.ai':'AI','nav.download':'ডাউনলোড','nav.admin':'অ্যাডমিন লগইন','nav.buy_btn':'এখনই কিনুন','nav.download_btn':'বিনামূল্যে ডাউনলোড',
                'hero.app_store':'অ্যাপ স্টোর','hero.play_store':'গুগল প্লে','hero.rating_label':'রেটিং','hero.downloads_label':'ডাউনলোড','hero.languages_label':'ভাষা',
                'stats.surahs':'কুরআনের সূরা','stats.languages':'ভাষাসমূহ','stats.rating':'অ্যাপ রেটিং','stats.downloads':'ডাউনলোড',
                'quran.verse_trans':'"আমি কুরআনকে স্মরণের জন্য সহজ করে দিয়েছি, অতএব কোনো স্মরণকারী আছে কি?" — সূরা আল-কামার ৫৪:১৭',
                'quran.surah_title':'সম্পূর্ণ ১১৪টি সূরা','quran.surah_desc':'একাধিক তেলাওয়াত স্টাইল সহ সকল ৬,২৩৬টি আয়াত।',
                'quran.audio_title':'অডিও কুরআন','quran.audio_desc':'বিশ্বখ্যাত কারীদের কণ্ঠে শুনুন অফলাইন সাপোর্ট সহ।',
                'quran.bookmark_title':'বুকমার্ক ও ইতিহাস','quran.bookmark_desc':'আপনার জায়গা সেভ করুন, প্রিয় আয়াত বুকমার্ক করুন।',
                'prayer.qibla_title':'কিবলা নির্দেশক','prayer.qibla_desc':'উন্নত নির্ভুলতার সঠিক কম্পাস',
                'prayer.adhan_title':'আজানের সতর্কতা','prayer.adhan_desc':'বেছে নেওয়ার জন্য একাধিক সুন্দর কারী',
                'prayer.ramadan_title':'রমজান মোড','prayer.ramadan_desc':'আপনার শহরের ইফতার ও সেহরির সময়',
                'prayer.custom_title':'কাস্টমাইজযোগ্য','prayer.custom_desc':'ম্যানুয়াল সমন্বয় এবং AM/PM ফরম্যাট',
                'prayer.card_label':'আজকের নামাজের সময়',
                'ai.chat_title':'AI ইসলামিক চ্যাট','ai.chat_desc':'যেকোনো ইসলামিক প্রশ্ন করুন এবং তাৎক্ষণিক সঠিক উত্তর পান। ফিকহ থেকে দৈনন্দিন দোয়া পর্যন্ত।',
                'ai.chat_q':'খাওয়ার আগে দোয়া কী?','ai.chat_a':'"বিসমিল্লাহ" — আল্লাহর নামে। (বুখারি ও মুসলিম)',
                'ai.name_title':'ইসলামিক নাম জেনারেটর','ai.name_desc':'আপনার সন্তানের জন্য নিখুঁত ইসলামিক নাম খুঁজুন। AI আরবি উৎস ও উচ্চারণ সহ সুন্দর নাম তৈরি করে।','ai.name_label':'ছেলেদের জন্য প্রস্তাবিত নাম',
                'dhikr.tasbih':'তাসবিহ কাউন্টার','dhikr.tasbih_desc':'কাস্টমাইজযোগ্য বাক্যাংশ সহ ডিজিটাল জিকির কাউন্টার।',
                'dhikr.dua':'দোয়ার সংগ্রহ','dhikr.dua_desc':'সকাল, সন্ধ্যা, সফর, খাওয়া ও বিশেষ উপলক্ষের দোয়া।',
                'dhikr.names':'আল্লাহর ৯৯ নাম','dhikr.names_desc':'অর্থ, উচ্চারণ ও ফজিলত সহ সকল আসমাউল হুসনা।',
                'dhikr.haram':'হারাম কোড','dhikr.haram_desc':'দৈনন্দিন সিদ্ধান্তে গাইড করার ইসলামিক নির্দেশিকা সিস্টেম।',
                'tech.title':'পারফরম্যান্সের জন্য তৈরি','tech.subtitle':'আধুনিক, দ্রুত এবং ক্রস-প্ল্যাটফর্ম',
                'tech.flutter':'ফ্লাটার ফ্রেমওয়ার্ক','tech.flutter_desc':'মসৃণ 60fps পারফরম্যান্সের জন্য Flutter ও Dart 3.1.5',
                'tech.cross':'ক্রস-প্ল্যাটফর্ম','tech.cross_desc':'একটি কোডবেস, iOS ও Android-এ নেটিভ পারফরম্যান্স',
                'tech.updates':'বিনামূল্যে আপডেট','tech.updates_desc':'নিয়মিত ফিচার আপডেট ও বাগ ফিক্স',
                'tech.privacy':'গোপনীয়তা প্রথম','tech.privacy_desc':'ন্যূনতম অনুমতি সহ আপনার ডেটা ব্যক্তিগত থাকে',
                'download.app_store_top':'ডাউনলোড করুন','download.app_store':'অ্যাপ স্টোর','download.play_top':'পাওয়া যাচ্ছে','download.play':'গুগল প্লে',
                'download.codecanyon':'পুনরায় বিক্রি বা কাস্টমাইজ করতে চান?','download.codecanyon_link':'CodeCanyon থেকে সোর্স কোড পান →',
                'footer.features':'বৈশিষ্ট্যসমূহ','footer.links':'লিংকসমূহ','footer.holy_quran':'পবিত্র কুরআন','footer.prayer_times':'নামাজের সময়','footer.ai_chat':'AI চ্যাট',
                'footer.qibla':'কিবলা নির্দেশক','footer.zakat':'যাকাত ক্যালকুলেটর','footer.mosque':'মসজিদ খোঁজুন',
                'footer.privacy':'গোপনীয়তা নীতি','footer.terms':'শর্তাবলী','footer.support':'সহায়তা','footer.admin':'অ্যাডমিন প্যানেল',
                'footer.copyright':'ইসলামিক অ্যাপ। সর্বস্বত্ব সংরক্ষিত।','footer.built':'Flutter • Laravel • ভালোবাসা দিয়ে তৈরি ❤️',
                'hero.badge':'iOS ও Android-এ পাওয়া যাচ্ছে','hero.title':'আপনার সম্পূর্ণ','hero.subtitle':'ইসলামিক সঙ্গী',
                'hero.description':'জাবি আপনার কাছে নিয়ে আসে সম্পূর্ণ কুরআন, নামাজের সময়, হাদিস, দোয়া, কিবলা, যাকাত ক্যালকুলেটর, AI ইসলামিক চ্যাট এবং ৪০+ ভাষা — আপনার দৈনন্দিন ইসলামিক জীবনের সবকিছু একটি সুন্দর অ্যাপে।',
                'features.title':'আপনার যা দরকার সব','features.desc':'একটি সম্পূর্ণ ইসলামিক জীবনধারার সঙ্গী যা আপনাকে প্রতিদিন আপনার দ্বীনের সাথে সংযুক্ত রাখে।',
                'quran.title':'সম্পূর্ণ কুরআন পাঠের','quran.highlight':'অভিজ্ঞতা','quran.description':'বহুভাষিক অনুবাদ ও অডিও তেলাওয়াত সহ পবিত্র কুরআন পড়ুন, শুনুন ও বুঝুন।',
                'prayer.title':'কোনো নামাজ','prayer.highlight':'মিস করবেন না','prayer.description':'সুন্দর আজানের নোটিফিকেশন সহ নামাজের সঠিক সময় পান। উন্নত কম্পাস দিয়ে কিবলার দিক খুঁজুন।',
                'ai.title':'কৃত্রিম বুদ্ধিমত্তা দ্বারা চালিত','ai.description':'আপনার আঙুলের ডগায় বুদ্ধিমান ইসলামিক গাইডেন্স — যেকোনো সময়, যেকোনো জায়গায়।',
                'dhikr.title':'জিকির, দোয়া ও স্মরণ','dhikr.description':'প্রতিটি উপলক্ষের দোয়া ও জিকিরের বিস্তৃত সংগ্রহ নিয়ে আল্লাহর সাথে সংযুক্ত থাকুন।',
                'download.title':'আপনার ইসলামিক যাত্রা','download.highlight':'আজই শুরু করুন','download.description':'বিশ্বজুড়ে লক্ষ লক্ষ মুসলিমের সাথে যোগ দিন। আজই বিনামূল্যে ডাউনলোড করুন।',
                'footer.description':'আপনার সম্পূর্ণ ইসলামিক সঙ্গী অ্যাপ। আধুনিক প্রযুক্তি দিয়ে ইসলামের সৌন্দর্য আপনার কাছে নিয়ে আসছি।',
                'nav.donate':'দান করুন',
                'donate.title':'আমাদের মিশন সমর্থন করুন','donate.desc':'আপনার উদারতা বিশ্বজুড়ে লক্ষ লক্ষ মুসলিমের জন্য জাবিকে বিনামূল্যে রাখে।',
                'donate.verse_trans':'"যারা আল্লাহর পথে তাদের সম্পদ ব্যয় করে তাদের উদাহরণ একটি শস্যদানার মতো যা থেকে সাতটি শীষ জন্মায়" — আল-বাকারা ২:২৬১',
                'donate.why1_title':'সর্বদা বিনামূল্যে অ্যাপ','donate.why1_desc':'বিশ্বব্যাপী লক্ষ লক্ষ মুসলিমের জন্য অ্যাপটি বিনামূল্যে রাখে।',
                'donate.why2_title':'বৈশ্বিক অবকাঠামো','donate.why2_desc':'সার্ভার, CDN এবং ২৪/৭ আপটাইম অর্থায়ন করে।',
                'donate.why3_title':'নতুন বৈশিষ্ট্য','donate.why3_desc':'নতুন ইসলামিক সরঞ্জাম তৈরি সক্ষম করে।',
                'donate.why4_title':'গোপনীয়তা ও নিরাপত্তা','donate.why4_desc':'বিজ্ঞাপন ছাড়াই গোপনীয়তা অবকাঠামো বজায় রাখে।',
                'donate.accepted':'গৃহীত মাধ্যমে',
                'donate.amount_label':'পরিমাণ নির্বাচন করুন','donate.custom_placeholder':'কাস্টম পরিমাণ (USD)',
                'donate.category_label':'দান বিভাগ','donate.category_placeholder':'একটি কারণ নির্বাচন করুন...',
                'donate.email_label':'আপনার ইমেইল',
                'donate.payment_label':'পেমেন্ট পদ্ধতি',
                'donate.btn':'এখনই দান করুন',
                'donate.name_label':'আপনার নাম','donate.privacy_note':'🔒 সুরক্ষিত ও এনক্রিপ্টেড। আমরা কার্ডের বিবরণ সংরক্ষণ করি না।',
                'feature.0.title':'কুরআন ও ইসলামিক কন্টেন্ট','feature.0.desc':'বহুভাষিক অনুবাদ ও অডিও তেলাওয়াত সহ সম্পূর্ণ কুরআন পাঠের অভিজ্ঞতা।',
                'feature.1.title':'নামাজ ও ইবাদত','feature.1.desc':'সঠিক নামাজের সময়, আজান নোটিফিকেশন এবং কিবলা নির্দেশক কম্পাস।',
                'feature.2.title':'AI-চালিত বৈশিষ্ট্যসমূহ','feature.2.desc':'ইসলামিক প্রশ্নের তাৎক্ষণিক উত্তর পান এবং পরিবারের জন্য ইসলামিক নাম তৈরি করুন।',
                'feature.3.title':'মসজিদ ও অবস্থান','feature.3.desc':'GPS ব্যবহার করে কাছের মসজিদ খুঁজুন এবং নেভিগেশন সহায়তা পান।',
                'feature.4.title':'ইসলামিক অর্থনীতি ও দান','feature.4.desc':'কাস্টমাইজযোগ্য নিসাব সেটিং সহ সঠিকভাবে যাকাত গণনা করুন।',
                'feature.5.title':'ব্যক্তিগতকরণ','feature.5.desc':'ডার্ক মোড, RTL সাপোর্ট, ডায়নামিক ওয়ালপেপার এবং ৪০+ ভাষার বিকল্প।',
                'feature.0.bullets':'৪টি ভাষা অনুবাদ\nঅডিও কুরআন সাপোর্ট\nট্রান্সলিটারেশন ফিচার\nহাদিস ও দোয়া সংগ্রহ\nআল্লাহর ৯৯ নাম',
                'feature.1.bullets':'সঠিক নামাজের সময়\nআজানের নোটিফিকেশন\nকিবলা ফাইন্ডার ও কম্পাস\nরমজান সময়সূচি\nএকাধিক কারী',
                'feature.2.bullets':'AI ইসলামিক Q&A চ্যাট\nইসলামিক নাম জেনারেটর\nস্মার্ট রেকমেন্ডেশন\nতাৎক্ষণিক উত্তর\n২৪/৭ উপলব্ধ',
                'feature.3.bullets':'কাছের মসজিদ খোঁজক\nGPS নেভিগেশন\nরিয়েল-টাইম অবস্থান\nশহরভিত্তিক নামাজের সময়',
                'feature.4.bullets':'যাকাত ক্যালকুলেটর\nকাস্টমাইজযোগ্য নিসাব\nদান মডিউল\nএকাধিক মুদ্রা',
                'feature.5.bullets':'ডার্ক মোড সাপোর্ট\nRTL ভাষা সাপোর্ট\nডায়নামিক ওয়ালপেপার\nকাস্টম জিকির ও দোয়া',
                'nav.listen':'শুনুন',
                'donate.form_title':'একটি দান করুন','donate.form_subtitle':'প্রতিটি অবদান একটি পার্থক্য তৈরি করে',
                'quran_audio.title':'পড়ুন ও শুনুন ','quran_audio.highlight':'একসাথে','quran_audio.desc':'বিশ্বখ্যাত কারীদের কণ্ঠ শুনতে শুনতে আরবি পাঠ অনুসরণ করুন — আয়াত বাই আয়াত।',
                'ai_chat.badge':'লাইভ ডেমো • Groq দ্বারা চালিত','ai_chat.title_line1':'যেকোনো','ai_chat.title_line2':'ইসলামিক প্রশ্ন করুন',
                'ai_chat.desc':'ইসলাম সম্পর্কে তাৎক্ষণিক উত্তর পান — কুরআন ও হাদিস থেকে নামাজ, ফিকহ এবং দৈনন্দিন মুসলিম জীবন পর্যন্ত। এই পেজেই দ্রুততম AI।',
                'ai_chat.sub_title':'মিলিসেকেন্ডে উত্তর','ai_chat.sub_desc':'Groq LPU প্রযুক্তি মিলিসেকেন্ডে উত্তর দেয়',
                'ai_chat.hadith_title':'কুরআন ও হাদিস রেফারেন্স','ai_chat.hadith_desc':'উত্তরে আরবি পাঠ্য ও প্রামাণিক উৎস অন্তর্ভুক্ত',
                'ai_chat.app_title':'অ্যাপে সম্পূর্ণ অভিজ্ঞতা','ai_chat.app_desc':'চ্যাট হিস্ট্রি, অফলাইন অ্যাক্সেস এবং আরও অনেক কিছু Zabi অ্যাপে',
                'ai_chat.try_asking':'জিজ্ঞেস করে দেখুন:',
                'name_gen.title':'ইসলামিক নাম ','name_gen.highlight':'জেনারেটর','name_gen.desc':'আরবি লিপি, ইংরেজি উচ্চারণ এবং উৎস সহ সুন্দর ও অর্থবহ ইসলামিক নাম আবিষ্কার করুন — AI দ্বারা চালিত।',
                'name_gen.label':'নাম তৈরি করুন','name_gen.theme':'অর্থের থিম','name_gen.optional':'(ঐচ্ছিক)','name_gen.btn':'✨ নাম তৈরি করুন',
            },
            hi: {
                'nav.features':'विशेषताएं','nav.quran':'कुरान','nav.prayer':'नमाज़','nav.ai':'AI','nav.download':'डाउनलोड','nav.admin':'एडमिन लॉगिन','nav.buy_btn':'अभी खरीदें','nav.download_btn':'मुफ्त डाउनलोड',
                'hero.app_store':'ऐप स्टोर','hero.play_store':'गूगल प्ले','hero.rating_label':'रेटिंग','hero.downloads_label':'डाउनलोड','hero.languages_label':'भाषाएं',
                'stats.surahs':'कुरान की सूरतें','stats.languages':'भाषाएं','stats.rating':'ऐप रेटिंग','stats.downloads':'डाउनलोड',
                'quran.verse_trans':'"हमने कुरान को याद करने के लिए आसान बना दिया है, तो क्या कोई याद करने वाला है?" — सूरह अल-कमर 54:17',
                'quran.surah_title':'पूरी 114 सूरतें','quran.surah_desc':'कई तिलावत शैलियों के साथ सभी 6,236 आयतें।',
                'quran.audio_title':'ऑडियो कुरान','quran.audio_desc':'ऑफलाइन सपोर्ट के साथ विश्वप्रसिद्ध कारियों को सुनें।',
                'quran.bookmark_title':'बुकमार्क और इतिहास','quran.bookmark_desc':'अपनी जगह सेव करें, पसंदीदा आयतें बुकमार्क करें।',
                'prayer.qibla_title':'क़िबला दिशा','prayer.qibla_desc':'बेहतर सटीकता के साथ सटीक कम्पास',
                'prayer.adhan_title':'अज़ान अलर्ट','prayer.adhan_desc':'चुनने के लिए कई सुंदर कारी',
                'prayer.ramadan_title':'रमज़ान मोड','prayer.ramadan_desc':'आपके शहर के इफ्तार और सहरी का समय',
                'prayer.custom_title':'अनुकूलनीय','prayer.custom_desc':'मैनुअल समायोजन और AM/PM प्रारूप',
                'prayer.card_label':'आज का नमाज़ का समय',
                'ai.chat_title':'AI इस्लामिक चैट','ai.chat_desc':'कोई भी इस्लामिक प्रश्न पूछें और तुरंत सटीक उत्तर पाएं। फिकह से लेकर रोज़ाना की दुआओं तक।',
                'ai.chat_q':'खाने से पहले की दुआ क्या है?','ai.chat_a':'"बिस्मिल्लाह" — अल्लाह के नाम से। (बुखारी और मुस्लिम)',
                'ai.name_title':'इस्लामिक नाम जनरेटर','ai.name_desc':'अपने बच्चे के लिए सही इस्लामिक नाम खोजें। AI अरबी मूल और उच्चारण के साथ सुंदर नाम बनाता है।','ai.name_label':'लड़कों के लिए सुझाए गए नाम',
                'dhikr.tasbih':'तस्बीह काउंटर','dhikr.tasbih_desc':'कस्टमाइज़ेबल वाक्यांशों के साथ डिजिटल ज़िक्र काउंटर।',
                'dhikr.dua':'दुआ संग्रह','dhikr.dua_desc':'सुबह, शाम, यात्रा, खाने और विशेष अवसरों की दुआएं।',
                'dhikr.names':'अल्लाह के 99 नाम','dhikr.names_desc':'अर्थ, उच्चारण और फ़ज़ीलत के साथ सभी अस्माउल हुस्ना।',
                'dhikr.haram':'हराम कोड','dhikr.haram_desc':'रोज़ाना के फैसलों में मार्गदर्शन करने वाली इस्लामिक प्रणाली।',
                'tech.title':'प्रदर्शन के लिए बनाया गया','tech.subtitle':'आधुनिक, तेज़ और क्रॉस-प्लेटफ़ॉर्म',
                'tech.flutter':'फ्लटर फ्रेमवर्क','tech.flutter_desc':'स्मूद 60fps प्रदर्शन के लिए Flutter और Dart 3.1.5',
                'tech.cross':'क्रॉस-प्लेटफ़ॉर्म','tech.cross_desc':'एक कोडबेस, iOS और Android पर नेटिव प्रदर्शन',
                'tech.updates':'मुफ्त अपडेट','tech.updates_desc':'नियमित फ़ीचर अपडेट और बग फ़िक्स',
                'tech.privacy':'गोपनीयता पहले','tech.privacy_desc':'न्यूनतम अनुमतियों के साथ आपका डेटा निजी रहता है',
                'download.app_store_top':'डाउनलोड करें','download.app_store':'ऐप स्टोर','download.play_top':'प्राप्त करें','download.play':'गूगल प्ले',
                'download.codecanyon':'पुनः बेचना या कस्टमाइज़ करना चाहते हैं?','download.codecanyon_link':'CodeCanyon पर सोर्स कोड पाएं →',
                'footer.features':'विशेषताएं','footer.links':'लिंक','footer.holy_quran':'पवित्र कुरान','footer.prayer_times':'नमाज़ का समय','footer.ai_chat':'AI चैट',
                'footer.qibla':'क़िबला दिशा','footer.zakat':'ज़कात कैलकुलेटर','footer.mosque':'मस्जिद खोजें',
                'footer.privacy':'गोपनीयता नीति','footer.terms':'नियम और शर्तें','footer.support':'सहायता','footer.admin':'एडमिन पैनल',
                'footer.copyright':'इस्लामिक ऐप। सर्वाधिकार सुरक्षित।','footer.built':'Flutter • Laravel • प्यार से बनाया ❤️',
                'hero.badge':'iOS और Android पर उपलब्ध','hero.title':'आपका संपूर्ण','hero.subtitle':'इस्लामिक साथी',
                'hero.description':'ज़ाबी आपके लिए लाता है पूरा कुरान, नमाज़ का समय, हदीस, दुआएं, क़िबला, ज़कात कैलकुलेटर, AI इस्लामिक चैट, और 40+ भाषाएं — आपके दैनिक इस्लामिक जीवन के लिए सब कुछ एक सुंदर ऐप में।',
                'features.title':'वो सब कुछ जो आपको चाहिए','features.desc':'एक संपूर्ण इस्लामिक जीवनशैली साथी जो आपको हर दिन अपने दीन से जोड़े रखता है।',
                'quran.title':'पूर्ण कुरान पठन','quran.highlight':'अनुभव','quran.description':'बहुभाषी अनुवाद और ऑडियो तिलावत के साथ पवित्र कुरान पढ़ें, सुनें और समझें।',
                'prayer.title':'कोई नमाज़','prayer.highlight':'न चूकें','prayer.description':'सुंदर अज़ान सूचनाओं के साथ सटीक नमाज़ का समय पाएं। बेहतर कम्पास से क़िबला दिशा खोजें।',
                'ai.title':'आर्टिफिशियल इंटेलिजेंस द्वारा संचालित','ai.description':'अपनी उंगलियों पर बुद्धिमान इस्लामिक मार्गदर्शन — कहीं भी, कभी भी।',
                'dhikr.title':'ज़िक्र, दुआ और याद','dhikr.description':'हर अवसर के लिए दुआओं और ज़िक्र के व्यापक संग्रह के साथ अल्लाह से जुड़े रहें।',
                'download.title':'अपनी इस्लामिक यात्रा','download.highlight':'आज शुरू करें','download.description':'दुनिया भर के लाखों मुसलमानों के साथ जुड़ें। आज मुफ्त में डाउनलोड करें।',
                'footer.description':'आपका संपूर्ण इस्लामिक साथी ऐप। आधुनिक तकनीक के साथ इस्लाम की सुंदरता आपकी उंगलियों तक।',
                'nav.donate':'दान करें',
                'donate.title':'हमारे मिशन का समर्थन करें','donate.desc':'आपकी उदारता दुनिया भर के लाखों मुसलमानों के लिए ज़ाबी को मुफ्त रखती है।',
                'donate.verse_trans':'"जो लोग अल्लाह के रास्ते में अपना माल खर्च करते हैं उनकी मिसाल उस दाने जैसी है जिससे सात बालियाँ निकलें" — अल-बकरह 2:261',
                'donate.why1_title':'हमेशा मुफ्त ऐप','donate.why1_desc':'दुनिया भर के लाखों मुसलमानों के लिए ऐप को मुफ्त रखता है।',
                'donate.why2_title':'वैश्विक अवसंरचना','donate.why2_desc':'सर्वर, CDN और 24/7 अपटाइम को फंड करता है।',
                'donate.why3_title':'नई सुविधाएं','donate.why3_desc':'नए इस्लामिक उपकरणों के विकास को सक्षम करता है।',
                'donate.why4_title':'गोपनीयता और सुरक्षा','donate.why4_desc':'बिना विज्ञापन के गोपनीयता-प्रथम बुनियादी ढांचा।',
                'donate.accepted':'द्वारा स्वीकृत',
                'donate.amount_label':'राशि चुनें','donate.custom_placeholder':'कस्टम राशि (USD)',
                'donate.category_label':'दान श्रेणी','donate.category_placeholder':'एक कारण चुनें...',
                'donate.email_label':'आपका ईमेल',
                'donate.payment_label':'भुगतान विधि',
                'donate.btn':'अभी दान करें',
                'donate.name_label':'आपका नाम','donate.privacy_note':'🔒 सुरक्षित और एन्क्रिप्टेड। हम कार्ड विवरण संग्रहीत नहीं करते।',
                'feature.0.title':'कुरान और इस्लामिक सामग्री','feature.0.desc':'बहुभाषी अनुवाद और ऑडियो तिलावत के साथ पूरा अल-कुरान पढ़ने का अनुभव।',
                'feature.1.title':'नमाज़ और इबादत','feature.1.desc':'सटीक नमाज़ का समय, अज़ान नोटिफिकेशन और क़िबला फाइंडर।',
                'feature.2.title':'AI-संचालित विशेषताएं','feature.2.desc':'इस्लामिक सवालों के तुरंत जवाब और परिवार के लिए इस्लामिक नाम।',
                'feature.3.title':'मस्जिद और स्थान','feature.3.desc':'GPS से नज़दीकी मस्जिद खोजें और नेविगेशन सहायता पाएं।',
                'feature.4.title':'इस्लामिक वित्त और दान','feature.4.desc':'कस्टमाइज़ेबल निसाब सेटिंग के साथ सटीक ज़कात की गणना करें।',
                'feature.5.title':'व्यक्तिगतकरण','feature.5.desc':'डार्क मोड, RTL सपोर्ट, डायनामिक वॉलपेपर और 40+ भाषाओं के विकल्प।',
                'feature.0.bullets':'4 भाषा अनुवाद\nऑडियो कुरान सपोर्ट\nट्रांसलिटरेशन फीचर\nहदीस और दुआ संग्रह\nअल्लाह के 99 नाम',
                'feature.1.bullets':'सटीक नमाज़ का समय\nअज़ान नोटिफिकेशन\nक़िबला फाइंडर और कम्पास\nरमज़ान शेड्यूल\nएकाधिक कारी',
                'feature.2.bullets':'AI इस्लामिक Q&A चैट\nइस्लामिक नाम जनरेटर\nस्मार्ट रेकमेंडेशन\nतुरंत जवाब\n24/7 उपलब्धता',
                'feature.3.bullets':'नज़दीकी मस्जिद खोजक\nGPS नेविगेशन\nरियल-टाइम लोकेशन\nशहर-आधारित नमाज़ का समय',
                'feature.4.bullets':'ज़कात कैलकुलेटर\nकस्टमाइज़ेबल निसाब\nदान मॉड्यूल\nएकाधिक मुद्राएं',
                'feature.5.bullets':'डार्क मोड सपोर्ट\nRTL भाषा सपोर्ट\nडायनामिक वॉलपेपर\nकस्टम ज़िक्र और दुआ',
                'nav.listen':'सुनें',
                'donate.form_title':'दान करें','donate.form_subtitle':'हर योगदान एक फर्क डालता है',
                'quran_audio.title':'पढ़ें और सुनें ','quran_audio.highlight':'एक साथ','quran_audio.desc':'विश्वप्रसिद्ध कारियों को सुनते हुए अरबी पाठ का अनुसरण करें — आयत दर आयत।',
                'ai_chat.badge':'लाइव डेमो • Groq द्वारा संचालित','ai_chat.title_line1':'कोई भी','ai_chat.title_line2':'इस्लामिक सवाल पूछें',
                'ai_chat.desc':'इस्लाम के बारे में तुरंत जानकारीपूर्ण उत्तर पाएं — कुरान और हदीस से नमाज़, फिकह और मुस्लिम दैनिक जीवन तक। अल्ट्राफास्ट AI, यहीं इस पेज पर।',
                'ai_chat.sub_title':'एक सेकंड से कम उत्तर','ai_chat.sub_desc':'Groq LPU तकनीक मिलीसेकंड में उत्तर देती है',
                'ai_chat.hadith_title':'कुरान और हदीस संदर्भित','ai_chat.hadith_desc':'उत्तरों में अरबी पाठ और प्रामाणिक स्रोत शामिल हैं',
                'ai_chat.app_title':'ऐप में पूरा अनुभव','ai_chat.app_desc':'चैट इतिहास, ऑफ़लाइन पहुंच और ज़ाबी ऐप में और बहुत कुछ',
                'ai_chat.try_asking':'पूछकर देखें:',
                'name_gen.title':'इस्लामिक नाम ','name_gen.highlight':'जनरेटर','name_gen.desc':'अरबी लिपि, अंग्रेज़ी लिप्यंतरण और मूल के साथ सुंदर इस्लामिक नाम खोजें — AI द्वारा संचालित।',
                'name_gen.label':'नाम उत्पन्न करें','name_gen.theme':'अर्थ थीम','name_gen.optional':'(वैकल्पिक)','name_gen.btn':'✨ नाम उत्पन्न करें',
            },
            es: {
                'nav.features':'Características','nav.quran':'Corán','nav.prayer':'Oración','nav.ai':'IA','nav.download':'Descargar','nav.admin':'Login Admin','nav.buy_btn':'Comprar Ahora','nav.download_btn':'Descargar Gratis',
                'hero.app_store':'App Store','hero.play_store':'Google Play','hero.rating_label':'Calificación','hero.downloads_label':'Descargas','hero.languages_label':'Idiomas',
                'stats.surahs':'Suras del Corán','stats.languages':'Idiomas','stats.rating':'Calificación','stats.downloads':'Descargas',
                'quran.verse_trans':'"Hemos facilitado el Corán para ser recordado, ¿habrá quien lo recuerde?" — Al-Qamar 54:17',
                'quran.surah_title':'114 Suras Completas','quran.surah_desc':'Las 6,236 aleyas con múltiples estilos de recitación y audio versículo por versículo.',
                'quran.audio_title':'Corán en Audio','quran.audio_desc':'Escucha recitadores de renombre mundial con soporte sin conexión.',
                'quran.bookmark_title':'Marcadores e Historial','quran.bookmark_desc':'Guarda tu lugar, marca tus aleyas favoritas y continúa donde lo dejaste.',
                'prayer.qibla_title':'Buscador de Qibla','prayer.qibla_desc':'Brújula precisa con mayor precisión mejorada',
                'prayer.adhan_title':'Alertas de Adhan','prayer.adhan_desc':'Múltiples recitadores hermosos para elegir',
                'prayer.ramadan_title':'Modo Ramadán','prayer.ramadan_desc':'Horarios de Iftar y Suhur para tu ciudad',
                'prayer.custom_title':'Personalizable','prayer.custom_desc':'Ajustes manuales y formato AM/PM',
                'prayer.card_label':'Horarios de Oración de Hoy',
                'ai.chat_title':'Chat Islámico con IA','ai.chat_desc':'Haz cualquier pregunta islámica y recibe respuestas precisas al instante. Desde fallos de fiqh hasta du\'as diarias.',
                'ai.chat_q':'¿Cuál es la du\'a antes de comer?','ai.chat_a':'"Bismillah" — En el nombre de Allah. (Bujari y Muslim)',
                'ai.name_title':'Generador de Nombres Islámicos','ai.name_desc':'Encuentra el nombre islámico perfecto para tu hijo. La IA genera nombres bellos y significativos con su origen árabe.','ai.name_label':'Nombres Sugeridos para Niños',
                'dhikr.tasbih':'Contador de Tasbih','dhikr.tasbih_desc':'Contador digital de dhikr con frases personalizables y retroalimentación háptica.',
                'dhikr.dua':'Colección de Du\'as','dhikr.dua_desc':'Du\'as completas para mañana, tarde, viaje, comida y ocasiones especiales.',
                'dhikr.names':'99 Nombres de Allah','dhikr.names_desc':'Todos los Asma ul Husna con significados, transliteración y virtudes.',
                'dhikr.haram':'Código Haram','dhikr.haram_desc':'Sistema de orientación islámica para decisiones cotidianas.',
                'tech.title':'Construido para el Rendimiento','tech.subtitle':'Moderno, rápido y multiplataforma',
                'tech.flutter':'Framework Flutter','tech.flutter_desc':'Construido con Flutter y Dart 3.1.5 para un rendimiento fluido de 60fps',
                'tech.cross':'Multiplataforma','tech.cross_desc':'Un código base, rendimiento nativo en iOS y Android',
                'tech.updates':'Actualizaciones Gratuitas','tech.updates_desc':'Actualizaciones regulares de funciones y corrección de errores',
                'tech.privacy':'Privacidad Primero','tech.privacy_desc':'Tus datos permanecen privados con permisos mínimos requeridos',
                'download.app_store_top':'Descargar en','download.app_store':'App Store','download.play_top':'Disponible en','download.play':'Google Play',
                'download.codecanyon':'¿Quieres revender o personalizar?','download.codecanyon_link':'Obtén el código fuente en CodeCanyon →',
                'footer.features':'Características','footer.links':'Enlaces','footer.holy_quran':'Santo Corán','footer.prayer_times':'Horarios de Oración','footer.ai_chat':'Chat con IA',
                'footer.qibla':'Buscador de Qibla','footer.zakat':'Calculadora de Zakat','footer.mosque':'Buscador de Mezquitas',
                'footer.privacy':'Política de Privacidad','footer.terms':'Términos y Condiciones','footer.support':'Soporte','footer.admin':'Panel de Admin',
                'footer.copyright':'Aplicación Islámica. Todos los derechos reservados.','footer.built':'Construido con Flutter • Laravel • Amor ❤️',
                'hero.badge':'Disponible en iOS y Android','hero.title':'Tu Compañero Islámico','hero.subtitle':'Completo',
                'hero.description':'Zabi te trae el Corán completo, horarios de oración, hadices, du\'as, Qibla, calculadora de Zakat, chat islámico con IA y más de 40 idiomas — todo en una hermosa aplicación.',
                'features.title':'Todo lo que Necesitas','features.desc':'Un compañero completo de estilo de vida islámico lleno de características que te ayudan a mantenerte conectado con tu fe cada día.',
                'quran.title':'Experiencia Completa de','quran.highlight':'Lectura del Corán','quran.description':'Lee, escucha y comprende el Sagrado Corán con traducciones multilingües, recitación de audio y hermosa tipografía árabe.',
                'prayer.title':'Nunca te Pierdas','prayer.highlight':'una Oración','prayer.description':'Obtén horarios de oración precisos con hermosas notificaciones de Adhan. Encuentra la dirección de la Qibla con una brújula mejorada.',
                'ai.title':'Impulsado por Inteligencia Artificial','ai.description':'Obtén orientación islámica inteligente al alcance de tu mano — en cualquier momento y lugar.',
                'dhikr.title':'Dhikr, Du\'a y Recuerdo','dhikr.description':'Mantente conectado con Allah con nuestra colección integral de du\'as y dhikr para cada ocasión.',
                'download.title':'Comienza tu Viaje','download.highlight':'Islámico Hoy','download.description':'Únete a cientos de miles de musulmanes en todo el mundo. Descárgalo gratis hoy.',
                'footer.description':'Tu aplicación compañera islámica completa. Llevando la belleza del Islam a tus manos con tecnología moderna.',
                'nav.donate':'Donar',
                'donate.title':'Apoya Nuestra Misión','donate.desc':'Tu generosidad mantiene Zabi gratuito para millones de musulmanes en todo el mundo.',
                'donate.verse_trans':'"El ejemplo de quienes gastan en el camino de Allah es como una semilla que produce siete espigas" — Al-Baqarah 2:261',
                'donate.why1_title':'App Siempre Gratuita','donate.why1_desc':'Mantiene la app gratuita para millones de musulmanes.',
                'donate.why2_title':'Infraestructura Global','donate.why2_desc':'Financia servidores, CDN y disponibilidad 24/7.',
                'donate.why3_title':'Nuevas Funciones','donate.why3_desc':'Permite el desarrollo de nuevas herramientas islámicas.',
                'donate.why4_title':'Privacidad y Seguridad','donate.why4_desc':'Infraestructura sin anuncios con privacidad primero.',
                'donate.accepted':'Aceptado vía',
                'donate.amount_label':'Seleccionar Monto','donate.custom_placeholder':'Monto personalizado (USD)',
                'donate.category_label':'Categoría de Donación','donate.category_placeholder':'Selecciona una causa...',
                'donate.email_label':'Tu Correo Electrónico',
                'donate.payment_label':'Método de Pago',
                'donate.btn':'Donar Ahora',
                'donate.name_label':'Tu Nombre','donate.privacy_note':'🔒 Seguro y cifrado. Nunca almacenamos datos de tarjetas.',
                'feature.0.title':'Corán y Contenido Islámico','feature.0.desc':'Experiencia completa de lectura del Corán con traducciones multilingües y recitación de audio.',
                'feature.1.title':'Oración y Adoración','feature.1.desc':'Horarios de oración precisos, notificaciones de Adhan y buscador de Qibla con brújula.',
                'feature.2.title':'Características con IA','feature.2.desc':'Obtén respuestas instantáneas a preguntas islámicas y genera nombres islámicos para tu familia.',
                'feature.3.title':'Mezquita y Ubicación','feature.3.desc':'Encuentra mezquitas cercanas con GPS y obtén asistencia de navegación.',
                'feature.4.title':'Finanzas Islámicas y Caridad','feature.4.desc':'Calcula tu Zakat con precisión con configuraciones personalizables de Nisab.',
                'feature.5.title':'Personalización','feature.5.desc':'Modo oscuro, soporte RTL, fondos dinámicos y más de 40 opciones de idioma.',
                'feature.0.bullets':'4 Traducciones de Idiomas\nSoporte Audio Corán\nFunción de Transliteración\nColecciones de Hadith y Duʼa\n99 Nombres de Allah',
                'feature.1.bullets':'Horarios de Oración Precisos\nNotificaciones de Adhan\nBuscador de Qibla y Brújula\nCalendario de Ramadán\nMúltiples Reciters',
                'feature.2.bullets':'Chat IA de P&R Islámico\nGenerador de Nombres Islámicos\nRecomendaciones Inteligentes\nRespuestas Instantáneas\nDisponibilidad 24/7',
                'feature.3.bullets':'Buscador de Mezquitas Cercanas\nNavegación GPS\nUbicación en Tiempo Real\nHorarios por Ciudad',
                'feature.4.bullets':'Calculadora de Zakat\nNisab Personalizable\nMódulo de Donación\nMúltiples Monedas',
                'feature.5.bullets':'Soporte Modo Oscuro\nSoporte RTL\nFondos Dinámicos\nDhikr y Duʼa Personalizados',
                'nav.listen':'Escuchar',
                'donate.form_title':'Haz una Donación','donate.form_subtitle':'Cada contribución marca la diferencia',
                'quran_audio.title':'Lee y Escucha ','quran_audio.highlight':'Juntos','quran_audio.desc':'Sigue el texto árabe mientras escuchas a reciters de renombre mundial — versículo a versículo.',
                'ai_chat.badge':'Demo en Vivo • Impulsado por Groq','ai_chat.title_line1':'Haz Cualquier','ai_chat.title_line2':'Pregunta Islámica',
                'ai_chat.desc':'Obtén respuestas instantáneas y precisas sobre el Islam — del Corán y Hadith a la oración, el fiqh y la vida diaria musulmana. IA ultrarrápida, aquí mismo en la página.',
                'ai_chat.sub_title':'Respuestas en Menos de un Segundo','ai_chat.sub_desc':'La tecnología Groq LPU entrega respuestas en milisegundos',
                'ai_chat.hadith_title':'Corán y Hadith Referenciados','ai_chat.hadith_desc':'Las respuestas incluyen texto árabe y citas de fuentes auténticas',
                'ai_chat.app_title':'Experiencia Completa en la App','ai_chat.app_desc':'Historial de chat, acceso sin conexión y más dentro de Zabi',
                'ai_chat.try_asking':'Intenta preguntar:',
                'name_gen.title':'Nombres Islámicos ','name_gen.highlight':'Generador','name_gen.desc':'Descubre nombres islámicos hermosos y significativos con escritura árabe, transliteración inglesa y orígenes — impulsado por IA.',
                'name_gen.label':'Generar nombres para un','name_gen.theme':'Tema de Significado','name_gen.optional':'(opcional)','name_gen.btn':'✨ Generar Nombres',
            },
            fr: {
                'nav.features':'Fonctionnalités','nav.quran':'Coran','nav.prayer':'Prière','nav.ai':'IA','nav.download':'Télécharger','nav.admin':'Connexion Admin','nav.buy_btn':'Acheter Maintenant','nav.download_btn':'Télécharger Gratuitement',
                'hero.app_store':'App Store','hero.play_store':'Google Play','hero.rating_label':'Note','hero.downloads_label':'Téléchargements','hero.languages_label':'Langues',
                'stats.surahs':'Sourates du Coran','stats.languages':'Langues','stats.rating':'Note de l\'App','stats.downloads':'Téléchargements',
                'quran.verse_trans':'"Nous avons facilité le Coran pour la méditation, y a-t-il quelqu\'un pour méditer ?" — Al-Qamar 54:17',
                'quran.surah_title':'114 Sourates Complètes','quran.surah_desc':'Tous les 6 236 versets avec plusieurs styles de récitation et audio verset par verset.',
                'quran.audio_title':'Coran Audio','quran.audio_desc':'Écoutez des récitateurs de renommée mondiale avec support hors ligne.',
                'quran.bookmark_title':'Signets et Historique','quran.bookmark_desc':'Sauvegardez votre place, mettez en signet vos versets préférés.',
                'prayer.qibla_title':'Trouver la Qibla','prayer.qibla_desc':'Boussole précise avec précision améliorée',
                'prayer.adhan_title':'Alertes Adhan','prayer.adhan_desc':'Plusieurs beaux récitateurs au choix',
                'prayer.ramadan_title':'Mode Ramadan','prayer.ramadan_desc':'Horaires Iftar et Suhur pour votre ville',
                'prayer.custom_title':'Personnalisable','prayer.custom_desc':'Ajustements manuels et format AM/PM',
                'prayer.card_label':'Horaires de Prière d\'Aujourd\'hui',
                'ai.chat_title':'Chat Islamique IA','ai.chat_desc':'Posez n\'importe quelle question islamique et recevez des réponses précises instantanément.',
                'ai.chat_q':'Quelle est la doua avant de manger ?','ai.chat_a':'"Bismillah" — Au nom d\'Allah. (Bukhari et Muslim)',
                'ai.name_title':'Générateur de Prénoms Islamiques','ai.name_desc':'Trouvez le prénom islamique parfait pour votre enfant. L\'IA génère de beaux prénoms significatifs avec leur origine arabe.','ai.name_label':'Prénoms Suggérés pour Garçons',
                'dhikr.tasbih':'Compteur Tasbih','dhikr.tasbih_desc':'Compteur dhikr numérique avec phrases personnalisables et retour haptique.',
                'dhikr.dua':'Collection de Douas','dhikr.dua_desc':'Douas complètes pour le matin, soir, voyage, repas et occasions spéciales.',
                'dhikr.names':'99 Noms d\'Allah','dhikr.names_desc':'Tous les Asma ul Husna avec significations, translittération et vertus.',
                'dhikr.haram':'Code Haram','dhikr.haram_desc':'Système de guidance islamique pour les décisions quotidiennes.',
                'tech.title':'Conçu pour la Performance','tech.subtitle':'Moderne, rapide et multiplateforme',
                'tech.flutter':'Framework Flutter','tech.flutter_desc':'Construit avec Flutter et Dart 3.1.5 pour une performance fluide à 60fps',
                'tech.cross':'Multiplateforme','tech.cross_desc':'Une base de code, performance native sur iOS et Android',
                'tech.updates':'Mises à Jour Gratuites','tech.updates_desc':'Mises à jour régulières et corrections de bugs sans frais supplémentaires',
                'tech.privacy':'Vie Privée d\'Abord','tech.privacy_desc':'Vos données restent privées avec des permissions minimales requises',
                'download.app_store_top':'Télécharger sur','download.app_store':'App Store','download.play_top':'Disponible sur','download.play':'Google Play',
                'download.codecanyon':'Vous voulez revendre ou personnaliser ?','download.codecanyon_link':'Obtenez le code source sur CodeCanyon →',
                'footer.features':'Fonctionnalités','footer.links':'Liens','footer.holy_quran':'Saint Coran','footer.prayer_times':'Horaires de Prière','footer.ai_chat':'Chat IA',
                'footer.qibla':'Trouver la Qibla','footer.zakat':'Calculateur Zakat','footer.mosque':'Trouver une Mosquée',
                'footer.privacy':'Politique de Confidentialité','footer.terms':'Conditions d\'Utilisation','footer.support':'Support','footer.admin':'Panneau Admin',
                'footer.copyright':'Application Islamique. Tous droits réservés.','footer.built':'Construit avec Flutter • Laravel • Amour ❤️',
                'hero.badge':'Disponible sur iOS et Android','hero.title':'Votre Compagnon Islamique','hero.subtitle':'Complet',
                'hero.description':'Zabi vous apporte le Coran complet, les horaires de prière, les hadiths, les douas, la Qibla, le calculateur Zakat, le chat islamique IA et plus de 40 langues — tout dans une belle application.',
                'features.title':'Tout ce dont Vous Avez Besoin','features.desc':'Un compagnon de style de vie islamique complet rempli de fonctionnalités qui vous aident à rester connecté à votre foi chaque jour.',
                'quran.title':'Expérience de Lecture','quran.highlight':'Complète du Coran','quran.description':'Lisez, écoutez et comprenez le Saint Coran avec des traductions multilingues, une récitation audio et une belle typographie arabe.',
                'prayer.title':'Ne Manquez Jamais','prayer.highlight':'une Prière','prayer.description':'Obtenez des horaires de prière précis avec de belles notifications Adhan. Trouvez la direction Qibla avec une boussole améliorée.',
                'ai.title':'Propulsé par l\'Intelligence Artificielle','ai.description':'Obtenez une guidance islamique intelligente à portée de main — n\'importe où, n\'importe quand.',
                'dhikr.title':'Dhikr, Doua et Souvenir','dhikr.description':'Restez connecté à Allah avec notre collection complète de douas et dhikr pour chaque occasion.',
                'download.title':'Commencez Votre Voyage','download.highlight':'Islamique Aujourd\'hui','download.description':'Rejoignez des centaines de milliers de musulmans à travers le monde. Téléchargez gratuitement aujourd\'hui.',
                'footer.description':'Votre application compagnon islamique complète. Apportant la beauté de l\'Islam à vos mains avec la technologie moderne.',
                'nav.donate':'Faire un Don',
                'donate.title':'Soutenez Notre Mission','donate.desc':'Votre générosité garde Zabi gratuit pour des millions de musulmans dans le monde entier.',
                'donate.verse_trans':'"L\'exemple de ceux qui dépensent leurs biens dans le sentier d\'Allah est celui d\'un grain qui produit sept épis" — Al-Baqarah 2:261',
                'donate.why1_title':'App Toujours Gratuite','donate.why1_desc':'Garde l\'application gratuite pour des millions de musulmans.',
                'donate.why2_title':'Infrastructure Mondiale','donate.why2_desc':'Finance les serveurs, CDN et disponibilité 24/7.',
                'donate.why3_title':'Nouvelles Fonctionnalités','donate.why3_desc':'Permet le développement de nouveaux outils islamiques.',
                'donate.why4_title':'Confidentialité et Sécurité','donate.why4_desc':'Infrastructure sans publicité axée sur la confidentialité.',
                'donate.accepted':'Accepté via',
                'donate.amount_label':'Sélectionner le Montant','donate.custom_placeholder':'Montant personnalisé (USD)',
                'donate.category_label':'Catégorie de Don','donate.category_placeholder':'Choisir une cause...',
                'donate.email_label':'Votre Email',
                'donate.payment_label':'Méthode de Paiement',
                'donate.btn':'Faire un Don Maintenant',
                'donate.name_label':'Votre Nom','donate.privacy_note':'🔒 Sécurisé et chiffré. Nous ne stockons jamais les détails de carte.',
                'feature.0.title':'Coran et Contenu Islamique','feature.0.desc':'Expérience complète de lecture du Coran avec traductions multilingues et récitation audio.',
                'feature.1.title':'Prière et Adoration','feature.1.desc':'Horaires de prière précis, notifications Adhan et buscador Qibla avec boussole.',
                'feature.2.title':'Fonctionnalités IA','feature.2.desc':'Obtenez des réponses instantanées aux questions islamiques et générez des prénoms islamiques.',
                'feature.3.title':'Mosquée et Localisation','feature.3.desc':'Trouvez les mosquées proches avec GPS et obtenez une assistance de navigation.',
                'feature.4.title':'Finance Islamique et Charité','feature.4.desc':'Calculez votre Zakat précisément avec des paramètres Nisab personnalisables.',
                'feature.5.title':'Personnalisation','feature.5.desc':'Mode sombre, support RTL, fonds d\'écran dynamiques et plus de 40 options de langue.',
                'feature.0.bullets':'4 Traductions de Langues\nSupport Audio Coran\nFonction Translittération\nCollections Hadith et Doua\n99 Noms d\'Allah',
                'feature.1.bullets':'Horaires de Prière Précis\nNotifications Adhan\nQibla et Boussole\nCalendrier Ramadan\nMultiples Récitateurs',
                'feature.2.bullets':'Chat IA Q&R Islamique\nGénérateur de Prénoms Islamiques\nRecommandations Intelligentes\nRéponses Instantanées\nDisponibilité 24/7',
                'feature.3.bullets':'Trouver Mosquées Proches\nNavigation GPS\nLocalisation en Temps Réel\nHoraires par Ville',
                'feature.4.bullets':'Calculateur Zakat\nNisab Personnalisable\nModule de Don\nMultiples Devises',
                'feature.5.bullets':'Support Mode Sombre\nSupport RTL\nFonds d\'Écran Dynamiques\nDhikr et Doua Personnalisés',
                'nav.listen':'Écouter',
                'donate.form_title':'Faire un Don','donate.form_subtitle':'Chaque contribution fait une différence',
                'quran_audio.title':'Lisez et Écoutez ','quran_audio.highlight':'Ensemble','quran_audio.desc':'Suivez le texte arabe en écoutant des récitants de renommée mondiale — verset par verset.',
                'ai_chat.badge':'Démo en Direct • Propulsé par Groq','ai_chat.title_line1':'Posez N\'importe Quelle','ai_chat.title_line2':'Question Islamique',
                'ai_chat.desc':'Obtenez des réponses instantanées sur l\'Islam — du Coran et Hadith à la prière, le fiqh et la vie quotidienne musulmane. IA ultra-rapide, ici sur cette page.',
                'ai_chat.sub_title':'Réponses en Moins d\'une Seconde','ai_chat.sub_desc':'La technologie Groq LPU fournit des réponses en millisecondes',
                'ai_chat.hadith_title':'Coran et Hadith Référencés','ai_chat.hadith_desc':'Les réponses incluent le texte arabe et des citations de sources authentiques',
                'ai_chat.app_title':'Expérience Complète dans l\'App','ai_chat.app_desc':'Historique de chat, accès hors ligne et plus encore dans Zabi',
                'ai_chat.try_asking':'Essayez de demander :',
                'name_gen.title':'Prénom Islamique ','name_gen.highlight':'Générateur','name_gen.desc':'Découvrez de beaux prénoms islamiques significatifs avec écriture arabe, translittération anglaise et origines — propulsé par l\'IA.',
                'name_gen.label':'Générer des prénoms pour un','name_gen.theme':'Thème de Signification','name_gen.optional':'(optionnel)','name_gen.btn':'✨ Générer des Prénoms',
            },
        };

        // ── Prayer names per language ────────────────────────────
        const PRAYER_NAMES = {
            en: { Fajr:'Fajr', Sunrise:'Sunrise', Dhuhr:'Dhuhr', Asr:'Asr', Maghrib:'Maghrib', Isha:'Isha', Next:'Next', detecting:'Detecting location…', sample:'Sample Times' },
            ar: { Fajr:'الفجر', Sunrise:'الشروق', Dhuhr:'الظهر', Asr:'العصر', Maghrib:'المغرب', Isha:'العشاء', Next:'التالي', detecting:'جارٍ تحديد الموقع…', sample:'أوقات نموذجية' },
            bn: { Fajr:'ফজর', Sunrise:'সূর্যোদয়', Dhuhr:'যোহর', Asr:'আসর', Maghrib:'মাগরিব', Isha:'ইশা', Next:'পরবর্তী', detecting:'অবস্থান শনাক্ত হচ্ছে…', sample:'নমুনা সময়' },
            hi: { Fajr:'फ़ज्र', Sunrise:'सूर्योदय', Dhuhr:'ज़ुहर', Asr:'अस्र', Maghrib:'मग़रिब', Isha:'इशा', Next:'अगली', detecting:'स्थान पता किया जा रहा है…', sample:'नमूना समय' },
            es: { Fajr:'Fajr', Sunrise:'Amanecer', Dhuhr:'Dhuhr', Asr:'Asr', Maghrib:'Maghrib', Isha:'Isha', Next:'Próxima', detecting:'Detectando ubicación…', sample:'Horarios de Muestra' },
            fr: { Fajr:'Fajr', Sunrise:'Lever du Soleil', Dhuhr:'Dhuhr', Asr:'Asr', Maghrib:'Maghrib', Isha:'Isha', Next:'Suivante', detecting:'Détection localisation…', sample:'Horaires Exemples' },
        };

        // ── Language meta ────────────────────────────────────────
        const LANG_META = {
            en: { dir:'ltr', font:"'Inter', sans-serif",               label:'EN' },
            ar: { dir:'rtl', font:"'Cairo', 'Amiri', sans-serif",      label:'AR' },
            bn: { dir:'ltr', font:"'Noto Sans Bengali', sans-serif",   label:'BN' },
            hi: { dir:'ltr', font:"'Noto Sans Devanagari', sans-serif",label:'HI' },
            es: { dir:'ltr', font:"'Inter', sans-serif",               label:'ES' },
            fr: { dir:'ltr', font:"'Inter', sans-serif",               label:'FR' },
        };

        let currentLang = 'en';
        let cachedPrayers = null;

        // ── Language dropdown ────────────────────────────────────
        function toggleLangDropdown(e) {
            e.stopPropagation();
            document.getElementById('lang-menu').classList.toggle('open');
        }
        document.addEventListener('click', () => {
            document.getElementById('lang-menu').classList.remove('open');
        });

        // ── Apply translations ───────────────────────────────────
        function setLanguage(lang) {
            if (!TRANSLATIONS[lang]) return;
            currentLang = lang;
            const meta = LANG_META[lang];
            const t    = TRANSLATIONS[lang];

            // Direction + font
            document.documentElement.setAttribute('lang', lang);
            document.documentElement.setAttribute('dir', meta.dir);
            document.body.style.fontFamily = meta.font;

            // Update label
            document.querySelectorAll('#current-lang-label').forEach(el => el.textContent = meta.label);

            // Close dropdown + highlight active
            document.getElementById('lang-menu').classList.remove('open');
            document.querySelectorAll('.lang-option').forEach(btn => {
                btn.classList.toggle('active-lang', btn.dataset.lang === lang);
            });

            // Translate all data-i18n elements
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.dataset.i18n;
                if (lang === 'en') {
                    // Prefer PHP-rendered value stored in data-i18n-en
                    const en = el.dataset.i18nEn;
                    el.textContent = (en !== undefined && en !== '') ? en : (t[key] || el.textContent);
                } else {
                    if (t[key]) el.textContent = t[key];
                }
            });

            // Translate feature card bullet points
            document.querySelectorAll('[data-feature-bullets]').forEach(ul => {
                const idx = parseInt(ul.dataset.featureBullets);
                const key = 'feature.' + idx + '.bullets';
                let bullets;
                if (lang === 'en') {
                    const enStr = ul.dataset.enBullets;
                    if (enStr) {
                        bullets = enStr.split('\n').map(b => b.trim()).filter(Boolean);
                    } else if (t[key]) {
                        bullets = t[key].split('\n').map(b => b.trim()).filter(Boolean);
                    }
                } else if (t[key]) {
                    bullets = t[key].split('\n').map(b => b.trim()).filter(Boolean);
                }
                if (bullets && bullets.length) {
                    const checkColor = ul.className.indexOf('text-white') !== -1 ? '#d4a843' : '#1a5c38';
                    ul.innerHTML = bullets.map(function(b) {
                        return '<li class="flex items-center gap-2"><span style="color: ' + checkColor + ';">✓</span> ' + escapeHtml(b) + '</li>';
                    }).join('');
                }
            });

            // Re-render prayer rows with translated names
            if (cachedPrayers) renderPrayerRows(cachedPrayers);
            else {
                const pn = PRAYER_NAMES[lang] || PRAYER_NAMES.en;
                const cityEl = document.getElementById('prayer-city');
                if (cityEl && cityEl.textContent === (PRAYER_NAMES[currentLang === lang ? 'en' : 'en'].detecting || 'Detecting location…')) {
                    cityEl.textContent = pn.detecting;
                }
            }

            localStorage.setItem('zabi_lang', lang);
        }

        // ── Prayer times ─────────────────────────────────────────
        const FALLBACK_PRAYERS = [
            { name:'Fajr',    time:'05:12 AM', is_next:false },
            { name:'Sunrise', time:'06:34 AM', is_next:false },
            { name:'Dhuhr',   time:'12:30 PM', is_next:false },
            { name:'Asr',     time:'04:30 PM', is_next:true  },
            { name:'Maghrib', time:'06:42 PM', is_next:false },
            { name:'Isha',    time:'08:10 PM', is_next:false },
        ];

        function renderPrayerRows(prayers) {
            const pn = PRAYER_NAMES[currentLang] || PRAYER_NAMES.en;
            const container = document.getElementById('prayer-rows');
            if (!container) return;
            container.innerHTML = prayers.map((p, i) => `
                <div class="flex items-center justify-between py-3 ${i < prayers.length - 1 ? 'border-b border-gray-50' : ''}">
                    <div class="flex items-center gap-3">
                        <div class="w-2 h-2 rounded-full ${p.is_next ? 'bg-green-500 animate-pulse' : 'bg-gray-200'}"></div>
                        <span class="font-medium text-gray-900 text-sm">${pn[p.name] || p.name}</span>
                        ${p.is_next ? `<span class="text-xs px-2 py-0.5 rounded-full text-white" style="background:var(--green-mid);">${pn.Next || 'Next'}</span>` : ''}
                    </div>
                    <span class="font-semibold text-sm ${p.is_next ? 'text-emerald-700' : 'text-gray-500'}">${p.time}</span>
                </div>
            `).join('');
        }

        function loadPrayerTimes(lat, lng) {
            const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
            fetch(`/api/prayer-by-location?lat=${lat}&lng=${lng}&timezone=${encodeURIComponent(timezone)}`)
                .then(r => r.json())
                .then(data => {
                    if (data.status) {
                        document.getElementById('prayer-city').textContent = data.city;
                        cachedPrayers = data.prayers;
                        renderPrayerRows(data.prayers);
                    } else { showFallback(); }
                })
                .catch(() => showFallback());
        }

        function showFallback() {
            const pn = PRAYER_NAMES[currentLang] || PRAYER_NAMES.en;
            document.getElementById('prayer-city').textContent = pn.sample;
            cachedPrayers = FALLBACK_PRAYERS;
            renderPrayerRows(FALLBACK_PRAYERS);
        }

        if (navigator.geolocation) {
            const pn = PRAYER_NAMES[currentLang] || PRAYER_NAMES.en;
            document.getElementById('prayer-city').textContent = pn.detecting;
            renderPrayerRows(FALLBACK_PRAYERS);
            navigator.geolocation.getCurrentPosition(
                pos => loadPrayerTimes(pos.coords.latitude, pos.coords.longitude),
                ()  => showFallback(),
                { timeout: 8000 }
            );
        } else { showFallback(); }

        // ── Init language from localStorage ─────────────────────
        (function () {
            const saved = localStorage.getItem('zabi_lang') || 'en';
            if (saved !== 'en') setLanguage(saved);
        })();

        // ── Theme toggle ─────────────────────────────────────────
        function updateThemeIcons(isDark) {
            document.querySelectorAll('.theme-icon-sun').forEach(el => el.classList.toggle('hidden', !isDark));
            document.querySelectorAll('.theme-icon-moon').forEach(el => el.classList.toggle('hidden', isDark));
        }

        function toggleTheme() {
            const isDark = document.documentElement.classList.toggle('dark');
            localStorage.setItem('zabi_theme', isDark ? 'dark' : 'light');
            updateThemeIcons(isDark);
        }

        updateThemeIcons(document.documentElement.classList.contains('dark'));

        // ════════════════════════════════════════════════════════
        // DONATION MODULE
        // ════════════════════════════════════════════════════════

        // ════════════════════════════════════════════════════════
        // DONATION MODULE
        // ════════════════════════════════════════════════════════

        let selectedGateway = null;
        let paypalSdkLoaded = false;

        function selectDonationAmount(amount) {
            document.getElementById('donate-amount').value = amount;
            document.querySelectorAll('.donate-preset-btn').forEach(btn => {
                const active = parseInt(btn.dataset.amount) === amount;
                btn.style.borderColor = active ? '#d4a843' : '#e5e7eb';
                btn.style.background  = active ? 'linear-gradient(135deg,#d4a843,#f0c060)' : '#f9fafb';
                btn.style.color       = active ? '#1a1a1a' : '#374151';
            });
        }

        function clearDonationPresets() {
            document.querySelectorAll('.donate-preset-btn').forEach(btn => {
                btn.style.borderColor = '#e5e7eb';
                btn.style.background  = '#f9fafb';
                btn.style.color       = '#374151';
            });
        }

        function selectPaymentGateway(gateway) {
            selectedGateway = gateway;
            document.querySelectorAll('.donate-payment-card').forEach(card => {
                const active = card.dataset.gateway === gateway;
                card.style.borderColor = active ? '#d4a843' : '#e5e7eb';
                card.style.background  = active ? '#fffbeb' : '#fff';
                card.querySelector('.donate-check').style.display = active ? 'flex' : 'none';
            });

            const paypalContainer = document.getElementById('paypal-button-container');
            const submitBtn       = document.getElementById('donate-submit-btn');

            if (gateway === 'paypal') {
                submitBtn.classList.add('hidden');
                paypalContainer.classList.remove('hidden');
                initPaypalButtons();
            } else {
                submitBtn.classList.remove('hidden');
                paypalContainer.classList.add('hidden');
            }
        }

        function loadDonationCategories() {
            fetch('/api/donation-categories')
                .then(r => r.json())
                .then(res => {
                    const sel = document.getElementById('donate-category');
                    (res.data || []).forEach(cat => {
                        const opt = document.createElement('option');
                        opt.value = cat.id;
                        opt.textContent = cat.name;
                        sel.appendChild(opt);
                    });
                })
                .catch(() => {});
        }

        function showDonationFeedback(message, success) {
            const el = document.getElementById('donate-feedback');
            el.textContent = message;
            el.style.background = success ? '#d1fae5' : '#fee2e2';
            el.style.color      = success ? '#065f46' : '#991b1b';
            el.classList.remove('hidden');
            if (success) setTimeout(() => el.classList.add('hidden'), 8000);
        }

        function getDonationFormValues() {
            return {
                amount:   parseFloat(document.getElementById('donate-amount').value),
                category: document.getElementById('donate-category').value,
                email:    document.getElementById('donate-email').value.trim(),
                name:     document.getElementById('donate-name').value.trim() || null,
            };
        }

        function validateDonationForm() {
            const { amount, category, email } = getDonationFormValues();
            if (!amount || amount < 1)                             { showDonationFeedback('Please enter a valid amount (min $1).', false); return false; }
            if (!category)                                          { showDonationFeedback('Please select a donation category.', false); return false; }
            if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { showDonationFeedback('Please enter a valid email address.', false); return false; }
            if (!selectedGateway)                                   { showDonationFeedback('Please select a payment method.', false); return false; }
            return true;
        }

        function resetDonationForm() {
            document.getElementById('donate-amount').value   = '';
            document.getElementById('donate-category').value = '';
            document.getElementById('donate-email').value    = '';
            document.getElementById('donate-name').value     = '';
            clearDonationPresets();
            selectedGateway = null;
            document.querySelectorAll('.donate-payment-card').forEach(c => {
                c.style.borderColor = '#e5e7eb';
                c.style.background  = '#fff';
                c.querySelector('.donate-check').style.display = 'none';
            });
            document.getElementById('paypal-button-container').classList.add('hidden');
            document.getElementById('donate-submit-btn').classList.remove('hidden');
        }

        // ── Stripe Checkout ──────────────────────────────────────
        function submitStripe(formValues) {
            return fetch('/api/donation/stripe/checkout', {
                method:  'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body:    JSON.stringify({ ...formValues, category_id: parseInt(formValues.category), currency: 'USD' }),
            })
            .then(r => r.json())
            .then(res => {
                if (res.status && res.checkout_url) {
                    window.location.href = res.checkout_url;
                } else {
                    showDonationFeedback(res.message || 'Stripe error. Please try again.', false);
                }
            });
        }

        // ── PayPal ───────────────────────────────────────────────
        function initPaypalButtons() {
            const container = document.getElementById('paypal-button-container');
            if (paypalSdkLoaded && window.paypal) {
                renderPaypalButtons(container);
                return;
            }
            fetch('/api/donation/paypal/client-id')
                .then(r => r.json())
                .then(res => {
                    if (!res.status) { showDonationFeedback('PayPal is not configured.', false); return; }
                    const script = document.createElement('script');
                    script.src = `https://www.paypal.com/sdk/js?client-id=${res.client_id}&currency=USD`;
                    script.onload = () => { paypalSdkLoaded = true; renderPaypalButtons(container); };
                    document.head.appendChild(script);
                })
                .catch(() => showDonationFeedback('Could not load PayPal. Please try another method.', false));
        }

        function renderPaypalButtons(container) {
            container.innerHTML = '';
            window.paypal.Buttons({
                createOrder: function(data, actions) {
                    if (!validateDonationForm()) return actions.reject();
                    const { amount, category, email, name } = getDonationFormValues();
                    return fetch('/api/donation/paypal/create-order', {
                        method:  'POST',
                        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                        body:    JSON.stringify({ amount, category_id: parseInt(category), email, name, currency: 'USD' }),
                    })
                    .then(r => r.json())
                    .then(res => {
                        if (!res.status) throw new Error(res.message);
                        container.dataset.donationId = res.donation_id;
                        return res.order_id;
                    });
                },
                onApprove: function(data, actions) {
                    const donationId = container.dataset.donationId;
                    return fetch('/api/donation/paypal/capture-order', {
                        method:  'POST',
                        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                        body:    JSON.stringify({ order_id: data.orderID, donation_id: donationId }),
                    })
                    .then(r => r.json())
                    .then(res => {
                        if (res.status) {
                            showDonationFeedback('JazakAllah Khair! PayPal payment successful. 🤲', true);
                            resetDonationForm();
                        } else {
                            showDonationFeedback(res.message || 'Payment verification failed.', false);
                        }
                    });
                },
                onError: function(err) {
                    showDonationFeedback('PayPal error. Please try again.', false);
                },
                style: { layout: 'horizontal', color: 'gold', shape: 'rect', label: 'donate', height: 36 },
            }).render(container);
        }

        // ── Razorpay ─────────────────────────────────────────────
        function submitRazorpay(formValues) {
            return new Promise((resolve) => {
                fetch('/api/donation/razorpay/create-order', {
                    method:  'POST',
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body:    JSON.stringify({ ...formValues, category_id: parseInt(formValues.category), currency: 'INR' }),
                })
                .then(r => r.json())
                .then(res => {
                    if (!res.status) { showDonationFeedback(res.message || 'Razorpay error. Please try again.', false); resolve(); return; }
                    const open = () => {
                        const rzp = new window.Razorpay({
                            key:         res.key_id,
                            amount:      res.amount,
                            currency:    res.currency,
                            name:        'Zabi — Islamic App',
                            description: res.description,
                            order_id:    res.order_id,
                            prefill:     { name: res.name, email: res.email },
                            theme:       { color: '#d4a843' },
                            handler: function(response) {
                                fetch('/api/donation/razorpay/verify', {
                                    method:  'POST',
                                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                                    body:    JSON.stringify({
                                        razorpay_payment_id: response.razorpay_payment_id,
                                        razorpay_order_id:   response.razorpay_order_id,
                                        razorpay_signature:  response.razorpay_signature,
                                        donation_id:         res.donation_id,
                                    }),
                                })
                                .then(r => r.json())
                                .then(v => {
                                    if (v.status) { showDonationFeedback('JazakAllah Khair! Razorpay payment successful. 🤲', true); resetDonationForm(); }
                                    else          { showDonationFeedback(v.message || 'Payment verification failed.', false); }
                                })
                                .catch(() => showDonationFeedback('Verification error. Please contact support.', false));
                            },
                        });
                        rzp.open();
                        resolve();
                    };
                    if (window.Razorpay) { open(); return; }
                    const s = document.createElement('script');
                    s.src = 'https://checkout.razorpay.com/v1/checkout.js';
                    s.onload  = open;
                    s.onerror = () => { showDonationFeedback('Could not load Razorpay. Please try another method.', false); resolve(); };
                    document.head.appendChild(s);
                })
                .catch(() => { showDonationFeedback('Network error. Please check your connection.', false); resolve(); });
            });
        }

        // ── Paystack ─────────────────────────────────────────────
        function submitPaystack(formValues) {
            return new Promise((resolve) => {
                fetch('/api/donation/paystack/initialize', {
                    method:  'POST',
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body:    JSON.stringify({ ...formValues, category_id: parseInt(formValues.category), currency: 'NGN' }),
                })
                .then(r => r.json())
                .then(res => {
                    if (!res.status) { showDonationFeedback(res.message || 'Paystack error. Please try again.', false); resolve(); return; }
                    const open = () => {
                        const handler = window.PaystackPop.setup({
                            key:      res.public_key,
                            email:    res.email,
                            amount:   res.amount,
                            currency: res.currency,
                            ref:      res.reference,
                            callback: function(response) {
                                fetch('/api/donation/paystack/verify', {
                                    method:  'POST',
                                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                                    body:    JSON.stringify({ reference: response.reference, donation_id: res.donation_id }),
                                })
                                .then(r => r.json())
                                .then(v => {
                                    if (v.status) { showDonationFeedback('JazakAllah Khair! Paystack payment successful. 🤲', true); resetDonationForm(); }
                                    else          { showDonationFeedback(v.message || 'Payment verification failed.', false); }
                                })
                                .catch(() => showDonationFeedback('Verification error. Please contact support.', false));
                            },
                            onClose: function() {},
                        });
                        handler.openIframe();
                        resolve();
                    };
                    if (window.PaystackPop) { open(); return; }
                    const s = document.createElement('script');
                    s.src = 'https://js.paystack.co/v1/inline.js';
                    s.onload  = open;
                    s.onerror = () => { showDonationFeedback('Could not load Paystack. Please try another method.', false); resolve(); };
                    document.head.appendChild(s);
                })
                .catch(() => { showDonationFeedback('Network error. Please check your connection.', false); resolve(); });
            });
        }

        // ── SSLCommerz ───────────────────────────────────────────
        function submitSslCommerz(formValues) {
            return fetch('/api/donation/sslcommerz/initiate', {
                method:  'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body:    JSON.stringify({ ...formValues, category_id: parseInt(formValues.category), currency: 'BDT' }),
            })
            .then(r => r.json())
            .then(res => {
                if (res.status && res.gateway_url) {
                    window.location.href = res.gateway_url;
                } else {
                    showDonationFeedback(res.message || 'SSLCommerz error. Please try again.', false);
                }
            });
        }

        // ── Main submit handler ──────────────────────────────────
        function submitDonation() {
            if (!validateDonationForm()) return;

            const formValues = getDonationFormValues();
            const btn        = document.getElementById('donate-submit-btn');
            const btnTxt     = document.getElementById('donate-btn-text');
            const loader     = document.getElementById('donate-btn-loader');

            btn.disabled       = true;
            btnTxt.textContent = 'Processing…';
            loader.classList.remove('hidden');

            const done = () => {
                btn.disabled       = false;
                btnTxt.textContent = (TRANSLATIONS[currentLang] || TRANSLATIONS.en)['donate.btn'] || 'Donate Now';
                loader.classList.add('hidden');
            };

            let promise;
            if      (selectedGateway === 'stripe')     promise = submitStripe(formValues);
            else if (selectedGateway === 'razorpay')   promise = submitRazorpay(formValues);
            else if (selectedGateway === 'paystack')   promise = submitPaystack(formValues);
            else if (selectedGateway === 'sslcommerz') promise = submitSslCommerz(formValues);
            else                                       promise = Promise.resolve();

            promise.catch(() => showDonationFeedback('Network error. Please check your connection.', false))
                   .finally(done);
        }

        // ── On-load: check payment return params ─────────────────
        (function checkPaymentReturn() {
            const params   = new URLSearchParams(window.location.search);
            const donation = params.get('donation');

            if (donation === 'success') {
                const sessionId  = params.get('session_id');
                const donationId = params.get('donation_id');
                if (sessionId && donationId) {
                    fetch('/api/donation/stripe/verify', {
                        method:  'POST',
                        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                        body:    JSON.stringify({ session_id: sessionId, donation_id: donationId }),
                    }).catch(() => {});
                }
                setTimeout(() => {
                    const el = document.getElementById('donate-feedback');
                    if (el) { el.textContent = 'JazakAllah Khair! Your Stripe payment was successful. 🤲'; el.style.background='#d1fae5'; el.style.color='#065f46'; el.classList.remove('hidden'); }
                    document.getElementById('donate')?.scrollIntoView({ behavior: 'smooth' });
                }, 500);
                history.replaceState({}, '', window.location.pathname);
            } else if (donation === 'ssl_success') {
                setTimeout(() => {
                    const el = document.getElementById('donate-feedback');
                    if (el) { el.textContent = 'JazakAllah Khair! Your SSLCommerz payment was successful. 🤲'; el.style.background='#d1fae5'; el.style.color='#065f46'; el.classList.remove('hidden'); }
                    document.getElementById('donate')?.scrollIntoView({ behavior: 'smooth' });
                }, 500);
                history.replaceState({}, '', window.location.pathname);
            } else if (donation === 'ssl_fail') {
                setTimeout(() => {
                    const el = document.getElementById('donate-feedback');
                    if (el) { el.textContent = 'Payment failed. Please try again.'; el.style.background='#fee2e2'; el.style.color='#991b1b'; el.classList.remove('hidden'); }
                    document.getElementById('donate')?.scrollIntoView({ behavior: 'smooth' });
                }, 500);
                history.replaceState({}, '', window.location.pathname);
            } else if (donation === 'cancelled') {
                setTimeout(() => {
                    const el = document.getElementById('donate-feedback');
                    if (el) { el.textContent = 'Payment was cancelled.'; el.style.background='#fee2e2'; el.style.color='#991b1b'; el.classList.remove('hidden'); }
                    document.getElementById('donate')?.scrollIntoView({ behavior: 'smooth' });
                }, 500);
                history.replaceState({}, '', window.location.pathname);
            }
        })();

        // Load categories on page load
        loadDonationCategories();

        // ════════════════════════════════════════════════════════
        // AI CHAT MODULE
        // ════════════════════════════════════════════════════════
        let aiChatBusy = false;

        function escapeHtml(str) {
            return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        }

        function formatAIReply(text) {
            // Bold **text**
            text = text.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
            // Line breaks
            text = text.replace(/\n/g, '<br>');
            return text;
        }

        function appendChatBubble(role, html, isHtml) {
            const container = document.getElementById('ai-chat-messages');
            const div = document.createElement('div');

            if (role === 'user') {
                div.className = 'flex gap-2.5 justify-end';
                div.innerHTML = `
                    <div class="rounded-xl rounded-tr-none px-4 py-3 text-sm max-w-xs leading-relaxed" style="background: linear-gradient(135deg,var(--green-mid),var(--green-light)); color: rgba(255,255,255,0.92);">
                        ${isHtml ? html : escapeHtml(html)}
                    </div>
                    <div class="w-6 h-6 rounded-lg flex-shrink-0 flex items-center justify-center text-xs mt-0.5" style="background:rgba(255,255,255,0.08); color:rgba(255,255,255,0.6);">👤</div>
                `;
            } else {
                div.className = 'flex gap-2.5';
                div.innerHTML = `
                    <div class="w-6 h-6 rounded-lg flex-shrink-0 flex items-center justify-center text-xs mt-0.5" style="background:linear-gradient(135deg,var(--gold),var(--gold-light));">🤖</div>
                    <div class="rounded-xl rounded-tl-none px-4 py-3 text-sm max-w-sm leading-relaxed" style="background:rgba(255,255,255,0.06); color:rgba(255,255,255,0.82);">
                        ${isHtml ? html : escapeHtml(html)}
                    </div>
                `;
            }
            container.appendChild(div);
            container.scrollTop = container.scrollHeight;
            return div;
        }

        function appendTypingIndicator() {
            const container = document.getElementById('ai-chat-messages');
            const div = document.createElement('div');
            div.id = 'ai-typing';
            div.className = 'flex gap-2.5';
            div.innerHTML = `
                <div class="w-6 h-6 rounded-lg flex-shrink-0 flex items-center justify-center text-xs mt-0.5" style="background:linear-gradient(135deg,var(--gold),var(--gold-light));">🤖</div>
                <div class="rounded-xl rounded-tl-none px-4 py-3" style="background:rgba(255,255,255,0.06);">
                    <div class="flex gap-1 items-center h-4">
                        <span class="w-1.5 h-1.5 rounded-full bg-white/40 animate-bounce" style="animation-delay:0ms"></span>
                        <span class="w-1.5 h-1.5 rounded-full bg-white/40 animate-bounce" style="animation-delay:150ms"></span>
                        <span class="w-1.5 h-1.5 rounded-full bg-white/40 animate-bounce" style="animation-delay:300ms"></span>
                    </div>
                </div>
            `;
            container.appendChild(div);
            container.scrollTop = container.scrollHeight;
        }

        function removeTypingIndicator() {
            document.getElementById('ai-typing')?.remove();
        }

        function sendAIChatMessage() {
            if (aiChatBusy) return;
            const input = document.getElementById('ai-chat-input');
            const message = input.value.trim();
            if (!message) return;

            aiChatBusy = true;
            input.value = '';
            input.style.height = 'auto';
            document.getElementById('ai-chat-send').style.opacity = '0.5';

            appendChatBubble('user', message, false);
            appendTypingIndicator();

            fetch('/api/ai/chat', {
                method:  'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body:    JSON.stringify({ message }),
            })
            .then(r => r.json())
            .then(data => {
                removeTypingIndicator();
                if (data.success) {
                    appendChatBubble('bot', formatAIReply(escapeHtml(data.reply)), true);
                } else {
                    appendChatBubble('bot', data.error || 'Sorry, an error occurred. Please try again.', false);
                }
            })
            .catch(() => {
                removeTypingIndicator();
                appendChatBubble('bot', 'Network error. Please check your connection and try again.', false);
            })
            .finally(() => {
                aiChatBusy = false;
                document.getElementById('ai-chat-send').style.opacity = '1';
            });
        }

        function handleAIChatKeydown(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendAIChatMessage();
            }
        }

        function sendQuickChatQuestion(q) {
            document.getElementById('ai-chat-input').value = q;
            document.getElementById('ai-chat').scrollIntoView({ behavior: 'smooth', block: 'center' });
            setTimeout(sendAIChatMessage, 400);
        }

        // ════════════════════════════════════════════════════════
        // ISLAMIC NAME GENERATOR MODULE
        // ════════════════════════════════════════════════════════
        let ngGender = 'boy';

        function selectNameGender(gender) {
            ngGender = gender;
            const boyBtn  = document.getElementById('ng-btn-boy');
            const girlBtn = document.getElementById('ng-btn-girl');
            if (gender === 'boy') {
                boyBtn.style.borderColor  = '#1a5c38';
                boyBtn.style.background   = '#1a5c38';
                boyBtn.style.color        = 'white';
                girlBtn.style.borderColor = 'var(--lp-border)';
                girlBtn.style.background  = 'var(--lp-surface)';
                girlBtn.style.color       = 'var(--lp-text-soft)';
            } else {
                girlBtn.style.borderColor = '#be185d';
                girlBtn.style.background  = '#be185d';
                girlBtn.style.color       = 'white';
                boyBtn.style.borderColor  = 'var(--lp-border)';
                boyBtn.style.background   = 'var(--lp-surface)';
                boyBtn.style.color        = 'var(--lp-text-soft)';
            }
        }

        function generateIslamicNames() {
            const btn    = document.getElementById('ng-generate-btn');
            const btnTxt = document.getElementById('ng-btn-text');
            const loader = document.getElementById('ng-btn-loader');
            const errEl  = document.getElementById('ng-error');
            const theme  = document.getElementById('ng-theme').value.trim();

            btn.disabled  = true;
            btnTxt.classList.add('hidden');
            loader.classList.remove('hidden');
            errEl.classList.add('hidden');

            fetch('/api/ai/generate-names', {
                method:  'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body:    JSON.stringify({ gender: ngGender, theme }),
            })
            .then(r => r.json())
            .then(data => {
                if (data.success && Array.isArray(data.names) && data.names.length) {
                    renderNameCards(data.names);
                } else {
                    showNgError(data.error || 'Could not generate names. Please try again.');
                }
            })
            .catch(() => showNgError('Network error. Please check your connection.'))
            .finally(() => {
                btn.disabled = false;
                btnTxt.classList.remove('hidden');
                loader.classList.add('hidden');
            });
        }

        function renderNameCards(names) {
            const grid    = document.getElementById('ng-names-grid');
            const wrap    = document.getElementById('ng-results-wrap');
            const label   = document.getElementById('ng-results-label');
            const placeholder = document.getElementById('ng-placeholder');

            const genderLabel = ngGender === 'boy' ? 'Boys' : 'Girls';
            label.textContent = `AI-generated Islamic names for ${genderLabel}`;

            grid.innerHTML = names.map(n => `
                <div class="bg-white rounded-2xl p-5 card-hover" style="border:1px solid var(--lp-border); animation: fadeInUp 0.4s ease both;">
                    <div class="flex items-start justify-between mb-3">
                        <span class="font-arabic text-2xl leading-none" style="color:var(--lp-accent);">${escapeHtml(n.arabic || '')}</span>
                        <span class="text-xs px-2 py-0.5 rounded-full font-medium" style="background:${ngGender==='boy'?'#dbeafe':'#fce7f3'}; color:${ngGender==='boy'?'#1d4ed8':'#be185d'};">${ngGender==='boy'?'Boy':'Girl'}</span>
                    </div>
                    <p class="font-bold text-gray-900 text-base mb-1">${escapeHtml(n.name || '')}</p>
                    <p class="text-gray-500 text-sm leading-relaxed mb-2">${escapeHtml(n.meaning || '')}</p>
                    <p class="text-gray-400 text-xs">Origin: ${escapeHtml(n.origin || 'Arabic')}</p>
                </div>
            `).join('');

            placeholder.style.display = 'none';
            wrap.classList.remove('hidden');
            observer.observe(wrap);

            document.getElementById('name-generator').scrollIntoView({ behavior: 'smooth', block: 'center' });
        }

        function showNgError(msg) {
            const el = document.getElementById('ng-error');
            el.textContent = msg;
            el.classList.remove('hidden');
        }

        // ════════════════════════════════════════════════════════
        // QURAN AUDIO PLAYER MODULE
        // ════════════════════════════════════════════════════════

        // All 114 surahs hardcoded — avoids /api/chapters which requires translator_id
        const QA_SURAHS = [
            {id:1,  ar:'الفاتحة',   en:'Al-Fatiha',       v:7},
            {id:2,  ar:'البقرة',    en:'Al-Baqarah',      v:286},
            {id:3,  ar:'آل عمران',  en:"Ali 'Imran",      v:200},
            {id:4,  ar:'النساء',    en:"An-Nisa",         v:176},
            {id:5,  ar:'المائدة',   en:'Al-Maidah',       v:120},
            {id:6,  ar:'الأنعام',   en:"Al-An'am",        v:165},
            {id:7,  ar:'الأعراف',   en:"Al-A'raf",        v:206},
            {id:8,  ar:'الأنفال',   en:'Al-Anfal',        v:75},
            {id:9,  ar:'التوبة',    en:'At-Tawbah',       v:129},
            {id:10, ar:'يونس',      en:'Yunus',           v:109},
            {id:11, ar:'هود',       en:'Hud',             v:123},
            {id:12, ar:'يوسف',      en:'Yusuf',           v:111},
            {id:13, ar:'الرعد',     en:"Ar-Ra'd",         v:43},
            {id:14, ar:'إبراهيم',   en:'Ibrahim',         v:52},
            {id:15, ar:'الحجر',     en:'Al-Hijr',         v:99},
            {id:16, ar:'النحل',     en:'An-Nahl',         v:128},
            {id:17, ar:'الإسراء',   en:"Al-Isra",         v:111},
            {id:18, ar:'الكهف',     en:'Al-Kahf',         v:110},
            {id:19, ar:'مريم',      en:'Maryam',          v:98},
            {id:20, ar:'طه',        en:'Ta-Ha',           v:135},
            {id:21, ar:'الأنبياء',  en:'Al-Anbiya',       v:112},
            {id:22, ar:'الحج',      en:'Al-Hajj',         v:78},
            {id:23, ar:'المؤمنون',  en:"Al-Mu'minun",     v:118},
            {id:24, ar:'النور',     en:'An-Nur',          v:64},
            {id:25, ar:'الفرقان',   en:'Al-Furqan',       v:77},
            {id:26, ar:'الشعراء',   en:"Ash-Shu'ara",     v:227},
            {id:27, ar:'النمل',     en:'An-Naml',         v:93},
            {id:28, ar:'القصص',     en:'Al-Qasas',        v:88},
            {id:29, ar:'العنكبوت',  en:'Al-Ankabut',      v:69},
            {id:30, ar:'الروم',     en:'Ar-Rum',          v:60},
            {id:31, ar:'لقمان',     en:'Luqman',          v:34},
            {id:32, ar:'السجدة',    en:'As-Sajdah',       v:30},
            {id:33, ar:'الأحزاب',   en:'Al-Ahzab',        v:73},
            {id:34, ar:'سبأ',       en:'Saba',            v:54},
            {id:35, ar:'فاطر',      en:'Fatir',           v:45},
            {id:36, ar:'يس',        en:'Ya-Sin',          v:83},
            {id:37, ar:'الصافات',   en:'As-Saffat',       v:182},
            {id:38, ar:'ص',         en:'Sad',             v:88},
            {id:39, ar:'الزمر',     en:'Az-Zumar',        v:75},
            {id:40, ar:'غافر',      en:'Ghafir',          v:85},
            {id:41, ar:'فصلت',      en:'Fussilat',        v:54},
            {id:42, ar:'الشورى',    en:'Ash-Shura',       v:53},
            {id:43, ar:'الزخرف',    en:'Az-Zukhruf',      v:89},
            {id:44, ar:'الدخان',    en:'Ad-Dukhan',       v:59},
            {id:45, ar:'الجاثية',   en:'Al-Jathiyah',     v:37},
            {id:46, ar:'الأحقاف',   en:'Al-Ahqaf',        v:35},
            {id:47, ar:'محمد',      en:'Muhammad',        v:38},
            {id:48, ar:'الفتح',     en:'Al-Fath',         v:29},
            {id:49, ar:'الحجرات',   en:'Al-Hujurat',      v:18},
            {id:50, ar:'ق',         en:'Qaf',             v:45},
            {id:51, ar:'الذاريات',  en:'Adh-Dhariyat',    v:60},
            {id:52, ar:'الطور',     en:'At-Tur',          v:49},
            {id:53, ar:'النجم',     en:'An-Najm',         v:62},
            {id:54, ar:'القمر',     en:'Al-Qamar',        v:55},
            {id:55, ar:'الرحمن',    en:'Ar-Rahman',       v:78},
            {id:56, ar:'الواقعة',   en:"Al-Waqi'ah",      v:96},
            {id:57, ar:'الحديد',    en:'Al-Hadid',        v:29},
            {id:58, ar:'المجادلة',  en:'Al-Mujadila',     v:22},
            {id:59, ar:'الحشر',     en:'Al-Hashr',        v:24},
            {id:60, ar:'الممتحنة',  en:'Al-Mumtahanah',   v:13},
            {id:61, ar:'الصف',      en:'As-Saf',          v:14},
            {id:62, ar:'الجمعة',    en:"Al-Jumu'ah",      v:11},
            {id:63, ar:'المنافقون', en:'Al-Munafiqun',    v:11},
            {id:64, ar:'التغابن',   en:'At-Taghabun',     v:18},
            {id:65, ar:'الطلاق',    en:'At-Talaq',        v:12},
            {id:66, ar:'التحريم',   en:'At-Tahrim',       v:12},
            {id:67, ar:'الملك',     en:'Al-Mulk',         v:30},
            {id:68, ar:'القلم',     en:'Al-Qalam',        v:52},
            {id:69, ar:'الحاقة',    en:'Al-Haqqah',       v:52},
            {id:70, ar:'المعارج',   en:"Al-Ma'arij",      v:44},
            {id:71, ar:'نوح',       en:'Nuh',             v:28},
            {id:72, ar:'الجن',      en:'Al-Jinn',         v:28},
            {id:73, ar:'المزمل',    en:'Al-Muzzammil',    v:20},
            {id:74, ar:'المدثر',    en:'Al-Muddaththir',  v:56},
            {id:75, ar:'القيامة',   en:'Al-Qiyamah',      v:40},
            {id:76, ar:'الإنسان',   en:'Al-Insan',        v:31},
            {id:77, ar:'المرسلات',  en:'Al-Mursalat',     v:50},
            {id:78, ar:'النبأ',     en:"An-Naba",         v:40},
            {id:79, ar:'النازعات',  en:"An-Nazi'at",      v:46},
            {id:80, ar:'عبس',       en:'Abasa',           v:42},
            {id:81, ar:'التكوير',   en:'At-Takwir',       v:29},
            {id:82, ar:'الانفطار',  en:'Al-Infitar',      v:19},
            {id:83, ar:'المطففين',  en:'Al-Mutaffifin',   v:36},
            {id:84, ar:'الانشقاق',  en:'Al-Inshiqaq',     v:25},
            {id:85, ar:'البروج',    en:'Al-Buruj',        v:22},
            {id:86, ar:'الطارق',    en:'At-Tariq',        v:17},
            {id:87, ar:'الأعلى',    en:"Al-A'la",         v:19},
            {id:88, ar:'الغاشية',   en:'Al-Ghashiyah',    v:26},
            {id:89, ar:'الفجر',     en:'Al-Fajr',         v:30},
            {id:90, ar:'البلد',     en:'Al-Balad',        v:20},
            {id:91, ar:'الشمس',     en:'Ash-Shams',       v:15},
            {id:92, ar:'الليل',     en:'Al-Layl',         v:21},
            {id:93, ar:'الضحى',     en:'Ad-Duhaa',        v:11},
            {id:94, ar:'الشرح',     en:'Ash-Sharh',       v:8},
            {id:95, ar:'التين',     en:'At-Tin',          v:8},
            {id:96, ar:'العلق',     en:"Al-'Alaq",        v:19},
            {id:97, ar:'القدر',     en:'Al-Qadr',         v:5},
            {id:98, ar:'البينة',    en:'Al-Bayyinah',     v:8},
            {id:99, ar:'الزلزلة',   en:'Az-Zalzalah',     v:8},
            {id:100,ar:'العاديات',  en:"Al-'Adiyat",      v:11},
            {id:101,ar:'القارعة',   en:"Al-Qari'ah",      v:11},
            {id:102,ar:'التكاثر',   en:'At-Takathur',     v:8},
            {id:103,ar:'العصر',     en:"Al-'Asr",         v:3},
            {id:104,ar:'الهمزة',    en:'Al-Humazah',      v:9},
            {id:105,ar:'الفيل',     en:'Al-Fil',          v:5},
            {id:106,ar:'قريش',      en:'Quraysh',         v:4},
            {id:107,ar:'الماعون',   en:"Al-Ma'un",        v:7},
            {id:108,ar:'الكوثر',    en:'Al-Kawthar',      v:3},
            {id:109,ar:'الكافرون',  en:'Al-Kafirun',      v:6},
            {id:110,ar:'النصر',     en:'An-Nasr',         v:3},
            {id:111,ar:'المسد',     en:'Al-Masad',        v:5},
            {id:112,ar:'الإخلاص',   en:'Al-Ikhlas',       v:4},
            {id:113,ar:'الفلق',     en:'Al-Falaq',        v:5},
            {id:114,ar:'الناس',     en:'An-Nas',          v:6},
        ];

        const qa = {
            reciterSuras: {},
            currentSurah: null,
            translatorId: null,
            showTranslation: true,
            audioLoaded: false,
            autoPlay: false,
        };

        // Expand index container height on desktop
        (function qaResponsiveIndex() {
            function applyHeight() {
                const el = document.getElementById('qa-index-container');
                if (!el) return;
                el.style.maxHeight = window.innerWidth >= 1024 ? '540px' : '260px';
            }
            applyHeight();
            window.addEventListener('resize', applyHeight);
        })();

        // Populate surah dropdown immediately (no API needed)
        (function qaInit() {
            // Surah dropdown
            const sel = document.getElementById('qa-surah-select');
            QA_SURAHS.forEach(s => {
                const opt = document.createElement('option');
                opt.value = s.id;
                opt.textContent = s.id + '. ' + s.ar + '  –  ' + s.en;
                opt.style.background = '#0a2e1e';
                sel.appendChild(opt);
            });

            // Translators → tabs
            fetch('/api/translators')
                .then(r => r.json())
                .then(data => {
                    const list = data.data || [];
                    const tabWrap = document.getElementById('qa-translator-tabs');
                    tabWrap.innerHTML = '';
                    list.forEach((t, i) => {
                        const btn = document.createElement('button');
                        btn.className = 'qa-translator-tab flex-shrink-0 px-3 py-1.5 rounded-lg text-xs font-semibold transition-all whitespace-nowrap';
                        btn.dataset.tid = t.id;
                        // Show language + short name, e.g. "EN – Sahih"
                        btn.textContent = (t.language_code ? t.language_code.toUpperCase() : t.language) + ' – ' + (t.short_name || t.full_name);
                        btn.title = t.full_name;
                        btn.onclick = () => qaSetTranslator(t.id);
                        qaStyleTab(btn, false);
                        if (i === 0) {
                            qa.translatorId = t.id;
                            qaStyleTab(btn, true);
                        }
                        tabWrap.appendChild(btn);
                    });
                })
                .catch(() => {
                    document.getElementById('qa-translator-tabs').innerHTML =
                        '<span class="text-white/30 text-xs py-1.5">No translators found</span>';
                });

            // Reciters
            fetch('/api/reciters')
                .then(r => r.json())
                .then(data => {
                    const list = data.data || [];
                    const rSel = document.getElementById('qa-reciter-select');
                    list.forEach(rec => {
                        const opt = document.createElement('option');
                        opt.value = rec.id;
                        opt.textContent = rec.name;
                        opt.style.background = '#0a2e1e';
                        rSel.appendChild(opt);
                    });
                    if (list.length > 0) rSel.value = list[0].id;
                })
                .catch(() => {});
        })();

        function qaStyleTab(btn, active) {
            btn.style.cssText = active
                ? 'background:rgba(212,168,67,0.25);color:#d4a843;border:1px solid rgba(212,168,67,0.5);'
                : 'background:rgba(255,255,255,0.08);color:rgba(255,255,255,0.55);border:1px solid rgba(255,255,255,0.12);';
        }

        function qaSetTranslator(id) {
            qa.translatorId = id;
            document.querySelectorAll('.qa-translator-tab').forEach(btn => {
                qaStyleTab(btn, btn.dataset.tid == id);
            });
            if (qa.currentSurah) qaFetchVerses(qa.currentSurah.id);
        }

        function qaLoadSurah(surahId) {
            if (!surahId) return;
            const ch = QA_SURAHS.find(s => s.id == surahId);
            if (!ch) return;

            qa.currentSurah = { id: ch.id, arabicName: ch.ar, englishName: ch.en, versesCount: ch.v };

            document.getElementById('qa-surah-arabic').textContent = ch.ar;
            document.getElementById('qa-surah-english').textContent = ch.en;
            document.getElementById('qa-surah-count').textContent = ch.v + ' verses';
            document.getElementById('qa-surah-place').textContent = '';
            document.getElementById('qa-bismillah').classList.toggle('hidden', ch.id === 9);

            qaFetchVerses(ch.id);
        }

        function qaFetchVerses(surahId) {
            if (!qa.translatorId) {
                // translators still loading — retry briefly
                setTimeout(() => { if (qa.translatorId) qaFetchVerses(surahId); }, 600);
                return;
            }

            // Show loading state
            document.getElementById('qa-placeholder').style.display = 'none';
            const loading = document.getElementById('qa-loading');
            loading.classList.remove('hidden');
            loading.style.display = 'flex';
            const versesContainer = document.getElementById('qa-verses');
            versesContainer.querySelectorAll('.qa-verse-card').forEach(el => el.remove());
            document.getElementById('qa-verse-index').innerHTML =
                '<div class="p-6 text-center text-gray-300 text-sm">Loading…</div>';

            fetch('/api/verses/' + surahId + '?translator_id=' + qa.translatorId)
                .then(r => r.json())
                .then(data => {
                    loading.style.display = 'none';

                    if (!data.data?.chapter_info?.length) {
                        const msg = document.createElement('div');
                        msg.className = 'qa-verse-card py-10 text-center text-gray-400 text-sm';
                        msg.textContent = 'No translation data available for this surah.';
                        versesContainer.appendChild(msg);
                        return;
                    }

                    // Flatten pages → verses
                    const verses = data.data.chapter_info.flatMap(p => p.page_verses);

                    // Verse index (left panel)
                    const idx = document.getElementById('qa-verse-index');
                    idx.innerHTML = '';
                    verses.forEach((v, i) => {
                        const div = document.createElement('div');
                        div.className = 'qa-idx-item flex items-center gap-3 px-4 py-2.5 cursor-pointer transition-colors';
                        div.dataset.verse = i;
                        div.style.cssText = 'border-bottom:1px solid var(--lp-border);';
                        div.onmouseenter = () => { div.style.background = 'var(--lp-track)'; };
                        div.onmouseleave = () => { div.style.background = ''; };
                        const preview = v.arabic_name.length > 38 ? v.arabic_name.substring(0, 38) + '…' : v.arabic_name;
                        div.innerHTML = `
                            <div class="w-6 h-6 rounded-full flex items-center justify-center text-xs flex-shrink-0 font-semibold" style="background:var(--lp-track);color:var(--lp-text-soft);">${v.verses_number}</div>
                            <span class="font-arabic text-right flex-1 text-sm leading-relaxed text-gray-600" dir="rtl">${preview}</span>
                        `;
                        div.addEventListener('click', () => qaScrollToVerse(i));
                        idx.appendChild(div);
                    });

                    // Verse reading cards (right panel)
                    verses.forEach((v, i) => {
                        const card = document.createElement('div');
                        card.className = 'qa-verse-card rounded-2xl p-4 lg:p-5 transition-all';
                        card.dataset.verse = i;
                        card.style.cssText = 'background:var(--lp-input-bg); border:1px solid var(--lp-border);';
                        card.innerHTML = `
                            <div class="flex items-center gap-3 mb-3">
                                <div class="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0"
                                    style="background:linear-gradient(135deg,var(--green-dark),var(--green-mid));color:white;">${v.verses_number}</div>
                                <div class="h-px flex-1" style="background:var(--lp-border);"></div>
                            </div>
                            <p class="font-arabic text-xl lg:text-2xl text-gray-900 text-right mb-3"
                                dir="rtl" style="line-height:2.2;">${v.arabic_name}</p>
                            ${v.english_transliteration
                                ? `<p class="text-gray-400 text-xs italic mb-2 leading-relaxed">${escapeHtml(v.english_transliteration)}</p>`
                                : ''}
                            <p class="qa-translation text-gray-500 text-sm leading-relaxed${qa.showTranslation ? '' : ' hidden'}">${escapeHtml(v.translated_name || '')}</p>
                        `;
                        versesContainer.appendChild(card);
                    });

                    qaLoadAudio();
                })
                .catch(() => {
                    loading.style.display = 'none';
                    const msg = document.createElement('div');
                    msg.className = 'qa-verse-card py-10 text-center text-gray-400 text-sm';
                    msg.textContent = 'Could not load verses. Please check your connection.';
                    versesContainer.appendChild(msg);
                });
        }

        function qaScrollToVerse(idx) {
            // Scroll right panel (reading area) to the verse card
            const versesContainer = document.getElementById('qa-verses');
            const card = versesContainer.querySelector(`.qa-verse-card[data-verse="${idx}"]`);
            if (card) {
                const offset = card.offsetTop - versesContainer.offsetTop - 16;
                versesContainer.scrollTo({ top: offset, behavior: 'smooth' });
                // Brief highlight
                card.style.background = 'var(--lp-flash-bg)';
                card.style.borderColor = 'var(--lp-accent)';
                setTimeout(() => {
                    card.style.background = 'var(--lp-input-bg)';
                    card.style.borderColor = 'var(--lp-border)';
                }, 1200);
            }

            // Scroll left panel (index) to the matching index item
            const indexContainer = document.getElementById('qa-index-container');
            const idxItem = document.querySelector(`.qa-idx-item[data-verse="${idx}"]`);
            if (idxItem && indexContainer) {
                const header = document.getElementById('qa-surah-header');
                const headerH = header ? header.offsetHeight : 0;
                const offset = idxItem.offsetTop - indexContainer.offsetTop - headerH;
                indexContainer.scrollTo({ top: offset, behavior: 'smooth' });
            }
        }

        function qaLoadAudio() {
            const reciterSel = document.getElementById('qa-reciter-select');
            const reciterId = reciterSel.value;
            if (!reciterId || !qa.currentSurah) {
                document.getElementById('qa-no-audio').style.display = '';
                document.getElementById('qa-play-btn').disabled = true;
                return;
            }

            // Check cache
            if (qa.reciterSuras[reciterId]) {
                qaSetAudio(reciterId);
                return;
            }

            // Fetch reciter suras
            fetch('/api/reciter-sura/' + reciterId)
                .then(r => r.json())
                .then(data => {
                    if (data.data) {
                        qa.reciterSuras[reciterId] = data.data;
                        // Update avatar
                        if (data.data.length > 0) {
                            const avatar = document.getElementById('qa-reciter-avatar');
                            avatar.src = data.data[0].reciter_avatar || '';
                            avatar.classList.toggle('hidden', !data.data[0].reciter_avatar);
                        }
                    }
                    qaSetAudio(reciterId);
                })
                .catch(() => {
                    document.getElementById('qa-no-audio').style.display = '';
                });
        }

        function qaSetAudio(reciterId) {
            if (!qa.currentSurah) return;
            const suras = qa.reciterSuras[reciterId] || [];
            const match = suras.find(s => parseInt(s.number) === parseInt(qa.currentSurah.id));
            const audio = document.getElementById('qa-audio');
            const noAudio = document.getElementById('qa-no-audio');
            const playBtn = document.getElementById('qa-play-btn');

            // Stop everything and reset UI for the new surah
            audio.pause();
            qavStop();
            qaResetProgressUI();
            document.getElementById('qa-icon-pause').classList.add('hidden');
            document.getElementById('qa-icon-loading').classList.add('hidden');
            document.getElementById('qa-icon-play').classList.remove('hidden');

            if (match && match.path) {
                audio.src = match.path;
                audio.volume = (document.getElementById('qa-volume').value || 80) / 100;
                audio.load();
                qa.audioLoaded = true;
                noAudio.style.display = 'none';
                playBtn.disabled = false;
                // Set duration from API metadata (corrected by loadedmetadata event later)
                if (match.duration) {
                    document.getElementById('qa-duration').textContent = qaFmtTime(match.duration / 1000);
                }

                // Auto-play if advancing from previous surah ending
                if (qa.autoPlay) {
                    qa.autoPlay = false;
                    qavInit();
                    document.getElementById('qa-icon-play').classList.add('hidden');
                    document.getElementById('qa-icon-loading').classList.remove('hidden');
                    audio.play()
                        .then(() => {
                            document.getElementById('qa-icon-loading').classList.add('hidden');
                            document.getElementById('qa-icon-pause').classList.remove('hidden');
                            qavStart();
                            qaStartProgress();
                        })
                        .catch(() => {
                            document.getElementById('qa-icon-loading').classList.add('hidden');
                            document.getElementById('qa-icon-play').classList.remove('hidden');
                        });
                }
            } else {
                audio.src = '';
                qa.audioLoaded = false;
                qa.autoPlay = false;
                noAudio.style.display = '';
                playBtn.disabled = true;
                noAudio.textContent = suras.length === 0 ? 'No audio from this reciter' : 'Audio not available for this surah';
            }
        }

        // ── Frequency Visualizer ─────────────────────────────────
        const qav = { ctx: null, analyser: null, source: null, raf: null, peaks: [] };

        function qavInit() {
            if (qav.ctx) {
                // AudioContext may be suspended after page inactivity
                if (qav.ctx.state === 'suspended') qav.ctx.resume();
                return;
            }
            const audio = document.getElementById('qa-audio');
            try {
                qav.ctx      = new (window.AudioContext || window.webkitAudioContext)();
                qav.source   = qav.ctx.createMediaElementSource(audio);
                qav.analyser = qav.ctx.createAnalyser();
                qav.analyser.fftSize          = 256;   // 128 frequency bins
                qav.analyser.smoothingTimeConstant = 0.78;
                qav.source.connect(qav.analyser);
                qav.analyser.connect(qav.ctx.destination);
            } catch(e) { /* Web Audio not supported */ }
        }

        function qavStart() {
            if (!qav.analyser) return;
            const canvas = document.getElementById('qa-canvas');
            canvas.style.display = 'block';

            const bins = qav.analyser.frequencyBinCount;
            qav.peaks = new Float32Array(bins).fill(0);
            const ctx2d = canvas.getContext('2d');
            const dpr   = window.devicePixelRatio || 1;
            let lastCssW = 0;

            function syncSize() {
                // getBoundingClientRect gives the true CSS pixel width
                const cssW = Math.round(canvas.getBoundingClientRect().width);
                const cssH = 56;
                if (cssW === lastCssW) return;
                lastCssW = cssW;
                // Set physical buffer size (dpr-aware for crisp rendering)
                canvas.width  = cssW * dpr;
                canvas.height = cssH * dpr;
                ctx2d.scale(dpr, dpr);
            }

            function draw() {
                qav.raf = requestAnimationFrame(draw);
                syncSize();

                const W = lastCssW;
                const H = 56;
                if (!W) return;

                const data = new Uint8Array(bins);
                qav.analyser.getByteFrequencyData(data);

                ctx2d.clearRect(0, 0, W, H);

                // Use lower 65% of bins (bass + mids, skip ultrasonic noise)
                const useBins = Math.floor(bins * 0.65);
                const gap     = 2;
                const barW    = Math.max(2, Math.floor((W - gap * useBins) / useBins));
                const step    = barW + gap;

                // Shared vertical gradient (created once per frame is fine)
                const grad = ctx2d.createLinearGradient(0, H, 0, 0);
                grad.addColorStop(0,    '#1a5c38');
                grad.addColorStop(0.55, '#2d8a54');
                grad.addColorStop(1,    '#d4a843');

                for (let i = 0; i < useBins; i++) {
                    const ratio = data[i] / 255;
                    const barH  = Math.max(2, ratio * (H - 4));
                    const x     = i * step;
                    const y     = H - barH;

                    ctx2d.fillStyle = grad;

                    // Rounded-top bar
                    const r = Math.min(barW / 2, 2.5);
                    ctx2d.beginPath();
                    ctx2d.moveTo(x + r, y);
                    ctx2d.lineTo(x + barW - r, y);
                    ctx2d.quadraticCurveTo(x + barW, y, x + barW, y + r);
                    ctx2d.lineTo(x + barW, H);
                    ctx2d.lineTo(x, H);
                    ctx2d.lineTo(x, y + r);
                    ctx2d.quadraticCurveTo(x, y, x + r, y);
                    ctx2d.closePath();
                    ctx2d.fill();

                    // Falling peak line
                    qav.peaks[i] = ratio > qav.peaks[i]
                        ? ratio
                        : Math.max(0, qav.peaks[i] - 0.013);
                    const peakY = H - qav.peaks[i] * (H - 4) - 3;
                    ctx2d.fillStyle = 'rgba(212,168,67,0.9)';
                    ctx2d.fillRect(x, peakY, barW, 2);
                }
            }
            draw();
        }

        function qavStop() {
            if (qav.raf) { cancelAnimationFrame(qav.raf); qav.raf = null; }
            const canvas = document.getElementById('qa-canvas');
            if (!canvas) return;
            const ctx2d = canvas.getContext('2d');
            if (ctx2d) ctx2d.clearRect(0, 0, canvas.width, canvas.height);
            canvas.style.display = 'none';
            canvas.width = 0; // reset so next qavStart re-syncs size fresh
        }
        // ─────────────────────────────────────────────────────────

        function qaTogglePlay() {
            const audio = document.getElementById('qa-audio');
            if (!qa.audioLoaded || !audio.src) return;
            if (audio.paused) {
                qavInit();
                document.getElementById('qa-icon-play').classList.add('hidden');
                document.getElementById('qa-icon-loading').classList.remove('hidden');
                audio.play()
                    .then(() => {
                        document.getElementById('qa-icon-loading').classList.add('hidden');
                        document.getElementById('qa-icon-pause').classList.remove('hidden');
                        qavStart();
                        qaStartProgress();
                    })
                    .catch(() => {
                        document.getElementById('qa-icon-loading').classList.add('hidden');
                        document.getElementById('qa-icon-play').classList.remove('hidden');
                    });
            } else {
                audio.pause();
                document.getElementById('qa-icon-pause').classList.add('hidden');
                document.getElementById('qa-icon-play').classList.remove('hidden');
                qavStop();
                qaStopProgress();
            }
        }

        function qaOnAudioEnded() {
            qavStop();
            qaStopProgress();
            const currentId = qa.currentSurah?.id;
            if (currentId && currentId < 114) {
                qa.autoPlay = true;
                const nextId = currentId + 1;
                document.getElementById('qa-surah-select').value = nextId;
                qaLoadSurah(nextId);
            } else {
                document.getElementById('qa-icon-pause').classList.add('hidden');
                document.getElementById('qa-icon-play').classList.remove('hidden');
                qaResetProgressUI();
            }
        }

        // ── Progress polling (replaces unreliable ontimeupdate) ───
        let qaPollTimer = null;

        function qaStartProgress() {
            qaStopProgress();
            qaPollTimer = setInterval(() => {
                const audio = document.getElementById('qa-audio');
                const dur = audio.duration;
                if (!dur || isNaN(dur) || !isFinite(dur)) return;
                const pct = Math.min(100, (audio.currentTime / dur) * 100);
                document.getElementById('qa-progress-bar').style.width = pct + '%';
                document.getElementById('qa-current-time').textContent = qaFmtTime(audio.currentTime);
            }, 250);
        }

        function qaStopProgress() {
            if (qaPollTimer) { clearInterval(qaPollTimer); qaPollTimer = null; }
        }

        function qaResetProgressUI() {
            qaStopProgress();
            document.getElementById('qa-progress-bar').style.width = '0%';
            document.getElementById('qa-current-time').textContent = '0:00';
            document.getElementById('qa-duration').textContent = '0:00';
        }

        function qaOnMetadata() {
            const audio = document.getElementById('qa-audio');
            const dur = audio.duration;
            if (dur && isFinite(dur)) {
                document.getElementById('qa-duration').textContent = qaFmtTime(dur);
            }
        }

        function qaSeek(event, bar) {
            const audio = document.getElementById('qa-audio');
            if (!audio.duration) return;
            const rect = bar.getBoundingClientRect();
            const pct = Math.max(0, Math.min(1, (event.clientX - rect.left) / rect.width));
            audio.currentTime = pct * audio.duration;
        }

        function qaSkipBackward() {
            const audio = document.getElementById('qa-audio');
            audio.currentTime = Math.max(0, audio.currentTime - 10);
        }

        function qaSkipForward() {
            const audio = document.getElementById('qa-audio');
            audio.currentTime = Math.min(audio.duration || 0, audio.currentTime + 10);
        }

        function qaPrevSurah() {
            const currentId = qa.currentSurah?.id;
            if (!currentId || currentId <= 1) return;
            const prevId = currentId - 1;
            document.getElementById('qa-surah-select').value = prevId;
            qaLoadSurah(prevId);
        }

        function qaNextSurah() {
            const currentId = qa.currentSurah?.id;
            if (!currentId || currentId >= 114) return;
            const nextId = currentId + 1;
            document.getElementById('qa-surah-select').value = nextId;
            qaLoadSurah(nextId);
        }

        function qaSetVolume(val) {
            document.getElementById('qa-audio').volume = val / 100;
        }

        function qaToggleIndex() {
            const container = document.getElementById('qa-index-container');
            const btn = document.getElementById('qa-idx-toggle');
            const isHidden = container.classList.contains('hidden');
            container.classList.toggle('hidden', !isHidden);
            btn.style.background = isHidden ? 'rgba(212,168,67,0.2)' : 'rgba(255,255,255,0.1)';
            btn.style.color      = isHidden ? '#d4a843' : 'rgba(255,255,255,0.8)';
            btn.style.borderColor= isHidden ? 'rgba(212,168,67,0.3)' : 'rgba(255,255,255,0.2)';
        }

        function qaToggleTranslation() {
            qa.showTranslation = !qa.showTranslation;
            document.querySelectorAll('.qa-translation').forEach(el => {
                el.classList.toggle('hidden', !qa.showTranslation);
            });
            const btn = document.getElementById('qa-trans-toggle');
            btn.style.background = qa.showTranslation ? 'rgba(212,168,67,0.2)' : 'rgba(255,255,255,0.08)';
            btn.style.color = qa.showTranslation ? '#d4a843' : 'rgba(255,255,255,0.5)';
            btn.style.borderColor = qa.showTranslation ? 'rgba(212,168,67,0.3)' : 'rgba(255,255,255,0.15)';
        }

        function qaFmtTime(seconds) {
            if (!seconds || isNaN(seconds)) return '0:00';
            const m = Math.floor(seconds / 60);
            const s = Math.floor(seconds % 60);
            return m + ':' + String(s).padStart(2, '0');
        }
    </script>

    @if($showBuy)
    <a href="{{ $s['codecanyon_url'] }}" target="_blank"
       data-i18n="nav.buy_btn"
       style="position:fixed;bottom:28px;right:28px;z-index:9999;display:flex;align-items:center;gap:8px;padding:12px 20px;border-radius:50px;background:linear-gradient(135deg,#81B441,#5d8f2a);color:#fff;font-family:'Inter',sans-serif;font-size:14px;font-weight:600;text-decoration:none;box-shadow:0 4px 20px rgba(0,0,0,0.35);transition:transform 0.2s,box-shadow 0.2s;"
       onmouseover="this.style.transform='scale(1.06)';this.style.boxShadow='0 6px 28px rgba(0,0,0,0.45)';"
       onmouseout="this.style.transform='scale(1)';this.style.boxShadow='0 4px 20px rgba(0,0,0,0.35)';">
        <img src="{{ asset('assets/img/icons/buy_now.png') }}" alt="" width="20" height="20" style="display:inline-block;flex-shrink:0;">
        Buy Now
    </a>
    @endif

</body>
</html>
