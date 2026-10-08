<template>
    <app-loader v-if="pageLoader" />

    <div v-else class="pf-card">
        <!-- Section header -->
        <div class="pf-card__head">
            <div>
                <h3 class="pf-card__title">
                    {{ $t("profile.personal_information.title") }}
                </h3>
                <p class="pf-card__sub">
                    {{ $t("profile.personal_information.subtitle") }}
                </p>
            </div>
        </div>

        <div class="pf-card__body">
            <!-- Avatar upload row -->
            <div class="pf-avatar-row">
                <div class="pf-avatar-wrap">
                    <img
                        class="pf-avatar"
                        :src="profileAvatar || '/assets/img/avatar.png'"
                        alt="Avatar"
                    />
                    <label
                        class="pf-avatar__btn"
                        for="profile_picture"
                        :title="$t('profile.personal_information.change_photo')"
                    >
                        <svg
                            width="14"
                            height="14"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <path
                                d="M14.5 3.5l2 2L6 16H4v-2L14.5 3.5z"
                                stroke="currentColor"
                                stroke-width="1.7"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            />
                        </svg>
                        <input
                            id="profile_picture"
                            name="profile_picture"
                            type="file"
                            accept="image/*"
                            class="pf-avatar__input"
                            @change="onFileChange"
                        />
                    </label>
                </div>
                <div class="pf-avatar-info">
                    <p class="pf-avatar-info__title">
                        {{ $t("profile.personal_information.photo_title") }}
                    </p>
                    <p class="pf-avatar-info__hint">
                        {{ $t("profile.personal_information.photo_hint") }}
                    </p>
                </div>
            </div>

            <div class="pf-divider"></div>

            <!-- Name row -->
            <div class="pf-grid2">
                <div class="pf-field">
                    <label class="pf-label"
                        >{{
                            $t("profile.personal_information.first_name_label")
                        }}
                        <span class="pf-req">*</span></label
                    >
                    <input
                        class="pf-input"
                        :class="{ 'pf-input--err': errors.first_name }"
                        type="text"
                        v-model="formData.first_name"
                        :placeholder="
                            $t(
                                'profile.personal_information.first_name_placeholder',
                            )
                        "
                    />
                    <small class="pf-err" v-if="errors.first_name">{{
                        errors.first_name[0]
                    }}</small>
                </div>
                <div class="pf-field">
                    <label class="pf-label"
                        >{{
                            $t("profile.personal_information.last_name_label")
                        }}
                        <span class="pf-req">*</span></label
                    >
                    <input
                        class="pf-input"
                        :class="{ 'pf-input--err': errors.last_name }"
                        type="text"
                        v-model="formData.last_name"
                        :placeholder="
                            $t(
                                'profile.personal_information.last_name_placeholder',
                            )
                        "
                    />
                    <small class="pf-err" v-if="errors.last_name">{{
                        errors.last_name[0]
                    }}</small>
                </div>
            </div>

            <!-- Email -->
            <div class="pf-field">
                <label class="pf-label"
                    >{{ $t("profile.personal_information.email_label") }}
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
                        class="pf-input pf-input--icon"
                        :class="{ 'pf-input--err': errors.email }"
                        type="email"
                        v-model="formData.email"
                        placeholder="you@example.com"
                    />
                </div>
                <small class="pf-err" v-if="errors.email">{{
                    errors.email[0]
                }}</small>
            </div>

            <!-- Phone + DOB row -->
            <div class="pf-grid2">
                <div class="pf-field">
                    <label class="pf-label">{{
                        $t("profile.personal_information.phone_label")
                    }}</label>
                    <div class="pf-input-wrap">
                        <svg
                            class="pf-ico"
                            width="15"
                            height="15"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <path
                                d="M5 3h3l1.5 4-2 1.5a11 11 0 005 5L14 11l4 1.5V16a2 2 0 01-2 2C7.163 18 2 12.837 2 6a2 2 0 012-2z"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            />
                        </svg>
                        <input
                            class="pf-input pf-input--icon"
                            :class="{ 'pf-input--err': errors.phone_number }"
                            type="text"
                            v-model="formData.phone_number"
                            placeholder="+1 234 567 8900"
                        />
                    </div>
                    <small class="pf-err" v-if="errors.phone_number">{{
                        errors.phone_number[0]
                    }}</small>
                </div>
                <div class="pf-field">
                    <label class="pf-label">{{
                        $t("profile.personal_information.dob_label")
                    }}</label>
                    <div class="pf-input-wrap">
                        <svg
                            class="pf-ico"
                            width="15"
                            height="15"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <rect
                                x="2"
                                y="4"
                                width="16"
                                height="15"
                                rx="2"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />
                            <path
                                d="M2 9h16M6 2v4M14 2v4"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                            />
                        </svg>
                        <input
                            class="pf-input pf-input--icon"
                            :class="{ 'pf-input--err': errors.date_of_birth }"
                            type="date"
                            v-model="formData.date_of_birth"
                        />
                    </div>
                    <small class="pf-err" v-if="errors.date_of_birth">{{
                        errors.date_of_birth[0]
                    }}</small>
                </div>
            </div>

            <!-- Gender -->
            <div class="pf-field">
                <label class="pf-label">{{
                    $t("profile.personal_information.gender_label")
                }}</label>
                <div class="pf-gender-group">
                    <label
                        class="pf-gender"
                        :class="{
                            'pf-gender--active': formData.gender === 'male',
                        }"
                    >
                        <input
                            type="radio"
                            name="gender"
                            value="male"
                            v-model="formData.gender"
                            class="pf-gender__radio"
                        />
                        <svg
                            width="16"
                            height="16"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <circle
                                cx="10"
                                cy="7"
                                r="4"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />
                            <path
                                d="M5 19v-1a5 5 0 0110 0v1"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                            />
                        </svg>
                        {{ $t("profile.personal_information.gender_male") }}
                    </label>
                    <label
                        class="pf-gender"
                        :class="{
                            'pf-gender--active': formData.gender === 'female',
                        }"
                    >
                        <input
                            type="radio"
                            name="gender"
                            value="female"
                            v-model="formData.gender"
                            class="pf-gender__radio"
                        />
                        <svg
                            width="16"
                            height="16"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <circle
                                cx="10"
                                cy="7"
                                r="4"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />
                            <path
                                d="M5 19v-1a5 5 0 0110 0v1"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                            />
                        </svg>
                        {{ $t("profile.personal_information.gender_female") }}
                    </label>
                    <label
                        class="pf-gender"
                        :class="{
                            'pf-gender--active': formData.gender === 'other',
                        }"
                    >
                        <input
                            type="radio"
                            name="gender"
                            value="other"
                            v-model="formData.gender"
                            class="pf-gender__radio"
                        />
                        <svg
                            width="16"
                            height="16"
                            viewBox="0 0 20 20"
                            fill="none"
                        >
                            <circle
                                cx="10"
                                cy="10"
                                r="7"
                                stroke="currentColor"
                                stroke-width="1.5"
                            />
                            <path
                                d="M10 7v6M7 10h6"
                                stroke="currentColor"
                                stroke-width="1.5"
                                stroke-linecap="round"
                            />
                        </svg>
                        {{ $t("profile.personal_information.gender_other") }}
                    </label>
                </div>
                <small class="pf-err" v-if="errors.gender">{{
                    errors.gender[0]
                }}</small>
            </div>
        </div>

        <!-- Footer actions -->
        <div class="pf-card__footer">
            <button
                class="pf-btn"
                @click.prevent="submit"
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
                    {{ $t("profile.personal_information.submit") }}
                </template>
            </button>
        </div>
    </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import { toast } from "vue3-toastify";
