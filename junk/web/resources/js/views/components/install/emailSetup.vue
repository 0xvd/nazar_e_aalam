<template>
    <div class="installer-page">
        <div class="installer-wrapper">
            <div class="installer-header">
                <h1 class="installer-title">Application Installer</h1>
                <p class="installer-subtitle">
                    Follow the steps below to set up your application
                </p>
            </div>

            <StepIndicator :current-step="6" />

            <div class="installer-card">
                <div class="card-head">
                    <div class="step-icon">
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="22"
                            height="22"
                            fill="currentColor"
                            viewBox="0 0 16 16"
                        >
                            <path
                                d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V4Zm2-1a1 1 0 0 0-1 1v.217l7 4.2 7-4.2V4a1 1 0 0 0-1-1H2Zm13 2.383-4.708 2.825L15 11.105V5.383Zm-.034 6.876-5.64-3.471L8 9.583l-1.326-.795-5.64 3.47A1 1 0 0 0 2 13h12a1 1 0 0 0 .966-.741ZM1 11.105l4.708-2.897L1 5.383v5.722Z"
                            />
                        </svg>
                    </div>
                    <div>
                        <h4 class="card-title">Email Configuration</h4>
                        <p class="card-desc">
                            Set up outgoing email — you can skip this and
                            configure it later
                        </p>
                    </div>
                </div>

                <div class="card-body">
                    <div class="form-group">
                        <label class="form-label"
                            >Provider <span class="req">*</span></label
                        >
                        <select
                            class="form-input form-select"
                            v-model="formData.provider"
                        >
                            <option value="smtp">SMTP</option>
                        </select>
                        <small class="error-msg" v-if="errors.provider">{{
                            errors.provider[0]
                        }}</small>
                    </div>

                    <div class="form-row">
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >From Name <span class="req">*</span></label
                            >
                            <input
                                type="text"
                                class="form-input"
                                :class="{ error: errors.from_name }"
                                placeholder="Your App Name"
                                v-model="formData.from_name"
                            />
                            <small class="error-msg" v-if="errors.from_name">{{
                                errors.from_name[0]
                            }}</small>
                        </div>
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >From Email <span class="req">*</span></label
                            >
                            <input
                                type="email"
                                class="form-input"
                                :class="{ error: errors.from_email }"
                                placeholder="no-reply@example.com"
                                v-model="formData.from_email"
                            />
                            <small class="error-msg" v-if="errors.from_email">{{
                                errors.from_email[0]
                            }}</small>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >SMTP Host <span class="req">*</span></label
                            >
                            <input
                                type="text"
                                class="form-input"
                                :class="{ error: errors.smtp_host }"
                                placeholder="smtp.example.com"
                                v-model="formData.smtp_host"
                            />
                            <small class="error-msg" v-if="errors.smtp_host">{{
                                errors.smtp_host[0]
                            }}</small>
                        </div>
                        <div class="form-group flex-sm">
                            <label class="form-label"
                                >Port <span class="req">*</span></label
                            >
                            <input
                                type="text"
                                class="form-input"
                                :class="{ error: errors.smtp_port }"
                                placeholder="587"
                                v-model="formData.smtp_port"
                            />
                            <small class="error-msg" v-if="errors.smtp_port">{{
                                errors.smtp_port[0]
                            }}</small>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >SMTP Username <span class="req">*</span></label
                            >
                            <input
                                type="text"
                                class="form-input"
                                :class="{ error: errors.smtp_username }"
                                placeholder="smtp_username"
                                v-model="formData.smtp_username"
                            />
                            <small
                                class="error-msg"
                                v-if="errors.smtp_username"
                                >{{ errors.smtp_username[0] }}</small
                            >
                        </div>
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >Email Password
                                <span class="req">*</span></label
                            >
                            <input
                                type="password"
                                class="form-input"
                                :class="{ error: errors.email_password }"
                                placeholder="••••••••"
                                v-model="formData.email_password"
                            />
                            <small
                                class="error-msg"
                                v-if="errors.email_password"
                                >{{ errors.email_password[0] }}</small
                            >
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label"
                            >Encryption Type <span class="req">*</span></label
                        >
                        <input
                            type="text"
                            class="form-input"
                            :class="{ error: errors.encryption_type }"
                            placeholder="tls"
                            v-model="formData.encryption_type"
                        />
                        <small
                            class="error-msg"
                            v-if="errors.encryption_type"
                            >{{ errors.encryption_type[0] }}</small
                        >
                    </div>
                </div>

                <div class="card-foot">
                    <button
                        type="button"
                        class="btn-ghost"
                        :disabled="skipLoader"
                        @click.prevent="skip"
                    >
                        <app-button-loader v-if="skipLoader" />
                        <span>Skip for now</span>
                    </button>
                    <button
                        type="button"
                        class="btn-main"
                        :disabled="preloader"
                        @click.prevent="submit"
                    >
                        <app-button-loader v-if="preloader" />
                        <svg
                            v-if="!preloader"
                            xmlns="http://www.w3.org/2000/svg"
                            width="14"
                            height="14"
                            fill="currentColor"
                            viewBox="0 0 16 16"
                        >
                            <path
                                d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z"
                            />
                        </svg>
                        <span>Finish Setup</span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref } from "vue";
