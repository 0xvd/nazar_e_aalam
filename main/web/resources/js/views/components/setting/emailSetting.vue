<template>
    <app-loader v-if="preloader" />
    <div v-else class="settings-wrapper">
        <form @submit.prevent="submit" class="settings-form">
            <!-- Section: Sender Identity -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.email.sender_identity.title") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label" for="provider">
                            {{
                                $t(
                                    "setting.email.sender_identity.provider_label",
                                )
                            }}
                            <span class="required">*</span>
                        </label>
                        <div class="select-wrapper">
                            <select
                                class="field-input field-select"
                                id="provider"
                                v-model="formData.provider"
                            >
                                <option value="smtp">SMTP</option>
                            </select>
                            <span class="select-chevron">
                                <svg
                                    width="14"
                                    height="14"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2.5"
                                >
                                    <polyline points="6 9 12 15 18 9" />
                                </svg>
                            </span>
                        </div>
                        <small class="field-error" v-if="errors.provider">{{
                            errors.provider[0]
                        }}</small>
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="form_name">
                            {{
                                $t(
                                    "setting.email.sender_identity.from_name_label",
                                )
                            }}
                            <span class="required">*</span>
                        </label>
                        <input
                            type="text"
                            class="field-input"
                            id="form_name"
                            :placeholder="
                                $t(
                                    'setting.email.sender_identity.from_name_placeholder',
                                )
                            "
                            v-model="formData.from_name"
                        />
                        <small class="field-error" v-if="errors.from_name">{{
                            errors.from_name[0]
                        }}</small>
                    </div>

                    <div class="field-group field-group--full">
                        <label class="field-label" for="form_email">
                            {{
                                $t(
                                    "setting.email.sender_identity.from_email_label",
                                )
                            }}
                            <span class="required">*</span>
                        </label>
                        <input
                            type="email"
                            class="field-input"
                            id="form_email"
                            :placeholder="
                                $t(
                                    'setting.email.sender_identity.from_email_placeholder',
                                )
                            "
                            v-model="formData.from_email"
                        />
                        <small class="field-error" v-if="errors.from_email">{{
                            errors.from_email[0]
                        }}</small>
                    </div>
                </div>
            </div>

            <!-- Section: SMTP Server -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.email.smtp_server.title") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group field-group--full">
                        <label class="field-label" for="smtp_host">
                            {{
                                $t("setting.email.smtp_server.smtp_host_label")
                            }}
                            <span class="required">*</span>
                        </label>
                        <input
                            type="text"
                            class="field-input"
                            id="smtp_host"
                            placeholder="e.g. smtp.gmail.com"
                            v-model="formData.smtp_host"
                        />
                        <small class="field-error" v-if="errors.smtp_host">{{
                            errors.smtp_host[0]
                        }}</small>
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="smtp_port">
                            {{
                                $t("setting.email.smtp_server.smtp_port_label")
                            }}
                            <span class="required">*</span>
                        </label>
                        <input
                            type="number"
                            class="field-input"
                            id="smtp_port"
                            placeholder="e.g. 587"
                            v-model="formData.smtp_port"
                        />
                        <small class="field-error" v-if="errors.smtp_port">{{
                            errors.smtp_port[0]
                        }}</small>
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="encryption_type">
                            {{
                                $t(
                                    "setting.email.smtp_server.encryption_type_label",
                                )
                            }}
                            <span class="required">*</span>
                        </label>
                        <input
                            type="text"
                            class="field-input"
                            id="encryption_type"
                            placeholder="e.g. tls, ssl"
                            v-model="formData.encryption_type"
                        />
                        <small
                            class="field-error"
                            v-if="errors.encryption_type"
                            >{{ errors.encryption_type[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <!-- Section: Credentials -->
            <div class="settings-card">
                <div class="card-label">
                    <span class="label-dot"></span>
                    {{ $t("setting.email.credentials.title") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label" for="smtp_username">
                            {{
                                $t(
                                    "setting.email.credentials.smtp_username_label",
                                )
                            }}
                            <span class="required">*</span>
                        </label>
                        <input
                            type="text"
                            class="field-input"
                            id="smtp_username"
                            :placeholder="
                                $t(
                                    'setting.email.credentials.smtp_username_placeholder',
                                )
                            "
                            v-model="formData.smtp_username"
                        />
                        <small
                            class="field-error"
                            v-if="errors.smtp_username"
                            >{{ errors.smtp_username[0] }}</small
                        >
                    </div>

                    <div class="field-group">
                        <label class="field-label" for="email_password">
                            {{
                                $t(
                                    "setting.email.credentials.smtp_password_label",
                                )
                            }}
                            <span class="required">*</span>
                        </label>
                        <div class="password-wrapper">
                            <input
                                :type="showPassword ? 'text' : 'password'"
                                class="field-input field-input--password"
                                id="email_password"
                                :placeholder="
                                    $t(
                                        'setting.email.credentials.smtp_password_placeholder',
                                    )
                                "
                                v-model="formData.email_password"
                            />
                            <button
                                type="button"
                                class="password-toggle"
                                @click="showPassword = !showPassword"
                                tabindex="-1"
                            >
                                <svg
                                    v-if="!showPassword"
                                    width="15"
                                    height="15"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                >
                                    <path
                                        d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"
                                    />
                                    <circle cx="12" cy="12" r="3" />
                                </svg>
                                <svg
                                    v-else
                                    width="15"
                                    height="15"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                >
                                    <path
                                        d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"
                                    />
                                    <line x1="1" y1="1" x2="23" y2="23" />
                                </svg>
                            </button>
                        </div>
                        <small
                            class="field-error"
                            v-if="errors.email_password"
                            >{{ errors.email_password[0] }}</small
                        >
                    </div>
                </div>
            </div>

            <!-- Submit -->
            <div class="form-actions" v-if="$canAccess('update_email_setting')">
                <button
                    type="submit"
                    class="submit-btn"
                    :disabled="buttonLoader"
                >
                    <app-button-loader v-if="buttonLoader" />
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
                    {{ $t("setting.email.save_changes") }}
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

const formData = ref({
    provider: "smtp",
    smtp_host: "smtp.gmail.com",
    smtp_port: "587",
    encryption_type: "tls",
});
const errors = ref({});
const buttonLoader = ref(false);
const showPassword = ref(false);

const submit = () => {
    buttonLoader.value = true;
    Axios.post("email-settings", formData.value)
        .then(({ data }) => {
            toast.success(data.message);
            getServerData();
        })
        .catch(({ response }) => {
            if (response.status === 422) errors.value = response.data.errors;
            else toast.error(response.data.message);
        })
        .finally(() => {
            buttonLoader.value = false;
        });
};

const preloader = ref(false);
const getServerData = () => {
    preloader.value = true;
    Axios.get("email-settings")
        .then(({ data }) => {
            if (!_.isEmpty(data)) formData.value = data;
        })
        .finally(() => {
            preloader.value = false;
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
.field-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
}
.field-group--full {
    grid-column: 1 / -1;
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
.field-error {
    font-size: 0.77rem;
    color: var(--theme-error);
}

/* ── Select ── */
.select-wrapper {
    position: relative;
}
.field-select {
    appearance: none;
    cursor: pointer;
    padding-inline-end: 36px;
}
.select-chevron {
    position: absolute;
    inset-inline-end: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--theme-text-faint);
    pointer-events: none;
    display: flex;
    align-items: center;
}

/* ── Password ── */
.password-wrapper {
    position: relative;
}
.field-input--password {
    padding-inline-end: 42px;
}
.password-toggle {
    position: absolute;
    inset-inline-end: 12px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    cursor: pointer;
    color: var(--theme-text-faint);
    padding: 0;
    display: flex;
    align-items: center;
    transition: color 0.15s;
}
.password-toggle:hover {
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
    .fields-grid {
        grid-template-columns: 1fr;
    }
    .field-group--full {
        grid-column: 1;
    }
}
</style>
