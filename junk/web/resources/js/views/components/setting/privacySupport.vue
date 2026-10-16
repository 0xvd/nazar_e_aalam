<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="settings-wrapper">
        <form @submit.prevent="submit" class="settings-form">
            <div
                class="settings-card"
                v-for="section in sections"
                :key="section.key"
            >
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ section.title }}
                </div>
                <p class="card-desc">{{ section.desc }}</p>
                <div class="editor-wrapper">
                    <app-input v-model="formData[section.key]" type="editor" />
                </div>
            </div>

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
                    {{ $t("setting.privacy_support.save_changes") }}
                </button>
            </div>
        </form>
    </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import Axios from "@/services/axios/index.js";
import _ from "lodash";
import { toast } from "vue3-toastify";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const preloader = ref(false);
const pageLoader = ref(false);
const formData = ref({});
const errors = ref({});

const sections = [
    {
        key: "privacy_policy",
        title: t("setting.privacy_support.sections.privacy_policy.title"),
        desc: t("setting.privacy_support.sections.privacy_policy.desc"),
    },
    {
        key: "support",
        title: t("setting.privacy_support.sections.support.title"),
        desc: t("setting.privacy_support.sections.support.desc"),
    },
    {
        key: "terms_and_conditions",
        title: t("setting.privacy_support.sections.terms_and_conditions.title"),
        desc: t("setting.privacy_support.sections.terms_and_conditions.desc"),
    },
];

const submit = () => {
    preloader.value = true;
    errors.value = {};
    Axios.post("privacy-support", formData.value)
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

const getServerData = () => {
    pageLoader.value = true;
    Axios.get("settings")
        .then(({ data }) => {
            if (!_.isEmpty(data)) formData.value = data;
        })
        .finally(() => {
            pageLoader.value = false;
        });
};

onMounted(() => {
    getServerData();
});
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600&family=Playfair+Display:wght@500;600&display=swap");

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
    margin-bottom: 4px;
}
.label-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--theme-primary);
}

.card-desc {
    font-size: 0.83rem;
    color: var(--theme-text-faint);
    margin: 0 0 16px;
    line-height: 1.5;
}

/* ── Editor ── */
.editor-wrapper {
    border-radius: 9px;
    border: 1.5px solid var(--theme-border);
    overflow: hidden;
    transition:
        border-color 0.18s,
        box-shadow 0.18s;
    min-height: 280px;
}
.editor-wrapper:focus-within {
    border-color: var(--theme-secondary);
    box-shadow: 0 0 0 3px rgba(var(--theme-secondary-rgb), 0.11);
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
</style>
