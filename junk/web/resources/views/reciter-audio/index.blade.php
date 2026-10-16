@extends('layouts.app')
@section('title', __('pages.sura_list'))
@section('content')
    <app-audio-sura :reciter="{{ json_encode($reciter) }}"></app-audio-sura>
@endsection
