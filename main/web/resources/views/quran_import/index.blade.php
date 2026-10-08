@extends('layouts.app')

@section('title', __('pages.import_quran'))

@section('css')
    <!-- Add any additional CSS styles here -->
    <style>
        /* Add custom styles for the form here */
        .import-form {
            margin-top: 20px;
        }

        .import-btn {
            cursor: pointer;
        }

        .import-btn:hover {
            background-color: #4CAF50;
            color: white;
        }
    </style>
@endsection

@section('content')
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-4">
                <h1 class="h3 d-inline align-middle"><strong>Profile Information</strong></h1>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <div class="card card-primary card-outline">
                    <h1>You can't close the browser tab, can't reload the page. Just wait and see...!!</h1>
                    <a href="{{ route('finish') }}" class="btn btn-primary">Click Here</a>
                </div>
            </div>
        </div>
    </main>
@endsection
