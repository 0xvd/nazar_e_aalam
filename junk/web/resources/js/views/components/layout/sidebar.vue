<template>
    <nav id="sidebar" class="sidebar js-sidebar zabi-sidebar">
        <div class="sidebar-content js-simplebar zabi-sidebar__scroll">
            <a
                class="sidebar-brand zabi-sidebar__brand"
                :href="urlGenerator('dashboard')"
            >
                <span class="zabi-sidebar__brand-inner">
                    <app-logo />
                </span>
            </a>

            <ul class="sidebar-nav zabi-sidebar__nav">
                <template
                    v-for="(item, index) in menuItems"
                    :key="`${sectionId(item)}-${index}`"
                >
                    <li
                        v-if="item.permission"
                        class="sidebar-item zabi-sidebar__item"
                        :class="{
                            active: isItemActive(item),
                            'zabi-sidebar__item--open':
                                item.subMenu && isSubmenuOpen(item),
                        }"
                    >
                        <a
                            v-if="!item.subMenu"
                            class="sidebar-link zabi-sidebar__link"
                            :href="item.url"
                        >
                            <span class="zabi-sidebar__icon-wrap">
                                <img
                                    class="sidebar_icon zabi-sidebar__icon"
                                    :src="item.icon"
                                    alt=""
                                />
                            </span>
                            <span class="zabi-sidebar__label">{{
                                item.name
                            }}</span>
                        </a>

                        <template v-else>
                            <a
                                href="#"
                                class="sidebar-link zabi-sidebar__link zabi-sidebar__link--parent"
                                role="button"
                                @click.prevent="toggleSubmenu(item)"
                            >
                                <span class="zabi-sidebar__icon-wrap">
                                    <img
                                        class="sidebar_icon zabi-sidebar__icon"
                                        :src="item.icon"
                                        alt=""
                                    />
                                </span>
                                <span class="zabi-sidebar__label">{{
                                    item.name
                                }}</span>
                                <span
                                    class="zabi-sidebar__chevron"
                                    aria-hidden="true"
                                />
                            </a>

                            <ul
                                v-show="isSubmenuOpen(item)"
                                class="sidebar-dropdown list-unstyled zabi-sidebar__dropdown"
                            >
                                <template
                                    v-for="(
                                        submenuItem, subIndex
                                    ) in item.subMenu"
                                    :key="subIndex"
                                >
                                    <li
                                        v-if="
                                            submenuItem.permission === true ||
                                            submenuItem.permission === ''
                                        "
                                        class="sidebar-item zabi-sidebar__subitem"
                                        :class="{
                                            active: isRouteActive(
                                                submenuItem.url,
                                            ),
                                        }"
                                    >
                                        <a
                                            class="sidebar-link zabi-sidebar__link zabi-sidebar__link--sub"
                                            :href="submenuItem.url"
                                        >
                                            {{ submenuItem.name }}
                                        </a>
                                    </li>
                                </template>
                            </ul>
                        </template>
                    </li>
                </template>
            </ul>
        </div>
    </nav>
</template>

<script setup>
import { computed, reactive } from "vue";
import { urlGenerator } from "@/utilities/urlGenerator.js";

const props = defineProps({
    data: {
        type: [Array, Object],
        default: () => [],
    },
});

const menuItems = computed(() => {
    const raw = props.data;
    if (Array.isArray(raw)) {
        return raw;
    }
    if (raw && typeof raw === "object") {
        return Object.values(raw);
    }
    return [];
});

const normalizePath = (url) => {
    if (!url || typeof url !== "string") {
        return "";
    }
    try {
        const u = new URL(url, window.location.origin);
        let p = u.pathname;
        if (p.length > 1 && p.endsWith("/")) {
            p = p.slice(0, -1);
        }
        return p;
    } catch {
        return "";
    }
};

const currentPath = normalizePath(window.location.href);

const isRouteActive = (url) => normalizePath(url) === currentPath;

const sectionId = (item) => {
    if (item.id) {
        return String(item.id);
    }
    if (!item.name) {
        return "menu";
    }
    return item.name
        .toLowerCase()
        .trim()
        .replace(/\s+/g, "-")
        .replace(/[^a-z0-9-]/g, "");
};

const openSubmenus = reactive({});

const isSubmenuItemVisible = (sub) =>
    sub.permission === true || sub.permission === "";

const hasActiveChild = (item) =>
    item.subMenu?.some(
        (sub) => isSubmenuItemVisible(sub) && isRouteActive(sub.url),
    );

const isItemActive = (item) => {
    if (item.subMenu) {
        return hasActiveChild(item);
    }
    return isRouteActive(item.url);
};

const isSubmenuOpen = (item) => !!openSubmenus[sectionId(item)];

const toggleSubmenu = (item) => {
    const id = sectionId(item);
    openSubmenus[id] = !openSubmenus[id];
};

for (const item of menuItems.value) {
    if (item.subMenu && hasActiveChild(item)) {
        openSubmenus[sectionId(item)] = true;
    }
}
</script>