import Axios from "@/services/axios/index.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { formDataAssigner } from "@/utilities/helper.js";

const preloader = ref(false);
const errors = ref({});
const formData = ref({});
const file = ref(null);
const profileAvatar = ref("");
const pageLoader = ref(false);

const onFileChange = (event) => {
    file.value = event.target.files[0];
    profileAvatar.value = URL.createObjectURL(file.value);
};

const submit = () => {
    preloader.value = true;
    errors.value = {};
    delete formData.value?.profile;
    if (file.value) {
        formData.value.profile_picture = file.value;
    } else {
        delete formData.value?.profile_picture;
    }
    if (!formData.value.date_of_birth) formData.value.date_of_birth = "";
    if (!formData.value.phone_number) formData.value.phone_number = "";

    const data = formDataAssigner(new FormData(), formData.value);
    Axios.post("profile-update", data, {
        headers: { "Content-Type": "multipart/form-data" },
    })
        .then((response) => {
            toast.success(response.data.message);
            window.location.reload();
        })
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
            else toast.error(response.data.message);
        })
        .finally(() => (preloader.value = false));
};

const getMyProfile = () => {
    pageLoader.value = true;
    Axios.get("profile")
        .then((response) => {
            formData.value = response.data;
            if (response.data.profile) {
                const p = response.data.profile;
                formData.value.phone_number = p.phone_number;
                formData.value.date_of_birth = p.date_of_birth;
                formData.value.gender = p.gender;
                profileAvatar.value = urlGenerator(p.profile_picture);
            }
        })
        .finally(() => (pageLoader.value = false));
};

