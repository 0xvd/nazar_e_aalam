<template>
    <div class="auth-page">
        <!-- ── Left brand panel ── -->
        <div class="auth-panel">
            <div class="auth-panel__pattern"></div>

            <div class="auth-panel__top">
                <div class="auth-panel__bismillah">
                    بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ
                </div>
                <div class="auth-panel__logo"><app-logo /></div>
                <p class="auth-panel__tagline">{{ $t("auth.tagline") }}</p>
            </div>

            <div class="auth-panel__art">
                <svg
                    width="180"
                    height="180"
                    viewBox="0 0 200 200"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                >
                    <!-- Base platform -->
                    <rect
                        x="10"
                        y="168"
                        width="180"
                        height="8"
                        rx="4"
                        fill="rgba(255,255,255,0.08)"
                    />
                    <!-- Main building body -->
                    <rect
                        x="28"
                        y="110"
                        width="144"
                        height="60"
                        rx="5"
                        fill="rgba(255,255,255,0.07)"
                    />
                    <!-- Central dome -->
                    <path
                        d="M72 110 C72 80 128 80 128 110"
                        fill="rgba(255,255,255,0.13)"
                    />
                    <!-- Dome cap -->
                    <ellipse
                        cx="100"
                        cy="110"
                        rx="28"
                        ry="5"
                        fill="rgba(255,255,255,0.1)"
                    />
                    <!-- Dome finial -->
                    <line
                        x1="100"
                        y1="77"
                        x2="100"
                        y2="68"
                        stroke="rgba(212,168,67,0.7)"
                        stroke-width="2"
                    />
                    <path
                        d="M94 72 C94 66 106 66 106 72 C106 75 100 75 100 75 C100 75 94 75 94 72Z"
                        fill="rgba(212,168,67,0.6)"
                    />
                    <!-- Crescent moon -->
                    <path
                        d="M100 62 C97 62 95 65 96 68 C97.5 66.5 99.5 66 102 67 C101 64 100 62 100 62Z"
                        fill="rgba(212,168,67,0.85)"
                    />
                    <!-- Central door arch -->
                    <path
                        d="M88 170 L88 142 C88 135 112 135 112 142 L112 170 Z"
                        fill="rgba(255,255,255,0.1)"
                    />
                    <!-- Left minaret -->
                    <rect
                        x="30"
                        y="80"
                        width="18"
                        height="88"
                        rx="3"
                        fill="rgba(255,255,255,0.08)"
                    />
                    <path
                        d="M30 80 L39 62 L48 80Z"
                        fill="rgba(255,255,255,0.12)"
                    />
                    <line
                        x1="39"
                        y1="58"
                        x2="39"
                        y2="52"
                        stroke="rgba(212,168,67,0.5)"
                        stroke-width="1.5"
                    />
                    <circle cx="39" cy="51" r="2" fill="rgba(212,168,67,0.5)" />
                    <!-- Right minaret -->
                    <rect
                        x="152"
                        y="80"
                        width="18"
                        height="88"
                        rx="3"
                        fill="rgba(255,255,255,0.08)"
                    />
                    <path
                        d="M152 80 L161 62 L170 80Z"
                        fill="rgba(255,255,255,0.12)"
                    />
                    <line
                        x1="161"
                        y1="58"
                        x2="161"
                        y2="52"
                        stroke="rgba(212,168,67,0.5)"
                        stroke-width="1.5"
                    />
                    <circle
                        cx="161"
                        cy="51"
                        r="2"
                        fill="rgba(212,168,67,0.5)"
                    />
                    <!-- Windows row -->
                    <rect
                        x="42"
                        y="128"
                        width="16"
                        height="20"
                        rx="8"
                        fill="rgba(255,255,255,0.08)"
                    />
                    <rect
                        x="66"
                        y="128"
                        width="16"
                        height="20"
                        rx="8"
                        fill="rgba(255,255,255,0.08)"
                    />
                    <rect
                        x="118"
                        y="128"
                        width="16"
                        height="20"
                        rx="8"
                        fill="rgba(255,255,255,0.08)"
                    />
                    <rect
                        x="142"
                        y="128"
                        width="16"
                        height="20"
                        rx="8"
                        fill="rgba(255,255,255,0.08)"
                    />
                    <!-- Stars -->
                    <path
                        d="M160 38L161.5 43H167L162.5 46L164 51L160 48L156 51L157.5 46L153 43H158.5Z"
                        fill="rgba(212,168,67,0.35)"
                    />
                    <path
                        d="M40 30L41 33H44L41.5 35L42.5 38L40 36.5L37.5 38L38.5 35L36 33H39Z"
                        fill="rgba(212,168,67,0.3)"
                    />
                </svg>
            </div>

            <div class="auth-panel__bottom">
                <p class="auth-panel__verse">
                    "وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ"
                </p>
                <p class="auth-panel__verse-ref">Al-Baqarah 2:45</p>
            </div>
        </div>

        <!-- ── Right form panel ── -->
        <div class="auth-form-side">
            <div class="auth-form-wrap">
                <!-- Mobile logo (hidden on desktop) -->
                <div class="auth-mobile-header">
                    <div class="auth-mobile-bismillah">
                        بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ
                    </div>
                    <div class="auth-mobile-logo"><app-logo /></div>
                </div>

                <h2 class="auth-title">{{ $t("auth.welcome_back") }}</h2>
                <p class="auth-subtitle">{{ $t("auth.subtitle") }}</p>

                <!-- Demo role -->
                <div class="af-field" v-if="isDemoVersion === 'true'">
                    <label class="af-label"
                        >{{ $t("auth.role") }}
                        <span class="af-req">*</span></label
                    >
                    <select
                        class="af-input"
                        v-model="formData.role"
                        @change="updateCredentials"
                    >
                        <option value="">{{ $t("auth.choose_role") }}</option>
                        <option value="admin">{{ $t("auth.admin") }}</option>
                    </select>
                </div>

                <!-- Email -->
                <div class="af-field">
                    <label class="af-label"
                        >{{ $t("auth.email") }}
                        <span class="af-req">*</span></label
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
                            :placeholder="$t('auth.email_placeholder')"
                            autocomplete="email"
                        />
                    </div>
                    <small class="af-err" v-if="errors.email">{{
                        errors.email[0]
                    }}</small>
                </div>

                <!-- Password -->
                <div class="af-field">
                    <label class="af-label"
                        >{{ $t("auth.password") }}
                        <span class="af-req">*</span></label
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
                            :placeholder="$t('auth.password_placeholder')"
                            autocomplete="current-password"
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

                <!-- Forgot -->
                <div class="af-forgot">
                    <a href="forget-password" class="af-forgot__link">{{
                        $t("auth.forgot_password")
                    }}</a>
                </div>

                <!-- Submit -->
                <button
                    class="af-btn"
                    @click.prevent="submit"
                    :disabled="preloader"
                >
                    <app-button-loader v-if="preloader" />
                    <span v-else>{{ $t("auth.sign_in") }}</span>
                </button>

                <!-- Footer -->
                <div class="af-footer">
                    <app-auth-footer />
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, watch, onMounted } from "vue";
import Axios from "@/services/axios/index.js";

