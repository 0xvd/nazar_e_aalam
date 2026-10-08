@extends('layouts.app')
@section('title', __('pages.blog_posts'))
@section('content')
    <main class="content">
        <div class="container-fluid p-0">
            <app-blog></app-blog>
        </div>
    </main>
@endsection
