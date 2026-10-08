@extends('layouts.app')
@section('title', __('pages.edit_prayer_time'))
@section('content')
    <app-prayer-create @if(isset($id)) selected-url="/prayer-times/{{$id}}" @endif></app-prayer-create>
@endsection
