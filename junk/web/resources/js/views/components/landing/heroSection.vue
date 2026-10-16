<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="lp-wrapper">
        <div class="lp-header">
            <div class="lp-header-icon">🏠</div>
            <div>
                <h2 class="lp-title">{{ $t("landing_hero.title") }}</h2>
                <p class="lp-subtitle">{{ $t("landing_hero.subtitle") }}</p>
            </div>
            <a href="/" target="_blank" class="preview-btn"
                >{{ $t("landing_hero.preview_page") }} ↗</a
            >
        </div>

        <form @submit.prevent="submit">
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_hero.section.app_identity") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_hero.form.app_name_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_hero.form.app_name_placeholder')
                            "
                            v-model="form.app_name"
                        />
                        <small class="field-error" v-if="errors.app_name">{{
                            errors.app_name[0]
                        }}</small>
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_hero.form.badge_text_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_hero.form.badge_text_placeholder')
                            "
                            v-model="form.hero_badge_text"
                        />
                        <small
                            class="field-error"
                            v-if="errors.hero_badge_text"
                            >{{ errors.hero_badge_text[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_hero.section.headline") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_hero.form.hero_title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_hero.form.hero_title_placeholder')
                            "
                            v-model="form.hero_title"
                        />
                        <small class="field-error" v-if="errors.hero_title">{{
                            errors.hero_title[0]
                        }}</small>
                    </div>
                    <div class="field-group">
                        <label class="field-label"
                            >{{ $t("landing_hero.form.hero_subtitle_label") }}
                            <span class="hint"
                                >({{
                                    $t("landing_hero.form.highlighted_in_gold")
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_hero.form.hero_subtitle_placeholder',
                                )
                            "
                            v-model="form.hero_subtitle"
                        />
                        <small
                            class="field-error"
                            v-if="errors.hero_subtitle"
                            >{{ errors.hero_subtitle[0] }}</small
                        >
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_hero.form.hero_description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="4"
                            :placeholder="
                                $t(
                                    'landing_hero.form.hero_description_placeholder',
                                )
                            "
                            v-model="form.hero_description"
                        ></textarea>
                        <small
                            class="field-error"
                            v-if="errors.hero_description"
                            >{{ errors.hero_description[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_hero.section.download_links") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_hero.form.app_store_url_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="url"
                            placeholder="https://apps.apple.com/..."
                            v-model="form.app_store_url"
                        />
                        <small
                            class="field-error"
                            v-if="errors.app_store_url"
                            >{{ errors.app_store_url[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_hero.form.play_store_url_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="url"
                            placeholder="https://play.google.com/..."
                            v-model="form.play_store_url"
                        />
                        <small
                            class="field-error"
                            v-if="errors.play_store_url"
                            >{{ errors.play_store_url[0] }}</small
                        >
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
                    {{ $t("common.save") }}
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
const errors = ref({});
const form = ref({
    app_name: "",
    hero_badge_text: "",
    hero_title: "",
    hero_subtitle: "",
    hero_description: "",
    app_store_url: "",
    play_store_url: "",
});

const load = () => {
    pageLoader.value = true;
    Axios.get("landing-settings")
        .then(({ data }) => {
            Object.assign(form.value, data);
        })
        .finally(() => {
            pageLoader.value = false;
        });
};

const heroFields = [
    "app_name",
    "hero_badge_text",
    "hero_title",
    "hero_subtitle",
    "hero_description",
    "app_store_url",
    "play_store_url",
];

const submit = () => {
    saving.value = true;
    errors.value = {};
    const payload = Object.fromEntries(
        heroFields.map((k) => [k, form.value[k]]),
    );
    Axios.post("landing-settings", payload)
        .then(({ data }) => toast.success(data.message))
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
            else
                toast.error(
                    response?.data?.message ?? t("landing_hero.error_saving"),
                );
        })
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
    transition: background 0.15s;
}
.preview-btn:hover {
    background: #f0faf4;
}
.lp-card {
    background: var(--theme-card);
    border-radius: 14px;
    border: 1px solid var(--theme-border);
    padding: 24px 26px;
    margin-bottom: 16px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}
.lp-card:hover {
    box-shadow: 0 4px 18px rgba(0, 0, 0, 0.07);
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
.fields-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
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
    min-height: 100px;
    line-height: 1.6;
}
.field-error {
    font-size: 0.77rem;
    color: var(--theme-error);
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
