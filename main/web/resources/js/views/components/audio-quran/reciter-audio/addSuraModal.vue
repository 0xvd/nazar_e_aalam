<template>
    <app-modal
        :modal-id="modalId"
        modal-size="large"
        :title="
            selectedUrl
                ? $t('common.update_item', {
                      item: $t('reciter_audio.singular'),
                  })
                : $t('common.add_item', { item: $t('reciter_audio.singular') })
        "
        :preloader="preloader || uploadStatus.isUploading"
        @submit="submit"
        @close="closeModal"
    >
        <template v-slot:body>
            <app-loader v-if="pageLoader" />
            <form v-else>
                <!-- Sura Name -->
                <div class="mb-3">
                    <label class="name"
                        >{{ $t("reciter_audio.form.sura_name") }}
                        <span class="text-danger">*</span></label
                    >
                    <Select2
                        v-model="formData.name"
                        :placeholder="
                            $t('reciter_audio.form.sura_name_placeholder')
                        "
                        :options="selectOptions"
                        v-if="!selectedUrl"
                        @update:modelValue="onSuraNameChange"
                    />
                    <input
                        v-else
                        type="text"
                        readonly
                        v-model="formData.name"
                        class="form-control"
                    />
                    <small class="text-danger" v-if="errors.name">{{
                        errors.name[0]
                    }}</small>
                </div>

                <!-- Auto-filled fields: Sura Number, Duration, Revealed Place -->
                <div class="row g-3 mb-3">
                    <div class="col-md-4">
                        <label
                            class="number d-flex justify-content-between align-items-center"
                        >
                            <span
                                >{{ $t("reciter_audio.form.sura_number") }}
                                <span class="text-danger">*</span></span
                            >
                            <small class="text-muted">{{
                                $t("reciter_audio.form.auto_filled")
                            }}</small>
                        </label>
                        <input
                            type="number"
                            id="number"
                            v-model="formData.number"
                            class="form-control"
                            readonly
                            autocomplete
                            :placeholder="
                                $t('reciter_audio.form.select_sura_name')
                            "
                        />
                        <small class="text-danger" v-if="errors.number">{{
                            errors.number[0]
                        }}</small>
                    </div>

                    <div class="col-md-4">
                        <label
                            class="sura_number d-flex justify-content-between align-items-center"
                        >
                            <span
                                >{{ $t("reciter_audio.form.revealed_place") }}
                                <span class="text-danger">*</span></span
                            >
                            <small class="text-muted">{{
                                $t("reciter_audio.form.auto_filled")
                            }}</small>
                        </label>
                        <input
                            type="text"
                            v-model="formData.revealed_place"
                            class="form-control"
                            readonly
                            :placeholder="
                                $t('reciter_audio.form.select_sura_name')
                            "
                        />
                        <small
                            class="text-danger"
                            v-if="errors.revealed_place"
                            >{{ errors.revealed_place[0] }}</small
                        >
                    </div>

                    <div class="col-md-4">
                        <label
                            class="duration d-flex justify-content-between align-items-center"
                        >
                            <span
                                >{{ $t("reciter_audio.form.duration") }}
                                <span class="text-danger">*</span>
                                <code v-if="durationText">{{
                                    durationText
                                }}</code></span
                            >
                            <small class="text-muted">{{
                                $t("reciter_audio.form.auto_filled")
                            }}</small>
                        </label>
                        <input
                            type="number"
                            id="duration"
                            v-model="formData.duration"
                            class="form-control"
                            disabled
                            autocomplete="false"
                            :placeholder="
                                $t('reciter_audio.form.select_audio_file')
                            "
                        />
                        <small class="text-danger" v-if="errors.duration">{{
                            errors.duration[0]
                        }}</small>
                    </div>
                </div>

                <!-- Audio File Upload with Enhanced Progress -->
                <div class="mb-3">
                    <label
                        class="sura_number d-flex justify-content-between align-items-center"
                    >
                        <span
                            >{{ $t("reciter_audio.form.audio_file") }}
                            <span class="text-danger">*</span></span
                        >
                        <small class="text-muted">{{
                            $t("reciter_audio.form.max_size", {
                                size: formatFileSize(MAX_FILE_SIZE),
                            })
                        }}</small>
                    </label>
                    <input
                        ref="fileInputRef"
                        type="file"
                        class="form-control"
                        @change="handleFileUpload"
                        accept="audio/*"
                        :disabled="uploadStatus.isUploading"
                    />
                    <small class="text-danger" v-if="errors.audio_file">{{
                        errors.audio_file[0]
                    }}</small>

                    <!-- Selected File Info -->
                    <div
                        v-if="selectedFile"
                        class="selected-file-chip d-flex justify-content-between align-items-center mt-2 px-3 py-2"
                    >
                        <span
                            class="d-flex align-items-center gap-2 text-truncate"
                        >
                            <span>🎵</span>
                            <span class="fw-semibold text-truncate">{{
                                selectedFile.name
                            }}</span>
                            <span class="text-muted"
                                >({{ formatFileSize(selectedFile.size) }})</span
                            >
                        </span>
                        <button
                            type="button"
                            class="btn btn-sm btn-link text-danger p-0 flex-shrink-0"
                            :disabled="uploadStatus.isUploading"
                            @click.prevent="removeSelectedFile"
                        >
                            ✕ {{ $t("reciter_audio.form.remove") }}
                        </button>
                    </div>

                    <!-- Enhanced Progress Display -->
                    <div
                        v-if="
                            uploadStatus.isUploading ||
                            uploadStatus.progress > 0
                        "
                        class="mt-3"
                    >
                        <!-- Progress Bar -->
                        <div class="progress mb-2" style="height: 25px">
                            <div
                                class="progress-bar progress-bar-striped progress-bar-animated"
                                :class="
                                    uploadStatus.progress === 100
                                        ? 'bg-success'
                                        : 'bg-primary'
                                "
                                role="progressbar"
                                :style="{ width: uploadStatus.progress + '%' }"
                                :aria-valuenow="uploadStatus.progress"
                                aria-valuemin="0"
                                aria-valuemax="100"
                            >
                                {{ uploadStatus.progress }}%
                            </div>
                        </div>

                        <!-- Upload Details -->
                        <div class="upload-details">
                            <div
                                class="d-flex justify-content-between align-items-center mb-2"
                            >
                                <small class="text-muted">
                                    <strong>{{ uploadStatus.fileName }}</strong>
                                </small>
                                <small class="text-muted">
                                    {{
                                        formatFileSize(
                                            uploadStatus.uploadedSize,
                                        )
                                    }}
                                    /
                                    {{ formatFileSize(uploadStatus.totalSize) }}
                                </small>
                            </div>

                            <!-- Chunk Progress -->
                            <div
                                v-if="uploadStatus.totalChunks > 1"
                                class="mb-2"
                            >
                                <small class="text-muted">
                                    {{
                                        $t(
                                            "reciter_audio.form.uploading_chunk",
                                            {
                                                current:
                                                    uploadStatus.currentChunk,
                                                total: uploadStatus.totalChunks,
                                            },
                                        )
                                    }}
                                </small>
                            </div>

                            <!-- Upload Speed & Time Remaining -->
                            <div class="d-flex justify-content-between">
                                <small class="text-muted">
                                    ️🚀
                                    {{
                                        $t("reciter_audio.form.speed", {
                                            speed: uploadStatus.speed,
                                        })
                                    }}
                                </small>
                                <small
                                    class="text-muted"
                                    v-if="uploadStatus.timeRemaining"
                                >
                                    ⏰
                                    {{
                                        $t(
                                            "reciter_audio.form.time_remaining",
                                            {
                                                time: uploadStatus.timeRemaining,
                                            },
                                        )
                                    }}
                                </small>
                            </div>

                            <!-- Status Message -->
                            <div v-if="uploadStatus.message" class="mt-2">
                                <div
                                    class="alert py-2 mb-0"
                                    :class="
                                        uploadStatus.hasFailed
                                            ? 'alert-warning'
                                            : 'alert-info'
                                    "
                                    role="alert"
                                >
                                    <small>{{ uploadStatus.message }}</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Retry Button -->
                    <div v-if="uploadStatus.canRetry" class="mt-2">
                        <button
                            type="button"
                            class="btn btn-warning btn-sm"
                            @click.prevent="retryUpload"
                        >
                            🔄 {{ $t("reciter_audio.form.retry_upload") }}
                        </button>
                    </div>

                    <!-- Success Message -->
                    <div
                        v-if="
                            uploadStatus.isComplete && !uploadStatus.isUploading
                        "
                        class="alert alert-success mt-3 py-2 px-3"
                    >
                        ✅ {{ $t("reciter_audio.form.upload_complete") }}
                    </div>
                </div>
            </form>
        </template>
    </app-modal>
