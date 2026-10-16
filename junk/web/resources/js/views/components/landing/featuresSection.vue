<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="lp-wrapper">
        <div class="lp-header">
            <div class="lp-header-icon">⚡</div>
            <div>
                <h2 class="lp-title">{{ $t("landing_features.title") }}</h2>
                <p class="lp-subtitle">{{ $t("landing_features.subtitle") }}</p>
            </div>
            <a href="/" target="_blank" class="preview-btn"
                >{{ $t("landing_features.preview_page") }} ↗</a
            >
        </div>

        <form @submit.prevent="submit">
            <div v-for="(card, i) in features" :key="i" class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_features.card_label", { n: i + 1 }) }}
                    <span class="card-emoji">{{ card.icon }}</span>
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_features.form.icon_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            placeholder="📖"
                            v-model="card.icon"
                            maxlength="4"
                        />
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_features.form.title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_features.form.title_placeholder')
                            "
                            v-model="card.title"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_features.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            :placeholder="
                                $t(
                                    'landing_features.form.description_placeholder',
                                )
                            "
                            v-model="card.description"
                        ></textarea>
                    </div>
                    <div class="field-group full">
                        <label class="field-label"
                            >{{ $t("landing_features.form.bullets_label") }}
                            <span class="hint"
                                >({{
                                    $t("landing_features.form.one_per_line")
                                }})</span
                            ></label
                        >
                        <textarea
                            class="field-input field-textarea"
                            rows="5"
                            :placeholder="
                                $t('landing_features.form.bullets_placeholder')
                            "
                            v-model="card.bullets"
                        ></textarea>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="save-btn" :disabled="saving">
                    <app-button-loader v-if="saving" />
                    <svg
                        v-else
                        width="16"
                        height="16"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2.5"
                    >
                        <polyline points="20 6 9 17 4 12" />
                    </svg>
                    {{ $t("landing_features.save_all") }}
                </button>
            </div>
        </form>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const pageLoader = ref(false);
const saving = ref(false);

const defaultFeatures = [
    {
        icon: "📖",
        title: "Quran & Islamic Content",
        description:
            "Complete Al-Quran reading experience with multi-language translations, audio recitation, transliteration, and ayah sharing.",
        bullets:
            "4 Language Translations\nAudio Quran Support\nTransliteration Feature\nHadith & Dua Collections\nAllah's 99 Names",
    },
    {
        icon: "🕌",
        title: "Prayer & Worship",
        description:
            "Accurate prayer times, customizable schedules, Adhan notifications with multiple reciters, and Qibla finder with compass.",
        bullets:
            "Accurate Prayer Times\nAdhan Notifications\nQibla Finder & Compass\nRamadan Schedule\nMultiple Adhan Reciters",
    },
    {
        icon: "🤖",
        title: "AI-Powered Features",
        description:
            "Get answers to Islamic questions instantly with our AI Islamic Chat and generate beautiful Islamic names for your family.",
        bullets:
            "AI Islamic Q&A Chat\nIslamic Name Generator\nSmart Recommendations\nInstant Responses\n24/7 Availability",
    },
    {
        icon: "📍",
        title: "Mosque & Location",
        description:
            "Find nearby mosques using GPS, get navigation assistance, and manage location permissions easily.",
        bullets:
            "Nearby Mosque Finder\nGPS Navigation\nReal-time Location\nCity-based Prayer Times",
    },
    {
        icon: "💰",
        title: "Islamic Finance & Charity",
        description:
            "Calculate your Zakat accurately with customizable Nisab settings and support charitable causes through the donation module.",
        bullets:
            "Zakat Calculator\nCustomizable Nisab\nDonation Module\nMultiple Currencies",
    },
    {
        icon: "🎨",
        title: "Personalization",
        description:
            "Make the app yours with dark mode, RTL support, dynamic wallpapers, custom dhikr, dua, and 40+ language options.",
        bullets:
            "Dark Mode Support\nRTL Language Support\nDynamic Wallpapers\nCustom Dhikr & Dua",
    },
];

