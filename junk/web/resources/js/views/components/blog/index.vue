<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-3">
                <h1 class="h3 d-inline align-middle">
                    <strong>{{ $t("blog.title") }}</strong>
                </h1>
                <a
                    href=""
                    @click.prevent="isModalActive = true"
                    class="btn bg-primary text-white float-end"
                >
                    {{ $t("common.add_item", { item: $t("blog.singular") }) }}
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
                                    <th scope="col">
                                        {{ $t("blog.table.thumbnail") }}
                                    </th>
                                    <th scope="col">
                                        {{ $t("common.title") }}
                                    </th>
                                    <th scope="col">
                                        {{ $t("common.category") }}
                                    </th>
                                    <th scope="col">
                                        {{ $t("common.status") }}
                                    </th>
                                    <th scope="col">
                                        {{ $t("blog.table.published") }}
                                    </th>
                                    <th scope="col" class="text-end">
                                        {{ $t("common.action") }}
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="post in dataSetList.data"
                                    :key="post.id"
                                >
                                    <td>
                                        <img
                                            v-if="post.thumbnail"
                                            :src="urlGenerator(post.thumbnail)"
                                            alt=""
                                            style="
                                                width: 48px;
                                                height: 36px;
                                                object-fit: cover;
                                                border-radius: 6px;
                                            "
                                        />
                                        <span v-else>—</span>
                                    </td>
                                    <td>
                                        <div>{{ post.title }}</div>
                                        <small class="text-muted"
                                            >/blog/{{ post.slug }}</small
                                        >
                                    </td>
                                    <td>{{ post.category }}</td>
                                    <td>
                                        <span
                                            class="badge"
                                            :class="
                                                post.status === 'published'
                                                    ? 'bg-success'
                                                    : 'bg-warning text-dark'
                                            "
                                        >
                                            {{ post.status }}
                                        </span>
                                    </td>
                                    <td>
                                        {{
                                            post.published_at
                                                ? formatDate(post.published_at)
                                                : "—"
                                        }}
                                    </td>
                                    <td class="table-action">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <a
                                                    @click.prevent="
                                                        editData(post)
                                                    "
                                                >
                                                    <img
                                                        class="action_icon"
                                                        :src="
                                                            urlGenerator(
                                                                'assets/img/icons/edit.svg',
                                                            )
                                                        "
                                                        alt="Edit"
                                                    />
                                                </a>
                                            </div>
                                            <div class="col-md-6">
                                                <a
                                                    @click.prevent="
                                                        deleteData(post)
                                                    "
                                                >
                                                    <img
                                                        class="action_icon"
                                                        :src="
                                                            urlGenerator(
                                                                'assets/img/icons/trash.svg',
                                                            )
                                                        "
                                                        alt="Delete"
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

        <blog-post-modal
            v-if="isModalActive"
            modal-id="blog-post-modal"
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
import BlogPostModal from "@/components/blog/blogModal.vue";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { debounce as _debounce } from "lodash";

const { isModalActive, selectedData, closeModal } = useOpenModal();
const { deleteUrl, isDeleteModal, cancelled } = useDeleteModal();

const dataSetList = ref({});
const preloader = ref(false);
const search = ref("");

const formatDate = (d) =>
    new Date(d).toLocaleDateString("en-GB", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

const getSearchValue = _debounce(() => {
    getServerData(1, search.value || "");
}, 500);

const getServerData = (page = 1, searchVal = "") => {
    preloader.value = true;
    Axios.get(`blog-posts?page=${page}&search=${searchVal}`)
        .then(({ data }) => {
            dataSetList.value = data;
        })
        .finally(() => (preloader.value = false));
};

const editData = (row) => {
    isModalActive.value = true;
    selectedData.value = `blog-posts/${row.id}`;
};

const deleteData = (row) => {
    isDeleteModal.value = true;
    deleteUrl.value = `blog-posts/${row.id}`;
};

const emitter = useEmitter();

onMounted(() => {
    getServerData();
    emitter.on("reload-table", (value = true) => {
        if (value) getServerData();
    });
});
</script>
