<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="settings-wrapper">
        <form @submit.prevent="submit" class="settings-form">
            <!-- Section: Organization -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.index.organization.title") }}
                </div>

                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label" for="company_name"
                            >{{
                                $t(
                                    "setting.index.organization.company_name_label",
                                )
                            }}
                            <span class="required">*</span></label
                        >
                        <input
                            type="text"
                            class="field-input"
                            id="company_name"
                            :placeholder="
                                $t(
                                    'setting.index.organization.company_name_placeholder',
                                )
                            "
                            v-model="formData.company_name"
                        />
                        <small class="field-error" v-if="errors.company_name">{{
                            errors.company_name[0]
                        }}</small>
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="address"
                            >{{
                                $t("setting.index.organization.address_label")
                            }}
                            <span class="required">*</span></label
                        >
                        <input
                            type="text"
                            class="field-input"
                            id="address"
                            :placeholder="
                                $t(
                                    'setting.index.organization.address_placeholder',
                                )
                            "
                            v-model="formData.address"
                        />
                        <small class="field-error" v-if="errors.address">{{
                            errors.address[0]
                        }}</small>
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="zakat_nisab"
                            >{{
                                $t(
                                    "setting.index.organization.zakat_nisab_label",
                                )
                            }}
                            <span class="required">*</span></label
                        >
                        <input
                            type="number"
                            class="field-input"
                            id="zakat_nisab"
                            :placeholder="
                                $t(
                                    'setting.index.organization.zakat_nisab_placeholder',
                                )
                            "
                            v-model="formData.zakat_nisab"
                        />
                        <small class="field-error" v-if="errors.zakat_nisab">{{
                            errors.zakat_nisab[0]
                        }}</small>
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="currency_symbol">{{
                            $t(
                                "setting.index.organization.currency_symbol_label",
                            )
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="currency_symbol"
                            placeholder="e.g. $, €, ৳"
                            v-model="formData.currency_symbol"
                        />
                        <small
                            class="field-error"
                            v-if="errors.currency_symbol"
                            >{{ errors.currency_symbol[0] }}</small
                        >
                    </div>
                </div>

                <div class="toggles-row">
                    <div class="toggle-item">
                        <div class="toggle-info">
                            <span class="toggle-label">{{
                                $t(
                                    "setting.index.organization.ramadan_schedule_label",
                                )
                            }}</span>
                            <span class="toggle-desc">{{
                                $t(
                                    "setting.index.organization.ramadan_schedule_desc",
                                )
                            }}</span>
                        </div>
                        <label class="toggle-switch">
                            <input
                                type="checkbox"
                                id="ramadan_schedule"
                                v-model="formData.ramadan_schedule"
                            />
                            <span class="toggle-track"
                                ><span class="toggle-thumb"></span
                            ></span>
                        </label>
                    </div>

                    <div class="toggle-item">
                        <div class="toggle-info">
                            <span class="toggle-label">{{
                                $t(
                                    "setting.index.organization.show_donation_banner_label",
                                )
                            }}</span>
                            <span class="toggle-desc">{{
                                $t(
                                    "setting.index.organization.show_donation_banner_desc",
                                )
                            }}</span>
                        </div>
                        <label class="toggle-switch">
                            <input
                                type="checkbox"
                                id="show_donation_banner"
                                v-model="formData.show_donation_banner"
                            />
                            <span class="toggle-track"
                                ><span class="toggle-thumb"></span
                            ></span>
                        </label>
                    </div>

                    <div class="toggle-item">
                        <div class="toggle-info">
                            <span class="toggle-label">{{
                                $t(
                                    "setting.index.organization.show_donation_icon_label",
                                )
                            }}</span>
                            <span class="toggle-desc">{{
                                $t(
                                    "setting.index.organization.show_donation_icon_desc",
                                )
                            }}</span>
                        </div>
                        <label class="toggle-switch">
                            <input
                                type="checkbox"
                                id="show_donation_icon"
                                v-model="formData.show_donation_icon"
                            />
                            <span class="toggle-track"
                                ><span class="toggle-thumb"></span
                            ></span>
                        </label>
                    </div>
                </div>
            </div>

            <!-- Section: Media Assets -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.index.media.title") }}
                </div>

                <div class="media-grid">
                    <div
                        class="media-item"
                        v-for="media in mediaItems"
                        :key="media.key"
                    >
                        <div class="media-preview">
                            <img
                                :id="media.imgId"
                                :src="formData[media.key]"
                                :alt="media.label"
                                class="preview-img"
                            />
                            <div class="preview-overlay">
                                <label :for="media.inputId" class="overlay-btn">
                                    <svg
                                        width="15"
                                        height="15"
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
                                    {{ $t("setting.index.media.upload") }}
                                </label>
                                <input
                                    :id="media.inputId"
                                    :name="media.inputId"
                                    type="file"
                                    class="hidden-input"
                                    @change="media.handler($event)"
                                />
                            </div>
                        </div>
                        <span class="media-label">{{ media.label }}</span>
                    </div>
                </div>
            </div>

            <!-- Section: Appearance -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.index.appearance.title") }}
                </div>
                <p class="section-desc">
                    {{ $t("setting.index.appearance.description") }}
                </p>

                <div class="theme-grid">
                    <button
                        type="button"
                        v-for="(preset, key) in themePresets"
                        :key="key"
                        class="theme-swatch"
                        :class="{
                            'theme-swatch--active': formData.app_theme === key,
                        }"
                        @click="formData.app_theme = key"
                    >
                        <span class="theme-swatch-colors">
                            <span
                                class="swatch-dot"
                                :style="{ background: preset.colors.primary }"
                            ></span>
                            <span
                                class="swatch-dot"
                                :style="{ background: preset.colors.secondary }"
                            ></span>
                            <span
                                class="swatch-dot"
                                :style="{ background: preset.colors.accent }"
                            ></span>
                        </span>
                        <span
                            class="theme-swatch-preview"
                            :style="{
                                background: preset.colors.background,
                                borderColor: preset.colors.surface,
                            }"
                        >
                            <span
                                class="theme-swatch-bar"
                                :style="{ background: preset.colors.primary }"
                            ></span>
                        </span>
                        <span class="theme-swatch-name">{{ preset.name }}</span>
                        <span class="theme-swatch-mode">{{ preset.mode }}</span>
                        <span
                            v-if="formData.app_theme === key"
                            class="theme-swatch-check"
                        >
                            <svg
                                width="13"
                                height="13"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="3"
                            >
                                <polyline points="20 6 9 17 4 12" />
                            </svg>
                        </span>
                    </button>
                </div>

                <!-- Custom colors -->
                <div class="custom-theme">
                    <div class="toggle-item toggle-item--flush">
                        <div class="toggle-info">
                            <span class="toggle-label">{{
                                $t("setting.index.appearance.customize_label")
                            }}</span>
                            <span class="toggle-desc">{{
                                $t("setting.index.appearance.customize_desc")
                            }}</span>
                        </div>
                        <label class="toggle-switch">
                            <input type="checkbox" v-model="useCustom" />
                            <span class="toggle-track"
                                ><span class="toggle-thumb"></span
                            ></span>
                        </label>
                    </div>

                    <div v-if="useCustom" class="custom-colors">
                        <div class="custom-colors-grid">
                            <div
                                class="color-field"
                                v-for="tok in colorTokens"
                                :key="tok.key"
                            >
                                <label class="color-field-label">{{
                                    tok.label
                                }}</label>
                                <div class="color-input-wrap">
                                    <input
                                        type="color"
                                        class="color-picker"
                                        v-model="customColors[tok.key]"
                                    />
                                    <input
                                        type="text"
                                        class="field-input hex-input"
                                        v-model="customColors[tok.key]"
                                        maxlength="7"
                                        spellcheck="false"
                                    />
                                </div>
                            </div>
                            <div class="color-field">
                                <label class="color-field-label">{{
                                    $t("setting.index.appearance.mode_label")
                                }}</label>
                                <select
                                    class="field-input"
                                    v-model="customMode"
                                >
                                    <option value="light">
                                        {{
                                            $t(
                                                "setting.index.appearance.mode_light",
                                            )
                                        }}
                                    </option>
                                    <option value="dark">
                                        {{
                                            $t(
                                                "setting.index.appearance.mode_dark",
                                            )
                                        }}
                                    </option>
                                </select>
                            </div>
                        </div>
                        <button
                            type="button"
                            class="reset-colors-btn"
                            @click="resetToPreset"
                        >
                            {{ $t("setting.index.appearance.reset_to_preset") }}
                        </button>
                    </div>
                </div>
            </div>

            <!-- Section: Integrations -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.index.integrations.title") }}
                </div>

                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label" for="google_map_key">{{
                            $t(
                                "setting.index.integrations.google_map_key_label",
                            )
                        }}</label>
                        <input
                            type="text"
                            class="field-input"
                            id="google_map_key"
                            :placeholder="
                                $t(
                                    'setting.index.integrations.google_map_key_placeholder',
                                )
                            "
                            v-model="formData.google_map_key"
                        />
                        <small
                            class="field-error"
                            v-if="errors.google_map_key"
                            >{{ errors.google_map_key[0] }}</small
                        >
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="islamic_name_api_key"
                            >{{
                                $t(
                                    "setting.index.integrations.ai_secret_key_label",
                                )
                            }}
                            <a
                                href="https://groq.com"
                                target="_blank"
                                class="text-primary"
                                >{{
                                    $t(
                                        "setting.index.integrations.get_api_key_groq",
                                    )
                                }}</a
                            >
                        </label>
                        <input
                            type="text"
                            class="field-input"
                            id="islamic_name_api_key"
                            :placeholder="
                                $t(
                                    'setting.index.integrations.ai_secret_key_placeholder',
                                )
                            "
                            v-model="formData.islamic_name_api_key"
                        />
                        <small
                            class="field-error"
                            v-if="errors.islamic_name_api_key"
                            >{{ errors.islamic_name_api_key[0] }}</small
                        >
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="play_store_url">{{
                            $t(
                                "setting.index.integrations.play_store_url_label",
                            )
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
                        <label class="field-label" for="app_store_url">{{
                            $t("setting.index.integrations.app_store_url_label")
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
                </div>
            </div>

            <!-- Section: Descriptions -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.index.descriptions.title") }}
                </div>

                <div class="fields-grid two-col">
                    <div class="field-group">
                        <label class="field-label" for="zakat_description">{{
                            $t(
                                "setting.index.descriptions.zakat_description_label",
                            )
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            id="zakat_description"
                            rows="6"
                            v-model="formData.zakat_description"
                            :placeholder="
                                $t(
                                    'setting.index.descriptions.zakat_description_placeholder',
                                )
                            "
                        ></textarea>
                        <small
                            class="field-error"
                            v-if="errors.zakat_description"
                            >{{ errors.zakat_description[0] }}</small
                        >
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="haram_description">{{
                            $t(
                                "setting.index.descriptions.haram_description_label",
                            )
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            id="haram_description"
                            rows="6"
                            v-model="formData.haram_description"
                            :placeholder="
                                $t(
                                    'setting.index.descriptions.haram_description_placeholder',
                                )
                            "
                        ></textarea>
                        <small
                            class="field-error"
                            v-if="errors.haram_description"
                            >{{ errors.haram_description[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <!-- Submit -->
            <div class="form-actions" v-if="$canAccess('update_setting')">
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
                    {{ $t("setting.index.save_changes") }}
                </button>
            </div>
        </form>
    </div>
</template>

<script setup>
import { onMounted, ref, computed, watch } from "vue";
import Axios from "@/services/axios/index.js";
import _ from "lodash";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { toast } from "vue3-toastify";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const preloader = ref(false);
const formData = ref({});
const errors = ref({});
const themePresets = ref({});

/* ── Custom theme colors ────────────────────────────────── */
const useCustom = ref(false);
const customMode = ref("light");
const customColors = ref({
    primary: "#1A6B4A",
    secondary: "#2D8A63",
    accent: "#E8B84B",
    background: "#FFFFFF",
    surface: "#F5F7FB",
    text_primary: "#1A1F2E",
    text_secondary: "#5A6478",
    error: "#E05C5C",
});
const colorTokens = computed(() => [
    { key: "primary", label: t("setting.index.appearance.color_primary") },
    { key: "secondary", label: t("setting.index.appearance.color_secondary") },
    { key: "accent", label: t("setting.index.appearance.color_accent") },
    {
        key: "background",
        label: t("setting.index.appearance.color_background"),
    },
    { key: "surface", label: t("setting.index.appearance.color_surface") },
    {
        key: "text_primary",
        label: t("setting.index.appearance.color_text_primary"),
    },
    {
        key: "text_secondary",
        label: t("setting.index.appearance.color_text_secondary"),
    },
    { key: "error", label: t("setting.index.appearance.color_error") },
]);

function hexToRgb(hex) {
    hex = String(hex || "").replace("#", "");
    if (hex.length === 3)
        hex = hex
            .split("")
            .map((c) => c + c)
            .join("");
    const n = parseInt(hex, 16);
    if (hex.length !== 6 || isNaN(n)) return "0, 0, 0";
    return [(n >> 16) & 255, (n >> 8) & 255, n & 255].join(", ");
}
function readableOn(hex) {
    const [r, g, b] = hexToRgb(hex).split(", ").map(Number);
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255 > 0.6
        ? "#1A1F2E"
        : "#FFFFFF";
}
// Mirror of resources/views/partials/theme-vars.blade.php for live preview.
function applyThemeVars(c, mode) {
    const el = document.documentElement,
        s = el.style,
        dark = mode === "dark";
    s.setProperty("--theme-primary", c.primary);
    s.setProperty("--theme-secondary", c.secondary);
    s.setProperty("--theme-accent", c.accent);
    s.setProperty("--theme-error", c.error);
    s.setProperty("--theme-primary-rgb", hexToRgb(c.primary));
    s.setProperty("--theme-secondary-rgb", hexToRgb(c.secondary));
    s.setProperty("--theme-accent-rgb", hexToRgb(c.accent));
    s.setProperty("--theme-error-rgb", hexToRgb(c.error));
    s.setProperty("--theme-on-primary", readableOn(c.primary));
    s.setProperty("--theme-on-accent", readableOn(c.accent));
    s.setProperty("--theme-text", c.text_primary);
    s.setProperty("--theme-text-muted", c.text_secondary);
    s.setProperty("--theme-text-faint", dark ? c.text_secondary : "#9AA3B5");
    s.setProperty("--theme-card", dark ? c.surface : "#FFFFFF");
    s.setProperty("--theme-muted-bg", dark ? c.background : c.surface);
    s.setProperty("--theme-page", dark ? c.background : c.surface);
    s.setProperty(
        "--theme-border",
        dark ? "rgba(255, 255, 255, 0.10)" : "#E4E8F0",
    );
    s.setProperty("--green-dark", c.primary);
    s.setProperty("--green-mid", c.secondary);
    s.setProperty("--gold", c.accent);
    el.setAttribute("data-theme-mode", dark ? "dark" : "light");
    el.classList.toggle("dark", dark);
}
function currentPreset() {
    return themePresets.value?.[formData.value.app_theme] || null;
}
// Copy the active preset's palette into the editable custom pickers.
function seedFromPreset() {
    const p = currentPreset();
    if (!p) return;
    customColors.value = { ...customColors.value, ...p.colors };
    customMode.value = p.mode || "light";
}
function resetToPreset() {
    seedFromPreset();
}
// Push the effective palette (custom or preset) onto the live page.
function applyPreview() {
    const p = currentPreset();
    if (useCustom.value) {
        applyThemeVars(customColors.value, customMode.value);
    } else if (p) {
        applyThemeVars(p.colors, p.mode);
    }
}

const handleFileChange = (fileRef, formDataKey) => (event) => {
    const file = event.target.files[0];
    fileRef.value = file;
    formData.value[formDataKey] = URL.createObjectURL(file);
};

const webLogo = ref(null);
const changeWebLogo = handleFileChange(webLogo, "web_logo");
const webIcon = ref(null);
const changeWebIcon = handleFileChange(webIcon, "web_icon");
const appBanner = ref(null);
const changeAppBanner = handleFileChange(appBanner, "app_logo");
const donationBanner = ref(null);
const changeDonationBanner = handleFileChange(
    donationBanner,
    "donation_banner",
);

const mediaItems = computed(() => [
    {
        key: "web_logo",
        label: t("setting.index.media.company_logo"),
        imgId: "web_logo_img",
        inputId: "web_logo",
        handler: changeWebLogo,
    },
    {
        key: "web_icon",
        label: t("setting.index.media.company_icon"),
        imgId: "web_icon_img",
        inputId: "web_icon",
        handler: changeWebIcon,
    },
    {
        key: "app_logo",
        label: t("setting.index.media.app_banner"),
        imgId: "app_logo_img",
        inputId: "app_logo",
        handler: changeAppBanner,
    },
    {
        key: "donation_banner",
        label: t("setting.index.media.donation_banner"),
        imgId: "app_donation_img",
        inputId: "app_donation_banner",
        handler: changeDonationBanner,
    },
]);

const submit = () => {
    preloader.value = true;
    errors.value = {};
    setOrDeleteProperty(formData.value, "web_logo", webLogo.value);
    setOrDeleteProperty(formData.value, "web_icon", webIcon.value);
    setOrDeleteProperty(formData.value, "app_logo", appBanner.value);
    setOrDeleteProperty(
        formData.value,
        "donation_banner",
        donationBanner.value,
    );
    formData.value.show_donation_banner =
        formData.value.show_donation_banner === true ? 1 : 0;
    formData.value.show_donation_icon =
        formData.value.show_donation_icon === true ? 1 : 0;
    formData.value.ramadan_schedule =
        formData.value.ramadan_schedule === true ? 1 : 0;

    // Persist custom theme colors (or clear them when custom mode is off).
    formData.value.theme_use_custom = useCustom.value ? "1" : "0";
    formData.value.theme_c_mode = useCustom.value ? customMode.value : "";
    colorTokens.value.forEach(({ key }) => {
        formData.value["theme_c_" + key] = useCustom.value
            ? customColors.value[key]
            : "";
    });

    Axios.post("settings", formData.value, {
        headers: { "Content-Type": "multipart/form-data" },
    })
        .then(({ data }) => {
            toast.success(data.message);
            location.reload();
        })
        .catch(({ response }) => {
            if (response.status === 422) errors.value = response.data.errors;
            else toast.error(response.data.message);
        })
        .finally(() => {
            preloader.value = false;
        });
};

function setOrDeleteProperty(obj, key, value) {
    if (value) obj[key] = value;
    else delete obj[key];
}

const pageLoader = ref(false);
const originalGoogleMapKey = ref(null);
const originalIslamicNameApiKey = ref(null);
const isInitialLoadComplete = ref(false);

const getServerData = () => {
    pageLoader.value = true;
    Axios.get("settings")
        .then(({ data }) => {
            if (!_.isEmpty(data)) {
                formData.value = data;
                formData.value.web_logo = data.web_logo
                    ? urlGenerator(data.web_logo)
                    : null;
                formData.value.web_icon = data.web_icon
                    ? urlGenerator(data.web_icon)
                    : null;
                formData.value.app_logo = data.app_logo
                    ? urlGenerator(data.app_logo)
                    : null;
                formData.value.donation_banner = data.donation_banner
                    ? urlGenerator(data.donation_banner)
                    : null;
                formData.value.show_donation_banner =
                    Number(data.show_donation_banner) === 1;
                formData.value.show_donation_icon =
                    Number(data.show_donation_icon) === 1;
                formData.value.ramadan_schedule =
                    Number(data.ramadan_schedule) === 1;

                formData.value.islamic_name_api_key =
                    data.islamic_name_api_key || "";
                originalIslamicNameApiKey.value =
                    data.islamic_name_api_key || "";

                formData.value.google_map_key = data.google_map_key || "";
                originalGoogleMapKey.value = data.google_map_key || "";
                isInitialLoadComplete.value = true;
            }
        })
        .finally(() => {
            pageLoader.value = false;
        });
};

watch(
    () => formData.value.google_map_key,
    (newVal) => {
        if (!isInitialLoadComplete.value) return;
        if (newVal !== originalGoogleMapKey.value)
            formData.value.is_typed_g_map = true;
        else delete formData.value.is_typed_g_map;
    },
);

watch(
    () => formData.value.islamic_name_api_key,
    (newVal) => {
        if (!isInitialLoadComplete.value) return;
        if (newVal !== originalIslamicNameApiKey.value)
            formData.value.is_typed_islamic_name = true;
        else delete formData.value.is_typed_islamic_name;
    },
);

const getThemePresets = () => {
    return Axios.get("theme-presets").then(({ data }) => {
        themePresets.value = data;
    });
};

const HEX_RE = /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/;
// Initialise custom-color state from saved settings once both loads finish.
function initTheme() {
    const d = formData.value || {};
    useCustom.value = String(d.theme_use_custom) === "1";
    seedFromPreset(); // start from the active preset...
    // ...then layer any saved overrides on top.
    colorTokens.value.forEach(({ key }) => {
        const saved = d["theme_c_" + key];
        if (typeof saved === "string" && HEX_RE.test(saved))
            customColors.value[key] = saved;
    });
    if (d.theme_c_mode === "light" || d.theme_c_mode === "dark")
        customMode.value = d.theme_c_mode;
    applyPreview();
}

// Live preview as the admin edits.
watch(useCustom, applyPreview);
watch(customMode, applyPreview);
watch(customColors, applyPreview, { deep: true });
watch(
    () => formData.value.app_theme,
    () => {
        if (!useCustom.value) seedFromPreset(); // follow the newly picked preset
        applyPreview();
    },
);

onMounted(() => {
    pageLoader.value = true;
    Promise.all([
        Axios.get("settings").then(({ data }) => {
            if (!_.isEmpty(data)) {
                formData.value = data;
                formData.value.web_logo = data.web_logo
                    ? urlGenerator(data.web_logo)
                    : null;
                formData.value.web_icon = data.web_icon
                    ? urlGenerator(data.web_icon)
                    : null;
                formData.value.app_logo = data.app_logo
                    ? urlGenerator(data.app_logo)
                    : null;
                formData.value.donation_banner = data.donation_banner
                    ? urlGenerator(data.donation_banner)
                    : null;
                formData.value.show_donation_banner =
                    Number(data.show_donation_banner) === 1;
                formData.value.show_donation_icon =
                    Number(data.show_donation_icon) === 1;
                formData.value.ramadan_schedule =
                    Number(data.ramadan_schedule) === 1;
                formData.value.islamic_name_api_key =
                    data.islamic_name_api_key || "";
                originalIslamicNameApiKey.value =
                    data.islamic_name_api_key || "";
                formData.value.google_map_key = data.google_map_key || "";
                originalGoogleMapKey.value = data.google_map_key || "";
                isInitialLoadComplete.value = true;
            }
        }),
        getThemePresets(),
    ])
        .then(() => {
            initTheme();
        })
        .finally(() => {
            pageLoader.value = false;
        });
});
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600&family=Playfair+Display:wght@500;600&display=swap");

.settings-wrapper {
    font-family: "DM Sans", sans-serif;
    max-width: 900px;
    padding: 0 0 48px;
    color: var(--theme-text);
}

/* ── Header ── */
.settings-header {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 28px;
}
.header-icon {
    width: 46px;
    height: 46px;
    border-radius: 12px;
    background: var(--theme-primary);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 4px 14px rgba(var(--theme-primary-rgb), 0.28);
}
.settings-title {
    font-family: "Playfair Display", serif;
    font-size: 1.5rem;
    font-weight: 600;
    color: var(--theme-text);
    margin: 0;
    line-height: 1.2;
}
.settings-subtitle {
    font-size: 0.84rem;
    color: var(--theme-text-faint);
    margin: 3px 0 0;
}

/* ── Card ── */
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

/* ── Fields ── */
.fields-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
}
.two-col {
    grid-template-columns: 1fr 1fr;
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
.required {
    color: var(--theme-error);
    margin-inline-start: 2px;
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
    min-height: 120px;
    line-height: 1.6;
}
.field-error {
    font-size: 0.77rem;
    color: var(--theme-error);
}

/* ── Toggles ── */
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
    border-bottom: 1px solid var(--theme-border);
}
.toggle-item:last-child {
    border-bottom: none;
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

/* ── Media ── */
.media-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
}
.media-item {
    display: flex;
    flex-direction: column;
    gap: 8px;
    align-items: center;
}
.media-preview {
    position: relative;
    width: 100%;
    aspect-ratio: 1;
    border-radius: 10px;
    border: 1.5px solid var(--theme-border);
    background: var(--theme-muted-bg);
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
}
.preview-img {
    max-width: 80%;
    max-height: 80%;
    object-fit: contain;
}
.preview-overlay {
    position: absolute;
    inset: 0;
    background: rgba(var(--theme-primary-rgb), 0.87);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity 0.2s ease;
    border-radius: 10px;
}
.media-preview:hover .preview-overlay {
    opacity: 1;
}
.overlay-btn {
    display: flex;
    align-items: center;
    gap: 5px;
    color: #fff;
    font-size: 0.78rem;
    font-weight: 500;
    cursor: pointer;
    padding: 6px 11px;
    border-radius: 6px;
    border: 1px solid rgba(255, 255, 255, 0.35);
    background: rgba(255, 255, 255, 0.1);
    transition: background 0.15s;
}
.overlay-btn:hover {
    background: rgba(255, 255, 255, 0.2);
}
.hidden-input {
    display: none;
}
.media-label {
    font-size: 0.77rem;
    font-weight: 500;
    color: var(--theme-text-muted);
    text-align: center;
}

/* ── Appearance ── */
.section-desc {
    font-size: 0.82rem;
    color: var(--theme-text-faint);
    margin: -12px 0 18px;
}
.theme-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 14px;
}
.theme-swatch {
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    padding: 14px;
    background: var(--theme-muted-bg);
    border: 1.5px solid var(--theme-border);
    border-radius: 12px;
    cursor: pointer;
    font-family: "DM Sans", sans-serif;
    text-align: start;
    transition:
        border-color 0.18s,
        box-shadow 0.18s,
        background 0.18s;
}
.theme-swatch:hover {
    border-color: #b7c3d6;
}
.theme-swatch--active {
    border-color: var(--theme-secondary);
    background: var(--theme-card);
    box-shadow: 0 0 0 3px rgba(var(--theme-secondary-rgb), 0.11);
}
.theme-swatch-colors {
    display: flex;
    gap: 5px;
}
.swatch-dot {
    width: 14px;
    height: 14px;
    border-radius: 50%;
    box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.08);
}
.theme-swatch-preview {
    width: 100%;
    height: 34px;
    border-radius: 8px;
    border: 1.5px solid;
    display: flex;
    align-items: flex-end;
    overflow: hidden;
}
.theme-swatch-bar {
    width: 100%;
    height: 8px;
}
.theme-swatch-name {
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--theme-text);
}
.theme-swatch-mode {
    font-size: 0.72rem;
    color: var(--theme-text-faint);
    text-transform: capitalize;
}
.theme-swatch-check {
    position: absolute;
    top: 10px;
    right: 10px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: var(--theme-secondary);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
}

/* ── Custom colors ── */
.custom-theme {
    margin-top: 20px;
    border-top: 1px solid var(--theme-border);
    padding-top: 8px;
}
.toggle-item--flush {
    padding: 12px 0;
    border-bottom: none;
}
.custom-colors {
    margin-top: 6px;
    padding: 18px;
    background: var(--theme-muted-bg);
    border: 1px solid var(--theme-border);
    border-radius: 12px;
}
.custom-colors-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 14px;
}
.color-field {
    display: flex;
    flex-direction: column;
    gap: 6px;
}
.color-field-label {
    font-size: 0.78rem;
    font-weight: 500;
    color: var(--theme-text-muted);
}
.color-input-wrap {
    display: flex;
    align-items: center;
    gap: 8px;
    background: var(--theme-card);
    border: 1.5px solid var(--theme-border);
    border-radius: 9px;
    padding: 5px 8px;
}
.color-picker {
    width: 30px;
    height: 30px;
    padding: 0;
    border: none;
    background: none;
    cursor: pointer;
    border-radius: 6px;
    flex-shrink: 0;
}
.color-picker::-webkit-color-swatch-wrapper {
    padding: 0;
}
.color-picker::-webkit-color-swatch {
    border: 1px solid rgba(0, 0, 0, 0.12);
    border-radius: 6px;
}
.hex-input {
    border: none !important;
    background: transparent !important;
    padding: 0 !important;
    font-size: 0.82rem;
    text-transform: uppercase;
    box-shadow: none !important;
}
.reset-colors-btn {
    margin-top: 16px;
    background: transparent;
    border: 1.5px solid var(--theme-border);
    color: var(--theme-text-muted);
    font-family: "DM Sans", sans-serif;
    font-size: 0.82rem;
    font-weight: 500;
    padding: 8px 16px;
    border-radius: 8px;
    cursor: pointer;
    transition:
        border-color 0.18s,
        color 0.18s;
}
.reset-colors-btn:hover {
    border-color: var(--theme-primary);
    color: var(--theme-primary);
}

/* ── Submit ── */
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
.submit-btn:active:not(:disabled) {
    transform: translateY(0);
}
.submit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

@media (max-width: 680px) {
    .fields-grid,
    .two-col {
        grid-template-columns: 1fr;
    }
    .media-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}
</style>