const errors = ref({});
const preloader = ref(false);
const showPass = ref(false);
const isDemoVersion = ref(process.env.IS_DEMO);
const formData = reactive({ role: "", email: "", password: "" });

const updateCredentials = () => {
    switch (formData.role) {
        case "admin":
            formData.email = "admin@demo.com";
            formData.password = "123456";
            break;
        default:
            formData.email = "";
            formData.password = "";
    }
};

onMounted(updateCredentials);
watch(formData, (n, o) => {
    if (n.role !== o.role && isDemoVersion.value) updateCredentials();
});

const submit = () => {
    preloader.value = true;
    errors.value = {};
    Axios.post("login", formData)
        .then(({ data }) => {
            if (data.status) window.location.href = "dashboard";
        })
        .catch(({ response }) => {
            if (response.status === 422) errors.value = response.data.errors;
        })
        .finally(() => (preloader.value = false));
};
</script>

<style scoped>
/* ── Page shell ──────────────────────────────────────────── */
.auth-page {
    display: flex;
    min-height: 100vh;
}

/* ── Left decorative panel ───────────────────────────────── */
.auth-panel {
    width: 42%;
    min-height: 100vh;
    background: linear-gradient(
        155deg,
        #062416 0%,
        #0d3a22 45%,
        #1a5c38 90%,
        #22794a 100%
    );
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;
    padding: 3rem 2rem 2.5rem;
    position: relative;
    overflow: hidden;
    flex-shrink: 0;
}

.auth-panel__pattern {
    position: absolute;
    inset: 0;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='70' height='70' viewBox='0 0 70 70'%3E%3Cg fill='none' stroke='%23ffffff05' stroke-width='1'%3E%3Cpath d='M35 0 L70 35 L35 70 L0 35 Z'/%3E%3Ccircle cx='35' cy='35' r='18'/%3E%3C/g%3E%3C/svg%3E");
    pointer-events: none;
}

/* Radial glow in center */
.auth-panel::after {
    content: "";
    position: absolute;
    top: 35%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 300px;
    height: 300px;
    background: radial-gradient(
        circle,
        rgba(var(--theme-accent-rgb), 0.06) 0%,
        transparent 70%
    );
    pointer-events: none;
}

.auth-panel__top {
    text-align: center;
    position: relative;
    z-index: 1;
}

.auth-panel__bismillah {
    font-family: "Amiri", "Times New Roman", serif;
    font-size: 1.25rem;
    color: rgba(var(--theme-accent-rgb), 0.9);
    margin-bottom: 1.25rem;
    letter-spacing: 0.04em;
}

