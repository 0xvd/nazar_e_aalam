<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}" dir="{{ app()->getLocale() === 'ar' ? 'rtl' : 'ltr' }}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta property="og:title" content="{{config('settings.application.company_name')}}">
    <meta property="og:description" content="{{config('settings.application.company_name')}} Admin Panel">
    <meta property="og:image" content="{{config('settings.application.web_logo')}}">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:url" content="{{ env('APP_URL') }}">
    <meta property="og:type" content="website">
    <link rel="apple-touch-icon" href="{{config('settings.application.web_icon')}}"/>
    <link rel="apple-touch-icon-precomposed" href="{{config('settings.application.web_icon')}}"/>
    <meta name="description" content="{{config('settings.application.company_name')}} Admin Panel">
    <meta name="author" content="{{config('settings.application.company_name')}}">
    <meta name="keywords" content="{{config('settings.application.company_name')}}">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="base-url" content="{{ url('/') }}">
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link rel="shortcut icon" href="{{config('settings.application.web_icon')}}"/>
    <title>{{config('settings.application.company_name')}} | @yield('title')</title>
    <link href="{{asset('assets/css/app.css')}}" rel="stylesheet">
    @if(app()->getLocale() === 'ar')
        <link href="{{ asset('assets/css/app-rtl.css') }}" rel="stylesheet">
    @endif
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Amiri:wght@400;700&display=swap" rel="stylesheet">
    @include('partials.theme-vars')
    <link href="{{ asset('assets/css/theme-dynamic.css') }}" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; height: 100%; }
        body { background: #062416; font-family: 'Inter', sans-serif; }
        #app { min-height: 100vh; }
        @yield('css')
    </style>
</head>
<body>
<div id="app">@yield('content')</div>
@vite('resources/js/app.js')
<script src="{{asset('assets/js/app.js')}}"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
@yield('script')
<script>
    window.localStorage.setItem('company_name', "{{ config('settings.application.company_name') }}")
    window.localStorage.setItem('company_logo', "{{ config('settings.application.web_logo') }}")
</script>
</body>
</html>
