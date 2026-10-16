<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="settings-wrapper">
        <form @submit.prevent="submit" class="settings-form">
            <!-- Hero Section -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.landing.hero.title") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label" for="app_name">{{
                            $t("setting.landing.hero.app_name_label")
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="app_name"
                            placeholder="e.g. Zabi"
                            v-model="formData.app_name"
                        />
                        <small class="field-error" v-if="errors.app_name">{{
                            errors.app_name[0]
                        }}</small>
                    </div>
                    <div class="field-group">
                        <label class="field-label" for="hero_badge_text">{{
                            $t("setting.landing.hero.badge_text_label")
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="hero_badge_text"
                            placeholder="e.g. Available on iOS & Android"
                            v-model="formData.hero_badge_text"
                        />
                        <small
                            class="field-error"
                            v-if="errors.hero_badge_text"
                            >{{ errors.hero_badge_text[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label" for="hero_title">{{
                            $t("setting.landing.hero.hero_title_label")
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="hero_title"
                            placeholder="e.g. Your Complete"
                            v-model="formData.hero_title"
                        />
                        <small class="field-error" v-if="errors.hero_title">{{
                            errors.hero_title[0]
                        }}</small>
                    </div>
                    <div class="field-group">
                        <label class="field-label" for="hero_subtitle">{{
                            $t("setting.landing.hero.hero_subtitle_label")
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="hero_subtitle"
                            placeholder="e.g. Islamic Companion"
                            v-model="formData.hero_subtitle"
                        />
                        <small
                            class="field-error"
                            v-if="errors.hero_subtitle"
                            >{{ errors.hero_subtitle[0] }}</small
                        >
                    </div>
                    <div class="field-group full-width">
                        <label class="field-label" for="hero_description">{{
                            $t("setting.landing.hero.hero_description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            id="hero_description"
                            rows="4"
                            :placeholder="
                                $t(
                                    'setting.landing.hero.hero_description_placeholder',
                                )
                            "
                            v-model="formData.hero_description"
                        ></textarea>
                        <small
                            class="field-error"
                            v-if="errors.hero_description"
                            >{{ errors.hero_description[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <!-- Stats & Badges -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.landing.stats.title") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label" for="rating">{{
                            $t("setting.landing.stats.rating_label")
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="rating"
                            placeholder="e.g. 4.9"
                            v-model="formData.rating"
                        />
                        <small class="field-error" v-if="errors.rating">{{
                            errors.rating[0]
                        }}</small>
                    </div>
                    <div class="field-group">
                        <label class="field-label" for="downloads_count">{{
                            $t("setting.landing.stats.downloads_count_label")
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="downloads_count"
                            placeholder="e.g. 100K+"
                            v-model="formData.downloads_count"
                        />
                        <small
                            class="field-error"
                            v-if="errors.downloads_count"
                            >{{ errors.downloads_count[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label" for="languages_count">{{
                            $t("setting.landing.stats.languages_count_label")
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="languages_count"
                            placeholder="e.g. 40+"
                            v-model="formData.languages_count"
                        />
                        <small
                            class="field-error"
                            v-if="errors.languages_count"
                            >{{ errors.languages_count[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <!-- Download Links -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.landing.links.title") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label" for="app_store_url">{{
                            $t("setting.landing.links.app_store_url_label")
                        }}</label>
                        <input
                            type="url"
                            class="field-input"
                            id="app_store_url"
                            placeholder="https://apps.apple.com/..."
                            v-model="formData.app_store_url"
                        />
                        <small
                            class="field-error"
                            v-if="errors.app_store_url"
                            >{{ errors.app_store_url[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label" for="play_store_url">{{
                            $t("setting.landing.links.play_store_url_label")
                        }}</label>
                        <input
                            type="url"
                            class="field-input"
                            id="play_store_url"
                            placeholder="https://play.google.com/..."
                            v-model="formData.play_store_url"
                        />
                        <small
                            class="field-error"
                            v-if="errors.play_store_url"
                            >{{ errors.play_store_url[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label" for="codecanyon_url">{{
                            $t("setting.landing.links.codecanyon_url_label")
                        }}</label>
                        <input
                            type="url"
                            class="field-input"
                            id="codecanyon_url"
                            placeholder="https://codecanyon.net/..."
                            v-model="formData.codecanyon_url"
                        />
                        <small
                            class="field-error"
                            v-if="errors.codecanyon_url"
                            >{{ errors.codecanyon_url[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.landing.footer.title") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group full-width">
                        <label class="field-label" for="footer_description">{{
                            $t("setting.landing.footer.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            id="footer_description"
                            rows="3"
                            :placeholder="
                                $t(
                                    'setting.landing.footer.description_placeholder',
                                )
                            "
                            v-model="formData.footer_description"
                        ></textarea>
                        <small
                            class="field-error"
                            v-if="errors.footer_description"
                            >{{ errors.footer_description[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <!-- Submit -->
            <div class="form-actions">
                <button type="submit" class="submit-btn" :disabled="preloader">
                    <app-button-loader v-if="preloader" />
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
                    {{ $t("setting.landing.save_changes") }}
                </button>
            </div>
        </form>
    </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";

const preloader = ref(false);
const pageLoader = ref(false);
const formData = ref({});
const errors = ref({});

const getServerData = () => {
    pageLoader.value = true;
    Axios.get("landing-settings")
        .then(({ data }) => {
            formData.value = data;
        })
        .finally(() => {
            pageLoader.value = false;
        });
};

const submit = () => {
    preloader.value = true;
    errors.value = {};
    Axios.post("landing-settings", formData.value)
        .then(({ data }) => {
            toast.success(data.message);
        })
        .catch(({ response }) => {
            if (response.status === 422) errors.value = response.data.errors;
            else toast.error(response.data.message);
        })
        .finally(() => {
            preloader.value = false;
        });
};

onMounted(() => {
    getServerData();
});
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600&display=swap");

.settings-wrapper {
    font-family: "DM Sans", sans-serif;
    max-width: 900px;
    padding: 0 0 48px;
    color: var(--theme-text);
}
.settings-card {
    background: var(--theme-card);
    border-radius: 14px;
    border: 1px solid var(--theme-border);
    padding: 26px 28px;
    margin-bottom: 18px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    transition: box-shadow 0.2s ease;
}
.settings-card:hover {
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
    margin-bottom: 20px;
}
.label-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--theme-primary);
}
.fields-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
}
.full-width {
    grid-column: 1 / -1;
}
.field-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
}
.field-label {
    font-size: 0.82rem;
    font-weight: 500;
    color: var(--theme-text-muted);
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
        box-shadow 0.18s,
        background 0.18s;
}
.field-input::placeholder {
    color: #b0b9cc;
}
.field-input:focus {
    border-color: var(--theme-secondary);
    background: var(--theme-card);
    box-shadow: 0 0 0 3px rgba(var(--theme-secondary-rgb), 0.11);
}
.field-textarea {
    resize: vertical;
    min-height: 90px;
    line-height: 1.6;
}
.field-error {
    font-size: 0.77rem;
    color: var(--theme-error);
}
.form-actions {
    display: flex;
    justify-content: flex-end;
    margin-top: 6px;
}
.submit-btn {
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
    transition:
        background 0.18s,
        transform 0.18s,
        box-shadow 0.18s;
    box-shadow: 0 4px 14px rgba(var(--theme-primary-rgb), 0.28);
}
.submit-btn:hover:not(:disabled) {
    background: var(--theme-secondary);
    transform: translateY(-1px);
    box-shadow: 0 6px 20px rgba(var(--theme-primary-rgb), 0.36);
}
.submit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}
@media (max-width: 680px) {
    .fields-grid {
        grid-template-columns: 1fr;
    }
}
</style>
