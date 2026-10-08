@extends('layouts.auth.auth_master')
@section('title', __('pages.reset_password'))
@section('content')
    <app-reset-password token="{{json_encode($token)}}"></app-reset-password>
@endsection
