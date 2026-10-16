<template>
    <main class="content wallpaper-module">
        <div class="container-fluid p-0">
            <header class="wallpaper-header">
                <div class="wallpaper-header-text">
                    <h1 class="wallpaper-title">{{ $t("wallpaper.title") }}</h1>
                    <p class="wallpaper-lede">{{ $t("wallpaper.lede") }}</p>
                </div>
                <button
                    v-if="$canAccess('view_wallpaper')"
                    type="button"
                    class="btn-add-wallpaper"
                    @click.prevent="isModalActive = true"
                >
                    <span class="btn-add-wallpaper-icon" aria-hidden="true"
                        >+</span
                    >
                    {{ $t("wallpaper.add") }}
                </button>
            </header>

            <div class="wallpaper-toolbar">
                <div class="search-field">
                    <span class="search-field-icon" aria-hidden="true">⌕</span>
                    <input
                        type="search"
                        class="search-field-input"
                        v-model="search"
                        @input="getSearchValue()"
                        :placeholder="$t('wallpaper.search_placeholder')"
                        autocomplete="off"
                    />
                </div>
            </div>

            <app-loader v-if="preloader" />

            <template v-else>
                <div v-if="!dataSetList.data?.length" class="wallpaper-empty">
                    <div class="wallpaper-empty-inner">
                        <p class="wallpaper-empty-title">
                            {{ $t("wallpaper.empty_title") }}
                        </p>
                        <p class="wallpaper-empty-copy">
                            {{
                                search
                                    ? $t("wallpaper.empty_search_copy")
                                    : $t("wallpaper.empty_copy")
                            }}
                        </p>
                        <button
                            v-if="$canAccess('view_wallpaper') && !search"
                            type="button"
                            class="btn-add-wallpaper btn-add-wallpaper--ghost"
                            @click.prevent="isModalActive = true"
                        >
                            {{ $t("wallpaper.add") }}
                        </button>
                    </div>
                </div>

                <div v-else class="wallpaper-grid">
                    <article
                        v-for="dataObj in dataSetList.data"
                        :key="dataObj.id"
                        class="wallpaper-card"
                    >
                        <div
                            class="wallpaper-card-media"
                            role="button"
                            tabindex="0"
                            @click.prevent="viewModal(dataObj)"
                            @keydown.enter.prevent="viewModal(dataObj)"
                            @keydown.space.prevent="viewModal(dataObj)"
                        >
                            <img
                                :src="urlGenerator(dataObj.image)"
                                class="wallpaper-card-img"
                                :alt="dataObj.name || 'Wallpaper'"
                            />
                            <span
                                v-if="dataObj.category?.name"
                                class="wallpaper-card-badge"
                                >{{ dataObj.category.name }}</span
                            >
                            <div
                                class="wallpaper-card-media-shade"
                                aria-hidden="true"
                            ></div>
                        </div>
                        <div class="wallpaper-card-body">
                            <h2 class="wallpaper-card-name">
                                {{ dataObj.name }}
                            </h2>
                            <div class="wallpaper-card-actions">
                                <button
                                    v-if="$canAccess('view_wallpaper')"
                                    type="button"
                                    class="wp-action wp-action--view"
                                    :title="$t('wallpaper.view')"
                                    @click.prevent="viewModal(dataObj)"
                                >
                                    <img
                                        :src="
                                            urlGenerator(
                                                'assets/img/icons/file.png',
                                            )
                                        "
                                        alt=""
                                        width="18"
                                        height="18"
                                    />
                                    <span class="wp-action-label">{{
                                        $t("wallpaper.view")
                                    }}</span>
                                </button>
                                <button
                                    v-if="$canAccess('update_wallpaper')"
                                    type="button"
                                    class="wp-action wp-action--edit"
                                    :title="$t('wallpaper.edit')"
                                    @click.prevent="editData(dataObj)"
                                >
                                    <img
                                        :src="
                                            urlGenerator(
                                                'assets/img/icons/edit.svg',
                                            )
                                        "
                                        alt=""
                                        width="18"
                                        height="18"
                                    />
                                    <span class="wp-action-label">{{
                                        $t("wallpaper.edit")
                                    }}</span>
                                </button>
                                <button
                                    v-if="$canAccess('delete_wallpaper')"
                                    type="button"
                                    class="wp-action wp-action--delete"
                                    :title="$t('wallpaper.delete')"
                                    @click.prevent="deleteData(dataObj)"
                                >
                                    <img
                                        :src="
                                            urlGenerator(
                                                'assets/img/icons/trash.svg',
                                            )
                                        "
                                        alt=""
                                        width="18"
                                        height="18"
                                    />
                                    <span class="wp-action-label">{{
                                        $t("wallpaper.delete")
                                    }}</span>
                                </button>
                            </div>
                        </div>
                    </article>
                </div>

                <div
                    v-if="dataSetList.data?.length"
                    class="wallpaper-pagination"
                >
                    <app-pagination
                        :data="dataSetList"
                        @pagination-change-page="getServerData"
                    />
                </div>
            </template>
        </div>

        <wallpaper-modal
            v-if="isModalActive"
            modal-id="wallpaper-modal"
            :selected-url="selectedData"
            @close="closeModal"
        />

        <view-wallpaper-modal
            v-if="activeViewModal"
            modal-id="view-wallpaper-modal"
            :data="rowData"
            @close="activeViewModal = false"
        />

        <app-delete-modal
            v-if="isDeleteModal"
            :selected-url="deleteUrl"
            @cancelled="cancelled"
        />
    </main>