</template>

<script setup>
import { useSubmitForm } from "@/composable/useSubmitForm.js";
import { computed, ref, watch } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";
import Select2 from "@/components/select/select2.vue";
import { useI18n } from "vue-i18n";

const props = defineProps({
    modalId: String,
    selectedUrl: String,
    reciterId: String,
    reciterName: String,
});

const emit = defineEmits(["close"]);
const { t } = useI18n();

const {
    preloader,
    pageLoader,
    errors,
    afterSuccess,
    afterError,
    afterFinalResponse,
    closeModal,
} = useSubmitForm(props, emit);

const formData = ref({
    name: "",
    number: "",
    duration: "",
    durationText: "",
    revealed_place: "",
    audio_file: null,
    reciter_name: props.reciterName,
});

const CHUNK_SIZE = 1024 * 1000; // 1 MB
const MAX_FILE_SIZE = 250 * 1024 * 1024; // 250 MB
const MAX_CHUNK_RETRIES = 4;

// The raw File object, kept independently of formData.audio_file so a failed
// upload can be retried/resumed even after formData.audio_file is set to the
// final server path on success.
const selectedFile = ref(null);
// The native file input, so it can be cleared when the user removes a selection.
const fileInputRef = ref(null);
// Promise for an in-flight chunked upload, so submit() can wait on it.
let uploadPromise = null;
// uploadId of the most recently started chunked upload, used to best-effort
// cancel an abandoned session when the user swaps in a different file.
let activeUploadId = null;

