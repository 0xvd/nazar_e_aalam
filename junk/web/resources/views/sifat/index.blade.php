@extends('layouts.app')
@section('title', __('pages.sifat_list'))
@section('content')
    <app-sifat></app-sifat>
{{--    <main class="content">--}}
{{--        <div class="container-fluid p-0">--}}
{{--            <div class="mb-3">--}}
{{--                <h1 class="h3 d-inline align-middle"><strong>Sifat List</strong></h1>--}}
{{--                <a href="{{ route('sifats.create') }}" class="btn bg-primary text-white float-end">--}}
{{--                    Add Sifat--}}
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
{{--                                <th scope="col" style="width: 10%;">Name (En)</th>--}}
{{--                                <th scope="col" style="width: 5%;">Name (Ar)</th>--}}
{{--                                <th scope="col" style="width: 10%;">Translated name</th>--}}
{{--                                <th scope="col" style="width: 30%;">Meaning</th>--}}
{{--                                <th scope="col" style="width: 30%;">Name Benefits</th>--}}
{{--                                <th scope="col" style="width: 5%;">Position</th>--}}
{{--                                <th scope="col" style="width: 10%;">Action</th>--}}
{{--                            </tr>--}}
{{--                            </thead>--}}
{{--                            <tbody>--}}
{{--                            @foreach($data as $key => $item)--}}
{{--                                <tr>--}}
{{--                                    <td>{{ $item->name }}</td>--}}
{{--                                    <td>{{ $item->ar_name }}</td>--}}
{{--                                    <td>{{ $item->translated_name }}</td>--}}
{{--                                    <td>{{ $item->meaning }}</td>--}}
{{--                                    <td>{{ $item->name_benefits }}</td>--}}
{{--                                    <td>{{ $item->position }}</td>--}}
{{--                                    <td class="table-action">--}}
{{--                                        <a href="{{ route('sifats.edit',$item->id) }}" class="text-decoration-none">--}}
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

