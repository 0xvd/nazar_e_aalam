<template>
    <div class="installer-page">
        <div class="installer-wrapper">
            <div class="installer-header">
                <h1 class="installer-title">Application Installer</h1>
                <p class="installer-subtitle">
                    Follow the steps below to set up your application
                </p>
            </div>

            <StepIndicator :current-step="2" />

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
                                d="M0 8a4 4 0 0 1 7.465-2H14a.5.5 0 0 1 .354.146l1.5 1.5a.5.5 0 0 1 0 .708l-1.5 1.5a.5.5 0 0 1-.708 0L13 9.207l-.646.647a.5.5 0 0 1-.708 0L11 9.207l-.646.647a.5.5 0 0 1-.708 0L9 9.207l-.646.647A.5.5 0 0 1 8 10h-.535A4 4 0 0 1 0 8zm4-3a3 3 0 1 0 2.712 4.285A.5.5 0 0 1 7.163 9h.63l.853-.854a.5.5 0 0 1 .708 0l.646.647.646-.647a.5.5 0 0 1 .708 0l.646.647.646-.647a.5.5 0 0 1 .708 0l.646.647.793-.793-1-1h-6.63a.5.5 0 0 1-.451-.285A3 3 0 0 0 4 5z"
                            />
                            <path d="M4 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0z" />
                        </svg>
                    </div>
                    <div>
                        <h4 class="card-title">Purchase Code</h4>
                        <p class="card-desc">
                            Enter your Envato purchase code to verify your
                            license
                        </p>
                    </div>
                </div>

                <div class="card-body">
                    <div class="form-group">
                        <label class="form-label"
                            >Purchase Code <span class="req">*</span></label
                        >
                        <input
                            type="text"
                            class="form-input"
                            :class="{ error: errors.purchase_code }"
                            placeholder="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
                            v-model="formData.purchase_code"
                        />
                        <small class="error-msg" v-if="errors.purchase_code">{{
                            errors.purchase_code[0]
                        }}</small>
                    </div>
                </div>

                <div class="card-foot">
                    <a :href="urlGenerator('install')" class="btn-ghost">
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="14"
                            height="14"
                            fill="currentColor"
                            viewBox="0 0 16 16"
                        >
                            <path
                                fill-rule="evenodd"
                                d="M11.354 1.646a.5.5 0 0 1 0 .708L5.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0z"
                            />
                        </svg>
                        Go Back
                    </a>
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

const formData = ref({ purchase_code: "" });
const errors = ref({});
const preloader = ref(false);

const submit = () => {
    delete axios.defaults.headers.common["X-Requested-With"];
    delete axios.defaults.headers.common["X-CSRF-TOKEN"];
    preloader.value = true;

    Axios.post("purchase-key", formData.value)
        .then((response) => {
            if (response?.data.message === "success") {
                preloader.value = true;
                axios
                    .get(response?.data.url)
                    .then((res) => {
                        if (res?.data?.message === "verified") {
                            toast.success(
                                "Purchase code verified successfully",
                            );
                            location.replace(
                                urlGenerator(
                                    `environment-setup?purchase_code=${formData.value.purchase_code}`,
                                ),
                            );
                        }
                    })
                    .catch(({ response }) => {
                        if (response?.status === 422)
                            errors.value = response?.data?.errors;
                        else toast.error(response?.data?.message);
                    })
                    .finally(() => (preloader.value = false));
            }
            errors.value = {};
        })
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
            preloader.value = false;
        });
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
    margin-bottom: 0;
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
    text-decoration: none;
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
.btn-ghost:hover {
    background: var(--theme-muted-bg);
    color: #374151;
}
</style>
