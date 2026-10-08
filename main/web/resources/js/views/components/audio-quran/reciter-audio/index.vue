<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-3">
                <h1 class="h3 d-inline align-middle">
                    <strong
                        >{{ props.reciter.name }}
                        {{ $t("reciter_audio.title") }}</strong
                    >
                </h1>
                <span class="text-muted ms-2" v-if="dataSetList.total"
                    >({{ dataSetList.total }}
                    {{ $t("reciter_audio.suras_count") }})</span
                >
                <a
                    href=""
                    v-if="$canAccess('create_reciter_sura')"
                    @click.prevent="isModalActive = true"
                    class="btn bg-primary text-white float-end"
                >
                    {{ $t("reciter_audio.add") }}
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
                                    <th scope="col" style="width: 45%">
                                        {{ $t("reciter_audio.table.sura") }}
                                    </th>
                                    <th scope="col" style="width: 20%">
                                        {{
                                            $t(
                                                "reciter_audio.table.sura_number",
                                            )
                                        }}
                                    </th>
                                    <th scope="col" style="width: 20%">
                                        {{ $t("reciter_audio.table.duration") }}
                                    </th>
                                    <th scope="col" style="width: 22%">
                                        {{ $t("reciter_audio.table.play") }}
                                    </th>
                                    <th
                                        scope="col"
                                        class="text-end"
                                        style="width: 15%"
                                    >
                                        {{ $t("common.action") }}
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <template v-if="dataSetList.data?.length">
                                    <tr
                                        v-for="dataObj in dataSetList.data"
                                        :key="dataObj.id"
                                    >
                                        <td width="30%">
                                            <div
                                                class="d-flex align-items-center"
                                            >
                                                <span class="sura-icon">
                                                    <img
                                                        :src="
                                                            urlGenerator(
                                                                'assets/img/icons/audio.png',
                                                            )
                                                        "
                                                        alt=""
                                                    />
                                                </span>
                                                <div class="ms-3">
                                                    <span class="fw-bold">{{
                                                        dataObj.name
                                                    }}</span>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span
                                                class="badge badge-info-light"
                                                >{{ dataObj.number }}</span
                                            >
                                        </td>
                                        <td class="text-muted">
                                            ⏱️
                                            {{
                                                formatDuration(dataObj.duration)
                                            }}
                                        </td>
                                        <td>
                                            <div
                                                class="audio-player"
                                                :class="{
                                                    'audio-player--active':
                                                        isActive(dataObj.id),
                                                }"
                                            >
                                                <button
                                                    type="button"
                                                    class="audio-btn"
                                                    :title="
                                                        isPlaying(dataObj.id)
                                                            ? $t(
                                                                  'reciter_audio.pause',
                                                              )
                                                            : $t(
                                                                  'reciter_audio.listen',
                                                              )
                                                    "
                                                    @click.prevent="
                                                        togglePlay(dataObj)
                                                    "
                                                >
                                                    <svg
                                                        v-if="
                                                            isPlaying(
                                                                dataObj.id,
                                                            )
                                                        "
                                                        class="audio-ico"
                                                        viewBox="0 0 24 24"
                                                        aria-hidden="true"
                                                    >
                                                        <rect
                                                            x="6"
                                                            y="5"
                                                            width="4"
                                                            height="14"
                                                            rx="1"
                                                        ></rect>
                                                        <rect
                                                            x="14"
                                                            y="5"
                                                            width="4"
                                                            height="14"
                                                            rx="1"
                                                        ></rect>
                                                    </svg>
                                                    <svg
                                                        v-else
                                                        class="audio-ico"
                                                        viewBox="0 0 24 24"
                                                        aria-hidden="true"
                                                    >
                                                        <path
                                                            d="M8 5.14v13.72a1 1 0 0 0 1.54.84l10.29-6.86a1 1 0 0 0 0-1.68L9.54 4.3A1 1 0 0 0 8 5.14z"
                                                        ></path>
                                                    </svg>
                                                </button>

                                                <div
                                                    class="audio-track"
                                                    @click="
                                                        seek($event, dataObj)
                                                    "
                                                >
                                                    <div
                                                        class="audio-progress"
                                                        :style="{
                                                            width:
                                                                (isActive(
                                                                    dataObj.id,
                                                                )
                                                                    ? playerProgress
                                                                    : 0) + '%',
                                                        }"
                                                    ></div>
                                                </div>

                                                <span class="audio-time">
                                                    {{
                                                        isActive(dataObj.id)
                                                            ? formatClock(
                                                                  playerCurrentTime,
                                                              )
                                                            : "0:00"
                                                    }}
                                                </span>

                                                <a
                                                    :href="
                                                        urlGenerator(
                                                            dataObj.path,
                                                        )
                                                    "
                                                    target="_blank"
                                                    class="audio-download"
                                                    :title="
                                                        $t(
                                                            'reciter_audio.table.view_file',
                                                        )
                                                    "
                                                >
                                                    <svg
                                                        class="audio-ico-sm"
                                                        viewBox="0 0 24 24"
                                                        aria-hidden="true"
                                                    >
                                                        <path
                                                            d="M14 3h7v7"
                                                            fill="none"
                                                            stroke="currentColor"
                                                            stroke-width="2"
                                                            stroke-linecap="round"
                                                            stroke-linejoin="round"
                                                        ></path>
                                                        <path
                                                            d="M21 3l-9 9"
                                                            fill="none"
                                                            stroke="currentColor"
                                                            stroke-width="2"
                                                            stroke-linecap="round"
                                                            stroke-linejoin="round"
                                                        ></path>
                                                        <path
                                                            d="M20 14v5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h5"
                                                            fill="none"
                                                            stroke="currentColor"
                                                            stroke-width="2"
                                                            stroke-linecap="round"
                                                            stroke-linejoin="round"
                                                        ></path>
                                                    </svg>
                                                </a>
                                            </div>
                                        </td>

                                        <td class="table-action">
                                            <div
                                                class="action-icons d-flex justify-content-end"
                                            >
                                                <div
                                                    v-if="
                                                        $canAccess(
                                                            'update_reciter_sura',
                                                        )
                                                    "
                                                >
                                                    <a
                                                        @click.prevent="
                                                            editData(dataObj)
                                                        "
                                                        :title="
                                                            $t('common.edit')
                                                        "
                                                    >
                                                        <img
                                                            class="action_icon"
                                                            :src="
                                                                urlGenerator(
                                                                    'assets/img/icons/edit.svg',
                                                                )
                                                            "
                                                            alt="Edit Icon"
                                                        />
                                                    </a>
                                                </div>
                                                <div
                                                    v-if="
                                                        $canAccess(
                                                            'delete_reciter_sura',
                                                        )
                                                    "
                                                >
                                                    <a
                                                        @click.prevent="
                                                            deleteData(dataObj)
                                                        "
                                                        :title="
                                                            $t(
                                                                'reciter_audio.delete',
                                                            )
                                                        "
                                                    >
                                                        <img
                                                            class="action_icon"
                                                            :src="
                                                                urlGenerator(
                                                                    'assets/img/icons/trash.svg',
                                                                )
                                                            "
                                                            alt="Trash Icon"
                                                        />
                                                    </a>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </template>

                                <tr v-else>
                                    <td colspan="5" class="text-center py-5">
                                        <div class="empty-state">
                                            <div class="empty-icon">🎙️</div>
                                            <div
                                                class="fw-semibold text-dark mt-3"
                                            >
                                                {{
                                                    $t(
                                                        "reciter_audio.empty.title",
                                                    )
                                                }}
                                            </div>
                                            <div class="text-muted small mt-1">
                                                {{
                                                    search
                                                        ? $t(
                                                              "reciter_audio.empty.search_hint",
                                                          )
                                                        : $t(
                                                              "reciter_audio.empty.default_hint",
                                                          )
                                                }}
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
        <add-audio-sura-modal
            v-if="isModalActive"
            modal-id="reciter-modal"
            :selected-url="selectedData"
            :reciter-id="props.reciter.id"
            :reciter-name="props.reciter.name"
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
import { onMounted, onBeforeUnmount, ref } from "vue";
import Axios from "@/services/axios/index.js";
import useEmitter from "@/composable/useEmitter.js";
import { useOpenModal } from "@/composable/useOpenModal.js";
import { useDeleteModal } from "@/composable/useDeleteModal.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import AddAudioSuraModal from "@/components/audio-quran/reciter-audio/addSuraModal.vue";