import Axios from "@/services/axios/index.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import StepIndicator from "./StepIndicator.vue";

const formData = ref({ provider: "smtp" });
const errors = ref({});
const preloader = ref(false);
const skipLoader = ref(false);

const submit = () => {
    preloader.value = true;
    Axios.post("email-store", formData.value)
        .then(() => {
            location.replace(urlGenerator("/login"));
        })
        .catch(({ response }) => {
            if (response.status === 422) errors.value = response.data.errors;
        })
        .finally(() => (preloader.value = false));
};

const skip = () => {
    skipLoader.value = true;
    Axios.post("setup-skip", formData.value)
        .then(() => {
            location.replace(urlGenerator("/login"));
        })
        .catch(({ response }) => {
            if (response.status === 422) errors.value = response.data.errors;
        })
        .finally(() => (skipLoader.value = false));
};
</script>

<style scoped>
.installer-page {
    min-height: 100vh;
    background: var(--theme-muted-bg);
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding: 40px 16px 60px;
    font-family: "DM Sans", sans-serif;
}
.installer-wrapper {
    width: 100%;
    max-width: 600px;
}
.installer-header {
    text-align: center;
    margin-bottom: 2rem;
}
.installer-title {
    font-size: 1.75rem;
    font-weight: 700;
    color: var(--theme-text);
    margin: 0 0 4px;
}
.installer-subtitle {
    color: #6c757d;
    font-size: 0.95rem;
    margin: 0;
}
.installer-card {
    background: var(--theme-card);
    border-radius: 12px;
    box-shadow:
        0 1px 3px rgba(0, 0, 0, 0.06),
        0 4px 16px rgba(0, 0, 0, 0.04);
    overflow: hidden;
}
.card-head {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 22px 28px;
    border-bottom: 1px solid #f3f4f6;
    background: #fafafa;
}
.step-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    background: #e6f5ef;
    color: var(--theme-primary);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.card-title {
    font-size: 1rem;
    font-weight: 700;
    color: #111827;
    margin: 0 0 2px;
}
.card-desc {
    font-size: 0.83rem;
    color: #6b7280;
    margin: 0;
}
.card-body {
    padding: 28px;
}
.card-foot {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 12px;
    padding: 18px 28px;
    border-top: 1px solid #f3f4f6;
    background: #fafafa;
}
.form-group {
    margin-bottom: 18px;
}
.form-row {
    display: flex;
    gap: 16px;
}
.flex-1 {
    flex: 1;
}
.flex-sm {
    flex: 0 0 110px;
}
.form-label {
    display: block;
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
    margin-bottom: 6px;
}
.req {
    color: #ef4444;
}
.form-input {
    width: 100%;
    height: 44px;
    padding: 0 14px;
    font-size: 0.9rem;
    font-family: "DM Sans", sans-serif;
    color: var(--theme-text);
    background: var(--theme-muted-bg);
    border: 1.5px solid var(--theme-border);
    border-radius: 8px;
    outline: none;
    transition:
        border-color 0.18s,
        background 0.18s,
        box-shadow 0.18s;
    box-sizing: border-box;
    appearance: none;
}
.form-input:focus {
    border-color: var(--theme-primary);
    background: var(--theme-card);
    box-shadow: 0 0 0 3px rgba(var(--theme-primary-rgb), 0.1);
}
.form-input.error {
    border-color: #ef4444;
}
.form-select {
    background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
    background-repeat: no-repeat;
    background-position: right 12px center;
    background-size: 16px;
    padding-right: 36px;
    cursor: pointer;
}
.error-msg {
    display: block;
    margin-top: 5px;
    font-size: 0.8rem;
    color: #dc2626;
}
.btn-main,
.btn-ghost {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 10px 22px;
    border-radius: 8px;
    font-size: 0.9rem;
    font-weight: 600;
    font-family: "DM Sans", sans-serif;
    cursor: pointer;
    transition: all 0.2s ease;
    border: none;
}
.btn-main {
    background: var(--theme-primary);
    color: #fff;
}
.btn-main:hover:not(:disabled) {
    background: var(--theme-secondary);
    transform: translateY(-1px);
    box-shadow: 0 4px 14px rgba(var(--theme-primary-rgb), 0.28);
}
.btn-main:disabled {
    opacity: 0.65;
    cursor: not-allowed;
}
.btn-ghost {
    background: transparent;
    color: #6b7280;
    border: 1.5px solid var(--theme-border);
}
.btn-ghost:hover:not(:disabled) {
    background: var(--theme-muted-bg);
    color: #374151;
}
.btn-ghost:disabled {
    opacity: 0.65;
    cursor: not-allowed;
}
@media (max-width: 480px) {
    .form-row {
        flex-direction: column;
        gap: 0;
    }
    .flex-sm {
        flex: 1;
    }
}
</style>