.auth-panel__logo {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 0.6rem;
}

.auth-panel__logo :deep(img) {
    max-height: 3.2rem;
    width: auto;
    filter: brightness(1.15) drop-shadow(0 2px 8px rgba(0, 0, 0, 0.4));
}

.auth-panel__tagline {
    font-size: 0.7rem;
    color: rgba(255, 255, 255, 0.45);
    text-transform: uppercase;
    letter-spacing: 0.14em;
    font-weight: 600;
    margin: 0;
}

.auth-panel__art {
    position: relative;
    z-index: 1;
    opacity: 0.9;
}

.auth-panel__bottom {
    text-align: center;
    position: relative;
    z-index: 1;
}

.auth-panel__verse {
    font-family: "Amiri", "Times New Roman", serif;
    font-size: 1rem;
    color: rgba(var(--theme-accent-rgb), 0.7);
    margin: 0 0 0.25rem;
    letter-spacing: 0.02em;
}

.auth-panel__verse-ref {
    font-size: 0.7rem;
    color: rgba(255, 255, 255, 0.3);
    margin: 0;
    letter-spacing: 0.08em;
}

/* ── Right form side ─────────────────────────────────────── */
.auth-form-side {
    flex: 1;
    background: #f5f8f6;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2.5rem 1.5rem;
    overflow-y: auto;
}

.auth-form-wrap {
    width: 100%;
    max-width: 400px;
}

/* Mobile logo — hidden on desktop */
.auth-mobile-header {
    display: none;
}

.auth-title {
    font-size: 1.6rem;
    font-weight: 800;
    color: #1c2b24;
    margin: 0 0 0.3rem;
}

.auth-subtitle {
    font-size: 0.85rem;
    color: #7a8e84;
    margin: 0 0 1.75rem;
}

/* ── Form fields ─────────────────────────────────────────── */
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
    inset-inline-start: 0.75rem;
    color: #9cb8ac;
    pointer-events: none;
    flex-shrink: 0;
}

.af-input-wrap .af-input {
    padding-inline-start: 2.5rem;
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
    padding-inline-end: 2.5rem;
}

.af-input-wrap--err .af-input {
    border-color: #e74c3c;
}

.af-input-wrap--err .af-input:focus {
    box-shadow: 0 0 0 3px rgba(231, 76, 60, 0.1);
}

.af-eye {
    position: absolute;
    inset-inline-end: 0.75rem;
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

/* ── Forgot link ─────────────────────────────────────────── */
.af-forgot {
    text-align: end;
    margin-bottom: 1.4rem;
    margin-top: -0.4rem;
}
.af-forgot__link {
    font-size: 0.78rem;
    font-weight: 600;
    color: #1a5c38;
    text-decoration: none;
    transition: color 0.15s;
}
.af-forgot__link:hover {
    color: #0d3a22;
    text-decoration: underline;
}

/* ── Submit button ───────────────────────────────────────── */
.af-btn {
    width: 100%;
    padding: 0.78rem;
    border: none;
    border-radius: 10px;
    background: linear-gradient(135deg, #1a5c38, #0d3a22);
    color: #fff;
    font-size: 0.9rem;
    font-weight: 700;
    letter-spacing: 0.02em;
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

/* ── Footer ──────────────────────────────────────────────── */
.af-footer {
    margin-top: 1.75rem;
    padding-top: 1.25rem;
    border-top: 1px solid rgba(26, 92, 56, 0.1);
}

.af-footer :deep(.copyright) {
    color: #9cb8ac;
    font-size: 11px;
}
.af-footer :deep(.link) {
    color: #7aab92;
    font-size: 11px;
}
.af-footer :deep(.link:hover) {
    color: #1a5c38;
}
.af-footer :deep(.separator) {
    color: rgba(26, 92, 56, 0.2);
}

/* ── Responsive ──────────────────────────────────────────── */
@media (max-width: 768px) {
    .auth-page {
        flex-direction: column;
    }

    .auth-panel {
        display: none;
    }

    .auth-mobile-header {
        display: block;
        text-align: center;
        margin-bottom: 1.75rem;
        padding-bottom: 1.25rem;
        border-bottom: 1px solid rgba(26, 92, 56, 0.1);
    }

    .auth-mobile-bismillah {
        font-family: "Amiri", "Times New Roman", serif;
        font-size: 1rem;
        color: var(--theme-accent);
        margin-bottom: 0.6rem;
    }

    .auth-mobile-logo :deep(img) {
        max-height: 2.5rem;
    }

    .auth-form-side {
        background: linear-gradient(
            150deg,
            #062416 0%,
            #0d3a22 45%,
            #1a5c38 100%
        );
        align-items: flex-start;
        padding: 2rem 1.25rem 3rem;
    }

    .auth-form-wrap {
        background: var(--theme-card);
        border-radius: 20px;
        padding: 1.75rem 1.5rem;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    }
}
</style>