onMounted(getMyProfile);
</script>

<style scoped>
/* ── Card shell ──────────────────────────────────────────── */
.pf-card {
    background: var(--theme-card);
    border-radius: 16px;
    border: 1px solid rgba(26, 92, 56, 0.1);
    box-shadow: 0 2px 12px rgba(10, 46, 30, 0.06);
    overflow: hidden;
}

.pf-card__head {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
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
    display: flex;
    gap: 0.75rem;
}

/* ── Avatar upload ───────────────────────────────────────── */
.pf-avatar-row {
    display: flex;
    align-items: center;
    gap: 1.25rem;
    margin-bottom: 1.4rem;
}

.pf-avatar-wrap {
    position: relative;
    flex-shrink: 0;
}

.pf-avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    object-fit: cover;
    border: 3px solid rgba(26, 92, 56, 0.15);
    display: block;
}

.pf-avatar__btn {
    position: absolute;
    bottom: 0;
    inset-inline-end: 0;
    width: 26px;
    height: 26px;
    border-radius: 50%;
    background: linear-gradient(135deg, #1a5c38, #0d3a22);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    border: 2px solid #fff;
    transition: transform 0.15s;
}
.pf-avatar__btn:hover {
    transform: scale(1.1);
}
.pf-avatar__input {
    display: none;
}

.pf-avatar-info__title {
    font-size: 0.875rem;
    font-weight: 600;
    color: #1c2b24;
    margin: 0 0 0.2rem;
}
.pf-avatar-info__hint {
    font-size: 0.75rem;
    color: #9cb8ac;
    margin: 0;
}

/* ── Divider ─────────────────────────────────────────────── */
.pf-divider {
    height: 1px;
    background: rgba(26, 92, 56, 0.08);
    margin-bottom: 1.4rem;
}

/* ── Grid ────────────────────────────────────────────────── */
.pf-grid2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem 1.25rem;
}

/* ── Fields ──────────────────────────────────────────────── */
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

.pf-err {
    display: block;
    margin-top: 0.3rem;
    font-size: 0.75rem;
    color: #c0392b;
}

/* ── Gender selector ─────────────────────────────────────── */
.pf-gender-group {
    display: flex;
    gap: 0.6rem;
    flex-wrap: wrap;
}

.pf-gender {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    padding: 0.5rem 1.1rem;
    border: 1.5px solid rgba(26, 92, 56, 0.18);
    border-radius: 10px;
    font-size: 0.82rem;
    font-weight: 500;
    color: #4b5f55;
    cursor: pointer;
    transition:
        border-color 0.15s,
        background 0.15s,
        color 0.15s;
    user-select: none;
}

.pf-gender:hover {
    border-color: #1a5c38;
    color: #1a5c38;
    background: #f5fbf7;
}

.pf-gender--active {
    border-color: #1a5c38;
    background: rgba(26, 92, 56, 0.08);
    color: #1a5c38;
    font-weight: 600;
}

.pf-gender__radio {
    display: none;
}

/* ── Save button ─────────────────────────────────────────── */
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

/* ── Responsive ──────────────────────────────────────────── */
@media (max-width: 600px) {
    .pf-grid2 {
        grid-template-columns: 1fr;
    }
    .pf-card__head,
    .pf-card__body,
    .pf-card__footer {
        padding-left: 1.25rem;
        padding-right: 1.25rem;
    }
}
</style>