const { isModalActive, selectedData, closeModal } = useOpenModal();
const { deleteUrl, isDeleteModal, cancelled } = useDeleteModal();
import { debounce as _debounce } from "lodash";

const props = defineProps({
    reciter: Object,
});

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
    Axios.get(
        `reciter-sura-list/${props.reciter.id}?page=${page}&search=${search}`,
    )
        .then((data) => {
            dataSetList.value = data.data;
        })
        .finally(() => (preloader.value = false));
};

const editData = (row) => {
    isModalActive.value = true;
    selectedData.value = `reciter-sura/${row.id}`;
};
const deleteData = (row) => {
    isDeleteModal.value = true;
    deleteUrl.value = `reciter-sura/${row.id}`;
};
const emitter = useEmitter();
const reloadDataTable = () => {
    emitter.on("reload-table", (value = true) => {
        console.log("value");
        if (value) {
            getServerData();
        }
    });
};
const formatDuration = (seconds) => {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    const hoursDisplay = hrs > 0 ? `${hrs}h ` : "";
    const minutesDisplay = mins > 0 ? `${mins}m ` : "";
    const secondsDisplay = secs > 0 ? `${secs}s` : "";

    return `${hoursDisplay}${minutesDisplay}${secondsDisplay}`.trim();
};

// ---- Inline audio player -------------------------------------------------
// A single shared <audio> element plays one sura at a time; starting another
// row automatically stops the previous one.
const activeId = ref(null);
const isPaused = ref(true);
const playerProgress = ref(0); // 0-100 for the active track
const playerCurrentTime = ref(0); // seconds
let audioEl = null;

