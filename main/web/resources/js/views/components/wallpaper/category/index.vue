<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1 class="h3 fw-bold mb-0">
                    {{ $t("wallpaper_category.title") }}
                </h1>
                <button
                    v-if="$canAccess('create_wallpaper_category')"
                    @click.prevent="isModalActive = true"
                    class="btn btn-primary"
                >
                    {{ $t("wallpaper_category.add") }}
                </button>
            </div>

            <div class="mb-4 d-flex justify-content-end">
                <input
                    type="text"
                    class="form-control"
                    v-model="search"
                    @input="getSearchValue"
                    :placeholder="$t('wallpaper_category.search_placeholder')"
                    style="max-width: 280px"
                />
            </div>

            <app-loader v-if="preloader" />

            <div v-else class="category-grid">
                <div
                    class="category-card"
                    v-for="dataObj in dataSetList.data"
                    :key="dataObj.id"
                >
                    <div class="card-content">
                        <h5 class="category-title">{{ dataObj.name }}</h5>
                        <p class="category-subtitle">
                            {{
                                $t("wallpaper_category.total_wallpaper", {
                                    count: dataObj.wallpapers_count || 0,
                                })
                            }}
                        </p>
                        <div class="category-actions">
                            <button
                                class="action-btn"
                                v-if="$canAccess('update_wallpaper_category')"
                                @click.prevent="editData(dataObj)"
                            >
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/edit.svg',
                                        )
                                    "
                                    alt="Edit"
                                />
                            </button>
                            <button
                                class="action-btn"
                                v-if="$canAccess('delete_wallpaper_category')"
                                @click.prevent="deleteData(dataObj)"
                            >
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/trash.svg',
                                        )
                                    "
                                    alt="Delete"
                                />
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-5 d-flex justify-content-center">
                <app-pagination
                    :data="dataSetList"
                    @pagination-change-page="getServerData"
                />
            </div>

            <wallpaper-category-modal
                v-if="isModalActive"
                modal-id="wallpaper-category-modal"
                :selected-url="selectedData"
                @close="closeModal"
            />

            <app-delete-modal
                v-if="isDeleteModal"
                :selected-url="deleteUrl"
                @cancelled="cancelled"
            />
        </div>
    </main>
</template>

<style scoped>
.category-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 24px;
    margin-top: 1rem;
}

.category-card {
    background: var(--theme-card);
    border-radius: 12px;
    box-shadow: 0 4px 12px rgb(0 0 0 / 0.05);
    cursor: pointer;
    overflow: hidden;
    transition:
        transform 0.3s ease,
        box-shadow 0.3s ease;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 24px;
    position: relative;
}

.category-card:hover {
    transform: scale(1.05);
    box-shadow: 0 12px 24px rgb(0 0 0 / 0.15);
    z-index: 5;
}

.card-content {
    display: flex;
    flex-direction: column;
    height: 100%;
    justify-content: space-between;
}

.category-title {
    font-weight: 700;
    font-size: 1.2rem;
    color: #1f2937; /* Dark slate gray */
    margin-bottom: 8px;
}

.category-subtitle {
    font-size: 0.9rem;
    color: #6b7280; /* Gray-500 */
    margin-bottom: 16px;
}

.category-actions {
    display: flex;
    gap: 12px;
}

.action-btn {
    background-color: #f3f4f6;
    border: none;
    border-radius: 8px;
    padding: 8px 10px;
    transition: background-color 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
}

.action-btn:hover {
    background-color: #e5e7eb;
}

.action-btn img {
    width: 18px;
    height: 18px;
}
</style>

<script setup>
import { onMounted, ref } from "vue";
import Axios from "@/services/axios/index.js";
import useEmitter from "@/composable/useEmitter.js";
import { useOpenModal } from "@/composable/useOpenModal.js";
import { useDeleteModal } from "@/composable/useDeleteModal.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import WallpaperCategoryModal from "./categoryModal.vue";
const { isModalActive, selectedData, closeModal } = useOpenModal();
const { deleteUrl, isDeleteModal, cancelled } = useDeleteModal();
import { debounce as _debounce } from "lodash";

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
const getServerData = (page = 1, search = "") => {
    preloader.value = true;
    Axios.get(`wallpaper-category?page=${page}&search=${search}`)
        .then((data) => {
            dataSetList.value = data.data;
        })
        .finally(() => (preloader.value = false));
};

const editData = (row) => {
    isModalActive.value = true;
    selectedData.value = `wallpaper-category/${row.id}`;
};
const deleteData = (row) => {
    isDeleteModal.value = true;
    deleteUrl.value = `wallpaper-category/${row.id}`;
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
