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
                        <circle
                            cx="16"
                            cy="11"
                            r="5"
                            stroke="rgba(255,255,255,0.9)"
                            stroke-width="1.8"
                        />
                        <path
                            d="M6 27c0-5.523 4.477-10 10-10s10 4.477 10 10"
                            stroke="rgba(255,255,255,0.9)"
                            stroke-width="1.8"
                            stroke-linecap="round"
                        />
                        <circle
                            cx="25"
                            cy="9"
                            r="4"
                            fill="rgba(212,168,67,0.2)"
                            stroke="rgba(212,168,67,0.8)"
                            stroke-width="1.5"
                        />
                        <path
                            d="M23 9l1.5 1.5L27 7.5"
                            stroke="rgba(212,168,67,0.9)"
                            stroke-width="1.3"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        />
                    </svg>
                </div>
                <h2 class="acp-card__title">Join the team</h2>
                <p class="acp-card__sub">
                    Create your password to activate your account
                </p>
            </div>

            <!-- Card body -->
            <div class="acp-card__body">
                <!-- Password hint -->
                <div class="acp-hint">
                    <svg width="13" height="13" viewBox="0 0 16 16" fill="none">
                        <circle
                            cx="8"
                            cy="8"
                            r="7"
                            stroke="currentColor"
                            stroke-width="1.3"
                        />
                        <path
                            d="M8 5v4M8 11v.5"
                            stroke="currentColor"
                            stroke-width="1.5"
                            stroke-linecap="round"
                        />
                    </svg>
                    At least 8 characters with uppercase, lowercase, number
                    &amp; symbol
                </div>

                <!-- Password -->
                <div class="af-field">
                    <label class="af-label"
                        >Password <span class="af-req">*</span></label
                    >
                    <div
                        class="af-input-wrap"
                        :class="{ 'af-input-wrap--err': errors.password }"
                    >
                        <svg
                            class="af-ico"
                            width="16"
                            height="16"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <rect
                                x="3"
                                y="8"
                                width="14"
                                height="11"
                                rx="2"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />
                            <path
                                d="M7 8V6a3 3 0 016 0v2"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                            />
                        </svg>
                        <input
                            class="af-input af-input--pad-right"
                            :type="showPass ? 'text' : 'password'"
                            v-model="formData.password"
                            placeholder="Create a password"
                        />
                        <button
                            type="button"
                            class="af-eye"
                            @click="showPass = !showPass"
                            tabindex="-1"
                        >
                            <svg
                                v-if="!showPass"
                                width="16"
                                height="16"
                                viewBox="0 0 20 20"
                                fill="none"
                            >
                                <path
                                    d="M2 10s3-6 8-6 8 6 8 6-3 6-8 6-8-6-8-6z"
                                    stroke="currentColor"
                                    stroke-width="1.5"
                                />
                                <circle
                                    cx="10"
                                    cy="10"
                                    r="2.5"
                                    stroke="currentColor"
                                    stroke-width="1.5"
                                />
                            </svg>
                            <svg
                                v-else
                                width="16"
                                height="16"
                                viewBox="0 0 20 20"
                                fill="none"
                            >
                                <path
                                    d="M3 3l14 14M8.5 8.7A2.5 2.5 0 0011.3 11.5M6.1 6.3C4.4 7.3 3 9 3 10s3 6 7 6c1.5 0 2.9-.5 4-1.3M10 4c4 0 7 5.5 7 6 0 .4-.3 1-.7 1.6"
                                    stroke="currentColor"
                                    stroke-width="1.5"
                                    stroke-linecap="round"
                                />
                            </svg>
                        </button>
                    </div>
                    <small class="af-err" v-if="errors.password">{{
                        errors.password[0]
                    }}</small>
                </div>

                <!-- Confirm password -->
                <div class="af-field">
                    <label class="af-label"
                        >Confirm password <span class="af-req">*</span></label
                    >
                    <div
                        class="af-input-wrap"
                        :class="{
                            'af-input-wrap--err': errors.confirm_password,
                        }"
                    >
                        <svg
                            class="af-ico"
                            width="16"
                            height="16"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <rect
                                x="3"
                                y="8"
                                width="14"
                                height="11"
                                rx="2"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />
                            <path
                                d="M7 8V6a3 3 0 016 0v2"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                            />
                        </svg>
                        <input
                            class="af-input af-input--pad-right"
                            :type="showConfirm ? 'text' : 'password'"
                            v-model="formData.confirm_password"
                            placeholder="Re-enter your password"
                        />
                        <button
                            type="button"
                            class="af-eye"
                            @click="showConfirm = !showConfirm"
                            tabindex="-1"
                        >
                            <svg
                                v-if="!showConfirm"
                                width="16"
                                height="16"
                                viewBox="0 0 20 20"
                                fill="none"
                            >
                                <path
                                    d="M2 10s3-6 8-6 8 6 8 6-3 6-8 6-8-6-8-6z"
                                    stroke="currentColor"
                                    stroke-width="1.5"
                                />
                                <circle
                                    cx="10"
                                    cy="10"
                                    r="2.5"
                                    stroke="currentColor"
                                    stroke-width="1.5"
                                />
                            </svg>
                            <svg
                                v-else
                                width="16"
                                height="16"
                                viewBox="0 0 20 20"
                                fill="none"
                            >
                                <path
                                    d="M3 3l14 14M8.5 8.7A2.5 2.5 0 0011.3 11.5M6.1 6.3C4.4 7.3 3 9 3 10s3 6 7 6c1.5 0 2.9-.5 4-1.3M10 4c4 0 7 5.5 7 6 0 .4-.3 1-.7 1.6"
                                    stroke="currentColor"
                                    stroke-width="1.5"
                                    stroke-linecap="round"
                                />
                            </svg>
                        </button>
                    </div>
                    <small class="af-err" v-if="errors.confirm_password">{{
                        errors.confirm_password[0]
                    }}</small>
                </div>

                <button
                    class="af-btn"
                    @click.prevent="submit"
                    :disabled="preloader"
                >
                    <app-button-loader v-if="preloader" />
                    <span v-else>Activate account</span>
                </button>
            </div>
        </div>

        <div class="acp-footer"><app-auth-footer /></div>
    </div>
