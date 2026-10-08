<template>
    <div class="pf-card">
        <!-- Section header -->
        <div class="pf-card__head">
            <div>
                <h3 class="pf-card__title">
                    {{ $t("profile.change_password.title") }}
                </h3>
                <p class="pf-card__sub">
                    {{ $t("profile.change_password.subtitle") }}
                </p>
            </div>
        </div>

        <div class="pf-card__body">
            <!-- Password requirement hint -->
            <div class="pf-hint">
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none">
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
                {{ $t("profile.change_password.password_hint") }}
            </div>

            <!-- Current password -->
            <div class="pf-field">
                <label class="pf-label"
                    >{{ $t("profile.change_password.current_password_label") }}
                    <span class="pf-req">*</span></label
                >
                <div class="pf-input-wrap">
                    <svg
                        class="pf-ico"
                        width="15"
                        height="15"
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
                        class="pf-input pf-input--icon pf-input--pad-r"
                        :class="{ 'pf-input--err': errors.current_password }"
                        :type="show.current ? 'text' : 'password'"
                        v-model="formData.current_password"
                        :placeholder="
                            $t(
                                'profile.change_password.current_password_placeholder',
                            )
                        "
                    />
                    <button
                        type="button"
                        class="pf-eye"
                        @click="show.current = !show.current"
                        tabindex="-1"
                    >
                        <svg
                            v-if="!show.current"
                            width="15"
                            height="15"
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
                            width="15"
                            height="15"
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
                <small class="pf-err" v-if="errors.current_password">{{
                    errors.current_password[0]
                }}</small>
            </div>

            <div class="pf-divider"></div>

            <!-- New password -->
            <div class="pf-field">
                <label class="pf-label"
                    >{{ $t("profile.change_password.new_password_label") }}
                    <span class="pf-req">*</span></label
                >
                <div class="pf-input-wrap">
                    <svg
                        class="pf-ico"
                        width="15"
                        height="15"
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
                        class="pf-input pf-input--icon pf-input--pad-r"
                        :class="{ 'pf-input--err': errors.password }"
                        :type="show.password ? 'text' : 'password'"
                        v-model="formData.password"
                        :placeholder="
                            $t(
                                'profile.change_password.new_password_placeholder',
                            )
                        "
                    />
                    <button
                        type="button"
                        class="pf-eye"
                        @click="show.password = !show.password"
                        tabindex="-1"
                    >
                        <svg
                            v-if="!show.password"
                            width="15"
                            height="15"
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
                            width="15"
                            height="15"
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
                <!-- Strength bar -->
                <div class="pf-strength" v-if="formData.password">
                    <div class="pf-strength__bars">
                        <span
                            class="pf-strength__bar"
                            v-for="i in 4"
                            :key="i"
                            :class="
                                i <= strength.score
                                    ? `pf-strength__bar--${strength.level}`
                                    : ''
                            "
                        ></span>
                    </div>
                    <span
                        class="pf-strength__label"
                        :class="`pf-strength__label--${strength.level}`"
                        >{{ strength.text }}</span
                    >
                </div>
                <small class="pf-err" v-if="errors.password">{{
                    errors.password[0]
                }}</small>
            </div>

            <!-- Confirm password -->
            <div class="pf-field">
                <label class="pf-label"
                    >{{ $t("profile.change_password.confirm_password_label") }}
                    <span class="pf-req">*</span></label
                >
                <div class="pf-input-wrap">
                    <svg
                        class="pf-ico"
                        width="15"
                        height="15"
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
                        class="pf-input pf-input--icon pf-input--pad-r"
                        :class="{ 'pf-input--err': errors.confirm_password }"
                        :type="show.confirm ? 'text' : 'password'"
                        v-model="formData.confirm_password"
                        :placeholder="
                            $t(
                                'profile.change_password.confirm_password_placeholder',
                            )
                        "
                    />
                    <button
                        type="button"
                        class="pf-eye"
                        @click="show.confirm = !show.confirm"
                        tabindex="-1"
                    >
                        <svg
                            v-if="!show.confirm"
                            width="15"
                            height="15"
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
                            width="15"
                            height="15"
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
                <small class="pf-err" v-if="errors.confirm_password">{{
                    errors.confirm_password[0]
                }}</small>
            </div>
        </div>

        <!-- Footer -->
        <div class="pf-card__footer">
            <button
                class="pf-btn"
                @click.prevent="updatePassword"
                :disabled="preloader"
            >
                <app-button-loader v-if="preloader" />
                <template v-else>
                    <svg width="15" height="15" viewBox="0 0 20 20" fill="none">
                        <path
                            d="M4 10l5 5 7-8"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        />
                    </svg>
                    {{ $t("profile.change_password.submit") }}
                </template>
            </button>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, reactive } from "vue";
import { toast } from "vue3-toastify";
import Axios from "@/services/axios/index.js";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const preloader = ref(false);
const errors = ref({});
const formData = ref({});
const show = reactive({ current: false, password: false, confirm: false });

const strength = computed(() => {
    const pw = formData.value.password || "";
    if (!pw) return { score: 0, level: "", text: "" };
    let score = 0;
    if (pw.length >= 8) score++;
    if (/[A-Z]/.test(pw)) score++;
    if (/[0-9]/.test(pw)) score++;
    if (/[^A-Za-z0-9]/.test(pw)) score++;
    const levels = ["", "weak", "fair", "good", "strong"];
    const texts = [
        "",
        t("profile.change_password.strength.weak"),
        t("profile.change_password.strength.fair"),
        t("profile.change_password.strength.good"),
        t("profile.change_password.strength.strong"),
    ];
    return { score, level: levels[score], text: texts[score] };
});

