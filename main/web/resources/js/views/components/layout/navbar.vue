<template>
    <nav class="navbar navbar-expand navbar-light navbar-bg">
        <button
            class="zabi-sidebar-toggle"
            :class="{ 'is-collapsed': !sidebarStatus }"
            @click.prevent="toggleSidebar"
            aria-label="Toggle sidebar"
        >
            <span class="zabi-sidebar-toggle__bar"></span>
            <span class="zabi-sidebar-toggle__bar"></span>
            <span class="zabi-sidebar-toggle__bar"></span>
        </button>
        <app-loader v-if="pageLoader" />
        <div v-else class="navbar-collapse collapse">
            <ul class="navbar-nav navbar-align">
                <li class="nav-item dropdown">
                    <a
                        class="nav-icon dropdown-toggle d-inline-block d-sm-none"
                        href="#"
                        data-bs-toggle="dropdown"
                    >
                        <svg
                            class="align-middle"
                            width="16"
                            height="16"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <circle cx="12" cy="12" r="10" />
                            <line x1="2" y1="12" x2="22" y2="12" />
                            <path
                                d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"
                            />
                        </svg>
                    </a>

                    <a
                        class="nav-link dropdown-toggle d-none d-sm-inline-block"
                        href="#"
                        data-bs-toggle="dropdown"
                    >
                        <svg
                            class="align-middle me-1"
                            width="14"
                            height="14"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <circle cx="12" cy="12" r="10" />
                            <line x1="2" y1="12" x2="22" y2="12" />
                            <path
                                d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"
                            />
                        </svg>
                        <span class="text-dark">{{
                            locale === "ar"
                                ? $t("common.arabic")
                                : $t("common.english")
                        }}</span>
                    </a>
                    <div class="dropdown-menu dropdown-menu-end">
                        <a
                            class="dropdown-item"
                            href="#"
                            @click.prevent="changeLocale('en')"
                            >{{ $t("common.english") }}</a
                        >
                        <a
                            class="dropdown-item"
                            href="#"
                            @click.prevent="changeLocale('ar')"
                            >{{ $t("common.arabic") }}</a
                        >
                    </div>
                </li>
                <li class="nav-item dropdown">
                    <a
                        class="nav-icon dropdown-toggle d-inline-block d-sm-none"
                        href="#"
                        data-bs-toggle="dropdown"
                    >
                        <svg
                            class="align-middle"
                            width="16"
                            height="16"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <circle cx="12" cy="12" r="3" />
                            <path
                                d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"
                            />
                        </svg>
                    </a>

                    <a
                        class="nav-link dropdown-toggle d-none d-sm-inline-block"
                        href="#"
                        data-bs-toggle="dropdown"
                    >
                        <img
                            :src="profilePicture"
                            class="avatar img-fluid rounded-circle"
                            alt="User profile"
                        />
                    </a>
                    <div class="dropdown-menu dropdown-menu-end">
                        <a
                            class="dropdown-item"
                            :href="urlGenerator('my-profile')"
                        >
                            <svg
                                class="align-middle me-1"
                                width="14"
                                height="14"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            >
                                <path
                                    d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"
                                />
                                <circle cx="12" cy="7" r="4" />
                            </svg>
                            {{ $t("common.profile") }}
                        </a>

                        <template v-if="$canAccess('view_setting')">
                            <div class="dropdown-divider"></div>
                            <a
                                class="dropdown-item"
                                :href="urlGenerator('setting')"
                                >{{ $t("common.settings") }}</a
                            >
                        </template>
                        <div class="dropdown-divider"></div>
                        <a
                            href=""
                            class="dropdown-item"
                            @click.prevent="logout"
                        >
                            <svg
                                class="align-middle me-1"
                                width="14"
                                height="14"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            >
                                <path
                                    d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"
                                />
                                <polyline points="16 17 21 12 16 7" />
                                <line x1="21" y1="12" x2="9" y2="12" />
                            </svg>
                            {{ $t("common.logout") }}
                        </a>
                    </div>
                </li>
            </ul>
        </div>
    </nav>
