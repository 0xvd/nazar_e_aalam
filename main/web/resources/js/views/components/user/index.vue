<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-3">
                <h1 class="h3 d-inline align-middle">
                    <strong>{{ $t("user.title") }}</strong>
                </h1>
                <a
                    href=""
                    v-if="$canAccess('invite_user')"
                    @click.prevent="isModalActive = true"
                    class="btn bg-primary text-white float-end"
                >
                    {{ $t("user.invite_user") }}
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
                                    <th>{{ $t("user.table.image") }}</th>
                                    <th>{{ $t("user.table.first_name") }}</th>
                                    <th>{{ $t("user.table.last_name") }}</th>
                                    <th>{{ $t("user.table.email") }}</th>
                                    <th>{{ $t("user.table.role") }}</th>
                                    <th class="text-end">
                                        {{ $t("common.action") }}
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="user in userList.data">
                                    <td>
                                        <img
                                            class="datatable_img"
                                            :src="
                                                user?.profile?.profile_picture
                                            "
                                            alt=""
                                        />
                                    </td>
                                    <td>{{ user.first_name }}</td>
                                    <td>{{ user.last_name }}</td>
                                    <td>{{ user.email }}</td>
                                    <td>
                                        <template v-if="user.role">
                                            {{ user.role.name }}
                                        </template>
                                    </td>
                                    <td class="table-action text-end">
                                        <a
                                            href="#"
                                            v-if="$canAccess('delete_users')"
                                            @click.prevent="deleteData(user)"
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
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <app-pagination
                        :data="userList"
                        @pagination-change-page="getServerData"
                    />
                </div>
            </div>
        </div>
        <user-invite-modal
            v-if="isModalActive"
            modal-id="invite-modal"
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
import UserInviteModal from "@/components/user/userInviteModal.vue";
import useEmitter from "@/composable/useEmitter.js";
import { useOpenModal } from "@/composable/useOpenModal.js";
import { useDeleteModal } from "@/composable/useDeleteModal.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { debounce as _debounce } from "lodash";

const { isModalActive, closeModal } = useOpenModal();
const { deleteUrl, isDeleteModal, cancelled } = useDeleteModal();

const userList = ref({});
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
    Axios.get(`users?page=${page}&search=${search}`)
        .then((data) => {
            userList.value = data.data;
        })
        .finally(() => (preloader.value = false));
};

const deleteData = (row) => {
    isDeleteModal.value = true;
    deleteUrl.value = `users/${row.id}`;
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
