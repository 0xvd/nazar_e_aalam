@extends('layouts.app')
@section('title', __('pages.landing_stats'))
@section('content')
    <main class="content">
        <div class="container-fluid p-0">
            <app-landing-stats></app-landing-stats>
        </div>
    </main>
@endsection
