@extends('layouts.app')
@section('title', __('pages.landing_sections'))
@section('content')
    <main class="content">
        <div class="container-fluid p-0">
            <app-landing-sections></app-landing-sections>
        </div>
    </main>
@endsection
