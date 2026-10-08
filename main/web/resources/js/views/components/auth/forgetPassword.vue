<template>
    <div class="acp-page">
        <div class="acp-page__pattern"></div>

        <div class="acp-card">
            <!-- Card header -->
            <div class="acp-card__header">
                <div class="acp-card__bismillah">
                    بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ
                </div>
                <div class="acp-card__logo"><app-logo /></div>
                <div class="acp-card__icon-wrap">
                    <svg width="28" height="28" viewBox="0 0 32 32" fill="none">
                        <rect
                            x="4"
                            y="14"
                            width="24"
                            height="18"
                            rx="3"
                            stroke="rgba(255,255,255,0.9)"
                            stroke-width="1.8"
                        />
                        <path
                            d="M10 14V10a6 6 0 0112 0v4"
                            stroke="rgba(255,255,255,0.9)"
                            stroke-width="1.8"
                            stroke-linecap="round"
                        />
                        <circle
                            cx="16"
                            cy="23"
                            r="2.5"
                            fill="rgba(212,168,67,0.9)"
                        />
                        <line
                            x1="16"
                            y1="25.5"
                            x2="16"
                            y2="28"
                            stroke="rgba(212,168,67,0.7)"
                            stroke-width="1.5"
                            stroke-linecap="round"
                        />
                    </svg>
                </div>
                <h2 class="acp-card__title">Forgot password?</h2>
                <p class="acp-card__sub">
                    Enter your email and we'll send you a reset link
                </p>
            </div>

            <!-- Card body -->
            <div class="acp-card__body">
                <div class="af-field">
                    <label class="af-label"
                        >Email address <span class="af-req">*</span></label
                    >
                    <div
                        class="af-input-wrap"
                        :class="{ 'af-input-wrap--err': errors.email }"
                    >
                        <svg
                            class="af-ico"
                            width="16"
                            height="16"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <path
                                d="M2 5a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V5z"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />
                            <path
                                d="M2 6l8 5 8-5"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                            />
                        </svg>
                        <input
                            class="af-input"
                            type="email"
                            v-model="formData.email"
                            placeholder="you@example.com"
                            autocomplete="email"
                        />
                    </div>
                    <small class="af-err" v-if="errors.email">{{
                        errors.email[0]
                    }}</small>
                </div>

                <button
                    class="af-btn"
                    @click.prevent="submit"
                    :disabled="preloader"
                >
                    <app-button-loader v-if="preloader" />
                    <span v-else>Send reset link</span>
                </button>

                <div class="acp-back">
                    <a href="login" class="acp-back__link">
                        <svg
                            width="14"
                            height="14"
                            viewBox="0 0 16 16"
                            fill="none"
                        >
                            <path
                                d="M10 3L5 8l5 5"
                                stroke="currentColor"
                                stroke-width="1.8"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            />
                        </svg>
                        Back to Sign in
                    </a>
                </div>
            </div>
        </div>

        <div class="acp-footer"><app-auth-footer /></div>
    </div>
</template>

<script setup>
import { ref } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";

const errors = ref({});
const preloader = ref(false);
const formData = ref({});

const submit = () => {
    preloader.value = true;
    errors.value = {};
    Axios.post("forget-password", formData.value)
        .then((response) => {
            toast.success(response.data.message);
            formData.value.email = "";
        })
        .catch(({ response }) => {
            if (response.status === 422) errors.value = response.data.errors;
            else toast.error(response.data.message);
        })
        .finally(() => (preloader.value = false));
};
</script>

