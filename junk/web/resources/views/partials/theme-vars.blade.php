{{--
    Dynamic theme variables.
    Emits :root CSS custom properties from the active preset (config/themes.php)
    merged with any custom overrides saved in settings. Included in the admin
    layout and the public landing page so a theme chosen in the admin panel
    drives colors, text, surfaces and light/dark mode everywhere on the web.
--}}
@php
    $__theme  = active_theme();
    $__c      = $__theme['colors'];
    $__mode   = $__theme['mode'];
    $__isDark = $__mode === 'dark';

    // Fallbacks keep things safe if a preset is missing a token.
    $__primary   = $__c['primary']        ?? '#1A6B4A';
    $__secondary = $__c['secondary']      ?? '#2D8A63';
    $__accent    = $__c['accent']         ?? '#E8B84B';
    $__bg        = $__c['background']      ?? '#FFFFFF';
    $__surface   = $__c['surface']        ?? '#F5F7FB';
    $__text      = $__c['text_primary']   ?? '#1A1F2E';
    $__textSec   = $__c['text_secondary'] ?? '#5A6478';
    $__error     = $__c['error']          ?? '#E05C5C';
@endphp
<style id="theme-vars">
    :root {
        /* Brand (from active preset) */
        --theme-primary: {{ $__primary }};
        --theme-secondary: {{ $__secondary }};
        --theme-accent: {{ $__accent }};
        --theme-error: {{ $__error }};

        --theme-primary-rgb: {{ theme_hex_to_rgb($__primary, '26, 107, 74') }};
        --theme-secondary-rgb: {{ theme_hex_to_rgb($__secondary, '45, 138, 99') }};
        --theme-accent-rgb: {{ theme_hex_to_rgb($__accent, '232, 184, 75') }};
        --theme-error-rgb: {{ theme_hex_to_rgb($__error, '224, 92, 92') }};

        /* Readable text color to place on a primary-colored surface */
        --theme-on-primary: {{ theme_readable_on($__primary) }};
        --theme-on-accent: {{ theme_readable_on($__accent) }};

        /* Semantic chrome tokens (mode aware) */
        --theme-text: {{ $__text }};
        --theme-text-muted: {{ $__textSec }};
        --theme-text-faint: {{ $__isDark ? $__textSec : '#9AA3B5' }};
        --theme-card: {{ $__isDark ? $__surface : '#FFFFFF' }};
        --theme-muted-bg: {{ $__isDark ? $__bg : $__surface }};
        --theme-page: {{ $__isDark ? $__bg : $__surface }};
        --theme-border: {{ $__isDark ? 'rgba(255, 255, 255, 0.10)' : '#E4E8F0' }};

        /* Landing-page palette (overrides the landing's own :root tokens) */
        --green-dark: {{ $__primary }};
        --green-mid: {{ $__secondary }};
        --green-light: {{ $__secondary }};
        --gold: {{ $__accent }};
        --gold-light: {{ $__accent }};
    }
</style>
<script>
    (function () {
        var mode = '{{ $__mode }}';
        var el = document.documentElement;
        el.setAttribute('data-theme-mode', mode);
        if (mode === 'dark') { el.classList.add('dark'); }
        else { el.classList.remove('dark'); }
    })();
</script>
