<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="settings-wrapper">
        <form @submit.prevent="submit" class="settings-form">
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.home_layout.title") }}
                </div>
                <p class="card-desc">
                    {{ $t("setting.home_layout.description") }}
                </p>

                <div class="layout-grid">
                    <button
                        type="button"
                        v-for="(preset, key) in layoutPresets"
                        :key="key"
                        class="layout-card"
                        :class="{
                            'layout-card--active': formData.home_layout === key,
                        }"
                        @click="formData.home_layout = key"
                    >
                        <span
                            class="layout-mockup"
                            :class="`layout-mockup--${key}`"
                        >
                            <!-- Modern mockup -->
                            <template v-if="key === 'modern'">
                                <span class="m-greeting">
                                    <span class="m-line m-line--sm"></span>
                                    <span class="m-line m-line--md"></span>
                                </span>
                                <span class="m-prayer-bar">
                                    <span
                                        class="m-dot"
                                        v-for="n in 5"
                                        :key="n"
                                    ></span>
                                </span>
                                <span class="m-ring-card">
                                    <span class="m-ring"></span>
                                    <span class="m-ring-lines">
                                        <span class="m-line m-line--sm"></span>
                                        <span class="m-line m-line--bar"></span>
                                    </span>
                                </span>
                                <span class="m-actions-grid">
                                    <span
                                        class="m-action"
                                        v-for="n in 6"
                                        :key="n"
                                    ></span>
                                </span>
                                <span class="m-feature-row">
                                    <span
                                        class="m-feature"
                                        v-for="n in 3"
                                        :key="n"
                                    ></span>
                                </span>
                                <span class="m-cta"></span>
                                <span class="m-navbar">
                                    <span
                                        class="m-nav-dot"
                                        v-for="n in 5"
                                        :key="n"
                                        :class="{
                                            'm-nav-dot--active': n === 1,
                                        }"
                                    ></span>
                                </span>
                            </template>

                            <!-- Classic mockup -->
                            <template v-else>
                                <span class="c-header">
                                    <span
                                        class="m-line m-line--sm c-line-light"
                                    ></span>
                                    <span
                                        class="m-line m-line--md c-line-light"
                                    ></span>
                                    <span class="c-dome"></span>
                                </span>
                                <span class="c-time-grid">
                                    <span
                                        class="c-time-card"
                                        v-for="n in 6"
                                        :key="n"
                                    ></span>
                                </span>
                                <span class="c-banner"></span>
                                <span class="c-actions-grid">
                                    <span
                                        class="c-action"
                                        v-for="n in 8"
                                        :key="n"
                                    ></span>
                                </span>
                                <span class="c-navbar"></span>
                            </template>
                        </span>

                        <span class="layout-info">
                            <span class="layout-name">{{ preset.name }}</span>
                            <span class="layout-desc">{{
                                preset.description
                            }}</span>
                        </span>

                        <span
                            v-if="formData.home_layout === key"
                            class="layout-check"
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
                    {{ $t("setting.home_layout.save_changes") }}
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
const layoutPresets = ref({});