// Enhanced upload status tracking
const uploadStatus = ref({
    isUploading: false,
    isComplete: false,
    hasFailed: false,
    canRetry: false,
    progress: 0,
    currentChunk: 0,
    totalChunks: 0,
    uploadedSize: 0,
    totalSize: 0,
    fileName: "",
    speed: "0 KB/s",
    timeRemaining: "",
    message: "",
});

// Sura data with numbers and revealed places
const suraData = [
    { number: 1, name: "Al-Fatihah", revealedPlace: "Makka" },
    { number: 2, name: "Al-Baqarah", revealedPlace: "Madina" },
    { number: 3, name: "Aal-E-Imran", revealedPlace: "Madina" },
    { number: 4, name: "An-Nisa", revealedPlace: "Madina" },
    { number: 5, name: "Al-Maidah", revealedPlace: "Madina" },
    { number: 6, name: "Al-Anam", revealedPlace: "Makka" },
    { number: 7, name: "Al-Araf", revealedPlace: "Makka" },
    { number: 8, name: "Al-Anfal", revealedPlace: "Madina" },
    { number: 9, name: "At-Tawbah", revealedPlace: "Madina" },
    { number: 10, name: "Yunus", revealedPlace: "Makka" },
    { number: 11, name: "Hud", revealedPlace: "Makka" },
    { number: 12, name: "Yusuf", revealedPlace: "Makka" },
    { number: 13, name: "Ar-Rad", revealedPlace: "Madina" },
    { number: 14, name: "Ibrahim", revealedPlace: "Makka" },
    { number: 15, name: "Al-Hijr", revealedPlace: "Makka" },
    { number: 16, name: "An-Nahl", revealedPlace: "Makka" },
    { number: 17, name: "Al-Isra", revealedPlace: "Makka" },
    { number: 18, name: "Al-Kahf", revealedPlace: "Makka" },
    { number: 19, name: "Maryam", revealedPlace: "Makka" },
    { number: 20, name: "Taha", revealedPlace: "Makka" },
    { number: 21, name: "Al-Anbiya", revealedPlace: "Makka" },
    { number: 22, name: "Al-Hajj", revealedPlace: "Madina" },
    { number: 23, name: "Al-Muminun", revealedPlace: "Makka" },
    { number: 24, name: "An-Nur", revealedPlace: "Madina" },
    { number: 25, name: "Al-Furqan", revealedPlace: "Makka" },
    { number: 26, name: "Ash-Shuara", revealedPlace: "Makka" },
    { number: 27, name: "An-Naml", revealedPlace: "Makka" },
    { number: 28, name: "Al-Qasas", revealedPlace: "Makka" },
    { number: 29, name: "Al-Ankabut", revealedPlace: "Makka" },
    { number: 30, name: "Ar-Rum", revealedPlace: "Makka" },
    { number: 31, name: "Luqman", revealedPlace: "Makka" },
    { number: 32, name: "As-Sajda", revealedPlace: "Makka" },
    { number: 33, name: "Al-Ahzab", revealedPlace: "Madina" },
    { number: 34, name: "Saba", revealedPlace: "Makka" },
    { number: 35, name: "Fatir", revealedPlace: "Makka" },
    { number: 36, name: "Ya-Sin", revealedPlace: "Makka" },
    { number: 37, name: "As-Saffat", revealedPlace: "Makka" },
    { number: 38, name: "Sad", revealedPlace: "Makka" },
    { number: 39, name: "Az-Zumar", revealedPlace: "Makka" },
    { number: 40, name: "Ghafir", revealedPlace: "Makka" },
    { number: 41, name: "Fussilat", revealedPlace: "Makka" },
    { number: 42, name: "Ash-Shura", revealedPlace: "Makka" },
    { number: 43, name: "Az-Zukhruf", revealedPlace: "Makka" },
    { number: 44, name: "Ad-Dukhan", revealedPlace: "Makka" },
    { number: 45, name: "Al-Jathiyah", revealedPlace: "Makka" },
    { number: 46, name: "Al-Ahqaf", revealedPlace: "Makka" },
    { number: 47, name: "Muhammad", revealedPlace: "Madina" },
    { number: 48, name: "Al-Fath", revealedPlace: "Madina" },
    { number: 49, name: "Al-Hujurat", revealedPlace: "Madina" },
    { number: 50, name: "Qaf", revealedPlace: "Makka" },
    { number: 51, name: "Adh-Dhariyat", revealedPlace: "Makka" },
    { number: 52, name: "At-Tur", revealedPlace: "Makka" },
    { number: 53, name: "An-Najm", revealedPlace: "Makka" },
    { number: 54, name: "Al-Qamar", revealedPlace: "Makka" },
    { number: 55, name: "Ar-Rahman", revealedPlace: "Madina" },
    { number: 56, name: "Al-Waqiah", revealedPlace: "Makka" },
    { number: 57, name: "Al-Hadid", revealedPlace: "Madina" },
    { number: 58, name: "Al-Mujadila", revealedPlace: "Madina" },
    { number: 59, name: "Al-Hashr", revealedPlace: "Madina" },
    { number: 60, name: "Al-Mumtahina", revealedPlace: "Madina" },
    { number: 61, name: "As-Saff", revealedPlace: "Madina" },
    { number: 62, name: "Al-Jumuah", revealedPlace: "Madina" },
    { number: 63, name: "Al-Munafiqun", revealedPlace: "Madina" },
    { number: 64, name: "At-Taghabun", revealedPlace: "Madina" },
    { number: 65, name: "At-Talaq", revealedPlace: "Madina" },
    { number: 66, name: "At-Tahrim", revealedPlace: "Madina" },
    { number: 67, name: "Al-Mulk", revealedPlace: "Makka" },
    { number: 68, name: "Al-Qalam", revealedPlace: "Makka" },
    { number: 69, name: "Al-Haqqah", revealedPlace: "Makka" },
    { number: 70, name: "Al-Maarij", revealedPlace: "Makka" },
    { number: 71, name: "Nuh", revealedPlace: "Makka" },
    { number: 72, name: "Al-Jinn", revealedPlace: "Makka" },
    { number: 73, name: "Al-Muzzammil", revealedPlace: "Makka" },
    { number: 74, name: "Al-Muddaththir", revealedPlace: "Makka" },
    { number: 75, name: "Al-Qiyamah", revealedPlace: "Makka" },
    { number: 76, name: "Al-Insan", revealedPlace: "Madina" },
    { number: 77, name: "Al-Mursalat", revealedPlace: "Makka" },
    { number: 78, name: "An-Naba", revealedPlace: "Makka" },
    { number: 79, name: "An-Naziat", revealedPlace: "Makka" },
    { number: 80, name: "Abasa", revealedPlace: "Makka" },
    { number: 81, name: "At-Takwir", revealedPlace: "Makka" },
    { number: 82, name: "Al-Infitar", revealedPlace: "Makka" },
    { number: 83, name: "Al-Mutaffifin", revealedPlace: "Makka" },
    { number: 84, name: "Al-Inshiqaq", revealedPlace: "Makka" },
    { number: 85, name: "Al-Buruj", revealedPlace: "Makka" },
    { number: 86, name: "At-Tariq", revealedPlace: "Makka" },
    { number: 87, name: "Al-Ala", revealedPlace: "Makka" },
    { number: 88, name: "Al-Ghashiyah", revealedPlace: "Makka" },
    { number: 89, name: "Al-Fajr", revealedPlace: "Makka" },
    { number: 90, name: "Al-Balad", revealedPlace: "Makka" },
    { number: 91, name: "Ash-Shams", revealedPlace: "Makka" },
    { number: 92, name: "Al-Lail", revealedPlace: "Makka" },
    { number: 93, name: "Ad-Duha", revealedPlace: "Makka" },
    { number: 94, name: "Ash-Sharh", revealedPlace: "Makka" },
    { number: 95, name: "At-Tin", revealedPlace: "Makka" },
    { number: 96, name: "Al-Alaq", revealedPlace: "Makka" },
    { number: 97, name: "Al-Qadr", revealedPlace: "Makka" },
    { number: 98, name: "Al-Bayyinah", revealedPlace: "Madina" },
    { number: 99, name: "Az-Zalzalah", revealedPlace: "Madina" },
    { number: 100, name: "Al-Adiyat", revealedPlace: "Makka" },
    { number: 101, name: "Al-Qariah", revealedPlace: "Makka" },
    { number: 102, name: "At-Takathur", revealedPlace: "Makka" },
    { number: 103, name: "Al-Asr", revealedPlace: "Makka" },
    { number: 104, name: "Al-Humazah", revealedPlace: "Makka" },
    { number: 105, name: "Al-Fil", revealedPlace: "Makka" },
    { number: 106, name: "Quraish", revealedPlace: "Makka" },
    { number: 107, name: "Al-Maun", revealedPlace: "Makka" },
    { number: 108, name: "Al-Kawthar", revealedPlace: "Makka" },
    { number: 109, name: "Al-Kafirun", revealedPlace: "Makka" },
    { number: 110, name: "An-Nasr", revealedPlace: "Madina" },
    { number: 111, name: "Al-Masad", revealedPlace: "Makka" },
    { number: 112, name: "Al-Ikhlas", revealedPlace: "Makka" },
    { number: 113, name: "Al-Falaq", revealedPlace: "Makka" },
    { number: 114, name: "An-Nas", revealedPlace: "Makka" },
];

