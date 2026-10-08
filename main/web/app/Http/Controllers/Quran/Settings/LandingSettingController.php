<?php

namespace App\Http\Controllers\Quran\Settings;

use App\Concerns\FileHandler;
use App\Http\Controllers\Controller;
use App\Repositories\Setting\SettingRepository;
use App\Services\Setting\SettingService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class LandingSettingController extends Controller
{
    use FileHandler;

    private array $allFields = [
        // Hero
        'app_name', 'hero_badge_text', 'hero_title', 'hero_subtitle', 'hero_description',
        'app_store_url', 'play_store_url',
        // Stats
        'rating', 'downloads_count', 'languages_count',
        // Features
        'features_title', 'features_description', 'features_json',
        // Sections
        'quran_title', 'quran_title_highlight', 'quran_description', 'quran_offline_note',
        'prayer_title', 'prayer_title_highlight', 'prayer_description',
        'ai_title', 'ai_description',
        'ai_chat_card_title', 'ai_chat_card_description',
        'ai_name_card_title', 'ai_name_card_description',
        'dhikr_title', 'dhikr_description',
        'donation_title', 'donation_description',
        'donation_verse_arabic', 'donation_verse_translation',
        'donation_why_json', 'donation_accepted_label', 'donation_gateways',
        // AI Chat demo
        'ai_chat_badge', 'ai_chat_title_line1', 'ai_chat_title_line2', 'ai_chat_description',
        'ai_chat_features_json', 'ai_chat_try_label', 'ai_chat_suggestions_json',
        // Islamic Name Generator
        'name_gen_title', 'name_gen_title_highlight', 'name_gen_description',
        // Tech specs
        'tech_title', 'tech_subtitle', 'tech_specs_json',
        // Download
        'download_title', 'download_title_highlight', 'download_description', 'codecanyon_url',
        'codecanyon_prompt_text', 'codecanyon_link_text', 'show_codecanyon_link',
        // Footer
        'footer_description',
        // SEO
        'seo_title', 'seo_description', 'seo_keywords', 'seo_canonical_url', 'seo_robots',
        'seo_og_title', 'seo_og_description', 'seo_og_image',
        'seo_twitter_card', 'seo_twitter_title', 'seo_twitter_description',
        'seo_google_analytics', 'seo_google_verification',
    ];

    public function index()
    {
        return resolve(SettingService::class)->getFormattedSettings('landing');
    }

    public function update(Request $request)
    {
        $request->validate([
            'app_name'             => ['nullable', 'string', 'max:100'],
            'hero_badge_text'      => ['nullable', 'string', 'max:100'],
            'hero_title'           => ['nullable', 'string', 'max:200'],
            'hero_subtitle'        => ['nullable', 'string', 'max:100'],
            'hero_description'     => ['nullable', 'string'],
            'rating'               => ['nullable', 'string', 'max:10'],
            'downloads_count'      => ['nullable', 'string', 'max:20'],
            'languages_count'      => ['nullable', 'string', 'max:10'],
            'app_store_url'        => ['nullable', 'url:https'],
            'play_store_url'       => ['nullable', 'url:https'],
            'codecanyon_url'       => ['nullable', 'url:https'],
            'features_title'       => ['nullable', 'string', 'max:200'],
            'features_description' => ['nullable', 'string'],
            'features_json'        => ['nullable', 'string'],
            'quran_title'             => ['nullable', 'string', 'max:200'],
            'quran_title_highlight'   => ['nullable', 'string', 'max:100'],
            'quran_description'       => ['nullable', 'string'],
            'quran_offline_note'      => ['nullable', 'string', 'max:300'],
            'prayer_title'            => ['nullable', 'string', 'max:200'],
            'prayer_title_highlight'  => ['nullable', 'string', 'max:100'],
            'prayer_description'      => ['nullable', 'string'],
            'ai_title'                => ['nullable', 'string', 'max:200'],
            'ai_description'          => ['nullable', 'string'],
            'ai_chat_card_title'        => ['nullable', 'string', 'max:100'],
            'ai_chat_card_description'  => ['nullable', 'string'],
            'ai_name_card_title'        => ['nullable', 'string', 'max:100'],
            'ai_name_card_description'  => ['nullable', 'string'],
            'dhikr_title'             => ['nullable', 'string', 'max:200'],
            'dhikr_description'       => ['nullable', 'string'],
            'donation_title'          => ['nullable', 'string', 'max:200'],
            'donation_description'    => ['nullable', 'string'],
            'donation_verse_arabic'       => ['nullable', 'string', 'max:500'],
            'donation_verse_translation'  => ['nullable', 'string', 'max:300'],
            'donation_why_json'           => ['nullable', 'string'],
            'donation_accepted_label'     => ['nullable', 'string', 'max:100'],
            'donation_gateways'           => ['nullable', 'string', 'max:500'],
            'ai_chat_badge'            => ['nullable', 'string', 'max:100'],
            'ai_chat_title_line1'      => ['nullable', 'string', 'max:100'],
            'ai_chat_title_line2'      => ['nullable', 'string', 'max:100'],
            'ai_chat_description'      => ['nullable', 'string'],
            'ai_chat_features_json'    => ['nullable', 'string'],
            'ai_chat_try_label'        => ['nullable', 'string', 'max:100'],
            'ai_chat_suggestions_json' => ['nullable', 'string'],
            'name_gen_title'           => ['nullable', 'string', 'max:100'],
            'name_gen_title_highlight' => ['nullable', 'string', 'max:100'],
            'name_gen_description'     => ['nullable', 'string'],
            'tech_title'               => ['nullable', 'string', 'max:200'],
            'tech_subtitle'            => ['nullable', 'string', 'max:200'],
            'tech_specs_json'          => ['nullable', 'string'],
            'download_title'          => ['nullable', 'string', 'max:200'],
            'download_title_highlight'=> ['nullable', 'string', 'max:100'],
            'download_description'    => ['nullable', 'string'],
            'codecanyon_prompt_text'   => ['nullable', 'string', 'max:150'],
            'codecanyon_link_text'     => ['nullable', 'string', 'max:150'],
            'show_codecanyon_link'     => ['nullable', Rule::in(['0', '1', 0, 1])],
            'footer_description'        => ['nullable', 'string'],
            // SEO
            'seo_title'                 => ['nullable', 'string', 'max:70'],
            'seo_description'           => ['nullable', 'string', 'max:200'],
            'seo_keywords'              => ['nullable', 'string', 'max:500'],
            'seo_canonical_url'         => ['nullable', 'url'],
            'seo_robots'                => ['nullable', 'string', 'max:50'],
            'seo_og_title'              => ['nullable', 'string', 'max:100'],
            'seo_og_description'        => ['nullable', 'string', 'max:200'],
            'seo_og_image'              => ['nullable', 'image', 'max:2048'],
            'seo_twitter_card'          => ['nullable', 'in:summary,summary_large_image'],
            'seo_twitter_title'         => ['nullable', 'string', 'max:100'],
            'seo_twitter_description'   => ['nullable', 'string', 'max:200'],
            'seo_google_analytics'      => ['nullable', 'string', 'max:50'],
            'seo_google_verification'   => ['nullable', 'string', 'max:200'],
        ]);

        $fields = array_intersect_key($request->all(), array_flip($this->allFields));

        // Handle og image file upload separately
        if ($request->hasFile('seo_og_image')) {
            $existing = resolve(SettingRepository::class)->createSettingInstance('seo_og_image', 'landing');
            $this->deleteImage(optional($existing)->value);
            $fields['seo_og_image'] = $this->uploadImage($request->file('seo_og_image'), 'setting');
        } else {
            unset($fields['seo_og_image']);
        }

        foreach ($fields as $key => $value) {
            resolve(SettingRepository::class)
                ->createSettingInstance($key, 'landing')
                ->fill(['name' => $key, 'value' => $value, 'context' => 'landing'])
                ->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Landing page settings updated successfully',
        ]);
    }
}