<style scoped>
/* ── Sidebar shell ────────────────────────────────────────── */
.zabi-sidebar.sidebar {
    background: linear-gradient(
        175deg,
        color-mix(in srgb, var(--theme-primary) 55%, #000) 0%,
        color-mix(in srgb, var(--theme-primary) 72%, #000) 35%,
        var(--theme-primary) 80%,
        color-mix(in srgb, var(--theme-primary) 88%, #fff) 100%
    ) !important;
    box-shadow:
        4px 0 24px rgba(7, 36, 23, 0.35),
        inset -1px 0 0 rgba(255, 255, 255, 0.04);
}

.zabi-sidebar :deep(.sidebar-content),
body[data-theme="dark"] .zabi-sidebar :deep(.sidebar-content) {
    background: transparent !important;
}

/* ── Brand / logo area ────────────────────────────────────── */
.zabi-sidebar__brand {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1.5rem 1rem 1.25rem;
    margin: 0 0.75rem 0.5rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.07);
    text-decoration: none;
    position: relative;
}

/* Subtle gold glow under logo */
.zabi-sidebar__brand::after {
    content: "";
    position: absolute;
    bottom: -1px;
    left: 20%;
    right: 20%;
    height: 1px;
    background: linear-gradient(
        90deg,
        transparent,
        rgba(var(--theme-accent-rgb), 0.5),
        transparent
    );
}

.zabi-sidebar__brand-inner {
    display: inline-flex;
    align-items: center;
    max-width: 100%;
}

.zabi-sidebar__brand :deep(img) {
    max-height: 2.6rem;
    max-width: 160px;
    width: auto;
    object-fit: contain;
    filter: brightness(1.1) drop-shadow(0 1px 3px rgba(0, 0, 0, 0.25));
}

/* ── Nav list ─────────────────────────────────────────────── */
.zabi-sidebar__nav {
    padding: 0.5rem 0.75rem 1.5rem;
}

.zabi-sidebar__item {
    margin-bottom: 0.15rem;
}

/* ── Nav link base ────────────────────────────────────────── */
.zabi-sidebar__link {
    display: flex;
    align-items: center;
    gap: 0.7rem;
    padding: 0.58rem 0.9rem !important;
    margin: 0 !important;
    border-radius: 10px;
    border-inline: none !important;
    font-weight: 500;
    font-size: 0.875rem;
    letter-spacing: 0.01em;
    color: rgba(255, 255, 255, 0.72) !important;
    background: transparent !important;
    transition:
        background 0.18s ease,
        color 0.18s ease,
        box-shadow 0.18s ease;
    text-decoration: none;
}

.zabi-sidebar__link:hover {
    color: #fff !important;
    background: rgba(255, 255, 255, 0.09) !important;
    box-shadow: none !important;
}

/* ── Icon wrap ────────────────────────────────────────────── */
.zabi-sidebar__icon-wrap {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    width: 1.875rem;
    height: 1.875rem;
    border-radius: 7px;
    background: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.06);
    transition:
        background 0.18s ease,
        border-color 0.18s ease;
}

.zabi-sidebar__link:hover .zabi-sidebar__icon-wrap {
    background: rgba(255, 255, 255, 0.14);
    border-color: rgba(255, 255, 255, 0.1);
}

.zabi-sidebar__icon {
    width: 18px;
    height: 18px;
    object-fit: contain;
    flex-shrink: 0;
    margin-right: 0 !important;
}

/* ── Label ────────────────────────────────────────────────── */
.zabi-sidebar__label {
    flex: 1;
    min-width: 0;
    text-align: start;
}

/* ── Parent toggle ────────────────────────────────────────── */
.zabi-sidebar__link--parent {
    padding-inline-end: 0.55rem !important;
}

.zabi-sidebar__chevron {
    flex-shrink: 0;
    width: 0.42rem;
    height: 0.42rem;
    margin-inline-start: 0.2rem;
    border-right: 2px solid rgba(255, 255, 255, 0.38);
    border-bottom: 2px solid rgba(255, 255, 255, 0.38);
    transform: rotate(-45deg);
    transition: transform 0.22s ease;
}

.zabi-sidebar__item--open .zabi-sidebar__chevron {
    transform: rotate(45deg);
}

/* ── ACTIVE link — gold highlight ─────────────────────────── */
.zabi-sidebar__item.active > .zabi-sidebar__link:not(.zabi-sidebar__link--sub) {
    color: #fff !important;
    background: rgba(var(--theme-accent-rgb), 0.18) !important;
    box-shadow:
        inset 0 0 0 1px rgba(var(--theme-accent-rgb), 0.38),
        0 2px 8px rgba(var(--theme-accent-rgb), 0.12) !important;
}

.zabi-sidebar__item.active
    > .zabi-sidebar__link:not(.zabi-sidebar__link--sub)
    .zabi-sidebar__icon-wrap {
    background: rgba(var(--theme-accent-rgb), 0.22);
}

.zabi-sidebar__item.active
    > .zabi-sidebar__link:not(.zabi-sidebar__link--sub)
    .sidebar_icon {
    filter: brightness(0) saturate(100%) invert(75%) sepia(50%) saturate(600%)
        hue-rotate(10deg) brightness(1.1);
}

/* ── Submenu dropdown ─────────────────────────────────────── */
.zabi-sidebar__dropdown {
    margin: 0.1rem 0 0.3rem;
    padding-block: 0.1rem !important;
    padding-inline: 0.3rem 0 !important;
    border-inline-start: 2px solid rgba(var(--theme-accent-rgb), 0.2);
    margin-inline-start: 1.65rem;
}

.zabi-sidebar__link--sub {
    padding-block: 0.38rem !important;
    padding-inline: 0.8rem 0.75rem !important;
    font-size: 0.835rem;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.58) !important;
    border-radius: 8px;
}

.zabi-sidebar__link--sub:hover {
    color: rgba(255, 255, 255, 0.9) !important;
    background: rgba(255, 255, 255, 0.07) !important;
}

.zabi-sidebar__subitem.active .zabi-sidebar__link--sub {
    color: #fff !important;
    background: rgba(var(--theme-accent-rgb), 0.14) !important;
    box-shadow: none !important;
}

.zabi-sidebar__subitem.active .zabi-sidebar__link--sub:hover {
    background: rgba(var(--theme-accent-rgb), 0.2) !important;
}
</style>
