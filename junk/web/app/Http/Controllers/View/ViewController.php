<?php

namespace App\Http\Controllers\View;

use App\Http\Controllers\Controller;
use App\Models\Quran\Chapter\Chapter;
use App\Models\Quran\Reciter\Reciter;
use App\Services\Setting\SettingService;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Foundation\Application;
class ViewController extends Controller
{
    /**
     * @return View|Application|Factory|\Illuminate\Contracts\Foundation\Application
     */
    public function userList(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('user.index');
    }

    public function roleList(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('role.index');
    }

    public function importQuran(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application|\Illuminate\Http\RedirectResponse
    {
        $chapterCount = Chapter::query()->count();
        if ($chapterCount == 114)
            return redirect()->route('dashboard')->with('error', 'Sorry you are already imported Quran in your system.');

        return view('quran_import.index');
    }

    public function haramcodeList(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('haramcode.index');
    }

    public function sifatList(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('sifat.index');
    }

    public function dhikrList(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('dhikr.index');
    }

    public function duaList(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('dua.index');
    }

    public function wallpaperList(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('wallpaper.index');
    }
    public function wallpaperCategory(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('wallpaper.category.index');
    }

    public function prayerTimeList(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('prayer_times.index');
    }

    public function prayerTimeCreate(): View|Application|Factory|\Illuminate\Contracts\Foundation\Application
    {
        return view('prayer_times.create');
    }

    public function prayerTimeEdit($id): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('prayer_times.edit', compact('id'));
    }

    public function myProfile(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        $user = auth()->user()->load('profile');
        return view('profile.index', compact('user'));
    }

    public function setting(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('setting.index');
    }

    public function categoryList(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('category.index');
    }

    public function donationList(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('donation.index');
    }

    public function paymentMethodList()
    {
        return view('payment.index');
    }

    public function prayerTimeImport(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('prayer_times.import');
    }

    public function audioReciterList(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('reciter.index');
    }