</template>

<script setup>
import { ref, onMounted } from "vue";
import Axios from "@/services/axios/index.js";
import useEmitter from "@/composable/useEmitter.js";
import { useOpenModal } from "@/composable/useOpenModal.js";
import { useDeleteModal } from "@/composable/useDeleteModal.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { debounce as _debounce } from "lodash";
import WallpaperModal from "@/components/wallpaper/wallpaperModal.vue";
import ViewWallpaperModal from "@/components/wallpaper/viewWallpaperModal.vue";

const { isModalActive, selectedData, closeModal } = useOpenModal();
const { deleteUrl, isDeleteModal, cancelled } = useDeleteModal();

const dataSetList = ref({});
const preloader = ref(false);
const search = ref("");

const getSearchValue = _debounce(() => {
    if (search.value) {
        getServerData(1, search.value);
    } else {
        getServerData(1);
    }
}, 500);

const getServerData = async (page = 1, search = "") => {
    preloader.value = true;
    try {
        const response = await Axios.get(
            `wallpaper?page=${page}&search=${search}`,
        );
        dataSetList.value = response.data;
    } catch (error) {
        console.error("Error fetching data:", error);
    } finally {
        preloader.value = false;
    }
};

const editData = (row) => {
    isModalActive.value = true;
    selectedData.value = `wallpaper/${row.id}`;
};

const rowData = ref({});
const activeViewModal = ref(false);
const viewModal = (row) => {
    activeViewModal.value = true;
    rowData.value = row;
};

const deleteData = (row) => {
    isDeleteModal.value = true;
    deleteUrl.value = `wallpaper/${row.id}`;
};

const emitter = useEmitter();
const reloadDataTable = () => {
    emitter.on("reload-table", (value = true) => {
        if (value) {
            getServerData();
        }
    });
};

onMounted(() => {
    getServerData();
    reloadDataTable();
});
</script>
<style scoped>
.wallpaper-module {
    --wp-surface: #ffffff;
    --wp-border: #e5e7eb;
    --wp-muted: #6b7280;
    --wp-text: #111827;
    --wp-accent: #2563eb;
    --wp-accent-soft: #eff6ff;
    --wp-danger: #dc2626;
    --wp-danger-soft: #fef2f2;
    --wp-radius: 14px;
    --wp-shadow:
        0 1px 2px rgba(15, 23, 42, 0.06), 0 8px 24px rgba(15, 23, 42, 0.06);
    --wp-shadow-hover:
        0 4px 12px rgba(15, 23, 42, 0.08), 0 16px 40px rgba(15, 23, 42, 0.1);
}

.wallpaper-header {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    justify-content: space-between;
    gap: 1rem;
    margin-bottom: 1.5rem;
    padding-bottom: 1.25rem;
    border-bottom: 1px solid var(--wp-border);
}

.wallpaper-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--wp-text);
    margin: 0 0 0.35rem;
    letter-spacing: -0.02em;
}

.wallpaper-lede {
    margin: 0;
    font-size: 0.9375rem;
    color: var(--wp-muted);
    max-width: 36rem;
    line-height: 1.5;
}

.btn-add-wallpaper {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.6rem 1.1rem;
    font-size: 0.9375rem;
    font-weight: 600;
    color: #fff;
    background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
    border: none;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(37, 99, 235, 0.35);
    transition:
        transform 0.15s ease,
        box-shadow 0.15s ease;
}

.btn-add-wallpaper:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 14px rgba(37, 99, 235, 0.45);
}

.btn-add-wallpaper-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 1.25rem;
    height: 1.25rem;
    font-size: 1.1rem;
    line-height: 1;
    opacity: 0.95;
}

.btn-add-wallpaper--ghost {
    background: var(--wp-accent-soft);
    color: var(--wp-accent);
    box-shadow: none;
}

.btn-add-wallpaper--ghost:hover {
    background: #dbeafe;
    box-shadow: none;
}

.wallpaper-toolbar {
    margin-bottom: 1.25rem;
}

.search-field {
    display: flex;
    align-items: center;
    gap: 0.65rem;
    max-width: 320px;
    margin-inline-start: auto;
    padding: 0.5rem 0.85rem;
    background: var(--wp-surface);
    border: 1px solid var(--wp-border);
    border-radius: 10px;
    box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
    transition:
        border-color 0.15s ease,
        box-shadow 0.15s ease;
}

