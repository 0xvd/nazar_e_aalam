<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Mobile App Home Screen Layout
    |--------------------------------------------------------------------------
    |
    | The layout key applied when a site has no "home_layout" setting saved
    | yet (fresh installs get this seeded, but this is the final fallback).
    |
    */
    'default' => 'modern',

    /*
    |--------------------------------------------------------------------------
    | Home Screen Layouts
    |--------------------------------------------------------------------------
    |
    | Each entry is a distinct home screen composition the mobile app knows
    | how to render. Admins pick one from the settings screen; the mobile
    | app reads the active layout from GET /api/home-layout.
    |
    */
    'presets' => [
        'modern' => [
            'name' => 'Modern Dashboard',
            'description' => 'Greeting header, horizontal prayer time strip, circular Quran reading progress, and a quick action tile grid.',
            'sections' => [
                'greeting_header',
                'prayer_strip',
                'quran_progress_ring',
                'quick_actions_grid',
                'feature_cards',
                'quran_cta_banner',
            ],
        ],

        'classic' => [
            'name' => 'Classic List',
            'description' => 'Dark prayer header, two-column prayer/sehri/iftar time grid, donation banner, and an icon-based quick action grid.',
            'sections' => [
                'dark_prayer_header',
                'prayer_time_grid',
                'donation_banner',
                'quick_actions_grid',
            ],
        ],
    ],

];
