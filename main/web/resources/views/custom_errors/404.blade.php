@extends('custom_errors.master')

@section('title', __('pages.error_404'))
@section('css')
    body {
    background: url('{{ asset("assets/img/errors/404.svg") }}') no-repeat center center fixed;
    background-size: center cover;
    height: 100vh;
    margin: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    text-align: center;

    }
@endsection

@section('content')
@endsection