</template>

<script setup>
import { ref } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";

const props = defineProps({ user: { required: true } });
const errors = ref({});
const preloader = ref(false);
const showPass = ref(false);
const showConfirm = ref(false);
const formData = ref({});

const submit = () => {
    preloader.value = true;
    errors.value = {};
    const parsed = JSON.parse(props.user);
    formData.value.invitation_token = parsed.invitation_token;
    formData.value.email = parsed.email;
    Axios.post("join/user", formData.value)
        .then((response) => {
            toast.success(response.data.message);
            window.location.href = "/login";
        })
        .catch(({ response }) => {
            if (response.status === 422) {
                errors.value = response.data.errors;
                if (response.data.message) toast.error(response.data.message);
            } else {
                toast.error(response.data.message);
            }
        })
        .finally(() => (preloader.value = false));
};
</script>

<style scoped>
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

.acp-card__body {
    padding: 1.75rem 2rem 2rem;
}

.acp-hint {
    display: flex;
    align-items: flex-start;
    gap: 0.5rem;
    background: #f0faf5;
    border: 1px solid rgba(26, 92, 56, 0.15);
    border-radius: 9px;
    padding: 0.65rem 0.85rem;
    font-size: 0.75rem;
    color: #3d6b52;
    margin-bottom: 1.1rem;
    line-height: 1.45;
}
.acp-hint svg {
    flex-shrink: 0;
    margin-top: 1px;
    color: #1a5c38;
}

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
.af-input--pad-right {
    padding-right: 2.5rem;
}
.af-input-wrap--err .af-input {
    border-color: #e74c3c;
}
.af-input-wrap--err .af-input:focus {
    box-shadow: 0 0 0 3px rgba(231, 76, 60, 0.1);
}

.af-eye {
    position: absolute;
    right: 0.75rem;
    background: none;
    border: none;
    padding: 0;
    cursor: pointer;
    color: #9cb8ac;
    display: flex;
    align-items: center;
    transition: color 0.15s;
}
.af-eye:hover {
    color: #1a5c38;
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
