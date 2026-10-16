<template>
    <div class="installer-page">
        <div class="installer-wrapper">
            <div class="installer-header">
                <h1 class="installer-title">Application Installer</h1>
                <p class="installer-subtitle">
                    Follow the steps below to set up your application
                </p>
            </div>

            <StepIndicator :current-step="5" />

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
                                fill-rule="evenodd"
                                d="M14.763.075A.5.5 0 0 1 15 .5v15a.5.5 0 0 1-.5.5h-3a.5.5 0 0 1-.5-.5V14h-1v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V10a.5.5 0 0 1 .342-.474L6 7.64V4.5a.5.5 0 0 1 .276-.447l8-4a.5.5 0 0 1 .487.022zM6 8.694 1 10.36V15h5V8.694zM7 15h2v-1.5a.5.5 0 0 1 .5-.5h2a.5.5 0 0 1 .5.5V15h2V1.309l-7 3.5V15z"
                            />
                            <path
                                d="M2 11h1v1H2v-1zm2 0h1v1H4v-1zm-2 2h1v1H2v-1zm2 0h1v1H4v-1zm4-4h1v1H8V9zm2 0h1v1h-1V9zm-2 2h1v1H8v-1zm2 0h1v1h-1v-1zm2-2h1v1h-1V9zm0 2h1v1h-1v-1zM8 7h1v1H8V7zm2 0h1v1h-1V7zm2 0h1v1h-1V7zM8 5h1v1H8V5zm2 0h1v1h-1V5zm2 0h1v1h-1V5zm0-2h1v1h-1V3z"
                            />
                        </svg>
                    </div>
                    <div>
                        <h4 class="card-title">Company Information</h4>
                        <p class="card-desc">
                            Configure your organization's basic details
                        </p>
                    </div>
                </div>

                <div class="card-body">
                    <div class="form-group">
                        <label class="form-label"
                            >Company Name <span class="req">*</span></label
                        >
                        <input
                            type="text"
                            class="form-input"
                            :class="{ error: errors.company_name }"
                            placeholder="Your Company Name"
                            v-model="formData.company_name"
                        />
                        <small class="error-msg" v-if="errors.company_name">{{
                            errors.company_name[0]
                        }}</small>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Company Address</label>
                        <input
                            type="text"
                            class="form-input"
                            :class="{ error: errors.address }"
                            placeholder="123 Main St, City, Country"
                            v-model="formData.address"
                        />
                        <small class="error-msg" v-if="errors.address">{{
                            errors.address[0]
                        }}</small>
                    </div>

                    <div class="form-row">
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >Zakat Nisab <span class="req">*</span></label
                            >
                            <input
                                type="number"
                                class="form-input"
                                :class="{ error: errors.zakat_nisab }"
                                placeholder="e.g. 595"
                                v-model="formData.zakat_nisab"
                            />
                            <small
                                class="error-msg"
                                v-if="errors.zakat_nisab"
                                >{{ errors.zakat_nisab[0] }}</small
                            >
                        </div>
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >Currency Symbol
                                <span class="req">*</span></label
                            >
                            <input
                                type="text"
                                class="form-input"
                                :class="{ error: errors.currency_symbol }"
                                placeholder="e.g. $, €, £"
                                v-model="formData.currency_symbol"
                            />
                            <small
                                class="error-msg"
                                v-if="errors.currency_symbol"
                                >{{ errors.currency_symbol[0] }}</small
                            >
                        </div>
                    </div>
                </div>

                <div class="card-foot">
                    <button
                        type="button"
                        class="btn-main"
                        :disabled="preloader"
                        @click.prevent="submit"
                    >
                        <app-button-loader v-if="preloader" />
                        <span>Next</span>
                        <svg
                            v-if="!preloader"
                            xmlns="http://www.w3.org/2000/svg"
                            width="14"
                            height="14"
                            fill="currentColor"
                            viewBox="0 0 16 16"
                        >
                            <path
                                fill-rule="evenodd"
                                d="M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708z"
                            />
                        </svg>
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
import { toast } from "vue3-toastify";
import StepIndicator from "./StepIndicator.vue";

const formData = ref({});
const errors = ref({});
const preloader = ref(false);

const changeCompanyLogo = (file) => {
    formData.value.company_logo = file;
};
const changeCompanyIcon = (file) => {
    formData.value.company_icon = file;
};
const changeCompanyBanner = (file) => {
    formData.value.company_banner = file;
};

const submit = () => {
    preloader.value = true;
    Axios.post("company-store", formData.value)
        .then((response) => {
            toast.success(response.data.message);
            location.replace(urlGenerator("email-setup"));
        })
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
        })
        .finally(() => (preloader.value = false));
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
    max-width: 580px;
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
}
.form-input:focus {
    border-color: var(--theme-primary);
    background: var(--theme-card);
    box-shadow: 0 0 0 3px rgba(var(--theme-primary-rgb), 0.1);
}
.form-input.error {
    border-color: #ef4444;
}
.error-msg {
    display: block;
    margin-top: 5px;
    font-size: 0.8rem;
    color: #dc2626;
}
.btn-main {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 10px 22px;
    border: none;
    border-radius: 8px;
    font-size: 0.9rem;
    font-weight: 600;
    font-family: "DM Sans", sans-serif;
    cursor: pointer;
    background: var(--theme-primary);
    color: #fff;
    transition: all 0.2s ease;
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
@media (max-width: 480px) {
    .form-row {
        flex-direction: column;
        gap: 0;
    }
}
</style>
