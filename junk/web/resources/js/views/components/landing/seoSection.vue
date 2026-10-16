<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="lp-wrapper">
        <div class="lp-header">
            <div class="lp-header-icon">🔍</div>
            <div>
                <h2 class="lp-title">{{ $t("landing_seo.title") }}</h2>
                <p class="lp-subtitle">{{ $t("landing_seo.subtitle") }}</p>
            </div>
            <a href="/" target="_blank" class="preview-btn"
                >{{ $t("landing_seo.preview_page") }} ↗</a
            >
        </div>

        <form @submit.prevent="submit">
            <!-- Basic SEO -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_seo.section.basic_seo") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group full">
                        <label class="field-label"
                            >{{ $t("landing_seo.form.page_title_label") }}
                            <span class="hint"
                                >({{
                                    $t("landing_seo.form.page_title_hint")
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            maxlength="70"
                            :placeholder="
                                $t('landing_seo.form.page_title_placeholder')
                            "
                            v-model="form.seo_title"
                        />
                        <small
                            class="field-char"
                            :class="{
                                warn: (form.seo_title || '').length > 60,
                            }"
                        >
                            {{
                                $t("landing_seo.form.char_count_recommended", {
                                    count: (form.seo_title || "").length,
                                    max: 60,
                                })
                            }}
                        </small>
                        <small class="field-error" v-if="errors.seo_title">{{
                            errors.seo_title[0]
                        }}</small>
                    </div>
                    <div class="field-group full">
                        <label class="field-label"
                            >{{ $t("landing_seo.form.meta_description_label") }}
                            <span class="hint"
                                >({{
                                    $t(
                                        "landing_seo.form.meta_description_hint",
                                    )
                                }})</span
                            ></label
                        >
                        <textarea
                            class="field-input field-textarea"
                            rows="3"
                            maxlength="200"
                            :placeholder="
                                $t(
                                    'landing_seo.form.meta_description_placeholder',
                                )
                            "
                            v-model="form.seo_description"
                        ></textarea>
                        <small
                            class="field-char"
                            :class="{
                                warn: (form.seo_description || '').length > 160,
                            }"
                        >
                            {{
                                $t("landing_seo.form.char_count_recommended", {
                                    count: (form.seo_description || "").length,
                                    max: 160,
                                })
                            }}
                        </small>
                        <small
                            class="field-error"
                            v-if="errors.seo_description"
                            >{{ errors.seo_description[0] }}</small
                        >
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_seo.form.meta_keywords_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_seo.form.meta_keywords_placeholder')
                            "
                            v-model="form.seo_keywords"
                        />
                        <small class="field-hint">{{
                            $t("landing_seo.form.meta_keywords_hint")
                        }}</small>
                        <small class="field-error" v-if="errors.seo_keywords">{{
                            errors.seo_keywords[0]
                        }}</small>
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_seo.form.canonical_url_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="url"
                            placeholder="https://yourdomain.com/"
                            v-model="form.seo_canonical_url"
                        />
                        <small
                            class="field-error"
                            v-if="errors.seo_canonical_url"
                            >{{ errors.seo_canonical_url[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_seo.form.robots_label")
                        }}</label>
                        <select class="field-input" v-model="form.seo_robots">
                            <option value="">
                                {{
                                    $t("landing_seo.form.robots_option_default")
                                }}
                            </option>
                            <option value="index,follow">
                                {{
                                    $t(
                                        "landing_seo.form.robots_option_index_follow",
                                    )
                                }}
                            </option>
                            <option value="noindex,follow">
                                {{
                                    $t(
                                        "landing_seo.form.robots_option_noindex_follow",
                                    )
                                }}
                            </option>
                            <option value="index,nofollow">
                                {{
                                    $t(
                                        "landing_seo.form.robots_option_index_nofollow",
                                    )
                                }}
                            </option>
                            <option value="noindex,nofollow">
                                {{
                                    $t(
                                        "landing_seo.form.robots_option_noindex_nofollow",
                                    )
                                }}
                            </option>
                        </select>
                        <small class="field-error" v-if="errors.seo_robots">{{
                            errors.seo_robots[0]
                        }}</small>
                    </div>
                </div>
            </div>

            <!-- Open Graph -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_seo.section.open_graph") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label"
                            >{{ $t("landing_seo.form.og_title_label") }}
                            <span class="hint"
                                >({{
                                    $t("landing_seo.form.og_title_hint")
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_seo.form.og_title_placeholder')
                            "
                            v-model="form.seo_og_title"
                        />
                        <small class="field-error" v-if="errors.seo_og_title">{{
                            errors.seo_og_title[0]
                        }}</small>
                    </div>
                    <div class="field-group">
                        <label class="field-label"
                            >{{ $t("landing_seo.form.og_description_label") }}
                            <span class="hint"
                                >({{
                                    $t("landing_seo.form.og_description_hint")
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_seo.form.og_description_placeholder',
                                )
                            "
                            v-model="form.seo_og_description"
                        />
                        <small
                            class="field-error"
                            v-if="errors.seo_og_description"
                            >{{ errors.seo_og_description[0] }}</small
                        >
                    </div>
                    <div class="field-group full">
                        <label class="field-label"
                            >{{ $t("landing_seo.form.og_image_label") }}
                            <span class="hint"
                                >({{
                                    $t("landing_seo.form.og_image_hint")
                                }})</span
                            ></label
                        >
                        <div class="og-image-wrap">
                            <img
                                v-if="form.seo_og_image"
                                :src="form.seo_og_image"
                                alt="OG preview"
                                class="og-preview"
                            />
                            <div class="og-upload-area">
                                <label
                                    for="seo_og_image_input"
                                    class="og-upload-btn"
                                >
                                    <svg
                                        width="14"
                                        height="14"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                    >
                                        <path
                                            d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"
                                        />
                                        <polyline points="17 8 12 3 7 8" />
                                        <line x1="12" y1="3" x2="12" y2="15" />
                                    </svg>
                                    {{
                                        form.seo_og_image
                                            ? $t(
                                                  "landing_seo.form.change_image",
                                              )
                                            : $t(
                                                  "landing_seo.form.upload_image",
                                              )
                                    }}
                                </label>
                                <input
                                    id="seo_og_image_input"
                                    type="file"
                                    accept="image/*"
                                    class="hidden-input"
                                    @change="onOgImageChange"
                                />
                            </div>
                        </div>
                        <small class="field-error" v-if="errors.seo_og_image">{{
                            errors.seo_og_image[0]
                        }}</small>
                    </div>
                </div>
            </div>

            <!-- Twitter Card -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_seo.section.twitter_card") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_seo.form.card_type_label")
                        }}</label>
                        <select
                            class="field-input"
                            v-model="form.seo_twitter_card"
                        >
                            <option value="summary">
                                {{ $t("landing_seo.form.card_type_summary") }}
                            </option>
                            <option value="summary_large_image">
                                {{
                                    $t(
                                        "landing_seo.form.card_type_summary_large_image",
                                    )
                                }}
                            </option>
                        </select>
                        <small
                            class="field-error"
                            v-if="errors.seo_twitter_card"
                            >{{ errors.seo_twitter_card[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label"
                            >{{ $t("landing_seo.form.twitter_title_label") }}
                            <span class="hint"
                                >({{
                                    $t("landing_seo.form.twitter_title_hint")
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_seo.form.twitter_title_placeholder')
                            "
                            v-model="form.seo_twitter_title"
                        />
                        <small
                            class="field-error"
                            v-if="errors.seo_twitter_title"
                            >{{ errors.seo_twitter_title[0] }}</small
                        >
                    </div>
                    <div class="field-group full">
                        <label class="field-label"
                            >{{
                                $t("landing_seo.form.twitter_description_label")
                            }}
                            <span class="hint"
                                >({{
                                    $t(
                                        "landing_seo.form.twitter_description_hint",
                                    )
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_seo.form.twitter_description_placeholder',
                                )
                            "
                            v-model="form.seo_twitter_description"
                        />
                        <small
                            class="field-error"
                            v-if="errors.seo_twitter_description"
                            >{{ errors.seo_twitter_description[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <!-- Analytics & Verification -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span>
                    {{ $t("landing_seo.section.analytics_verification") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label"
                            >{{ $t("landing_seo.form.google_analytics_label") }}
                            <span class="hint">(GA4)</span></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            placeholder="G-XXXXXXXXXX"
                            v-model="form.seo_google_analytics"
                        />
                        <small
                            class="field-error"
                            v-if="errors.seo_google_analytics"
                            >{{ errors.seo_google_analytics[0] }}</small
                        >
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_seo.form.google_verification_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_seo.form.google_verification_placeholder',
                                )
                            "
                            v-model="form.seo_google_verification"
                        />
                        <small class="field-hint">{{
                            $t("landing_seo.form.google_verification_hint")
                        }}</small>
                        <small
                            class="field-error"
                            v-if="errors.seo_google_verification"
                            >{{ errors.seo_google_verification[0] }}</small
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
                    {{ $t("landing_seo.save_seo_settings") }}
                </button>
            </div>
        </form>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const pageLoader = ref(false);
const saving = ref(false);
const errors = ref({});
const ogImageFile = ref(null);

const form = ref({
    seo_title: "",
    seo_description: "",
    seo_keywords: "",
    seo_canonical_url: "",
    seo_robots: "",
    seo_og_title: "",
    seo_og_description: "",
    seo_og_image: "",
    seo_twitter_card: "summary_large_image",
    seo_twitter_title: "",
    seo_twitter_description: "",
    seo_google_analytics: "",
    seo_google_verification: "",
});

const onOgImageChange = (event) => {
    const file = event.target.files[0];
    if (!file) return;
    ogImageFile.value = file;
    form.value.seo_og_image = URL.createObjectURL(file);
};

const load = () => {
    pageLoader.value = true;
    Axios.get("landing-settings")
        .then(({ data }) => {
            Object.assign(form.value, data);
            if (data.seo_og_image) {
                form.value.seo_og_image = urlGenerator(data.seo_og_image);
            }
        })
        .finally(() => {
            pageLoader.value = false;
        });
};

const submit = () => {
    saving.value = true;
    errors.value = {};

    const payload = new FormData();
    const fields = [
        "seo_title",
        "seo_description",
        "seo_keywords",
        "seo_canonical_url",
        "seo_robots",
        "seo_og_title",
        "seo_og_description",
        "seo_twitter_card",
        "seo_twitter_title",
        "seo_twitter_description",
        "seo_google_analytics",
        "seo_google_verification",
    ];
    fields.forEach((key) => {
        if (form.value[key] !== null && form.value[key] !== undefined)
            payload.append(key, form.value[key]);
    });
    if (ogImageFile.value) payload.append("seo_og_image", ogImageFile.value);

    Axios.post("landing-settings", payload, {
        headers: { "Content-Type": "multipart/form-data" },
    })
        .then(({ data }) => {
            toast.success(data.message);
            ogImageFile.value = null;
        })
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
            else
                toast.error(
                    response?.data?.message ?? t("landing_seo.error_saving"),
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
    min-height: 80px;
    line-height: 1.6;
}
.field-char {
    font-size: 0.75rem;
    color: var(--theme-text-faint);
}
.field-char.warn {
    color: #e07b3a;
}
.field-hint {
    font-size: 0.75rem;
    color: var(--theme-text-faint);
}
.field-error {
    font-size: 0.77rem;
    color: var(--theme-error);
}
.og-image-wrap {
    display: flex;
    align-items: center;
    gap: 14px;
    flex-wrap: wrap;
}
.og-preview {
    width: 180px;
    height: 95px;
    object-fit: cover;
    border-radius: 8px;
    border: 1px solid var(--theme-border);
}
.og-upload-area {
    display: flex;
    align-items: center;
}
.og-upload-btn {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 9px 18px;
    background: var(--theme-muted-bg);
    border: 1.5px solid var(--theme-border);
    border-radius: 9px;
    font-size: 0.85rem;
    font-weight: 500;
    color: var(--theme-text-muted);
    cursor: pointer;
    transition:
        border-color 0.15s,
        background 0.15s;
}
.og-upload-btn:hover {
    border-color: var(--theme-secondary);
    color: var(--theme-primary);
    background: #f0faf4;
}
.hidden-input {
    display: none;
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
