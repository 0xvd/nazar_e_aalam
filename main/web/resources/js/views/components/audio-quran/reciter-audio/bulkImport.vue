<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-4">
                <h1 class="h3 d-inline align-middle">
                    <strong>{{ $t("reciter_audio.bulk.heading") }}</strong>
                </h1>
                <p class="text-muted mb-0 mt-1">
                    {{ $t("reciter_audio.bulk.subheading") }}
                </p>
            </div>

            <div class="row">
                <div class="col-lg-7">
                    <div class="card">
                        <div class="card-body">
                            <!-- Reciter selection -->
                            <div class="mb-4">
                                <label class="form-label fw-semibold">
                                    {{
                                        $t("reciter_audio.bulk.select_reciter")
                                    }}
                                    <span class="text-danger">*</span>
                                </label>
                                <Select2
                                    :key="reciterOptions.length"
                                    v-model="selectedReciterName"
                                    :placeholder="
                                        $t(
                                            'reciter_audio.bulk.select_reciter_placeholder',
                                        )
                                    "
                                    :options="reciterOptions"
                                    :disabled="isBusy"
                                    @update:modelValue="onReciterChange"
                                />
                            </div>

                            <!-- ZIP dropzone -->
                            <div class="mb-4">
                                <label
                                    class="form-label fw-semibold d-flex justify-content-between align-items-center"
                                >
                                    <span
                                        >{{ $t("reciter_audio.bulk.zip_file") }}
                                        <span class="text-danger">*</span></span
                                    >
                                    <small class="text-muted">{{
                                        $t("reciter_audio.bulk.max_size", {
                                            size: formatFileSize(MAX_FILE_SIZE),
                                        })
                                    }}</small>
                                </label>

                                <div
                                    v-if="!selectedFile"
                                    class="dropzone"
                                    :class="{
                                        'dropzone--active': isDragging,
                                        'dropzone--disabled': isBusy,
                                    }"
                                    @click="!isBusy && $refs.zipInput.click()"
                                    @dragover.prevent="isDragging = true"
                                    @dragleave.prevent="isDragging = false"
                                    @drop.prevent="onDrop"
                                >
                                    <div class="dropzone-icon">🗜️</div>
                                    <div class="fw-semibold">
                                        {{
                                            $t(
                                                "reciter_audio.bulk.dropzone_title",
                                            )
                                        }}
                                    </div>
                                    <div class="text-muted small mt-1">
                                        {{
                                            $t(
                                                "reciter_audio.bulk.dropzone_hint",
                                            )
                                        }}
                                    </div>
                                </div>

                                <input
                                    ref="zipInput"
                                    type="file"
                                    class="d-none"
                                    accept=".zip,application/zip,application/x-zip-compressed"
                                    @change="onFileSelected"
                                />

                                <!-- Selected file chip -->
                                <div
                                    v-if="selectedFile"
                                    class="selected-file-chip d-flex justify-content-between align-items-center px-3 py-2"
                                >
                                    <span
                                        class="d-flex align-items-center gap-2 text-truncate"
                                    >
                                        <span>🗜️</span>
                                        <span
                                            class="fw-semibold text-truncate"
                                            >{{ selectedFile.name }}</span
                                        >
                                        <span class="text-muted"
                                            >({{
                                                formatFileSize(
                                                    selectedFile.size,
                                                )
                                            }})</span
                                        >
                                    </span>
                                    <button
                                        type="button"
                                        class="btn btn-sm btn-link text-danger p-0 flex-shrink-0"
                                        :disabled="isBusy"
                                        @click.prevent="removeSelectedFile"
                                    >
                                        ✕
                                        {{
                                            $t("reciter_audio.bulk.remove_file")
                                        }}
                                    </button>
                                </div>
                            </div>

                            <!-- Replace toggle -->
                            <div class="mb-4">
                                <div class="form-check form-switch">
                                    <input
                                        class="form-check-input"
                                        type="checkbox"
                                        role="switch"
                                        id="replaceExisting"
                                        v-model="replaceExisting"
                                        :disabled="isBusy"
                                    />
                                    <label
                                        class="form-check-label fw-semibold"
                                        for="replaceExisting"
                                    >
                                        {{
                                            $t(
                                                "reciter_audio.bulk.replace_existing",
                                            )
                                        }}
                                    </label>
                                </div>
                                <small class="text-muted">{{
                                    $t("reciter_audio.bulk.replace_hint")
                                }}</small>
                            </div>

                            <!-- Actions -->
                            <div class="d-flex gap-2">
                                <button
                                    type="button"
                                    class="btn btn-primary fw-bold"
                                    :disabled="!canStart"
                                    @click.prevent="startImport"
                                >
                                    <span
                                        v-if="isBusy"
                                        class="spinner-border spinner-border-sm me-2"
                                        role="status"
                                    ></span>
                                    {{ $t("reciter_audio.bulk.start_import") }}
                                </button>
                                <button
                                    v-if="isFinished"
                                    type="button"
                                    class="btn btn-outline-secondary fw-bold"
                                    @click.prevent="reset"
                                >
                                    {{ $t("reciter_audio.bulk.reset") }}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Progress panel -->
                <div class="col-lg-5">
                    <div class="card" v-if="showProgressPanel">
                        <div class="card-body">
                            <!-- Phase label -->
                            <div
                                class="d-flex align-items-center justify-content-between mb-2"
                            >
                                <span class="fw-bold">{{ phaseLabel }}</span>
                                <span
                                    v-if="phase === 'completed'"
                                    class="badge bg-success"
                                    >✓</span
                                >
                                <span
                                    v-else-if="phase === 'failed'"
                                    class="badge bg-danger"
                                    >!</span
                                >
                            </div>

                            <!-- Upload progress -->
                            <div v-if="phase === 'uploading'" class="mb-3">
                                <div class="progress" style="height: 22px">
                                    <div
                                        class="progress-bar progress-bar-striped progress-bar-animated bg-primary"
                                        :style="{ width: uploadProgress + '%' }"
                                    >
                                        {{ uploadProgress }}%
                                    </div>
                                </div>
                                <small class="text-muted d-block mt-1">{{
                                    uploadMessage
                                }}</small>
                            </div>

                            <!-- Extraction (indeterminate) -->
                            <div
                                v-else-if="
                                    phase === 'extracting' || phase === 'queued'
                                "
                                class="mb-3"
                            >
                                <div class="progress" style="height: 22px">
                                    <div
                                        class="progress-bar progress-bar-striped progress-bar-animated bg-info"
                                        style="width: 100%"
                                    >
                                        …
                                    </div>
                                </div>
                            </div>

                            <!-- Import progress -->
                            <div v-else class="mb-3">
                                <div class="progress" style="height: 22px">
                                    <div
                                        class="progress-bar"
                                        :class="
                                            phase === 'failed'
                                                ? 'bg-danger'
                                                : phase === 'completed'
                                                  ? 'bg-success'
                                                  : 'bg-primary progress-bar-striped progress-bar-animated'
                                        "
                                        :style="{ width: importPercent + '%' }"
                                    >
                                        {{ importPercent }}%
                                    </div>
                                </div>
                                <small class="text-muted d-block mt-1">
                                    {{
                                        $t("reciter_audio.bulk.processed", {
                                            done: progress.processed,
                                            total: progress.total_files,
                                        })
                                    }}
                                </small>
                            </div>

                            <!-- Current file -->
                            <div
                                v-if="progress.current_file && !isFinished"
                                class="mb-3"
                            >
                                <div class="text-muted small">
                                    {{ $t("reciter_audio.bulk.current") }}
                                </div>
                                <code>{{ progress.current_file }}</code>
                            </div>

                            <!-- Counters -->
                            <div
                                class="row g-2 text-center mb-2"
                                v-if="
                                    phase !== 'uploading' && phase !== 'queued'
                                "
                            >
                                <div class="col">
                                    <div class="stat-box stat-success">
                                        <div class="stat-num">
                                            {{ progress.success_count }}
                                        </div>
                                        <div class="stat-label">
                                            {{
                                                $t("reciter_audio.bulk.success")
                                            }}
                                        </div>
                                    </div>
                                </div>
                                <div class="col">
                                    <div class="stat-box stat-skip">
                                        <div class="stat-num">
                                            {{ progress.skipped_count }}
                                        </div>
                                        <div class="stat-label">
                                            {{
                                                $t("reciter_audio.bulk.skipped")
                                            }}
                                        </div>
                                    </div>
                                </div>
                                <div class="col">
                                    <div class="stat-box stat-fail">
                                        <div class="stat-num">
                                            {{ progress.failed_count }}
                                        </div>
                                        <div class="stat-label">
                                            {{
                                                $t("reciter_audio.bulk.failed")
                                            }}
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Completion summary -->
                            <div
                                v-if="phase === 'completed'"
                                class="summary-card summary-card--success mt-3"
                            >
                                <div class="summary-head">
                                    <span class="summary-check">✓</span>
                                    <span class="summary-title">{{
                                        $t("reciter_audio.bulk.summary_title")
                                    }}</span>
                                </div>
                                <ul class="summary-list">
                                    <li>
                                        <span
                                            class="summary-dot dot-success"
                                        ></span>
                                        <span>{{
                                            $t("reciter_audio.bulk.imported")
                                        }}</span>
                                        <span class="summary-value">{{
                                            progress.success_count
                                        }}</span>
                                    </li>
                                    <li>
                                        <span
                                            class="summary-dot dot-skip"
                                        ></span>
                                        <span>{{
                                            $t("reciter_audio.bulk.skipped")
                                        }}</span>
                                        <span class="summary-value">{{
                                            progress.skipped_count
                                        }}</span>
                                    </li>
                                    <li>
                                        <span
                                            class="summary-dot dot-fail"
                                        ></span>
                                        <span>{{
                                            $t("reciter_audio.bulk.failed")
                                        }}</span>
                                        <span class="summary-value">{{
                                            progress.failed_count
                                        }}</span>
                                    </li>
                                </ul>
                            </div>

                            <div
                                v-if="phase === 'failed'"
                                class="summary-card summary-card--failed mt-3"
                            >
                                <div class="summary-head">
                                    <span class="summary-cross">!</span>
                                    <span class="summary-title">{{
                                        $t("reciter_audio.bulk.phase.failed")
                                    }}</span>
                                </div>
                                <p class="summary-message">
                                    {{ progress.message }}
                                </p>
                            </div>

                            <!-- Error log -->
                            <div
                                v-if="
                                    progress.error_log &&
                                    progress.error_log.length
                                "
                                class="mt-3"
                            >
                                <div class="fw-semibold small mb-1">
                                    {{ $t("reciter_audio.bulk.error_log") }} ({{
                                        progress.error_log.length
                                    }})
                                </div>
                                <div class="error-log">
                                    <div
                                        v-for="(err, idx) in progress.error_log"
                                        :key="idx"
                                        class="error-log-item"
                                    >
                                        <code>{{ err.file }}</code> —
                                        {{ err.reason }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</template>

<script setup>
import { computed, onMounted, onBeforeUnmount, ref } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";
import { useI18n } from "vue-i18n";
import Select2 from "@/components/select/select2.vue";

const { t } = useI18n();

const CHUNK_SIZE = 1024 * 1000; // 1 MB per chunk
const MAX_FILE_SIZE = 2 * 1024 * 1024 * 1024; // 2 GB
const MAX_CHUNK_RETRIES = 4;
const POLL_INTERVAL = 1500; // ms

// Reciter selection
const reciters = ref([]);
const selectedReciterName = ref(null);
const selectedReciterId = ref(null);

// File / upload state
const selectedFile = ref(null);
const isDragging = ref(false);
const replaceExisting = ref(false);
const uploadProgress = ref(0);
const uploadMessage = ref("");

// Import phase: idle | uploading | queued | extracting | processing | completed | failed
const phase = ref("idle");
const importId = ref(null);
const progress = ref({
    total_files: 0,
    processed: 0,
    success_count: 0,
    failed_count: 0,
    skipped_count: 0,
    current_file: null,
    message: "",
    error_log: [],
});

let pollTimer = null;
let activeUploadId = null;

const reciterOptions = computed(() =>
    reciters.value.map((r) => ({ id: r.id, name: r.name })),
);

const isBusy = computed(() =>
    ["uploading", "queued", "extracting", "processing"].includes(phase.value),
);

const isFinished = computed(() =>
    ["completed", "failed"].includes(phase.value),
);

const canStart = computed(
    () => !isBusy.value && !!selectedReciterId.value && !!selectedFile.value,
);

const showProgressPanel = computed(() => phase.value !== "idle");

const importPercent = computed(() => {
    if (!progress.value.total_files)
        return phase.value === "completed" ? 100 : 0;
    return Math.round(
        (progress.value.processed / progress.value.total_files) * 100,
    );
});

const phaseLabel = computed(() => {
    const map = {
        uploading: t("reciter_audio.bulk.phase.uploading"),
        queued: t("reciter_audio.bulk.phase.queued"),
        extracting: t("reciter_audio.bulk.phase.extracting"),
        processing: t("reciter_audio.bulk.phase.processing"),
        completed: t("reciter_audio.bulk.phase.completed"),
        failed: t("reciter_audio.bulk.phase.failed"),
    };
    return map[phase.value] || "";
});

const onReciterChange = (name) => {
    const match = reciters.value.find((r) => r.name === name);
    selectedReciterId.value = match ? match.id : null;
};

const formatFileSize = (bytes) => {
    if (!bytes) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + " " + sizes[i];
};

const isZip = (file) => {
    const name = file.name.toLowerCase();
    return (
        name.endsWith(".zip") ||
        [
            "application/zip",
            "application/x-zip-compressed",
            "multipart/x-zip",
        ].includes(file.type)
    );
};

const setFile = (file) => {
    if (!isZip(file)) {
        toast.error(t("reciter_audio.bulk.invalid_zip"));
        return;
    }
    if (file.size > MAX_FILE_SIZE) {
        toast.error(
            t("reciter_audio.bulk.size_exceeds", {
                size: formatFileSize(MAX_FILE_SIZE),
            }),
        );
        return;
    }
    selectedFile.value = file;
};

const onFileSelected = (event) => {
    const file = event.target.files[0];
    if (file) setFile(file);
    event.target.value = "";
};

const onDrop = (event) => {
    isDragging.value = false;
    if (isBusy.value) return;
    const file = event.dataTransfer.files[0];
    if (file) setFile(file);
};

const removeSelectedFile = () => {
    selectedFile.value = null;
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Deterministic upload id so an interrupted upload can resume.
const generateUploadId = (file, reciterId) => {
    const str = `${file.name}|${file.size}|${file.lastModified}|${reciterId}`;
    let h1 = 0xdeadbeef,
        h2 = 0x41c6ce57;
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

const checkUploadStatus = async (uploadId) => {
    try {
        const res = await Axios.get("bulk-sura-import/upload-chunk/status", {
            params: { uploadId },
        });
        return res.data;
    } catch {
        return { exists: false, receivedChunks: [] };
    }
};

const uploadChunkWithRetry = async (chunkForm) => {
    let attempt = 0;
    while (true) {
        try {
            return await Axios.post(
                "bulk-sura-import/upload-chunk",
                chunkForm,
                {
                    headers: { "Content-Type": "multipart/form-data" },
                    timeout: 60000,
                },
            );
        } catch (error) {
            const status = error.response?.status;
            const isRetryable = !error.response || status >= 500;
            attempt++;
            if (!isRetryable || attempt > MAX_CHUNK_RETRIES) throw error;
            await sleep(
                Math.min(1000 * 2 ** (attempt - 1), 8000) + Math.random() * 300,
            );
        }
    }
};

const startImport = async () => {
    if (!canStart.value) return;

    const file = selectedFile.value;
    const reciterId = selectedReciterId.value;
    const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
    const uploadId = generateUploadId(file, reciterId);
    activeUploadId = uploadId;

    phase.value = "uploading";
    uploadProgress.value = 0;
    uploadMessage.value = "";
    resetProgress();

    try {
        const status = await checkUploadStatus(uploadId);
        const receivedChunks = new Set(
            status.exists ? status.receivedChunks : [],
        );

        for (let chunkNumber = 1; chunkNumber <= totalChunks; chunkNumber++) {
            if (!receivedChunks.has(chunkNumber)) {
                const start = (chunkNumber - 1) * CHUNK_SIZE;
                const chunk = file.slice(start, start + CHUNK_SIZE);
                const form = new FormData();
                form.append("file", chunk, `${file.name}.part`);
                form.append("uploadId", uploadId);
                form.append("chunkNumber", chunkNumber);
                form.append("totalChunks", totalChunks);
                form.append("fileName", file.name);

                uploadMessage.value = t("reciter_audio.bulk.uploading_chunk", {
                    current: chunkNumber,
                    total: totalChunks,
                });
                await uploadChunkWithRetry(form);
            }
            uploadProgress.value = Math.round(
                (chunkNumber / totalChunks) * 100,
            );
        }

        uploadMessage.value = t("reciter_audio.bulk.finalizing");
        phase.value = "queued";

        const complete = await Axios.post(
            "bulk-sura-import/upload-chunk/complete",
            {
                uploadId,
                totalChunks,
                fileName: file.name,
                reciter_id: reciterId,
                replace_existing: replaceExisting.value,
            },
        );

        importId.value = complete.data.import_id;
        activeUploadId = null;
        startPolling();
    } catch (error) {
        console.error("Bulk upload error:", error);
        phase.value = "failed";
        progress.value.message =
            error.response?.data?.message ||
            t("reciter_audio.bulk.upload_failed");
        toast.error(progress.value.message);
    }
};

const startPolling = () => {
    stopPolling();
    pollTimer = setInterval(fetchProgress, POLL_INTERVAL);
    fetchProgress();
};

const stopPolling = () => {
    if (pollTimer) {
        clearInterval(pollTimer);
        pollTimer = null;
    }
};

const fetchProgress = async () => {
    if (!importId.value) return;
    try {
        const res = await Axios.get(
            `bulk-sura-import/${importId.value}/progress`,
        );
        const data = res.data;
        progress.value = {
            total_files: data.total_files,
            processed: data.processed,
            success_count: data.success_count,
            failed_count: data.failed_count,
            skipped_count: data.skipped_count,
            current_file: data.current_file,
            message: data.message,
            error_log: data.error_log || [],
        };
        phase.value = data.status; // extracting | processing | completed | failed

        if (data.status === "completed" || data.status === "failed") {
            stopPolling();
        }

        // Once finished successfully, clear the form inputs but keep the
        // summary panel visible so the user can review the result.
        if (data.status === "completed") {
            selectedFile.value = null;
            selectedReciterName.value = null;
            selectedReciterId.value = null;
            replaceExisting.value = false;
        }
    } catch (error) {
        console.error("Progress poll error:", error);
    }
};

const resetProgress = () => {
    progress.value = {
        total_files: 0,
        processed: 0,
        success_count: 0,
        failed_count: 0,
        skipped_count: 0,
        current_file: null,
        message: "",
        error_log: [],
    };
};

const reset = () => {
    stopPolling();
    phase.value = "idle";
    importId.value = null;
    selectedFile.value = null;
    uploadProgress.value = 0;
    uploadMessage.value = "";
    resetProgress();
};

const loadReciters = async () => {
    try {
        const res = await Axios.get("bulk-sura-import/reciters");
        reciters.value = res.data || [];
    } catch (error) {
        console.error("Failed to load reciters:", error);
    }
};

onMounted(loadReciters);
onBeforeUnmount(stopPolling);
</script>

<style scoped>
.dropzone {
    border: 2px dashed #cfd4da;
    border-radius: 10px;
    padding: 32px 16px;
    text-align: center;
    cursor: pointer;
    transition: all 0.15s ease;
    background: #fbfcfd;
}

.dropzone--active {
    border-color: var(--z-green-500, #12b76a);
    background: var(--z-green-50, #f0faf5);
}

.dropzone--disabled {
    opacity: 0.6;
    pointer-events: none;
}

.dropzone-icon {
    font-size: 2.2rem;
    margin-bottom: 6px;
}

.selected-file-chip {
    background-color: #f0f7ff;
    border: 1px solid #cfe2ff;
    border-radius: 8px;
}

.stat-box {
    border-radius: 8px;
    padding: 10px 6px;
}

.stat-num {
    font-size: 1.35rem;
    font-weight: 700;
    line-height: 1;
}

.stat-label {
    font-size: 0.72rem;
    text-transform: uppercase;
    letter-spacing: 0.03em;
    margin-top: 4px;
}

.stat-success {
    background: #e7f7ef;
    color: #0a7d47;
}

.stat-skip {
    background: #fff6e6;
    color: #b7791f;
}

.stat-fail {
    background: #fdecec;
    color: #c0392b;
}

.summary-card {
    border-radius: 12px;
    padding: 16px 18px;
    border: 1px solid transparent;
}

.summary-card--success {
    background: #f0faf4;
    border-color: #cdeede;
}

.summary-card--failed {
    background: #fdecec;
    border-color: #f6cccc;
}

.summary-head {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 12px;
}

.summary-check,
.summary-cross {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 26px;
    height: 26px;
    border-radius: 50%;
    color: #fff;
    font-weight: 700;
    font-size: 0.9rem;
    flex-shrink: 0;
}

.summary-check {
    background: #12b76a;
}

.summary-cross {
    background: #c0392b;
}

.summary-title {
    font-weight: 700;
    font-size: 1rem;
    color: #101828;
}

.summary-list {
    list-style: none;
    margin: 0;
    padding: 0;
}

.summary-list li {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 7px 0;
    font-size: 0.9rem;
    color: #475467;
    border-top: 1px solid rgba(0, 0, 0, 0.05);
}

.summary-list li:first-child {
    border-top: none;
}

.summary-value {
    margin-left: auto;
    font-weight: 700;
    color: #101828;
}

.summary-dot {
    width: 9px;
    height: 9px;
    border-radius: 50%;
    flex-shrink: 0;
}

.dot-success {
    background: #12b76a;
}

.dot-skip {
    background: #f5a623;
}

.dot-fail {
    background: #c0392b;
}

.summary-message {
    margin: 0;
    font-size: 0.88rem;
    color: #922;
}

.error-log {
    max-height: 220px;
    overflow-y: auto;
    border: 1px solid #eee;
    border-radius: 8px;
    padding: 8px;
    background: #fafafa;
}

.error-log-item {
    font-size: 0.8rem;
    padding: 4px 2px;
    border-bottom: 1px dashed #eee;
}

.error-log-item:last-child {
    border-bottom: none;
}
</style>
