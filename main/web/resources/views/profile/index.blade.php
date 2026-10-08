@extends('layouts.app')
@section('title', __('pages.my_profile'))

@section('content')
<main class="content">
    <div class="container-fluid p-0">

        <!-- ── Profile hero card ─────────────────────────────── -->
        <div class="prof-hero">
            <div class="prof-hero__cover">
                <div class="prof-hero__pattern"></div>
            </div>

            <div class="prof-hero__body">
                <!-- Avatar + info -->
                <div class="prof-hero__identity">
                    <div class="prof-hero__avatar-wrap">
                        @php
                            $avatarUrl = asset('assets/img/avatar.png');
                            if (@$user->profile->profile_picture) {
                                $avatarUrl = asset($user->profile->profile_picture);
                            }
                        @endphp
                        <img class="prof-hero__avatar" src="{{ $avatarUrl }}" alt="Profile picture">
                        <span class="prof-hero__avatar-dot"></span>
                    </div>
                    <div class="prof-hero__info">
                        <h2 class="prof-hero__name">{{ auth()->user()->full_name }}</h2>
                        <p class="prof-hero__email">{{ auth()->user()->email }}</p>
                    </div>
                </div>

                <!-- Tab nav -->
                <div class="prof-tabs">
                    <button class="prof-tab prof-tab--active" onclick="switchProfileTab(event,'personal')">
                        <svg width="14" height="14" viewBox="0 0 20 20" fill="none">
                            <circle cx="10" cy="7" r="4" stroke="currentColor" stroke-width="1.6"/>
                            <path d="M3 18c0-3.866 3.134-7 7-7s7 3.134 7 7" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                        </svg>
                        Personal Information
                    </button>
                    <button class="prof-tab" onclick="switchProfileTab(event,'change-password')">
                        <svg width="14" height="14" viewBox="0 0 20 20" fill="none">
                            <rect x="3" y="9" width="14" height="10" rx="2" stroke="currentColor" stroke-width="1.6"/>
                            <path d="M7 9V7a3 3 0 016 0v2" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                        </svg>
                        Change Password
                    </button>
                </div>
            </div>
        </div>

        <!-- ── Tab panels ────────────────────────────────────── -->
        <div id="personal" class="prof-panel prof-panel--active">
            <app-personal-info></app-personal-info>
        </div>
        <div id="change-password" class="prof-panel">
            <app-password-change></app-password-change>
        </div>

    </div>
</main>
@endsection

@section('css')
.prof-hero {
    background: #fff;
    border-radius: 14px;
    border: 1px solid rgba(26,92,56,0.1);
    box-shadow: 0 2px 10px rgba(10,46,30,0.06);
    overflow: hidden;
    margin-bottom: 1.25rem;
}

.prof-hero__cover {
    height: 80px;
    background: linear-gradient(130deg, #072417 0%, #0d3a22 40%, #1a5c38 80%, #22794a 100%);
    position: relative;
    overflow: hidden;
}

.prof-hero__pattern {
    position: absolute;
    inset: 0;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='70' height='70' viewBox='0 0 70 70'%3E%3Cg fill='none' stroke='%23ffffff05' stroke-width='1'%3E%3Cpath d='M35 0 L70 35 L35 70 L0 35 Z'/%3E%3Ccircle cx='35' cy='35' r='18'/%3E%3C/g%3E%3C/svg%3E");
    pointer-events: none;
}

.prof-hero__body {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 1.75rem 0 1.75rem;
    margin-top: -28px;
    flex-wrap: wrap;
    gap: 0.75rem;
}

.prof-hero__identity {
    display: flex;
    align-items: flex-end;
    gap: 0.9rem;
}

.prof-hero__avatar-wrap { position: relative; flex-shrink: 0; }

.prof-hero__avatar {
    width: 66px; height: 66px;
    border-radius: 50%;
    object-fit: cover;
    border: 3px solid #fff;
    box-shadow: 0 3px 10px rgba(10,46,30,0.18);
    display: block;
}

.prof-hero__avatar-dot {
    position: absolute; bottom: 3px; right: 3px;
    width: 12px; height: 12px;
    background: #22c55e;
    border-radius: 50%;
    border: 2px solid #fff;
}

.prof-hero__info { padding-bottom: 0.5rem; }

.prof-hero__name {
    font-size: 1rem;
    font-weight: 800;
    color: #1c2b24;
    margin: 0 0 0.1rem;
}

.prof-hero__email {
    font-size: 0.75rem;
    color: #7a8e84;
    margin: 0;
}

/* Tab nav — right-aligned on same row as identity */
.prof-tabs {
    display: flex;
    gap: 0.2rem;
    padding-bottom: 0;
    align-self: flex-end;
    padding-bottom: 0.1rem;
}

.prof-tab {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    padding: 0.55rem 1rem;
    font-size: 0.8rem;
    font-weight: 600;
    color: #7a8e84;
    background: none;
    border: none;
    border-bottom: 2px solid transparent;
    cursor: pointer;
    transition: color 0.15s, border-color 0.15s;
    white-space: nowrap;
    font-family: inherit;
}

.prof-tab:hover { color: #1a5c38; }

.prof-tab--active {
    color: #1a5c38;
    border-bottom-color: #1a5c38;
}

/* Panels */
.prof-panel { display: none; }
.prof-panel--active { display: block; }
@endsection

@section('script')
<script>
function switchProfileTab(e, id) {
    document.querySelectorAll('.prof-tab').forEach(function(t) {
        t.classList.remove('prof-tab--active');
    });
    e.currentTarget.classList.add('prof-tab--active');

    document.querySelectorAll('.prof-panel').forEach(function(p) {
        p.classList.remove('prof-panel--active');
    });
    document.getElementById(id).classList.add('prof-panel--active');
}
</script>
@endsection