// Generate select options from suraData
const selectOptions = computed(() => {
    return suraData.map((sura) => ({
        id: sura.name,
        name: sura.name,
    }));
});

// Handle Sura name change - auto-fill number and revealed place
const onSuraNameChange = (suraName) => {
    const selectedSura = suraData.find((sura) => sura.name === suraName);
    if (selectedSura) {
        formData.value.number = selectedSura.number;
        formData.value.revealed_place = selectedSura.revealedPlace;
    }
};

// Computed property to format duration
const durationText = computed(() => {
    const durationInSeconds = formData.value.duration;
    if (!durationInSeconds) return "";

    const hours = Math.floor(durationInSeconds / 3600);
    const minutes = Math.floor((durationInSeconds % 3600) / 60);
    const seconds = durationInSeconds % 60;

    return hours > 0
        ? `${hours}:${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`
        : `${minutes}:${seconds.toString().padStart(2, "0")}`;
});

// Format file size helper
const formatFileSize = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + " " + sizes[i];
};

// Calculate upload speed and time remaining
const calculateUploadMetrics = (uploadedBytes, totalBytes, startTime) => {
    const elapsedTime = (Date.now() - startTime) / 1000; // in seconds
    const speed = uploadedBytes / elapsedTime; // bytes per second
    const remainingBytes = totalBytes - uploadedBytes;
    const remainingTime = remainingBytes / speed; // in seconds

    // Format speed
    const speedFormatted =
        speed > 1024 * 1024
            ? `${(speed / (1024 * 1024)).toFixed(2)} MB/s`
            : `${(speed / 1024).toFixed(2)} KB/s`;

    // Format time remaining
    let timeRemainingFormatted = "";
    if (remainingTime < 60) {
        timeRemainingFormatted = `${Math.ceil(remainingTime)}s`;
    } else if (remainingTime < 3600) {
        timeRemainingFormatted = `${Math.ceil(remainingTime / 60)}m`;
    } else {
        const hours = Math.floor(remainingTime / 3600);
        const minutes = Math.ceil((remainingTime % 3600) / 60);
        timeRemainingFormatted = `${hours}h ${minutes}m`;
    }

    return {
        speed: speedFormatted,
        timeRemaining: timeRemainingFormatted,
    };
};

