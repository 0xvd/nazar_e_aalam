<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Mobile App Theme
    |--------------------------------------------------------------------------
    |
    | The preset key applied when a site has no "app_theme" setting saved
    | yet (fresh installs get this seeded, but this is the final fallback).
    |
    */
    'default' => 'emerald',

    /*
    |--------------------------------------------------------------------------
    | Theme Presets
    |--------------------------------------------------------------------------
    |
    | Each preset is a complete color palette the mobile app can apply
    | directly to its theme. Admins pick one from the settings screen;
    | the mobile app reads the active preset from GET /api/theme.
    |
    */
    'presets' => [
        'emerald' => [
            'name' => 'Emerald',
            'mode' => 'light',
            'colors' => [
                'primary' => '#1A6B4A',
                'secondary' => '#2D8A63',
                'accent' => '#E8B84B',
                'background' => '#FFFFFF',
                'surface' => '#F5F7FB',
                'text_primary' => '#1A1F2E',
                'text_secondary' => '#5A6478',
                'error' => '#E05C5C',
            ],
        ],

        'midnight' => [
            'name' => 'Midnight',
            'mode' => 'dark',
            'colors' => [
                'primary' => '#3DDC97',
                'secondary' => '#2AA876',
                'accent' => '#E8B84B',
                'background' => '#0F1420',
                'surface' => '#1A1F2E',
                'text_primary' => '#F5F7FB',
                'text_secondary' => '#9AA3B5',
                'error' => '#F0796F',
            ],
        ],

        'ocean' => [
            'name' => 'Ocean Blue',
            'mode' => 'light',
            'colors' => [
                'primary' => '#1565C0',
                'secondary' => '#2E8FE0',
                'accent' => '#F5A623',
                'background' => '#FFFFFF',
                'surface' => '#F0F5FB',
                'text_primary' => '#122539',
                'text_secondary' => '#5A6C80',
                'error' => '#E05C5C',
            ],
        ],

        'royal_gold' => [
            'name' => 'Royal Gold',
            'mode' => 'light',
            'colors' => [
                'primary' => '#8A6D1F',
                'secondary' => '#C9A227',
                'accent' => '#1A6B4A',
                'background' => '#FFFDF7',
                'surface' => '#FBF6E7',
                'text_primary' => '#2A2410',
                'text_secondary' => '#6B6042',
                'error' => '#E05C5C',
            ],
        ],

        'amethyst' => [
            'name' => 'Amethyst',
            'mode' => 'dark',
            'colors' => [
                'primary' => '#9D6FE0',
                'secondary' => '#7C4FCC',
                'accent' => '#E8B84B',
                'background' => '#161221',
                'surface' => '#211C33',
                'text_primary' => '#F1EEFA',
                'text_secondary' => '#A79DC4',
                'error' => '#F0796F',
            ],
        ],
    ],

];
