@extends('layouts.app')
@section('title', __('pages.settings'))
@section('css')

@endsection
@section('content')
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-4">
                <h1 class="h3 d-inline align-middle"><strong>General Settings</strong></h1>
            </div>
        </div>
        <div class="row">
            <div class="col-md-9">
                <div class="card">
                    <div class="card-body">
                        <div class="container">
                            <ul class="nav nav-tabs" id="myTabs">
                                @can('view_setting')
                                    <li class="nav-item">
                                        <a class="nav-link btn info-btn active" id="tab1" data-bs-toggle="tab"
                                           href="#personal">General Settings</a>
                                    </li>
                                @endcan
                                @can('view_email_setting')
                                    <li class="nav-item">
                                        <a class="nav-link btn info-btn ml-5" id="tab2" data-bs-toggle="tab"
                                           href="#email-setup">Email Setup</a>
                                    </li>
                                @endcan
                                @can('view_setting')
                                    <li class="nav-item">
                                        <a class="nav-link btn info-btn ml-5" id="tab2" data-bs-toggle="tab"
                                           href="#privacy-and-support">Privacy & Support</a>
                                    </li>
                                @endcan
                                @can('view_setting')
                                    <li class="nav-item">
                                        <a class="nav-link btn info-btn ml-5" id="tab4" data-bs-toggle="tab"
                                           href="#home-layout">Home Screen</a>
                                    </li>
                                @endcan
                            </ul>

                            <div class="tab-content mt-2">
                                <div class="tab-pane fade show active" id="personal">
                                    <div class="tab-content">
                                        <div class="tab-pane active" id="personal">
                                            <app-setting></app-setting>
                                        </div>
                                    </div>
                                </div>

                                <div class="tab-pane fade" id="email-setup">
                                    <app-email-setting></app-email-setting>
                                </div>

                                <div class="tab-pane fade" id="privacy-and-support">
                                    <app-privacy-and-support></app-privacy-and-support>
                                </div>

                                <div class="tab-pane fade" id="home-layout">
                                    <app-home-layout></app-home-layout>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
@endsection