</template>

<script setup>
import { urlGenerator } from "@/utilities/urlGenerator.js";
import Axios from "@/services/axios/index.js";
import { onMounted, ref } from "vue";
import { useI18n } from "vue-i18n";
import { setLocale } from "~/utilities/locale.js";

const { locale } = useI18n();
const changeLocale = (newLocale) => setLocale(newLocale);

const logout = () => {
    Axios.post("logout").then(({ data }) => {
        window.location.href = urlGenerator("login");
    });
};

const sidebarStatus = ref(true);
const toggleSidebar = () => {
    const sidebar = document.querySelector("nav.zabi-sidebar");
    if (!sidebar) return;
    if (sidebarStatus.value) {
        sidebar.classList.add("collapsed");
        sidebarStatus.value = false;
    } else {
        sidebar.classList.remove("collapsed");
        sidebarStatus.value = true;
    }
};

const profilePicture = ref(null);
const pageLoader = ref(false);
const getMyProfile = () => {
    pageLoader.value = true;
    Axios.get("profile")
        .then(({ data }) => {
            profilePicture.value =
                data.profile && data.profile.profile_picture
                    ? urlGenerator(data.profile.profile_picture)
                    : urlGenerator("assets/img/avatar.png");
        })
        .finally(() => (pageLoader.value = false));
};

onMounted(() => {
    getMyProfile();
});
</script>

<style>
.sidebar,
body[data-theme="dark"] .sidebar {
    background: none !important;
}

/* Sidebar hamburger toggle */
.zabi-sidebar-toggle {
    display: inline-flex;
    flex-direction: column;
    justify-content: center;
    gap: 5px;
    width: 38px;
    height: 38px;
    padding: 8px 9px;
    margin-inline-end: 0.75rem;
    border-radius: 9px;
    border: 1px solid rgba(var(--theme-primary-rgb), 0.14);
    background: rgba(var(--theme-primary-rgb), 0.05);
    cursor: pointer;
    flex-shrink: 0;
    transition:
        background 0.15s,
        border-color 0.15s;
}

.zabi-sidebar-toggle:hover {
    background: rgba(var(--theme-primary-rgb), 0.1);
    border-color: rgba(var(--theme-primary-rgb), 0.25);
}

.zabi-sidebar-toggle__bar {
    display: block;
    height: 2px;
    border-radius: 2px;
    background: var(--theme-primary);
    transition:
        transform 0.22s ease,
        opacity 0.22s ease,
        width 0.22s ease;
    width: 100%;
}

/* Animate to X when collapsed */
.zabi-sidebar-toggle.is-collapsed .zabi-sidebar-toggle__bar:nth-child(1) {
    transform: translateY(7px) rotate(45deg);
}
.zabi-sidebar-toggle.is-collapsed .zabi-sidebar-toggle__bar:nth-child(2) {
    opacity: 0;
    transform: scaleX(0);
}
.zabi-sidebar-toggle.is-collapsed .zabi-sidebar-toggle__bar:nth-child(3) {
    transform: translateY(-7px) rotate(-45deg);
}

/* Space out the navbar pills so adjacent borders don't merge into a divider line */
.navbar-align > .nav-item + .nav-item {
    margin-inline-start: 0.6rem;
}

/* Profile dropdown toggle */
.navbar .nav-link.dropdown-toggle {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.35rem 0.75rem !important;
    border-radius: 10px;
    border: 1px solid rgba(var(--theme-primary-rgb), 0.12);
    background: rgba(var(--theme-primary-rgb), 0.04);
    transition:
        background 0.15s,
        border-color 0.15s;
}

.navbar .nav-link.dropdown-toggle:hover {
    background: rgba(var(--theme-primary-rgb), 0.1);
    border-color: rgba(var(--theme-primary-rgb), 0.22);
}
</style>