const isActive = (id) => activeId.value === id;
const isPlaying = (id) => activeId.value === id && !isPaused.value;

const ensureAudioEl = () => {
    if (audioEl) return audioEl;
    audioEl = new Audio();
    audioEl.addEventListener("timeupdate", () => {
        playerCurrentTime.value = audioEl.currentTime;
        playerProgress.value = audioEl.duration
            ? (audioEl.currentTime / audioEl.duration) * 100
            : 0;
    });
    audioEl.addEventListener("ended", () => {
        isPaused.value = true;
        playerProgress.value = 0;
        playerCurrentTime.value = 0;
    });
    audioEl.addEventListener("pause", () => {
        isPaused.value = true;
    });
    audioEl.addEventListener("play", () => {
        isPaused.value = false;
    });
    return audioEl;
};

const togglePlay = (row) => {
    const el = ensureAudioEl();

    // Same row: just toggle play/pause.
    if (activeId.value === row.id) {
        isPaused.value ? el.play() : el.pause();
        return;
    }

    // Different row: switch source and start from the beginning.
    el.pause();
    el.src = urlGenerator(row.path);
    activeId.value = row.id;
    playerProgress.value = 0;
    playerCurrentTime.value = 0;
    el.play().catch(() => {
        isPaused.value = true;
    });
};

const seek = (event, row) => {
    if (activeId.value !== row.id || !audioEl || !audioEl.duration) return;
    const rect = event.currentTarget.getBoundingClientRect();
    const ratio = Math.min(
        Math.max((event.clientX - rect.left) / rect.width, 0),
        1,
    );
    audioEl.currentTime = ratio * audioEl.duration;
};

const formatClock = (seconds) => {
    if (!seconds || isNaN(seconds)) return "0:00";
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, "0")}`;
};

onMounted(() => {
    getServerData();
    reloadDataTable();
});

onBeforeUnmount(() => {
    if (audioEl) {
        audioEl.pause();
        audioEl.src = "";
        audioEl = null;
    }
});
</script>

<style scoped>
.profile-picture {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    object-fit: cover;
}

.fw-bold {
    font-weight: 600;
}

.audio-player {
    display: flex;
    align-items: center;
    gap: 10px;
    max-width: 260px;
}

.audio-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 34px;
    height: 34px;
    flex-shrink: 0;
    border: none;
    border-radius: 50%;
    background: var(--z-green-500, #12b76a);
    color: #fff;
    font-size: 1.05rem;
    line-height: 1;
    cursor: pointer;
    transition:
        background 0.15s ease,
        transform 0.1s ease;
}

.audio-btn:hover {
    background: var(--z-green-600, #0f9d58);
}

.audio-btn:active {
    transform: scale(0.94);
}

.audio-ico {
    width: 16px;
    height: 16px;
    fill: #fff;
    display: block;
}

.audio-ico-sm {
    width: 15px;
    height: 15px;
    display: block;
}

.audio-track {
    position: relative;
    flex: 1;
    height: 6px;
    min-width: 70px;
    border-radius: 6px;
    background: #e6e8eb;
    cursor: pointer;
    overflow: hidden;
}

.audio-progress {
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
    border-radius: 6px;
    background: var(--z-green-500, #12b76a);
    transition: width 0.15s linear;
}

.audio-time {
    font-size: 0.75rem;
    color: #667085;
    font-variant-numeric: tabular-nums;
    min-width: 34px;
    text-align: right;
}

.audio-download {
    color: #98a2b3;
    font-size: 0.9rem;
    flex-shrink: 0;
    display: inline-flex;
}

.audio-download:hover {
    color: var(--z-green-600, #0f9d58);
}

.audio-player--active .audio-time {
    color: var(--z-green-600, #0f9d58);
    font-weight: 600;
}

.sura-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    flex-shrink: 0;
    border-radius: 50%;
    background: var(--z-green-50, #f0faf5);
}

.sura-icon img {
    width: 16px;
    height: 16px;
    opacity: 0.8;
}

.empty-state {
    padding: 20px 0;
}

.empty-icon {
    font-size: 2.5rem;
}
</style>
