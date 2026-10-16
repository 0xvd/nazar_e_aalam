@extends('layouts.auth.auth_master')
@section('title', __('pages.join_user'))
@section('content')
    <app-join-user user="{{json_encode($user)}}"></app-join-user>
@endsection
