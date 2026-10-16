<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-3">
                <h1 class="h3 d-inline align-middle">
                    <strong>{{ $t("role.title") }}</strong>
                </h1>
                <a
                    href=""
                    v-if="$canAccess('create_roles')"
                    @click.prevent="isModalActive = true"
                    class="btn bg-primary text-white float-end"
                >
                    {{ $t("common.add_item", { item: $t("role.singular") }) }}
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
                                    <th>{{ $t("common.name") }}</th>
                                    <th class="text-center">
                                        {{ $t("common.action") }}
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="role in roleList">
                                    <td>{{ role.name }}</td>
                                    <td class="table-action text-center">
                                        <template v-if="!role.is_default">
                                            <a
                                                href=""
                                                v-if="
                                                    $canAccess('update_roles')
                                                "
                                                @click.prevent="editRole(role)"
                                                class="text-decoration-none"
                                            >
                                                <img
                                                    class="action_icon"
                                                    :src="
                                                        urlGenerator(
                                                            'assets/img/icons/edit.svg',
                                                        )
                                                    "
                                                    alt=""
                                                />
                                            </a>
                                            <a
                                                href="#"
                                                v-if="
                                                    $canAccess('delete_roles')
                                                "
                                                @click.prevent="
                                                    deleteRole(role)
                                                "
                                                class="text-decoration-none delete-btn"
                                            >
                                                <img
                                                    class="action_icon"
                                                    :src="
                                                        urlGenerator(
                                                            'assets/img/icons/trash.svg',
                                                        )
                                                    "
                                                    alt=""
                                                />
                                            </a>
                                        </template>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <role-modal
            v-if="isModalActive"
            modal-id="role-modal"
            :data="{ permissions: permissions }"
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
import RoleModal from "@/components/role/roleModal.vue";
import useEmitter from "@/composable/useEmitter.js";
import { useOpenModal } from "@/composable/useOpenModal.js";
import { useDeleteModal } from "@/composable/useDeleteModal.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { debounce as _debounce } from "lodash";

const { isModalActive, selectedData, closeModal } = useOpenModal();
const { deleteUrl, isDeleteModal, cancelled } = useDeleteModal();

const roleList = ref({});
const preloader = ref(false);

const search = ref("");

const getSearchValue = _debounce(() => {
    if (search.value) {
        getRoles(search.value);
    } else {
        getRoles();
    }
}, 500);
const getRoles = (search = "") => {
    preloader.value = true;
    Axios.get(`roles?search=${search}`)
        .then((data) => {
            roleList.value = data.data;
        })
        .finally(() => (preloader.value = false));
};

const editRole = (row) => {
    isModalActive.value = true;
    selectedData.value = `roles/${row.id}`;
};

const deleteRole = (row) => {
    isDeleteModal.value = true;
    deleteUrl.value = `roles/${row.id}`;
};
const emitter = useEmitter();
const reloadDataTable = () => {
    emitter.on("reload-table", (value = true) => {
        if (value) {
            getRoles();
        }
    });
};

const permissions = ref([]);
const getPermission = () => {
    Axios.get("permissions").then(({ data }) => (permissions.value = data));
};
onMounted(() => {
    getRoles();
    getPermission();
    reloadDataTable();
});
</script>

<style scoped></style>
