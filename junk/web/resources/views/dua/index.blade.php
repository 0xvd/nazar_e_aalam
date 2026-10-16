@extends('layouts.app')
@section('title', __('pages.dua_list'))
@section('content')
    <app-dua></app-dua>

{{--    <main class="content">--}}
{{--        <div class="container-fluid p-0">--}}
{{--            <div class="mb-3">--}}
{{--                <h1 class="h3 d-inline align-middle"><strong>Dua List</strong></h1>--}}
{{--                <a href="{{ route('dua.create') }}" class="btn bg-primary text-white float-end">--}}
{{--                    Add Dua--}}
{{--                </a>--}}
{{--            </div>--}}
{{--        </div>--}}

{{--        <div class="row">--}}

{{--            <div class="col-12">--}}
{{--                <div class="card">--}}
{{--                    <div class="table-responsive">--}}
{{--                        <table class="table mb-3">--}}
{{--                            <thead>--}}
{{--                            <tr>--}}
{{--                                <th scope="col" style="width: 10%;">Short name (En)</th>--}}
{{--                                <th scope="col" style="width: 10%;">Short name (Ar)</th>--}}
{{--                                <th scope="col" style="width: 40%;">Full Name (En)</th>--}}
{{--                                <th scope="col" style="width: 40%;">Full Name (Ar)</th>--}}
{{--                                <th scope="col" style="width: 40%;">Position</th>--}}
{{--                                <th scope="col" style="width: 10%;">Action</th>--}}
{{--                            </tr>--}}
{{--                            </thead>--}}
{{--                            <tbody>--}}
{{--                            @foreach($data as $key => $item)--}}
{{--                                <tr>--}}
{{--                                    <td>{{ $item->en_short_name }}</td>--}}
{{--                                    <td>{{ $item->ar_short_name }}</td>--}}
{{--                                    <td>{{ $item->en_full_name }}</td>--}}
{{--                                    <td>{{ $item->ar_full_name }}</td>--}}
{{--                                    <td>{{ $item->position }}</td>--}}
{{--                                    <td class="table-action">--}}
{{--                                        <a href="{{ route('dua.edit',$item->id) }}" class="text-decoration-none">--}}
{{--                                            <i class="align-middle" data-feather="edit"></i>--}}
{{--                                        </a>--}}
{{--                                        <a href="#" class="text-decoration-none delete-btn" data-id="{{ $item->id }}">--}}
{{--                                            <i class="align-middle" data-feather="trash"></i>--}}
{{--                                        </a>--}}

{{--                                    </td>--}}
{{--                                </tr>--}}
{{--                            @endforeach--}}
{{--                            </tbody>--}}
{{--                        </table>--}}
{{--                        <div style="margin-right: 10%!important;"> {{ $data->links() }}</div>--}}
{{--                    </div>--}}
{{--                </div>--}}
{{--            </div>--}}
{{--        </div>--}}
{{--    </main>--}}
@endsection

