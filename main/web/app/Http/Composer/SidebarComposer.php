<?php

namespace App\Http\Composer;

use Illuminate\View\View;

class SidebarComposer
{
    public function compose(View $view): void
    {
        $view->with(['data' => [
            [
                'icon' => asset('assets/img/icons/home.svg'),
                'name' => __('menu.dashboard'),
                'url' => route('dashboard'),
                'permission' => auth()->user()->can('manage_dashboard'),
            ],
            [
                'name' => __('menu.administrator'),
                'icon' => asset('assets/img/icons/roles.svg'),
                'permission' =>authorize_any(['view_roles', 'view_users']),
                'subMenu' => [
                    [
                        'name' => __('menu.roles'),
                        'url' => route('role-list.view'),
                        'permission' => auth()->user()->can('view_roles'),
                    ],
                    [
                        'name' => __('menu.users'),
                        'url' => route('user-list.view'),
                        'permission' => auth()->user()->can('view_users'),
                    ]
                ]
            ],
            [
                'name' => __('menu.prayer_times'),
                'id' => 'prayer-times',
                'icon' => asset('assets/img/icons/prayer_clock.svg'),
                'permission' =>authorize_any(['create_prayer_times', 'view_prayer_times']),
                'subMenu' => [
                    [
                        'name' => __('menu.add_prayer_time'),
                        'url' => route('prayer-time-create.view'),
                        'permission' => auth()->user()->can('create_prayer_times'),
                    ],
                    [
                        'name' => __('menu.prayer_times_list'),
                        'url' => route('prayer-time-list.view'),
                        'permission' => auth()->user()->can('view_prayer_times'),
                    ],
                    [
                        'name' => __('menu.import_prayer_times'),
                        'url' => route('prayer-time-import.view'),
                        'permission' => auth()->user()->can('import_prayer_times'),
                    ],
                ],
            ],
            [
                'name' => __('menu.audio_quran'),
                'id' => 'audio-quran',
                'icon' => asset('assets/img/icons/audio.png'),
                'permission' => authorize_any(['create_reciter', 'view_reciter', 'import_reciter_sura']),
                'subMenu' => [
                    [
                        'name' => __('menu.reciter_list'),
                        'url' => route('audio-reciter-list.view'),
                        'permission' => auth()->user()->can('view_reciter'),
                    ],
                    [
                        'name' => __('menu.bulk_audio_import'),
                        'url' => route('audio-sura-bulk-import.view'),
                        'permission' => auth()->user()->can('import_reciter_sura'),
                    ],
                ],
            ],
            [
                'icon' => asset('assets/img/icons/dua.svg'),
                'name' => __('menu.dua'),
                'url' => route('dua-list.view'),
                'permission' => auth()->user()->can('view_dua'),
            ],
            [
                'icon' => asset('assets/img/icons/dhikr.svg'),
                'name' => __('menu.dhikr'),
                'url' => route('dhikr-list.view'),
                'permission' => auth()->user()->can('view_dhikrs'),
            ],
            [
                'name' => __('menu.wallpaper'),
                'id' => 'wallpaper-list',
                'icon' => asset('assets/img/icons/wallpaper.png'),
                'permission' => authorize_any(['view_wallpaper_category', 'view_wallpaper']),
                'subMenu' => [
                    [
                        'name' => __('menu.wallpaper_category'),
                        'url' => route('wallpaper-category.view'),
                        'permission' => auth()->user()->can('view_wallpaper_category'),
                    ],
                    [
                        'name' => __('menu.wallpaper_list'),
                        'url' => route('wallpaper-list.view'),
                        'permission' => auth()->user()->can('view_wallpaper'),
                    ]
                ],
            ],
            [
                'icon' => asset('assets/img/icons/allah_icon.svg'),
                'name' => __('menu.sifat_name'),
                'url' => route('sifat-list.view'),
                'permission' => auth()->user()->can('view_sifats'),
            ],
            [
                'icon' => asset('assets/img/icons/haram.svg'),
                'name' => __('menu.haram_code'),
                'url' => route('haramcode-list.view'),
                'permission' => auth()->user()->can('view_haram_codes'),
            ],
            [
                'name' => __('menu.donation'),
                'id' => 'donations',
                'icon' => asset('assets/img/icons/donation.svg'),
                'permission' =>authorize_any(['view_category', 'view_donation','view_payment_method']),
                'subMenu' => [
                    [
                        'name' => __('menu.donation_category'),
                        'url' => route('category.view'),
                        'permission' => auth()->user()->can('view_category'),
                    ],
                    [
                        'name' => __('menu.donation_list'),
                        'url' => route('donation-list.view'),
                        'permission' => auth()->user()->can('view_donation'),
                    ],
                    [
                        'name' => __('menu.payment_methods'),
                        'url' => route('payment-list.view'),
                        'permission' => auth()->user()->can('view_payment_method'),
                    ],
                ],
            ],
            [
                'name' => __('menu.landing_page'),
                'id'   => 'landing-page',
                'icon' => asset('assets/img/icons/surah.svg'),
                'permission' => auth()->user()->can('view_setting'),
                'subMenu' => [
                    [
                        'name' => __('menu.hero_section'),
                        'url'  => route('landing-hero.view'),
                        'permission' => auth()->user()->can('view_setting'),
                    ],
                    [
                        'name' => __('menu.stats_badges'),
                        'url'  => route('landing-stats.view'),
                        'permission' => auth()->user()->can('view_setting'),
                    ],
                    [
                        'name' => __('menu.features_grid'),
                        'url'  => route('landing-features.view'),
                        'permission' => auth()->user()->can('view_setting'),
                    ],
                    [
                        'name' => __('menu.section_content'),
                        'url'  => route('landing-sections.view'),
                        'permission' => auth()->user()->can('view_setting'),
                    ],
                    [
                        'name' => __('menu.download_cta'),
                        'url'  => route('landing-download.view'),
                        'permission' => auth()->user()->can('view_setting'),
                    ],
                    [
                        'name' => __('menu.footer'),
                        'url'  => route('landing-footer.view'),
                        'permission' => auth()->user()->can('view_setting'),
                    ],
                    [
                        'name' => __('menu.seo'),
                        'url'  => route('landing-seo.view'),
                        'permission' => auth()->user()->can('view_setting'),
                    ],
                ],
            ],
            [
                'icon' => asset('assets/img/icons/surah.svg'),
                'name' => __('menu.blog'),
                'url'  => route('blog-list.view'),
                'permission' => auth()->user()->can('view_setting'),
            ],
            [
                'icon' => asset('assets/img/icons/settings.svg'),
                'name' => __('menu.settings'),
                'url' => route('setting.view'),
                'permission' => authorize_any(['view_setting', 'view_email_setting']),
            ],

        ]]);
    }
}
