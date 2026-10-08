<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-3">
                <h1 class="h3 d-inline align-middle">
                    <strong>{{ $t("sifat.title") }}</strong>
                </h1>
                <a
                    href=""
                    v-if="$canAccess('create_sifats')"
                    @click.prevent="isModalActive = true"
                    class="btn bg-primary text-white float-end"
                >
                    {{ $t("common.add_item", { item: $t("sifat.singular") }) }}
                </a>
            </div>
        </div>

        <div
            class="search-container d-flex justify-content-end align-items-center"
        >
            <input
                type="text"
                class="form-control"
                v-model="search"
                @input="getSearchValue()"
                :placeholder="$t('common.search')"
            />
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <app-loader v-if="preloader" />
                    <div v-else class="table-responsive">
                        <table class="table mb-3">
                            <thead>
                                <tr>
                                    <th scope="col" style="width: 10%">
                                        {{ $t("sifat.table.name_en") }}
                                    </th>
                                    <th scope="col" style="width: 5%">
                                        {{ $t("sifat.table.name_ar") }}
                                    </th>
                                    <th scope="col" style="width: 10%">
                                        {{ $t("sifat.table.translated_name") }}
                                    </th>
                                    <th scope="col" style="width: 30%">
                                        {{ $t("sifat.table.meaning") }}
                                    </th>
                                    <th scope="col" style="width: 30%">
                                        {{ $t("sifat.table.name_benefits") }}
                                    </th>
                                    <th scope="col" style="width: 5%">
                                        {{ $t("common.position") }}
                                    </th>
                                    <th
                                        scope="col"
                                        class="text-end"
                                        style="width: 2%"
                                    >
                                        {{ $t("common.action") }}
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="dataObj in dataSetList.data">
                                    <td>{{ dataObj.name }}</td>
                                    <td>{{ dataObj.ar_name }}</td>
                                    <td>{{ dataObj.translated_name }}</td>
                                    <td>{{ dataObj.meaning }}</td>
                                    <td>{{ dataObj.name_benefits }}</td>
                                    <td>{{ dataObj.position }}</td>

                                    <td class="table-action">
                                        <div class="row">
                                            <div
                                                class="col-md-6"
                                                v-if="
                                                    $canAccess('update_sifats')
                                                "
                                            >
                                                <a
                                                    @click.prevent="
                                                        editData(dataObj)
                                                    "
                                                >
                                                    <img
                                                        class="action_icon"
                                                        :src="
                                                            urlGenerator(
                                                                'assets/img/icons/edit.svg',
                                                            )
                                                        "
                                                        alt="Icon"
                                                    />
                                                </a>
                                            </div>
                                            <div
                                                class="col-md-6 pull-left"
                                                v-if="
                                                    $canAccess('delete_sifats')
                                                "
                                            >
                                                <a
                                                    @click.prevent="
                                                        deleteData(dataObj)
                                                    "
                                                >
                                                    <img
                                                        class="action_icon"
                                                        :src="
                                                            urlGenerator(
                                                                'assets/img/icons/trash.svg',
                                                            )
                                                        "
                                                        alt="Icon"
                                                    />
                                                </a>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <app-pagination
                        :data="dataSetList"
                        @pagination-change-page="getServerData"
                    />
                </div>
            </div>
        </div>
        <sifat-modal
            v-if="isModalActive"
            modal-id="sifat-modal"
            :selected-url="selectedData"
            @close="closeModal"
        />

        <app-delete-modal
            v-if="isDeleteModal"
            :selected-url="deleteUrl"
            @cancelled="cancelled"
        />
    </main>
</template>

<script setup>
import { onMounted, ref } from "vue";
import Axios from "@/services/axios/index.js";
import useEmitter from "@/composable/useEmitter.js";
import { useOpenModal } from "@/composable/useOpenModal.js";
import { useDeleteModal } from "@/composable/useDeleteModal.js";
import SifatModal from "@/components/sifat/sifatModal.vue";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { debounce as _debounce } from "lodash";

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
const getServerData = (page = 1, search = "") => {
    preloader.value = true;
    Axios.get(`sifats?page=${page}&search=${search}`)
        .then((data) => {
            dataSetList.value = data.data;
        })
        .finally(() => (preloader.value = false));
};

const editData = (row) => {
    isModalActive.value = true;
    selectedData.value = `sifats/${row.id}`;
};
const deleteData = (row) => {
    isDeleteModal.value = true;
    deleteUrl.value = `sifats/${row.id}`;
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

<style scoped></style>
