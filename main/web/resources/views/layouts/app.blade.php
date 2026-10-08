<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}" dir="{{ app()->getLocale() === 'ar' ? 'rtl' : 'ltr' }}">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="Responsive Admin &amp; Dashboard Template based on Bootstrap 5">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="base-url" content="{{ url('/') }}">
    <meta name="author" content="{{ config('settings.application.company_name') }}">
    <meta name="keywords" content="{{ config('settings.application.company_name') }}">
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link rel="shortcut icon" href="{{ asset(config('settings.application.web_icon')) }}" />
    <title>{{ config('settings.application.company_name') }} | @yield('title')</title>
    <link href="{{ asset('assets/css/app.css') }}" rel="stylesheet">
    @if(app()->getLocale() === 'ar')
        <link href="{{ asset('assets/css/app-rtl.css') }}" rel="stylesheet">
    @endif
    <link href="{{ asset('assets/css/zabi-style.css') }}" rel="stylesheet">
    @if(app()->getLocale() === 'ar')
        <link href="{{ asset('assets/css/zabi-style-rtl.css') }}" rel="stylesheet">
    @endif
    @include('partials.theme-vars')
    <link href="{{ asset('assets/css/theme-dynamic.css') }}" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        .pagination {
            margin-left: 1% !important;
        }

        @yield('css')

        .sidebar-content {
            display: flex;
            flex-direction: column;
            height: 100vh;
            position: sticky;
            top: 0;
            overflow-y: auto;
            transition: margin-left .35s ease-in-out, left .35s ease-in-out, margin-right .35s ease-in-out, right .35s ease-in-out;
        }

    </style>
</head>

<body @if(app()->getLocale() === 'ar') data-sidebar-position="right" @endif>
    <div class="wrapper" id="app">

        @include('layouts.sidebar')

        <div class="main">

            @include('layouts.navbar')

            @yield('content')

        </div>
    </div>
    @vite('resources/js/app.js')
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    @if (Session::has('success'))
        <script>
            Swal.fire({
                title: 'Success!',
                text: '{{ Session::get('success') }}',
                icon: 'success',
                confirmButtonText: 'Close',
                timer: 1500
            })
        </script>
    @endif
    @if (Session::has('error'))
        <script>
            Swal.fire({
                title: 'Error!',
                text: "{{ Session::get('error') }}",
                icon: 'error',
                confirmButtonText: 'Close'
            })
        </script>
    @endif
    @yield('script')

    @auth()
        <script>
            window.localStorage.setItem('permissions', JSON.stringify(
                <?php echo json_encode(
                    array_merge(resolve(\App\Repositories\User\UserRepository::class)->getPermissionsForFrontEnd(), [
                        'is_app_admin' => auth()->user()->isAppAdmin(),
                    ]),
                );
                ?>
            ))
        </script>
    @endauth

    <script>
        window.localStorage.setItem('company_name', "{{ config('settings.application.company_name') }}")
        window.localStorage.setItem('company_logo', "{{ config('settings.application.web_logo') }}")
    </script>

</body>

</html>