<style scoped>
/* ── Page ────────────────────────────────────────────────── */
.acp-page {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 2rem 1rem;
    background: linear-gradient(150deg, #062416 0%, #0d3a22 45%, #1a5c38 100%);
    position: relative;
    overflow: hidden;
}

.acp-page__pattern {
    position: absolute;
    inset: 0;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='70' height='70' viewBox='0 0 70 70'%3E%3Cg fill='none' stroke='%23ffffff04' stroke-width='1'%3E%3Cpath d='M35 0 L70 35 L35 70 L0 35 Z'/%3E%3Ccircle cx='35' cy='35' r='18'/%3E%3C/g%3E%3C/svg%3E");
    pointer-events: none;
}

/* ── Card ────────────────────────────────────────────────── */
.acp-card {
    position: relative;
    z-index: 1;
    width: 100%;
    max-width: 420px;
    border-radius: 20px;
    overflow: hidden;
    background: var(--theme-card);
    box-shadow:
        0 24px 64px rgba(0, 0, 0, 0.32),
        0 4px 16px rgba(0, 0, 0, 0.15);
}

/* Header band */
.acp-card__header {
    background: linear-gradient(130deg, #072417 0%, #0d3a22 45%, #1a5c38 100%);
    padding: 1.75rem 2rem 1.5rem;
    text-align: center;
    position: relative;
}

.acp-card__header::after {
    content: "";
    position: absolute;
    bottom: 0;
    left: 15%;
    right: 15%;
    height: 1px;
    background: linear-gradient(
        90deg,
        transparent,
        rgba(var(--theme-accent-rgb), 0.45),
        transparent
    );
}

.acp-card__bismillah {
    font-family: "Amiri", "Times New Roman", serif;
    font-size: 0.95rem;
    color: rgba(var(--theme-accent-rgb), 0.8);
    margin-bottom: 0.75rem;
    letter-spacing: 0.03em;
}

.acp-card__logo {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 1rem;
}

.acp-card__logo :deep(img) {
    max-height: 2.4rem;
    width: auto;
    filter: brightness(1.1) drop-shadow(0 2px 6px rgba(0, 0, 0, 0.3));
}

.acp-card__icon-wrap {
    width: 56px;
    height: 56px;
    border-radius: 16px;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.15);
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 0.85rem;
}

.acp-card__title {
    font-size: 1.15rem;
    font-weight: 800;
    color: #fff;
    margin: 0 0 0.3rem;
}

.acp-card__sub {
    font-size: 0.8rem;
    color: rgba(255, 255, 255, 0.55);
    margin: 0;
}

/* Body */
.acp-card__body {
    padding: 1.75rem 2rem 2rem;
}

/* Shared field styles */
.af-field {
    margin-bottom: 1.1rem;
}

.af-label {
    display: block;
    font-size: 0.78rem;
    font-weight: 600;
    color: #4b5f55;
    margin-bottom: 0.4rem;
}

.af-req {
    color: #c0392b;
}

.af-input-wrap {
    position: relative;
    display: flex;
    align-items: center;
}

.af-ico {
    position: absolute;
    left: 0.75rem;
    color: #9cb8ac;
    pointer-events: none;
}

.af-input-wrap .af-input {
    padding-left: 2.5rem;
}

.af-input {
    width: 100%;
    padding: 0.7rem 0.9rem;
    border: 1.5px solid rgba(26, 92, 56, 0.18);
    border-radius: 10px;
    font-size: 0.875rem;
    color: #1c2b24;
    background: var(--theme-card);
    outline: none;
    transition:
        border-color 0.15s,
        box-shadow 0.15s;
    font-family: inherit;
    appearance: none;
}

.af-input:focus {
    border-color: #1a5c38;
    box-shadow: 0 0 0 3px rgba(26, 92, 56, 0.1);
}

.af-input-wrap--err .af-input {
    border-color: #e74c3c;
}
.af-input-wrap--err .af-input:focus {
    box-shadow: 0 0 0 3px rgba(231, 76, 60, 0.1);
}

.af-err {
    display: block;
    margin-top: 0.3rem;
    font-size: 0.75rem;
    color: #c0392b;
}

.af-btn {
    width: 100%;
    padding: 0.78rem;
    border: none;
    border-radius: 10px;
    background: linear-gradient(135deg, #1a5c38, #0d3a22);
    color: #fff;
    font-size: 0.9rem;
    font-weight: 700;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    box-shadow: 0 4px 16px rgba(10, 46, 30, 0.3);
    transition:
        opacity 0.18s,
        transform 0.18s,
        box-shadow 0.18s;
    font-family: inherit;
    margin-top: 0.25rem;
}
.af-btn:hover:not(:disabled) {
    opacity: 0.92;
    transform: translateY(-1px);
    box-shadow: 0 6px 22px rgba(10, 46, 30, 0.38);
}
.af-btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
}

.acp-back {
    text-align: center;
    margin-top: 1.2rem;
}

.acp-back__link {
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
    font-size: 0.8rem;
    font-weight: 600;
    color: #6b8c7a;
    text-decoration: none;
    transition: color 0.15s;
}
.acp-back__link:hover {
    color: #1a5c38;
}

/* Footer */
.acp-footer {
    position: relative;
    z-index: 1;
    margin-top: 1rem;
}
.acp-footer :deep(.copyright) {
    color: rgba(255, 255, 255, 0.35);
}
.acp-footer :deep(.link) {
    color: rgba(255, 255, 255, 0.4);
}
.acp-footer :deep(.link:hover) {
    color: rgba(var(--theme-accent-rgb), 0.85);
}
.acp-footer :deep(.separator) {
    color: rgba(255, 255, 255, 0.15);
}
</style>