const features = ref(defaultFeatures.map((f) => ({ ...f })));

const load = () => {
    pageLoader.value = true;
    Axios.get("landing-settings")
        .then(({ data }) => {
            if (data.features_json) {
                try {
                    const parsed = JSON.parse(data.features_json);
                    if (Array.isArray(parsed) && parsed.length)
                        features.value = parsed;
                } catch {}
            }
        })
        .finally(() => {
            pageLoader.value = false;
        });
};

const submit = () => {
    saving.value = true;
    Axios.post("landing-settings", {
        features_json: JSON.stringify(features.value),
    })
        .then(({ data }) => toast.success(data.message))
        .catch(({ response }) =>
            toast.error(
                response?.data?.message ?? t("landing_features.error_saving"),
            ),
        )
        .finally(() => {
            saving.value = false;
        });
};

onMounted(load);
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&display=swap");
.lp-wrapper {
    font-family: "DM Sans", sans-serif;
    max-width: 860px;
    padding-bottom: 48px;
    color: var(--theme-text);
}
.lp-header {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 28px;
}
.lp-header-icon {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    background: var(--theme-primary);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
}
.lp-title {
    font-size: 1.3rem;
    font-weight: 600;
    margin: 0;
}
.lp-subtitle {
    font-size: 0.82rem;
    color: var(--theme-text-faint);
    margin: 2px 0 0;
}
.preview-btn {
    margin-left: auto;
    padding: 8px 16px;
    border-radius: 8px;
    border: 1.5px solid var(--theme-border);
    font-size: 0.8rem;
    font-weight: 500;
    color: var(--theme-primary);
    text-decoration: none;
}
.preview-btn:hover {
    background: #f0faf4;
}
.lp-card {
    background: var(--theme-card);
    border-radius: 14px;
    border: 1px solid var(--theme-border);
    padding: 24px 26px;
    margin-bottom: 14px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}
.card-label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.7rem;
    font-weight: 600;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--theme-text-faint);
    margin-bottom: 18px;
}
.dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--theme-primary);
    flex-shrink: 0;
}
.card-emoji {
    font-size: 1rem;
}
.fields-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
}
.full {
    grid-column: 1 / -1;
}
.field-group {
    display: flex;
    flex-direction: column;
    gap: 5px;
}
.field-label {
    font-size: 0.82rem;
    font-weight: 500;
    color: var(--theme-text-muted);
}
.hint {
    font-size: 0.75rem;
    font-weight: 400;
    color: #b0b9cc;
}
.field-input {
    font-family: "DM Sans", sans-serif;
    font-size: 0.9rem;
    color: var(--theme-text);
    background: var(--theme-muted-bg);
    border: 1.5px solid var(--theme-border);
    border-radius: 9px;
    padding: 10px 13px;
    outline: none;
    width: 100%;
    box-sizing: border-box;
    transition:
        border-color 0.18s,
        background 0.18s;
}
.field-input:focus {
    border-color: var(--theme-secondary);
    background: var(--theme-card);
    box-shadow: 0 0 0 3px rgba(var(--theme-secondary-rgb), 0.1);
}
.field-input::placeholder {
    color: #b0b9cc;
}
.field-textarea {
    resize: vertical;
    min-height: 70px;
    line-height: 1.6;
}
.form-actions {
    display: flex;
    justify-content: flex-end;
    margin-top: 4px;
}
.save-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 11px 26px;
    background: var(--theme-primary);
    color: #fff;
    font-family: "DM Sans", sans-serif;
    font-size: 0.9rem;
    font-weight: 600;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(var(--theme-primary-rgb), 0.28);
    transition:
        background 0.18s,
        transform 0.18s;
}
.save-btn:hover:not(:disabled) {
    background: var(--theme-secondary);
    transform: translateY(-1px);
}
.save-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}
@media (max-width: 640px) {
    .fields-grid {
        grid-template-columns: 1fr;
    }
}
</style>