const updatePassword = () => {
    preloader.value = true;
    errors.value = {};
    Axios.post("password-change", formData.value)
        .then((response) => {
            toast.success(response.data.message);
            formData.value = {};
        })
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
            else toast.error(response.data.message);
        })
        .finally(() => (preloader.value = false));
};
</script>

<style scoped>
/* Card */
.pf-card {
    background: var(--theme-card);
    border-radius: 16px;
    border: 1px solid rgba(26, 92, 56, 0.1);
    box-shadow: 0 2px 12px rgba(10, 46, 30, 0.06);
    overflow: hidden;
}

.pf-card__head {
    padding: 1.4rem 1.75rem 1.1rem;
    border-bottom: 1px solid rgba(26, 92, 56, 0.08);
}

.pf-card__title {
    font-size: 1rem;
    font-weight: 700;
    color: #1c2b24;
    margin: 0 0 0.2rem;
}
.pf-card__sub {
    font-size: 0.8rem;
    color: #7a8e84;
    margin: 0;
}

.pf-card__body {
    padding: 1.5rem 1.75rem;
}

.pf-card__footer {
    padding: 1rem 1.75rem 1.5rem;
    border-top: 1px solid rgba(26, 92, 56, 0.08);
    background: #fafcfa;
}

/* Hint */
.pf-hint {
    display: flex;
    align-items: flex-start;
    gap: 0.5rem;
    background: #f0faf5;
    border: 1px solid rgba(26, 92, 56, 0.14);
    border-radius: 10px;
    padding: 0.7rem 0.9rem;
    font-size: 0.78rem;
    color: #3d6b52;
    margin-bottom: 1.4rem;
    line-height: 1.5;
}
.pf-hint svg {
    flex-shrink: 0;
    margin-top: 1px;
    color: #1a5c38;
}

.pf-divider {
    height: 1px;
    background: rgba(26, 92, 56, 0.08);
    margin-bottom: 1.2rem;
}

/* Fields */
.pf-field {
    margin-bottom: 1.1rem;
}

.pf-label {
    display: block;
    font-size: 0.78rem;
    font-weight: 600;
    color: #4b5f55;
    margin-bottom: 0.4rem;
}
.pf-req {
    color: #c0392b;
}

.pf-input-wrap {
    position: relative;
}

.pf-ico {
    position: absolute;
    inset-inline-start: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    color: #9cb8ac;
    pointer-events: none;
}

.pf-input {
    width: 100%;
    padding: 0.65rem 0.9rem;
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
}
.pf-input--icon {
    padding-inline-start: 2.4rem;
}
.pf-input--pad-r {
    padding-inline-end: 2.4rem;
}
.pf-input:focus {
    border-color: #1a5c38;
    box-shadow: 0 0 0 3px rgba(26, 92, 56, 0.1);
}
.pf-input--err {
    border-color: #e74c3c !important;
}
.pf-input--err:focus {
    box-shadow: 0 0 0 3px rgba(231, 76, 60, 0.1) !important;
}

.pf-eye {
    position: absolute;
    inset-inline-end: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    padding: 0;
    cursor: pointer;
    color: #9cb8ac;
    display: flex;
    align-items: center;
    transition: color 0.15s;
}
.pf-eye:hover {
    color: #1a5c38;
}

.pf-err {
    display: block;
    margin-top: 0.3rem;
    font-size: 0.75rem;
    color: #c0392b;
}

/* Strength bar */
.pf-strength {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    margin-top: 0.5rem;
}

.pf-strength__bars {
    display: flex;
    gap: 4px;
    flex: 1;
}

.pf-strength__bar {
    flex: 1;
    height: 4px;
    border-radius: 2px;
    background: rgba(26, 92, 56, 0.1);
    transition: background 0.25s;
}
.pf-strength__bar--weak {
    background: #e74c3c;
}
.pf-strength__bar--fair {
    background: #f39c12;
}
.pf-strength__bar--good {
    background: #2ecc71;
}
.pf-strength__bar--strong {
    background: #1a5c38;
}

.pf-strength__label {
    font-size: 0.7rem;
    font-weight: 700;
    min-width: 38px;
    text-align: end;
}
.pf-strength__label--weak {
    color: #e74c3c;
}
.pf-strength__label--fair {
    color: #f39c12;
}
.pf-strength__label--good {
    color: #2ecc71;
}
.pf-strength__label--strong {
    color: #1a5c38;
}

/* Button */
.pf-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.62rem 1.5rem;
    border: none;
    border-radius: 10px;
    background: linear-gradient(135deg, #1a5c38, #0d3a22);
    color: #fff;
    font-size: 0.875rem;
    font-weight: 700;
    cursor: pointer;
    box-shadow: 0 3px 12px rgba(10, 46, 30, 0.28);
    transition:
        opacity 0.18s,
        transform 0.18s;
    font-family: inherit;
}
.pf-btn:hover:not(:disabled) {
    opacity: 0.9;
    transform: translateY(-1px);
}
.pf-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

@media (max-width: 600px) {
    .pf-card__head,
    .pf-card__body,
    .pf-card__footer {
        padding-left: 1.25rem;
        padding-right: 1.25rem;
    }
}
</style>
