<?php

namespace Database\Seeders\Quran\Settings;

use App\Models\Quran\Settings\Setting;
use Illuminate\Database\Seeder;

class LandingSettingSeeder extends Seeder
{
    public function run(): void
    {
        $featuresJson = json_encode([
            [
                'icon'        => '📖',
                'title'       => 'Quran & Islamic Content',
                'description' => 'Complete Al-Quran reading experience with multi-language translations, audio recitation, transliteration, and ayah sharing.',
                'bullets'     => "4 Language Translations\nAudio Quran Support\nTransliteration Feature\nHadith & Dua Collections\nAllah's 99 Names",
            ],
            [
                'icon'        => '🕌',
                'title'       => 'Prayer & Worship',
                'description' => 'Accurate prayer times, customizable schedules, Adhan notifications with multiple reciters, and Qibla finder with compass.',
                'bullets'     => "Accurate Prayer Times\nAdhan Notifications\nQibla Finder & Compass\nRamadan Schedule\nMultiple Adhan Reciters",
            ],
            [
                'icon'        => '🤖',
                'title'       => 'AI-Powered Features',
                'description' => 'Get answers to Islamic questions instantly with our AI Islamic Chat and generate beautiful Islamic names for your family.',
                'bullets'     => "AI Islamic Q&A Chat\nIslamic Name Generator\nSmart Recommendations\nInstant Responses\n24/7 Availability",
            ],
            [
                'icon'        => '📍',
                'title'       => 'Mosque & Location',
                'description' => 'Find nearby mosques using GPS, get navigation assistance, and manage location permissions easily.',
                'bullets'     => "Nearby Mosque Finder\nGPS Navigation\nReal-time Location\nCity-based Prayer Times",
            ],
            [
                'icon'        => '💰',
                'title'       => 'Islamic Finance & Charity',
                'description' => 'Calculate your Zakat accurately with customizable Nisab settings and support charitable causes through the donation module.',
                'bullets'     => "Zakat Calculator\nCustomizable Nisab\nDonation Module\nMultiple Currencies",
            ],
            [
                'icon'        => '🎨',
                'title'       => 'Personalization',
                'description' => 'Make the app yours with dark mode, RTL support, dynamic wallpapers, custom dhikr, dua, and 40+ language options.',
                'bullets'     => "Dark Mode Support\nRTL Language Support\nDynamic Wallpapers\nCustom Dhikr & Dua",
            ],
        ]);

        $donationWhyJson = json_encode([
            ['icon' => '📱', 'title' => 'Free App Forever', 'description' => 'Keeps the app free for millions of Muslims globally.'],
            ['icon' => '🌍', 'title' => 'Global Infrastructure', 'description' => 'Funds servers, CDN, and 24/7 uptime for all users.'],
            ['icon' => '✨', 'title' => 'New Features', 'description' => 'Enables development of new Islamic tools and content.'],
            ['icon' => '🛡️', 'title' => 'Privacy & Security', 'description' => 'Maintains privacy-first infrastructure with no ads.'],
        ]);

        $aiChatFeaturesJson = json_encode([
            ['icon' => '⚡', 'title' => 'Sub-second Responses', 'description' => 'Groq LPU technology delivers answers in milliseconds'],
            ['icon' => '📚', 'title' => 'Quran & Hadith Referenced', 'description' => 'Answers include Arabic text and authentic source citations'],
            ['icon' => '📱', 'title' => 'Full Experience in the App', 'description' => 'Chat history, offline access, and more inside Zabi'],
        ]);

        $aiChatSuggestionsJson = json_encode([
            ['label' => 'Dua before sleeping', 'question' => 'What is the dua before sleeping?'],
            ['label' => 'Pillars of Islam', 'question' => 'What are the pillars of Islam?'],
            ['label' => 'How to do Wudu', 'question' => 'How to perform Wudu correctly?'],
            ['label' => 'Ramadan fasting rules', 'question' => 'What is the ruling on fasting in Ramadan?'],
            ['label' => 'Zakat explained', 'question' => 'What is Zakat and how is it calculated?'],
        ]);

        $techSpecsJson = json_encode([
            ['icon' => '⚡', 'title' => 'Flutter Framework', 'description' => 'Built with Flutter & Dart 3.1.5 for smooth 60fps performance'],
            ['icon' => '📱', 'title' => 'Cross-Platform', 'description' => 'One codebase, native performance on both iOS and Android'],
            ['icon' => '🔄', 'title' => 'Free Updates', 'description' => 'Regular feature updates and bug fixes at no extra cost'],
            ['icon' => '🛡️', 'title' => 'Privacy First', 'description' => 'Your data stays private with minimal permissions required'],
        ]);

        $settings = [
            // Hero
            'app_name'               => 'Zabi',
            'hero_badge_text'        => 'The Islamic Companion App',
            'hero_title'             => 'Your Complete Islamic Companion',
            'hero_subtitle'          => 'Faith in Your Hands',
            'hero_description'       => 'Your complete Islamic companion app. Bringing the beauty of Islam to your fingertips with modern technology.',
            'app_store_url'          => 'https://apps.apple.com',
            'play_store_url'         => 'https://play.google.com',

            // Stats
            'rating'                 => '5',
            'downloads_count'        => '50K+',
            'languages_count'        => '40+',

            // Features grid
            'features_title'         => 'Everything You Need',
            'features_description'   => 'A complete Islamic lifestyle companion packed with features that help you stay connected to your faith every day.',
            'features_json'          => $featuresJson,

            // Quran section
            'quran_title'            => 'Full Quran Reading Experience',
            'quran_title_highlight'  => 'Quran',
            'quran_description'      => 'Read, listen, and understand the Holy Quran with multi-language translations, phonetic transliteration, and beautiful Arabic typography. Share your favorite ayahs with one tap.',
            'quran_offline_note'     => 'Full offline experience with background play, bookmarks & 100+ reciters in the Zabi app.',

            // Prayer section
            'prayer_title'           => 'Never Miss A Prayer',
            'prayer_title_highlight' => 'Prayer',
            'prayer_description'     => 'Get accurate prayer times for your location with beautiful Adhan notifications. Find the Qibla direction with an improved compass, and stay on top of Ramadan Sehri & Iftar schedules.',

            // AI section
            'ai_title'               => 'Powered by Artificial Intelligence',
            'ai_description'         => 'Get intelligent Islamic guidance at your fingertips — anytime, anywhere.',
            'ai_chat_card_title'       => 'AI Islamic Chat',
            'ai_chat_card_description' => 'Ask any Islamic question and receive knowledgeable, accurate answers instantly. From fiqh rulings to daily duas, our AI assistant is always ready to guide you.',
            'ai_name_card_title'       => 'Islamic Name Generator',
            'ai_name_card_description' => 'Find the perfect Islamic name for your child. Our AI generates beautiful, meaningful names with their Arabic origin, meaning, and pronunciation.',

            // Dhikr section
            'dhikr_title'            => 'Dhikr, Dua & Remembrance',
            'dhikr_description'      => 'Stay connected to Allah with our comprehensive collection of duas and dhikr for every occasion.',

            // Donation section
            'donation_verse_arabic'      => 'مَّثَلُ الَّذِينَ يُنفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ',
            'donation_verse_translation' => '"The example of those who spend in the way of Allah is like a grain that sprouts seven ears" — Al-Baqarah 2:261',
            'donation_why_json'          => $donationWhyJson,
            'donation_accepted_label'    => 'Accepted via',
            'donation_gateways'          => "Razorpay\nPaystack\nStripe\nPayPal\nSslCommerz",

            // AI Chat demo
            'ai_chat_badge'            => 'Live Demo • Powered by Groq',
            'ai_chat_title_line1'      => 'Ask Any',
            'ai_chat_title_line2'      => 'Islamic Question',
            'ai_chat_description'      => 'Get instant, knowledgeable answers about Islam — from Quran & Hadith to prayer, fiqh, and daily Muslim life. Lightning-fast AI, right here on the page.',
            'ai_chat_features_json'    => $aiChatFeaturesJson,
            'ai_chat_try_label'        => 'Try asking:',
            'ai_chat_suggestions_json' => $aiChatSuggestionsJson,

            // Islamic Name Generator
            'name_gen_title'           => 'Islamic Name',
            'name_gen_title_highlight' => 'Generator',
            'name_gen_description'     => 'Discover beautiful, meaningful Islamic names with Arabic script, English transliteration, and origins — powered by AI.',

            // Tech specs
            'tech_title'               => 'Built for Performance',
            'tech_subtitle'            => 'Modern, fast, and cross-platform',
            'tech_specs_json'          => $techSpecsJson,

            // Download section
            'download_title'           => 'Start Your Islamic Journey Today',
            'download_title_highlight' => 'Today',
            'download_description'     => 'Join hundreds of thousands of Muslims worldwide who use Zabi for their daily Islamic needs. Download for free today.',
            'codecanyon_url'           => 'https://codecanyon.net/item/zabi-islamic-flutter-android-iso-app/50458856',
            'codecanyon_prompt_text'   => 'Want to resell or customize?',
            'codecanyon_link_text'     => 'Get the source code on CodeCanyon →',
            'show_codecanyon_link'     => '1',

            // Footer
            'footer_description'     => 'Your complete Islamic companion app. Bringing the beauty of Islam to your fingertips with modern technology.',

            // SEO
            'seo_title'              => 'Zabi — Complete Islamic Companion App | Quran, Prayer & AI',
            'seo_description'        => 'Zabi is your complete Islamic companion app. Read Quran, get accurate prayer times, AI Islamic guidance, Qibla finder, Zakat calculator, and more. Free on iOS & Android.',
            'seo_keywords'           => 'Islamic app, Quran app, prayer times, Qibla finder, Zakat calculator, AI Islamic chat, Muslim app, Dhikr, Dua, Adhan, Islamic companion, Flutter Islamic app',
            'seo_canonical_url'      => 'https://zabi.theme29.com',
            'seo_robots'             => 'index, follow',
            'seo_og_title'           => 'Zabi — Complete Islamic Companion App',
            'seo_og_description'     => 'Read Quran, get prayer times, AI Islamic guidance, Qibla finder, and Zakat calculator. Download Zabi free on iOS & Android.',
            'seo_twitter_card'       => 'summary_large_image',
            'seo_twitter_title'      => 'Zabi — Complete Islamic Companion App',
            'seo_twitter_description'=> 'Read Quran, get prayer times, AI Islamic guidance, Qibla finder, and more. Download Zabi free on iOS & Android.',
            'seo_google_analytics'   => '',
            'seo_google_verification'=> '',
        ];

        foreach ($settings as $name => $value) {
            Setting::query()->updateOrCreate(
                ['name' => $name, 'context' => 'landing'],
                ['name' => $name, 'value' => $value, 'context' => 'landing']
            );
        }
    }
}
