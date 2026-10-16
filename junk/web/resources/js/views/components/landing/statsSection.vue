<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="lp-wrapper">
        <div class="lp-header">
            <div class="lp-header-icon">📊</div>
            <div>
                <h2 class="lp-title">{{ $t("landing_stats.title") }}</h2>
                <p class="lp-subtitle">{{ $t("landing_stats.subtitle") }}</p>
            </div>
            <a href="/" target="_blank" class="preview-btn"
                >{{ $t("landing_stats.preview_page") }} ↗</a
            >
        </div>

        <form @submit.prevent="submit">
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_stats.section.trust_badges") }}
                </div>
                <div class="fields-grid three">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_stats.form.rating_label")
                        }}</label>
                        <div class="input-with-prefix">
                            <span class="prefix">★</span>
                            <input
                                class="field-input prefixed"
                                type="text"
                                placeholder="4.9"
                                v-model="form.rating"
                            />
                        </div>
                        <small class="field-error" v-if="errors.rating">{{
                            errors.rating[0]
                        }}</small>
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_stats.form.downloads_count_label")
                        }}</label>
                        <div class="input-with-prefix">
                            <span class="prefix">📥</span>
                            <input
                                class="field-input prefixed"
                                type="text"
                                placeholder="100K+"
                                v-model="form.downloads_count"
                            />
                        </div>
                        <small
                            class="field-error"
                            v-if="errors.downloads_count"
                            >{{ errors.downloads_count[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_stats.form.languages_count_label")
                        }}</label>
                        <div class="input-with-prefix">
                            <span class="prefix">🌍</span>
                            <input
                                class="field-input prefixed"
                                type="text"
                                placeholder="40+"
                                v-model="form.languages_count"
                            />
                        </div>
                        <small
                            class="field-error"
                            v-if="errors.languages_count"
                            >{{ errors.languages_count[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <div class="stat-preview">
                <p class="preview-label">
                    {{ $t("landing_stats.live_preview") }}
                </p>
                <div class="preview-row">
                    <span class="badge"
                        ><span class="stars">★★★★★</span>
                        {{ form.rating || "4.9" }}
                        {{ $t("landing_stats.preview.rating") }}</span
                    >
                    <span class="badge"
                        >📥 {{ form.downloads_count || "100K+" }}
                        {{ $t("landing_stats.preview.downloads") }}</span
                    >
                    <span class="badge"
                        >🌍 {{ form.languages_count || "40+" }}
                        {{ $t("landing_stats.preview.languages") }}</span
                    >
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
const form = ref({ rating: "", downloads_count: "", languages_count: "" });

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

const statsFields = ["rating", "downloads_count", "languages_count"];

const submit = () => {
    saving.value = true;
    errors.value = {};
    const payload = Object.fromEntries(
        statsFields.map((k) => [k, form.value[k]]),
    );
    Axios.post("landing-settings", payload)
        .then(({ data }) => toast.success(data.message))
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
            else
                toast.error(
                    response?.data?.message ?? t("landing_stats.error_saving"),
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
.three {
    grid-template-columns: 1fr 1fr 1fr;
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
.input-with-prefix {
    position: relative;
}
.prefix {
    position: absolute;
    inset-inline-start: 11px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 1rem;
    pointer-events: none;
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
.field-input.prefixed {
    padding-inline-start: 34px;
}
.field-input:focus {
    border-color: var(--theme-secondary);
    background: var(--theme-card);
    box-shadow: 0 0 0 3px rgba(var(--theme-secondary-rgb), 0.1);
}
.field-input::placeholder {
    color: #b0b9cc;
}
.field-error {
    font-size: 0.77rem;
    color: var(--theme-error);
}
.stat-preview {
    background: var(--theme-muted-bg);
    border-radius: 12px;
    border: 1.5px dashed #d0d7e5;
    padding: 18px 22px;
    margin-bottom: 16px;
}
.preview-label {
    font-size: 0.72rem;
    color: var(--theme-text-faint);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    margin: 0 0 10px;
}
.preview-row {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
}
.badge {
    background: var(--theme-card);
    border: 1px solid var(--theme-border);
    border-radius: 20px;
    padding: 6px 14px;
    font-size: 0.83rem;
    color: var(--theme-text-muted);
}
.stars {
    color: #f59e0b;
}
.form-actions {
    display: flex;
    justify-content: flex-end;
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
    .fields-grid,
    .three {
        grid-template-columns: 1fr;
    }
}
</style>
