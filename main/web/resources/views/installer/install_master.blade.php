<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="{{ config('settings.application.company_name') }} Admin Panel">
    <meta name="author" content="{{ config('settings.application.company_name') }}">
    <meta name="keywords" content="{{ config('settings.application.company_name') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="shortcut icon" href="{{ config('settings.application.web_icon') }}"/>
    <title>@yield('title')</title>

    <link href="{{ asset('assets/css/app.css') }}" rel="stylesheet">
    @include('partials.theme-vars')
    <link href="{{ asset('assets/css/theme-dynamic.css') }}" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        *, *::before, *::after { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; min-height: 100vh; }
        body { background: #f5f7fb; }
        #app { min-height: 100vh; }
    </style>
</head>

<body>
<div id="app">
    @yield('content')
</div>

@vite('resources/js/app.js')

</body>

</html>
