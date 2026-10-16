<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="lp-wrapper">
        <div class="lp-header">
            <div class="lp-header-icon">📲</div>
            <div>
                <h2 class="lp-title">{{ $t("landing_download.title") }}</h2>
                <p class="lp-subtitle">{{ $t("landing_download.subtitle") }}</p>
            </div>
            <a href="/" target="_blank" class="preview-btn"
                >{{ $t("landing_download.preview_page") }} ↗</a
            >
        </div>

        <form @submit.prevent="submit">
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_download.section.headline") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_download.form.title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_download.form.title_placeholder')
                            "
                            v-model="form.download_title"
                        />
                        <small
                            class="field-error"
                            v-if="errors.download_title"
                            >{{ errors.download_title[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label"
                            >{{
                                $t(
                                    "landing_download.form.title_highlight_label",
                                )
                            }}
                            <span class="hint"
                                >({{
                                    $t("landing_download.form.gold_colored")
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_download.form.title_highlight_placeholder',
                                )
                            "
                            v-model="form.download_title_highlight"
                        />
                        <small
                            class="field-error"
                            v-if="errors.download_title_highlight"
                            >{{ errors.download_title_highlight[0] }}</small
                        >
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_download.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="3"
                            :placeholder="
                                $t(
                                    'landing_download.form.description_placeholder',
                                )
                            "
                            v-model="form.download_description"
                        ></textarea>
                        <small
                            class="field-error"
                            v-if="errors.download_description"
                            >{{ errors.download_description[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_download.section.links") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_download.form.app_store_url_label")
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
                            $t("landing_download.form.play_store_url_label")
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
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_download.form.codecanyon_url_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="url"
                            placeholder="https://codecanyon.net/..."
                            v-model="form.codecanyon_url"
                        />
                        <small
                            class="field-error"
                            v-if="errors.codecanyon_url"
                            >{{ errors.codecanyon_url[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t(
                                "landing_download.form.codecanyon_prompt_text_label",
                            )
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            placeholder="Want to resell or customize?"
                            v-model="form.codecanyon_prompt_text"
                        />
                        <small
                            class="field-error"
                            v-if="errors.codecanyon_prompt_text"
                            >{{ errors.codecanyon_prompt_text[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t(
                                "landing_download.form.codecanyon_link_text_label",
                            )
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            placeholder="Get the source code on CodeCanyon →"
                            v-model="form.codecanyon_link_text"
                        />
                        <small
                            class="field-error"
                            v-if="errors.codecanyon_link_text"
                            >{{ errors.codecanyon_link_text[0] }}</small
                        >
                    </div>
                </div>

                <div class="toggles-row">
                    <div class="toggle-item">
                        <div class="toggle-info">
                            <span class="toggle-label">{{
                                $t(
                                    "landing_download.form.show_codecanyon_link_label",
                                )
                            }}</span>
                            <span class="toggle-desc">{{
                                $t(
                                    "landing_download.form.show_codecanyon_link_desc",
                                )
                            }}</span>
                        </div>
                        <label class="toggle-switch">
                            <input
                                type="checkbox"
                                v-model="form.show_codecanyon_link"
                            />
                            <span class="toggle-track"
                                ><span class="toggle-thumb"></span
                            ></span>
                        </label>
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
    download_title: "",
    download_title_highlight: "",
    download_description: "",
    app_store_url: "",
    play_store_url: "",
    codecanyon_url: "",
    codecanyon_prompt_text: "",
    codecanyon_link_text: "",
    show_codecanyon_link: true,
});

const load = () => {
    pageLoader.value = true;
    Axios.get("landing-settings")
        .then(({ data }) => {
            Object.assign(form.value, data);
            form.value.show_codecanyon_link =
                data.show_codecanyon_link === undefined
                    ? true
                    : Number(data.show_codecanyon_link) === 1;
        })
        .finally(() => {
            pageLoader.value = false;
        });
};

const downloadFields = [
    "download_title",
    "download_title_highlight",
    "download_description",
    "app_store_url",
    "play_store_url",
    "codecanyon_url",
    "codecanyon_prompt_text",
    "codecanyon_link_text",
];

const submit = () => {
    saving.value = true;
    errors.value = {};
    const payload = Object.fromEntries(
        downloadFields.map((k) => [k, form.value[k]]),
    );
    payload.show_codecanyon_link = form.value.show_codecanyon_link ? 1 : 0;
    Axios.post("landing-settings", payload)
        .then(({ data }) => toast.success(data.message))
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
            else
                toast.error(
                    response?.data?.message ??
                        t("landing_download.error_saving"),
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
    min-height: 90px;
    line-height: 1.6;
}
.field-error {
    font-size: 0.77rem;
    color: var(--theme-error);
}
.toggles-row {
    margin-top: 10px;
    border-top: 1px solid var(--theme-border);
    padding-top: 18px;
}
.toggle-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 11px 0;
}
.toggle-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
}
.toggle-label {
    font-size: 0.88rem;
    font-weight: 500;
    color: var(--theme-text);
}
.toggle-desc {
    font-size: 0.77rem;
    color: var(--theme-text-faint);
}
.toggle-switch {
    position: relative;
    display: inline-flex;
    cursor: pointer;
}
.toggle-switch input {
    position: absolute;
    opacity: 0;
    width: 0;
    height: 0;
}
.toggle-track {
    width: 44px;
    height: 24px;
    background: var(--theme-border);
    border-radius: 50px;
    position: relative;
    transition: background 0.2s ease;
    display: block;
}
.toggle-thumb {
    position: absolute;
    top: 3px;
    left: 3px;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: var(--theme-card);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.18);
    transition: transform 0.2s ease;
}
.toggle-switch input:checked + .toggle-track {
    background: var(--theme-primary);
}
.toggle-switch input:checked + .toggle-track .toggle-thumb {
    transform: translateX(20px);
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