// Reset upload status
const resetUploadStatus = () => {
    uploadStatus.value = {
        isUploading: false,
        isComplete: false,
        hasFailed: false,
        canRetry: false,
        progress: 0,
        currentChunk: 0,
        totalChunks: 0,
        uploadedSize: 0,
        totalSize: 0,
        fileName: "",
        speed: "0 KB/s",
        timeRemaining: "",
        message: "",
    };
};

// Small synchronous, non-cryptographic hash (cyrb53-style) used purely as a
// resumability correlation id — selecting the same file again reproduces the
// same id, so the server can report which chunks it already has.
const generateUploadId = (file, reciterName) => {
    const str = `${file.name}|${file.size}|${file.lastModified}|${reciterName}`;
    let h1 = 0xdeadbeef;
    let h2 = 0x41c6ce57;
    for (let i = 0; i < str.length; i++) {
        const ch = str.charCodeAt(i);
        h1 = Math.imul(h1 ^ ch, 2654435761);
        h2 = Math.imul(h2 ^ ch, 1597334677);
    }
    h1 =
        Math.imul(h1 ^ (h1 >>> 16), 2246822507) ^
        Math.imul(h2 ^ (h2 >>> 13), 3266489909);
    h2 =
        Math.imul(h2 ^ (h2 >>> 16), 2246822507) ^
        Math.imul(h1 ^ (h1 >>> 13), 3266489909);
    return (
        (h1 >>> 0).toString(16).padStart(8, "0") +
        (h2 >>> 0).toString(16).padStart(8, "0")
    );
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Ask the server which chunks of this upload id it already has on disk.
const checkUploadStatus = async (uploadId) => {
    try {
        const response = await Axios.get("upload-chunk/status", {
            params: { uploadId },
        });
        return response.data;
    } catch (error) {
        return { exists: false, receivedChunks: [] };
    }
};

// Uploads a single chunk, retrying transient failures (network errors,
// timeouts, 5xx) with exponential backoff. Validation errors (4xx) are not
// retryable and rethrow immediately.
const uploadChunkWithRetry = async (chunkForm) => {
    let attempt = 0;
    while (true) {
        try {
            return await Axios.post("upload-chunk", chunkForm, {
                headers: { "Content-Type": "multipart/form-data" },
                timeout: 30000,
            });
        } catch (error) {
            const status = error.response?.status;
            const isRetryable = !error.response || status >= 500;
            attempt++;
            if (!isRetryable || attempt > MAX_CHUNK_RETRIES) {
                throw error;
            }
            uploadStatus.value.message = t(
                "reciter_audio.messages.network_retry",
                { attempt, max: MAX_CHUNK_RETRIES },
            );
            await sleep(
                Math.min(1000 * 2 ** (attempt - 1), 8000) + Math.random() * 300,
            );
        }
    }
};

// Best-effort cleanup of an abandoned upload session (only safe once it's
// no longer actively uploading).
const cancelActiveUpload = () => {
    if (activeUploadId && !uploadStatus.value.isUploading) {
        Axios.delete("upload-chunk", {
            params: { uploadId: activeUploadId },
        }).catch(() => {});
        activeUploadId = null;
    }
};

// Clears the current file selection (and abandons its upload session, if any)
// so the user can pick a different file.
const removeSelectedFile = () => {
    cancelActiveUpload();
    selectedFile.value = null;
    formData.value.audio_file = null;
    formData.value.duration = "";
    resetUploadStatus();
    if (fileInputRef.value) {
        fileInputRef.value.value = "";
    }
};

// Handle file upload — for large files, the chunked upload starts right away
// (instead of waiting for Save) so it can run in the background and be
// retried independently of the rest of the form.
const handleFileUpload = async (event) => {
    const selected = event.target.files[0];
    if (!selected) return;

    cancelActiveUpload();
    resetUploadStatus();

    if (!selected.type.startsWith("audio/")) {
        toast.error(t("reciter_audio.messages.invalid_audio_file"));
        return;
    }

    if (selected.size > MAX_FILE_SIZE) {
        toast.error(
            t("reciter_audio.messages.file_size_exceeds", {
                size: formatFileSize(MAX_FILE_SIZE),
            }),
        );
        return;
    }

    selectedFile.value = selected;
    formData.value.audio_file = null;

    uploadStatus.value.fileName = selected.name;
    uploadStatus.value.totalSize = selected.size;

    const fileUrl = URL.createObjectURL(selected);
    const audio = new Audio(fileUrl);
    audio.addEventListener("loadedmetadata", () => {
        formData.value.duration = Math.round(audio.duration);
        URL.revokeObjectURL(fileUrl);
    });
    audio.addEventListener("error", () => {
        console.error("Failed to load audio metadata");
        toast.error(t("reciter_audio.messages.read_metadata_failed"));
    });

    if (selected.size > CHUNK_SIZE) {
        uploadPromise = uploadInChunks(selected, props.reciterName).then(
            (filePath) => {
                formData.value.audio_file = filePath;
            },
        );
    } else {
        formData.value.audio_file = selected;
    }
};

// Re-runs the chunked upload for the currently selected file. Because the
// upload id is deterministic, the server reports which chunks it already
// has and only the missing ones are sent.
const retryUpload = () => {
    if (!selectedFile.value) return;
    uploadPromise = uploadInChunks(selectedFile.value, props.reciterName).then(
        (filePath) => {
            formData.value.audio_file = filePath;
        },
    );
};

// Submit form
const submit = async () => {
    if (uploadPromise) {
        await uploadPromise;
    }

    if (uploadStatus.value.hasFailed) {
        toast.error(t("reciter_audio.messages.retry_before_saving"));
        return;
    }

    preloader.value = true;

    try {
        const submitData = new FormData();
        submitData.append("reciter_id", props.reciterId);
        submitData.append("name", formData.value.name);
        submitData.append("number", formData.value.number);
        submitData.append("duration", formData.value.duration);
        submitData.append("revealed_place", formData.value.revealed_place);

        if (formData.value.audio_file) {
            submitData.append("audio_file", formData.value.audio_file);
        }

        if (props.selectedUrl) {
            submitData.append("id", formData.value.id);
            submitData.append("_method", "PATCH");
        }

        // Submit the form
        await Axios.post(props.selectedUrl || "reciter-sura", submitData, {
            headers: {
                "Content-Type": "multipart/form-data",
            },
        })
            .then((response) => {
                afterSuccess(response);
            })
            .catch(({ response }) => {
                afterError(response);
            })
            .finally(() => {
                afterFinalResponse();
            });
    } catch (error) {
        console.error("Submission Error:", error);
        afterError(error.response);
    } finally {
        afterFinalResponse();
    }
};

// Upload in chunks with enhanced progress tracking, resume and retry support
const uploadInChunks = async (file, reciterName) => {
    const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
    const uploadId = generateUploadId(file, reciterName);
    activeUploadId = uploadId;

    uploadStatus.value.isUploading = true;
    uploadStatus.value.hasFailed = false;
    uploadStatus.value.canRetry = false;
    uploadStatus.value.totalChunks = totalChunks;
    uploadStatus.value.fileName = file.name;
    uploadStatus.value.totalSize = file.size;

    try {
        const status = await checkUploadStatus(uploadId);
        const receivedChunks = new Set(
            status.exists ? status.receivedChunks : [],
        );

        if (receivedChunks.size > 0) {
            uploadStatus.value.message = t(
                "reciter_audio.messages.resuming_upload",
                { received: receivedChunks.size, total: totalChunks },
            );
        }

        // Only the chunks not yet on the server count towards this session's
        // speed/ETA, otherwise resuming would make the estimate look wrong.
        let bytesRemainingToUpload = 0;
        for (let chunkNumber = 1; chunkNumber <= totalChunks; chunkNumber++) {
            if (!receivedChunks.has(chunkNumber)) {
                const start = (chunkNumber - 1) * CHUNK_SIZE;
                bytesRemainingToUpload += Math.min(
                    CHUNK_SIZE,
                    file.size - start,
                );
            }
        }

        const sessionStartTime = Date.now();
        let sessionUploadedBytes = 0;

        for (let chunkNumber = 1; chunkNumber <= totalChunks; chunkNumber++) {
            const start = (chunkNumber - 1) * CHUNK_SIZE;
            const chunkSize = Math.min(CHUNK_SIZE, file.size - start);

            if (!receivedChunks.has(chunkNumber)) {
                const chunk = file.slice(start, start + chunkSize);
                const chunkForm = new FormData();
                chunkForm.append("file", chunk, `${file.name}.part`);
                chunkForm.append("uploadId", uploadId);
                chunkForm.append("chunkNumber", chunkNumber);
                chunkForm.append("totalChunks", totalChunks);
                chunkForm.append("fileName", file.name);
                chunkForm.append("reciterName", reciterName);

                uploadStatus.value.message = t(
                    "reciter_audio.messages.uploading_chunk_progress",
                    { current: chunkNumber, total: totalChunks },
                );
                await uploadChunkWithRetry(chunkForm);

                sessionUploadedBytes += chunkSize;
                const metrics = calculateUploadMetrics(
                    sessionUploadedBytes,
                    bytesRemainingToUpload,
                    sessionStartTime,
                );
                uploadStatus.value.speed = metrics.speed;
                uploadStatus.value.timeRemaining = metrics.timeRemaining;
            }

            uploadStatus.value.currentChunk = chunkNumber;
            uploadStatus.value.uploadedSize = Math.min(
                chunkNumber * CHUNK_SIZE,
                file.size,
            );
            uploadStatus.value.progress = Math.round(
                (chunkNumber / totalChunks) * 100,
            );
        }

        uploadStatus.value.message = t("reciter_audio.messages.finalizing");
        const response = await Axios.post("upload-chunk/complete", {
            uploadId,
            totalChunks,
            fileName: file.name,
            reciterName,
        });

        uploadStatus.value.isUploading = false;
        uploadStatus.value.isComplete = true;
        uploadStatus.value.message = t(
            "reciter_audio.messages.upload_complete_bang",
        );
        return response.data.filePath;
    } catch (error) {
        console.error("Error uploading file:", error);
        uploadStatus.value.isUploading = false;
        uploadStatus.value.hasFailed = true;
        uploadStatus.value.canRetry = true;
        uploadStatus.value.message =
            error.response?.data?.message ||
            t("reciter_audio.messages.upload_paused");
        toast.error(t("reciter_audio.messages.upload_interrupted"));
        return null;
    }
};

// Fetch data when URL is selected and populate form
const fetchFormData = async () => {
    if (props.selectedUrl) {
        try {
            const response = await Axios.get(props.selectedUrl);
            formData.value.id = response.data.id;
            formData.value.name = response.data.name;
            formData.value.number = response.data.number;
            formData.value.duration = response.data.duration;
            formData.value.revealed_place = response.data.revealed_place;
        } catch (error) {
            toast.error(t("reciter_audio.messages.fetch_sura_failed"));
        }
    }
};

// Watch for URL change to trigger data fetch
watch(() => props.selectedUrl, fetchFormData, { immediate: true });
</script>

<style scoped>
.upload-details {
    background-color: #f8f9fa;
    padding: 15px;
    border-radius: 5px;
    border: 1px solid #dee2e6;
}

.progress {
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.progress-bar {
    font-weight: bold;
    font-size: 14px;
}

.selected-file-chip {
    background-color: #f0f7ff;
    border: 1px solid #cfe2ff;
    border-radius: 5px;
}
</style>