    public function audioSuraList(Reciter $reciter): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('reciter-audio.index',compact('reciter'));
    }

    public function bulkSuraImport(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('reciter-audio.bulk-import');
    }

    public function landingHero(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('landing_admin.hero');
    }

    public function landingStats(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('landing_admin.stats');
    }

    public function landingFeatures(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('landing_admin.features');
    }

    public function landingSections(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('landing_admin.sections');
    }

    public function landingDownload(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('landing_admin.download');
    }

    public function landingFooter(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('landing_admin.footer');
    }

    public function landingSeo(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('landing_admin.seo');
    }

    public function blogList(): Factory|Application|View|\Illuminate\Contracts\Foundation\Application
    {
        return view('blog_admin.index');
    }

    public function landingPage()
    {
        try {
            $landing = resolve(SettingService::class)->getFormattedSettings('landing');
            $app     = resolve(SettingService::class)->getFormattedSettings('app');
        } catch (\Throwable $e) {
            $landing = [];
            $app     = [];
        }

        $defaults = [
            'app_name'                 => 'Zabi',
            'hero_badge_text'          => 'Available on iOS & Android',
            'hero_title'               => 'Your Complete',
            'hero_subtitle'            => 'Islamic Companion',
            'hero_description'         => 'Zabi brings you the full Quran, prayer times, hadith, dua, Qibla, Zakat calculator, AI Islamic chat, and 40+ languages — everything you need for your daily Islamic life in one beautiful app.',
            'rating'                   => '4.9',
            'downloads_count'          => '100K+',
            'languages_count'          => '40+',
            'app_store_url'            => $app['app_store_url']  ?? '#',
            'play_store_url'           => $app['play_store_url'] ?? '#',
            'web_logo'                 => $app['web_logo']       ?? null,
            'codecanyon_url'           => 'https://codecanyon.net/item/zabi-islamic-flutter-android-iso-app/50458856',
            'features_title'           => 'Everything You Need',
            'features_description'     => 'A complete Islamic lifestyle companion packed with features that help you stay connected to your faith every day.',
            'quran_title'              => 'Full Quran Reading',
            'quran_title_highlight'    => 'Experience',
            'quran_description'        => 'Read, listen, and understand the Holy Quran with multi-language translations, phonetic transliteration, and beautiful Arabic typography. Share your favorite ayahs with one tap.',
            'quran_offline_note'       => 'Full offline experience with background play, bookmarks & 100+ reciters in the Zabi app.',
            'prayer_title'             => 'Never Miss',
            'prayer_title_highlight'   => 'A Prayer',
            'prayer_description'       => 'Get accurate prayer times for your location with beautiful Adhan notifications. Find the Qibla direction with an improved compass, and stay on top of Ramadan Sehri & Iftar schedules.',
            'ai_title'                 => 'Powered by Artificial Intelligence',
            'ai_description'           => 'Get intelligent Islamic guidance at your fingertips — anytime, anywhere.',
            'ai_chat_card_title'       => 'AI Islamic Chat',
            'ai_chat_card_description' => 'Ask any Islamic question and receive knowledgeable, accurate answers instantly. From fiqh rulings to daily duas, our AI assistant is always ready to guide you.',
            'ai_name_card_title'       => 'Islamic Name Generator',
            'ai_name_card_description' => 'Find the perfect Islamic name for your child. Our AI generates beautiful, meaningful names with their Arabic origin, meaning, and pronunciation.',
            'dhikr_title'              => 'Dhikr, Dua & Remembrance',
            'dhikr_description'        => 'Stay connected to Allah with our comprehensive collection of duas and dhikr for every occasion.',
            'donation_verse_arabic'      => 'مَّثَلُ الَّذِينَ يُنفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ',
            'donation_verse_translation' => '"The example of those who spend in the way of Allah is like a grain that sprouts seven ears" — Al-Baqarah 2:261',
            'donation_accepted_label'    => 'Accepted via',
            'donation_gateways'          => "Razorpay\nPaystack\nStripe\nPayPal\nSslCommerz",
            'ai_chat_badge'            => 'Live Demo • Powered by Groq',
            'ai_chat_title_line1'      => 'Ask Any',
            'ai_chat_title_line2'      => 'Islamic Question',
            'ai_chat_description'      => 'Get instant, knowledgeable answers about Islam — from Quran & Hadith to prayer, fiqh, and daily Muslim life. Lightning-fast AI, right here on the page.',
            'ai_chat_try_label'        => 'Try asking:',
            'name_gen_title'           => 'Islamic Name',
            'name_gen_title_highlight' => 'Generator',
            'name_gen_description'     => 'Discover beautiful, meaningful Islamic names with Arabic script, English transliteration, and origins — powered by AI.',
            'tech_title'               => 'Built for Performance',
            'tech_subtitle'            => 'Modern, fast, and cross-platform',
            'download_title'           => 'Start Your Islamic',
            'download_title_highlight' => 'Journey Today',
            'download_description'     => 'Join hundreds of thousands of Muslims worldwide who use Zabi for their daily Islamic needs. Download for free today.',
            'codecanyon_prompt_text'   => 'Want to resell or customize?',
            'codecanyon_link_text'     => 'Get the source code on CodeCanyon →',
            'show_codecanyon_link'     => '1',
            'footer_description'       => 'Your complete Islamic companion app. Bringing the beauty of Islam to your fingertips with modern technology.',
            'features'                 => [],
            // SEO defaults
            'seo_title'                => null,
            'seo_description'          => null,
            'seo_keywords'             => null,
            'seo_canonical_url'        => null,
            'seo_robots'               => 'index,follow',
            'seo_og_title'             => null,
            'seo_og_description'       => null,
            'seo_og_image'             => null,
            'seo_twitter_card'         => 'summary_large_image',
            'seo_twitter_title'        => null,
            'seo_twitter_description'  => null,
            'seo_google_analytics'     => null,
            'seo_google_verification'  => null,
        ];

        // Merge only non-empty saved values on top of defaults
        $saved = array_filter((array) $landing, fn ($v) => $v !== null && $v !== '');
        $s = array_merge($defaults, $saved);

        // Features JSON is stored separately
        $s['features'] = [];
        if (!empty($landing['features_json'])) {
            try {
                $parsed = json_decode($landing['features_json'], true);
                if (is_array($parsed) && count($parsed)) {
                    $s['features'] = $parsed;
                }
            } catch (\Throwable $e) {
                // fall through to empty array
            }
        }

        // Repeatable card lists stored as JSON, each with a hardcoded fallback
        $decodeList = function (?string $json, array $fallback) {
            if (!empty($json)) {
                try {
                    $parsed = json_decode($json, true);
                    if (is_array($parsed) && count($parsed)) {
                        return $parsed;
                    }
                } catch (\Throwable $e) {
                    // fall through to fallback
                }
            }
            return $fallback;
        };

        $s['donation_why'] = $decodeList($landing['donation_why_json'] ?? null, [
            ['icon' => '📱', 'title' => 'Free App Forever', 'description' => 'Keeps the app free for millions of Muslims globally.'],
            ['icon' => '🌍', 'title' => 'Global Infrastructure', 'description' => 'Funds servers, CDN, and 24/7 uptime for all users.'],
            ['icon' => '✨', 'title' => 'New Features', 'description' => 'Enables development of new Islamic tools and content.'],
            ['icon' => '🛡️', 'title' => 'Privacy & Security', 'description' => 'Maintains privacy-first infrastructure with no ads.'],
        ]);

        $s['ai_chat_features'] = $decodeList($landing['ai_chat_features_json'] ?? null, [
            ['icon' => '⚡', 'title' => 'Sub-second Responses', 'description' => 'Groq LPU technology delivers answers in milliseconds'],
            ['icon' => '📚', 'title' => 'Quran & Hadith Referenced', 'description' => 'Answers include Arabic text and authentic source citations'],
            ['icon' => '📱', 'title' => 'Full Experience in the App', 'description' => 'Chat history, offline access, and more inside Zabi'],
        ]);

        $s['ai_chat_suggestions'] = $decodeList($landing['ai_chat_suggestions_json'] ?? null, [
            ['label' => 'Dua before sleeping', 'question' => 'What is the dua before sleeping?'],
            ['label' => 'Pillars of Islam', 'question' => 'What are the pillars of Islam?'],
            ['label' => 'How to do Wudu', 'question' => 'How to perform Wudu correctly?'],
            ['label' => 'Ramadan fasting rules', 'question' => 'What is the ruling on fasting in Ramadan?'],
            ['label' => 'Zakat explained', 'question' => 'What is Zakat and how is it calculated?'],
        ]);

        $s['tech_specs'] = $decodeList($landing['tech_specs_json'] ?? null, [
            ['icon' => '⚡', 'title' => 'Flutter Framework', 'description' => 'Built with Flutter & Dart 3.1.5 for smooth 60fps performance'],
            ['icon' => '📱', 'title' => 'Cross-Platform', 'description' => 'One codebase, native performance on both iOS and Android'],
            ['icon' => '🔄', 'title' => 'Free Updates', 'description' => 'Regular feature updates and bug fixes at no extra cost'],
            ['icon' => '🛡️', 'title' => 'Privacy First', 'description' => 'Your data stays private with minimal permissions required'],
        ]);

        $showAdminLogin = env('SHOW_ADMIN_LOGIN', true);
        $showBuy        = env('SHOW_BUY', false);

        return view('landing.index', compact('s', 'showAdminLogin', 'showBuy'));
    }

}