const submit = () => {
    preloader.value = true;
    errors.value = {};
    Axios.post("home-layout", { home_layout: formData.value.home_layout })
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

const getLayoutPresets = () => {
    Axios.get("home-layout-presets").then(({ data }) => {
        layoutPresets.value = data;
    });
};

onMounted(() => {
    getServerData();
    getLayoutPresets();
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

.settings-card {
    background: var(--theme-card);
    border-radius: 14px;
    border: 1px solid var(--theme-border);
    padding: 26px 28px;
    margin-bottom: 18px;
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
    margin: 0 0 20px;
    line-height: 1.5;
}

/* ── Layout picker ── */
.layout-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 18px;
}
.layout-card {
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 14px;
    padding: 18px;
    background: var(--theme-muted-bg);
    border: 1.5px solid var(--theme-border);
    border-radius: 14px;
    cursor: pointer;
    font-family: "DM Sans", sans-serif;
    text-align: center;
    transition:
        border-color 0.18s,
        box-shadow 0.18s,
        background 0.18s;
}
.layout-card:hover {
    border-color: #b7c3d6;
}
.layout-card--active {
    border-color: var(--theme-secondary);
    background: var(--theme-card);
    box-shadow: 0 0 0 3px rgba(var(--theme-secondary-rgb), 0.11);
}
.layout-check {
    position: absolute;
    top: 12px;
    right: 12px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: var(--theme-secondary);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
}
.layout-info {
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.layout-name {
    font-size: 0.88rem;
    font-weight: 600;
    color: var(--theme-text);
}
.layout-desc {
    font-size: 0.74rem;
    color: var(--theme-text-faint);
    line-height: 1.4;
}

/* ── Mockup frame ── */
.layout-mockup {
    width: 150px;
    height: 280px;
    border-radius: 16px;
    border: 6px solid var(--theme-text);
    background: #fdfcf8;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12);
    padding: 8px 7px;
    gap: 5px;
}
.m-line {
    display: block;
    height: 5px;
    border-radius: 3px;
    background: #d7dce6;
}
.m-line--sm {
    width: 40%;
}
.m-line--md {
    width: 65%;
}
.m-line--bar {
    width: 100%;
    height: 4px;
    margin-top: 3px;
}

/* Modern mockup */
.layout-mockup--modern {
    background: linear-gradient(#eef1e6, #fdfcf8 40%);
}
.m-greeting {
    display: flex;
    flex-direction: column;
    gap: 4px;
    padding: 2px 2px 0;
}
.m-prayer-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: var(--theme-primary);
    border-radius: 8px;
    padding: 8px 6px;
}
.m-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.55);
}
.m-dot:nth-child(2) {
    background: var(--theme-card);
    width: 10px;
    height: 10px;
}
.m-ring-card {
    display: flex;
    align-items: center;
    gap: 8px;
    background: var(--theme-card);
    border: 1px solid var(--theme-border);
    border-radius: 8px;
    padding: 6px;
}
.m-ring {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    flex-shrink: 0;
    background: conic-gradient(
        var(--theme-primary) 0 60%,
        var(--theme-border) 0 100%
    );
    -webkit-mask: radial-gradient(
        farthest-side,
        transparent calc(100% - 5px),
        #000 calc(100% - 5px)
    );
    mask: radial-gradient(
        farthest-side,
        transparent calc(100% - 5px),
        #000 calc(100% - 5px)
    );
}
.m-ring-lines {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.m-actions-grid {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 3px;
}
.m-action {
    aspect-ratio: 1;
    border-radius: 4px;
    background: #eef1f6;
    border: 1px solid var(--theme-border);
}
.m-feature-row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 3px;
}
.m-feature {
    height: 20px;
    border-radius: 4px;
    background: #dfeee6;
}
.m-feature:nth-child(2) {
    background: #f6ecd8;
}
.m-feature:nth-child(3) {
    background: #e6ebf3;
}
.m-cta {
    flex: 1;
    min-height: 22px;
    border-radius: 6px;
    background: #141a2b;
}
.m-navbar {
    display: flex;
    justify-content: space-around;
    align-items: center;
    padding-top: 3px;
    border-top: 1px solid #eceff4;
}
.m-nav-dot {
    width: 5px;
    height: 5px;
    border-radius: 50%;
    background: #c7cedb;
}
.m-nav-dot--active {
    background: var(--theme-primary);
    width: 6px;
    height: 6px;
}

/* Classic mockup */
.layout-mockup--classic {
    background: #eef0f4;
    padding: 0;
}
.c-header {
    position: relative;
    background: #141a2b;
    border-radius: 0 0 12px 12px;
    padding: 10px 9px 14px;
    display: flex;
    flex-direction: column;
    gap: 5px;
    overflow: hidden;
}
.c-line-light {
    background: rgba(255, 255, 255, 0.35);
}
.c-dome {
    position: absolute;
    right: -6px;
    bottom: -10px;
    width: 34px;
    height: 34px;
    background: #d99a3d;
    border-radius: 50% 50% 0 0;
}
.c-time-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 4px;
    padding: 6px 7px 0;
}
.c-time-card {
    height: 16px;
    border-radius: 4px;
    background: var(--theme-card);
    border: 1px solid #e2e6ee;
}
.c-banner {
    margin: 5px 7px 0;
    height: 14px;
    border-radius: 4px;
    background: #1a1a1a;
    border: 1px solid #d9a441;
}
.c-actions-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 3px;
    padding: 6px 7px 0;
}
.c-action {
    aspect-ratio: 1;
    border-radius: 4px;
    background: var(--theme-card);
    border: 1px solid #e2e6ee;
}
.c-navbar {
    margin-top: auto;
    height: 16px;
    background: #141a2b;
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
