<?php
// app/helpers.php

use App\Models\Quran\Translator\Translator;

if (!function_exists('translateToLanguage')) {
    function translateToLanguage($input, $language = 'en')
    {
        $translations = [
            'en' => [
                'numbers' => [
                    0 => '0',
                    1 => '1',
                    2 => '2',
                    3 => '3',
                    4 => '4',
                    5 => '5',
                    6 => '6',
                    7 => '7',
                    8 => '8',
                    9 => '9',
                ],
                'texts' => [
                    'verses' => 'Verses',
                    'juz' => 'Juz'
                ],
            ],
            'bn' => [
                'numbers' => [
                    0 => '০',
                    1 => '১',
                    2 => '২',
                    3 => '৩',
                    4 => '৪',
                    5 => '৫',
                    6 => '৬',
                    7 => '৭',
                    8 => '৮',
                    9 => '৯',
                ],
                'texts' => [
                    'verses' => 'আয়াত',
                    'juz' => 'পাড়া'
                ],
            ],
            'sp' => [
                'numbers' => [
                    '0' => '0',
                    '1' => '1',
                    '2' => '2',
                    '3' => '3',
                    '4' => '4',
                    '5' => '5',
                    '6' => '6',
                    '7' => '7',
                    '8' => '8',
                    '9' => '9',
                ],
                'texts' => [
                    'verses' => 'versos',
                    'juz' => 'Juz'
                ],
            ],
            'fr' => [
                'numbers' => [
                    '0' => 'zéro',
                    '1' => 'un',
                    '2' => 'deux',
                    '3' => 'trois',
                    '4' => 'quatre',
                    '5' => 'cinq',
                    '6' => 'six',
                    '7' => 'sept',
                    '8' => 'huit',
                    '9' => 'neuf',
                ],
                'texts' => [
                    'verses' => 'Versets',
                    'juz' => 'Juz'
                ],
            ],
            'ar' => [
                'numbers' => [
                    '0' => '٠',
                    '1' => '١',
                    '2' => '٢',
                    '3' => '٣',
                    '4' => '٤',
                    '5' => '٥',
                    '6' => '٦',
                    '7' => '٧',
                    '8' => '٨',
                    '9' => '٩',
                ],
                'texts' => [
                    'verses' => 'الآيات',
                    'juz' => 'جزء'
                ],
            ],
        ];

        if (isset($translations[$language])) {
            $translationMap = $translations[$language];

            if (is_numeric($input)) {
                // Translate numbers
                $translatedNumber = '';
                $numberString = strval($input);
                foreach (str_split($numberString) as $digit) {
                    $translatedNumber .= $translationMap['numbers'][$digit];
                }
                return $translatedNumber;
            } elseif (is_string($input)) {
                // Translate text strings
                return $translationMap['texts'][$input] ?? $input;
            }
        }

        // If the specified language translation is not available or input type is not supported, return the original input
        return $input;
    }

    if (!function_exists('getTranslatorCode')) {
        function getTranslatorCode($id)
        {
            return Translator::query()
                ->where('id', $id)
                ->select('language_code')
                ->first()
                ->language_code;
        }
    }
}

if (!function_exists('active_theme')) {
    /**
     * Resolve the effective web theme (preset + optional custom overrides).
     * Returns: ['key','name','mode','colors' => [8 tokens]]
     */
    function active_theme(): array
    {
        $presets = config('themes.presets', []);
        $default = config('themes.default', 'emerald');

        $key = config('settings.application.app_theme', $default);
        if (!is_string($key) || !isset($presets[$key])) {
            $key = $default;
        }

        $preset = $presets[$key] ?? ['name' => 'Default', 'mode' => 'light', 'colors' => []];
        $colors = $preset['colors'] ?? [];
        $mode   = $preset['mode'] ?? 'light';

        // Custom overrides on top of the selected preset.
        if ((string) config('settings.application.theme_use_custom') === '1') {
            foreach (array_keys($colors) as $token) {
                $override = config('settings.application.theme_c_' . $token);
                if (is_string($override) && preg_match('/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/', trim($override))) {
                    $colors[$token] = trim($override);
                }
            }
            $modeOverride = config('settings.application.theme_c_mode');
            if (in_array($modeOverride, ['light', 'dark'], true)) {
                $mode = $modeOverride;
            }
        }

        return [
            'key'    => $key,
            'name'   => $preset['name'] ?? ucfirst($key),
            'mode'   => $mode,
            'colors' => $colors,
        ];
    }
}

if (!function_exists('theme_hex_to_rgb')) {
    /**
     * Convert a hex color to a comma-separated "r, g, b" string for rgba() use.
     */
    function theme_hex_to_rgb(?string $hex, string $fallback = '0, 0, 0'): string
    {
        $hex = ltrim((string) $hex, '#');
        if (strlen($hex) === 3) {
            $hex = $hex[0] . $hex[0] . $hex[1] . $hex[1] . $hex[2] . $hex[2];
        }
        if (strlen($hex) !== 6 || !ctype_xdigit($hex)) {
            return $fallback;
        }
        return implode(', ', [
            hexdec(substr($hex, 0, 2)),
            hexdec(substr($hex, 2, 2)),
            hexdec(substr($hex, 4, 2)),
        ]);
    }
}

if (!function_exists('theme_readable_on')) {
    /**
     * Pick black or white text for readability on a given background hex.
     */
    function theme_readable_on(?string $hex, string $dark = '#1A1F2E', string $light = '#FFFFFF'): string
    {
        $rgb = explode(', ', theme_hex_to_rgb($hex, '255, 255, 255'));
        [$r, $g, $b] = array_map('intval', $rgb + [0, 0, 0]);
        // Perceived luminance (ITU-R BT.601)
        $luminance = (0.299 * $r + 0.587 * $g + 0.114 * $b) / 255;
        return $luminance > 0.6 ? $dark : $light;
    }
}
