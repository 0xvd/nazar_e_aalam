<template>
    <div class="installer-page">
        <div class="installer-wrapper">
            <div class="installer-header">
                <h1 class="installer-title">Application Installer</h1>
                <p class="installer-subtitle">
                    Follow the steps below to set up your application
                </p>
            </div>

            <StepIndicator :current-step="3" />

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
                                d="M6 4.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm-1 0a.5.5 0 1 0-1 0 .5.5 0 0 0 1 0z"
                            />
                            <path
                                d="M2 1h12a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2zm12 1H2a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1zM2 8h12a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2a2 2 0 0 1 2-2zm12 1H2a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1z"
                            />
                        </svg>
                    </div>
                    <div>
                        <h4 class="card-title">Database Configuration</h4>
                        <p class="card-desc">
                            Connect your application to a database
                        </p>
                    </div>
                </div>

                <div class="card-body">
                    <div class="form-group">
                        <label class="form-label"
                            >Database Driver <span class="req">*</span></label
                        >
                        <select
                            class="form-input form-select"
                            v-model="formData.database_connection"
                        >
                            <option
                                v-for="db in databaseProviderList"
                                :key="db.id"
                                :value="db.id"
                            >
                                {{ db.name }}
                            </option>
                        </select>
                        <small
                            class="error-msg"
                            v-if="errors.database_connection"
                            >{{ errors.database_connection[0] }}</small
                        >
                    </div>

                    <div class="form-row">
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >Hostname <span class="req">*</span></label
                            >
                            <input
                                type="text"
                                class="form-input"
                                :class="{ error: errors.database_hostname }"
                                placeholder="localhost"
                                v-model="formData.database_hostname"
                            />
                            <small
                                class="error-msg"
                                v-if="errors.database_hostname"
                                >{{ errors.database_hostname[0] }}</small
                            >
                        </div>
                        <div class="form-group flex-sm">
                            <label class="form-label"
                                >Port <span class="req">*</span></label
                            >
                            <input
                                type="text"
                                class="form-input"
                                :class="{ error: errors.database_port }"
                                placeholder="3306"
                                v-model="formData.database_port"
                            />
                            <small
                                class="error-msg"
                                v-if="errors.database_port"
                                >{{ errors.database_port[0] }}</small
                            >
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label"
                            >Database Name <span class="req">*</span></label
                        >
                        <input
                            type="text"
                            class="form-input"
                            :class="{ error: errors.database_name }"
                            placeholder="Your Database Name"
                            v-model="formData.database_name"
                        />
                        <small class="error-msg" v-if="errors.database_name">{{
                            errors.database_name[0]
                        }}</small>
                    </div>

                    <div class="form-row">
                        <div class="form-group flex-1">
                            <label class="form-label"
                                >Username <span class="req">*</span></label
                            >
                            <input
                                type="text"
                                class="form-input"
                                :class="{ error: errors.database_username }"
                                placeholder="db_user"
                                v-model="formData.database_username"
                            />
                            <small
                                class="error-msg"
                                v-if="errors.database_username"
                                >{{ errors.database_username[0] }}</small
                            >
                        </div>
                        <div class="form-group flex-1">
                            <label class="form-label">Password</label>
                            <input
                                type="password"
                                class="form-input"
                                :class="{ error: errors.database_password }"
                                placeholder="••••••••"
                                v-model="formData.database_password"
                            />
                            <small
                                class="error-msg"
                                v-if="errors.database_password"
                                >{{ errors.database_password[0] }}</small
                            >
                        </div>
                    </div>

                    <div class="hint-box">
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="14"
                            height="14"
                            fill="currentColor"
                            viewBox="0 0 16 16"
                        >
                            <path
                                d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"
                            />
                        </svg>
                        Database name, username, and password must not contain
                        <code>#</code> or whitespace.
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
import mainAppFunction from "@/utilities/appFunction.js";
import Axios from "@/services/axios/index.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { toast } from "vue3-toastify";
import StepIndicator from "./StepIndicator.vue";

const formData = ref({
    database_connection: "mysql",
    database_hostname: "localhost",
    database_port: "3306",
    database_username: "",
    database_password: "",
});
const errors = ref({});
const databaseProviderList = ref([
    { id: "mysql", name: "MySQL" },
    { id: "sqlite", name: "SQLite" },
    { id: "pgsql", name: "PostgreSQL" },
]);
const preloader = ref(false);

const submit = () => {
    const purchaseCode = new URLSearchParams(window.location.search).get(
        "purchase_code",
    );
    const data = {
        ...formData.value,
        app_url: mainAppFunction.baseUrl(),
        purchase_code: purchaseCode,
    };
    preloader.value = true;
    errors.value = {};
    Axios.post(`connect-database`, data)
        .then((response) => {
            toast.success(response.data.message);
            location.replace(urlGenerator("user-information"));
        })
        .catch(({ response }) => {
            if (response.status === 422) errors.value = response.data.errors;
            else {
                errors.value = {};
                toast.error(response.data.message);
            }
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
.hint-box {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    background: #f0faf4;
    border: 1px solid #a7d7bc;
    border-radius: 8px;
    padding: 10px 14px;
    font-size: 0.82rem;
    color: #1a3d2e;
    margin-top: 4px;
}
.hint-box svg {
    flex-shrink: 0;
    margin-top: 1px;
    color: var(--theme-primary);
}
.hint-box code {
    background: #e6f5ef;
    padding: 1px 5px;
    border-radius: 4px;
    font-size: 0.8rem;
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
    .flex-sm {
        flex: 1;
    }
}
</style>