.search-field:focus-within {
    border-color: #93c5fd;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
}

.search-field-icon {
    color: var(--wp-muted);
    font-size: 1rem;
    user-select: none;
}

.search-field-input {
    flex: 1;
    min-width: 0;
    border: none;
    background: transparent;
    font-size: 0.9375rem;
    color: var(--wp-text);
    outline: none;
}

.search-field-input::placeholder {
    color: #9ca3af;
}

.wallpaper-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(272px, 1fr));
    gap: 1.25rem;
}

.wallpaper-card {
    display: flex;
    flex-direction: column;
    background: var(--wp-surface);
    border-radius: var(--wp-radius);
    border: 1px solid var(--wp-border);
    box-shadow: var(--wp-shadow);
    overflow: hidden;
    transition:
        box-shadow 0.2s ease,
        transform 0.2s ease,
        border-color 0.2s ease;
}

.wallpaper-card:hover {
    box-shadow: var(--wp-shadow-hover);
    transform: translateY(-2px);
    border-color: #d1d5db;
}

.wallpaper-card-media {
    position: relative;
    aspect-ratio: 4 / 3;
    overflow: hidden;
    cursor: pointer;
    background: #f3f4f6;
}

.wallpaper-card-media:focus {
    outline: 2px solid var(--wp-accent);
    outline-offset: 2px;
}

.wallpaper-card-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    transition: transform 0.35s ease;
}

.wallpaper-card:hover .wallpaper-card-img {
    transform: scale(1.06);
}

.wallpaper-card-media-shade {
    position: absolute;
    inset: 0;
    background: linear-gradient(
        to top,
        rgba(15, 23, 42, 0.45) 0%,
        transparent 55%
    );
    opacity: 0.85;
    pointer-events: none;
}

.wallpaper-card-badge {
    position: absolute;
    inset-inline-start: 0.65rem;
    bottom: 0.65rem;
    z-index: 1;
    padding: 0.25rem 0.6rem;
    font-size: 0.75rem;
    font-weight: 600;
    color: #f9fafb;
    background: rgba(15, 23, 42, 0.55);
    backdrop-filter: blur(8px);
    border-radius: 6px;
    max-width: calc(100% - 1.3rem);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.wallpaper-card-body {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    padding: 1rem 1rem 1rem;
    flex: 1;
}

.wallpaper-card-name {
    margin: 0;
    font-size: 1rem;
    font-weight: 600;
    color: var(--wp-text);
    line-height: 1.35;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.wallpaper-card-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin-top: auto;
}

.wp-action {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.4rem;
    flex: 1 1 auto;
    min-width: calc(33.333% - 0.34rem);
    padding: 0.5rem 0.65rem;
    font-size: 0.8125rem;
    font-weight: 600;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition:
        background 0.15s ease,
        color 0.15s ease,
        transform 0.12s ease;
}

.wp-action img {
    flex-shrink: 0;
    opacity: 0.85;
}

.wp-action:hover img {
    opacity: 1;
}

.wp-action:active {
    transform: scale(0.98);
}

.wp-action--view {
    color: #1e40af;
    background: var(--wp-accent-soft);
}

.wp-action--view:hover {
    background: #dbeafe;
}

.wp-action--edit {
    color: #0f766e;
    background: #f0fdfa;
}

.wp-action--edit:hover {
    background: #ccfbf1;
}

.wp-action--delete {
    color: var(--wp-danger);
    background: var(--wp-danger-soft);
}

.wp-action--delete:hover {
    background: #fee2e2;
}

.wallpaper-pagination {
    display: flex;
    justify-content: center;
    margin-top: 2rem;
    padding-top: 0.5rem;
}

.wallpaper-empty {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 280px;
    padding: 2.5rem 1rem;
    background: linear-gradient(180deg, #f9fafb 0%, #f3f4f6 100%);
    border: 1px dashed var(--wp-border);
    border-radius: var(--wp-radius);
}

.wallpaper-empty-inner {
    text-align: center;
    max-width: 360px;
}

.wallpaper-empty-title {
    margin: 0 0 0.5rem;
    font-size: 1.125rem;
    font-weight: 700;
    color: var(--wp-text);
}

.wallpaper-empty-copy {
    margin: 0 0 1.25rem;
    font-size: 0.9375rem;
    color: var(--wp-muted);
    line-height: 1.55;
}

@media (max-width: 576px) {
    .search-field {
        max-width: none;
        margin-inline-start: 0;
    }

    .wp-action {
        min-width: calc(50% - 0.25rem);
    }

    .wp-action-label {
        display: none;
    }

    .wp-action {
        min-height: 44px;
    }
}

@media (min-width: 577px) {
    .wp-action-label {
        display: inline;
    }
}
</style>
