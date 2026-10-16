<script setup>
import { ref, computed } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const preloader = ref(false);
const file = ref(null);
const fileInputEvent = ref(null);
const fileInput = ref(null);
const isDragging = ref(false);

const humanFileSize = computed(() => {
    if (!file.value) return "";
    const kb = file.value.size / 1024;
    return kb < 1024 ? `${kb.toFixed(1)} KB` : `${(kb / 1024).toFixed(2)} MB`;
});

const onFileChanged = (e) => {
    fileInputEvent.value = e;
    file.value = e.target.files[0];
};

const onDrop = (e) => {
    isDragging.value = false;
    const dropped = e.dataTransfer.files?.[0];
    if (!dropped) return;
    file.value = dropped;
    if (fileInput.value) {
        const dt = new DataTransfer();
        dt.items.add(dropped);
        fileInput.value.files = dt.files;
        fileInputEvent.value = { target: fileInput.value };
    }
};

const clearFile = () => {
    file.value = null;
    if (fileInput.value) fileInput.value.value = null;
};
const onsubmit = (e) => {
    preloader.value = true;

    if (!file.value) {
        toast.error(t("prayer_time.import.select_file_error"));
        preloader.value = false;
        return;
    }

    // Validate file type
    const allowedExtensions = ["xlsx", "xls", "csv"];
    const fileExtension = file.value.name.split(".").pop().toLowerCase();
    if (!allowedExtensions.includes(fileExtension)) {
        toast.error(t("prayer_time.import.file_type_error"));
        preloader.value = false;
        return;
    }

    // Validate file size (70 KB = 70 * 1024 bytes)
    const maxFileSize = 150 * 1024; // 70 KB
    if (file.value.size > maxFileSize) {
        toast.error(t("prayer_time.import.file_size_error"));
        preloader.value = false;
        return;
    }

    const formData = new FormData();
    formData.append("file", file.value);

    Axios.post("prayertime-import", formData, {
        headers: {
            "Content-Type": "multipart/form-data",
        },
    })
        .then((data) => {
            toast.success(data.data.message);
            file.value = null;
            fileInputEvent.value.target.value = null;
        })
        .catch(({ response }) => {
            toast.error(response.data.message);
        })
        .finally(() => (preloader.value = false));
};

// Example file download URL (replace with your actual file URL)
const exampleFileUrl = urlGenerator("assets/prayer_times.xlsx");
</script>
<template>
    <main class="pt-import-content py-5">
        <div class="pt-import-card">
            <!-- Header -->
            <div class="pt-import-header">
                <div class="pt-import-header-icon">
                    <svg
                        width="22"
                        height="22"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                    >
                        <path
                            d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"
                        ></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                        <line x1="12" y1="18" x2="12" y2="12"></line>
                        <polyline points="9 15 12 12 15 15"></polyline>
                    </svg>
                </div>
                <div>
                    <h1 class="pt-import-title">
                        {{ $t("prayer_time.import.title") }}
                    </h1>
                    <p class="pt-import-subtitle">
                        Upload an Excel or CSV file to add prayer times in bulk.
                    </p>
                </div>
            </div>

            <div class="pt-import-body">
                <!-- Instructions -->
                <div class="pt-instruction-box">
                    <div class="pt-instruction-title">
                        <svg
                            width="18"
                            height="18"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <circle cx="12" cy="12" r="10"></circle>
                            <line x1="12" y1="16" x2="12" y2="12"></line>
                            <line x1="12" y1="8" x2="12.01" y2="8"></line>
                        </svg>
                        <span>{{
                            $t("prayer_time.import.instructions_title")
                        }}</span>
                    </div>
                    <ul class="pt-instruction-list">
                        <li
                            v-html="
                                $t('prayer_time.import.instruction_date_format')
                            "
                        ></li>
                        <li
                            v-html="
                                $t('prayer_time.import.instruction_columns')
                            "
                        ></li>
                        <li>
                            {{ $t("prayer_time.import.instruction_file_size") }}
                        </li>
                    </ul>
                    <a
                        :href="exampleFileUrl"
                        download="prayer_times.xlsx"
                        class="pt-download-link"
                    >
                        <svg
                            width="15"
                            height="15"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <path
                                d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"
                            ></path>
                            <polyline points="7 10 12 15 17 10"></polyline>
                            <line x1="12" y1="15" x2="12" y2="3"></line>
                        </svg>
                        {{ $t("prayer_time.import.download_example") }}
                    </a>
                </div>

                <!-- Upload form -->
                <form enctype="multipart/form-data" @submit.prevent="onsubmit">
                    <div
                        class="pt-dropzone"
                        :class="{ 'is-dragging': isDragging, 'has-file': file }"
                        @dragover.prevent="isDragging = true"
                        @dragleave.prevent="isDragging = false"
                        @drop.prevent="onDrop"
                        @click="fileInput?.click()"
                    >
                        <input
                            ref="fileInput"
                            id="file"
                            class="pt-hidden-input"
                            type="file"
                            @change="onFileChanged($event)"
                            accept=".xlsx, .xls, .csv"
                        />

                        <template v-if="!file">
                            <div class="pt-dropzone-icon">
                                <svg
                                    width="30"
                                    height="30"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="1.8"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                >
                                    <path
                                        d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"
                                    ></path>
                                    <polyline points="17 8 12 3 7 8"></polyline>
                                    <line x1="12" y1="3" x2="12" y2="15"></line>
                                </svg>
                            </div>
                            <p class="pt-dropzone-text">
                                <span class="pt-dropzone-accent"
                                    >Click to upload</span
                                >
                                or drag and drop
                            </p>
                            <p class="pt-dropzone-hint">
                                XLSX, XLS or CSV — max 150 KB
                            </p>
                        </template>

                        <div v-else class="pt-file-chip" @click.stop>
                            <div class="pt-file-chip-icon">
                                <svg
                                    width="20"
                                    height="20"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                >
                                    <path
                                        d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"
                                    ></path>
                                    <polyline
                                        points="14 2 14 8 20 8"
                                    ></polyline>
                                </svg>
                            </div>
                            <div class="pt-file-chip-info">
                                <span class="pt-file-chip-name">{{
                                    file.name
                                }}</span>
                                <span class="pt-file-chip-size">{{
                                    humanFileSize
                                }}</span>
                            </div>
                            <button
                                type="button"
                                class="pt-file-chip-remove"
                                @click.stop="clearFile"
                                aria-label="Remove file"
                            >
                                <svg
                                    width="16"
                                    height="16"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                >
                                    <line x1="18" y1="6" x2="6" y2="18"></line>
                                    <line x1="6" y1="6" x2="18" y2="18"></line>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <button
                        :disabled="preloader"
                        type="submit"
                        class="pt-submit-btn"
                    >
                        <span
                            v-if="preloader"
                            class="spinner-border spinner-border-sm me-2"
                        ></span>
                        {{ $t("prayer_time.import.submit") }}
                    </button>
                </form>
            </div>
        </div>
    </main>
</template>

<style scoped>
/* Theme fallbacks so the component looks right even outside the admin layout */
.pt-import-content {
    --pt-primary: var(--theme-primary, #1a6b4a);
    --pt-secondary: var(--theme-secondary, #2d8a63);
    --pt-primary-rgb: var(--theme-primary-rgb, 26, 107, 74);
    --pt-text: var(--theme-text, #1a1f2e);
    --pt-text-muted: var(--theme-text-muted, #5a6478);
    --pt-card: var(--theme-card, #ffffff);
    --pt-page: var(--theme-page, #f5f7fb);
    --pt-border: var(--theme-border, #e4e8f0);

    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: var(--pt-page);
    padding: 2.5rem 1rem;
}

.pt-import-card {
    width: 100%;
    max-width: 560px;
    background: var(--pt-card);
    border: 1px solid var(--pt-border);
    border-radius: 16px;
    overflow: hidden;
    box-shadow:
        0 1px 2px rgba(16, 24, 40, 0.04),
        0 8px 28px rgba(16, 24, 40, 0.06);
}

/* Header — light, with small green icon */
.pt-import-header {
    display: flex;
    align-items: center;
    gap: 0.9rem;
    padding: 1.6rem 1.9rem;
    border-bottom: 1px solid var(--pt-border);
}
.pt-import-header-icon {
    flex-shrink: 0;
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 11px;
    background: rgba(var(--pt-primary-rgb), 0.1);
    color: var(--pt-primary);
}
.pt-import-title {
    font-size: 1.25rem;
    font-weight: 700;
    margin: 0;
    color: var(--pt-text);
    letter-spacing: -0.01em;
}
.pt-import-subtitle {
    margin: 0.15rem 0 0;
    font-size: 0.86rem;
    color: var(--pt-text-muted);
    line-height: 1.4;
}

.pt-import-body {
    padding: 1.75rem 1.9rem 1.9rem;
}

/* Instructions */
.pt-instruction-box {
    background: rgba(var(--pt-primary-rgb), 0.045);
    border: 1px solid rgba(var(--pt-primary-rgb), 0.12);
    border-radius: 12px;
    padding: 1.1rem 1.25rem;
    margin-bottom: 1.75rem;
}
.pt-instruction-title {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-weight: 600;
    font-size: 0.92rem;
    color: var(--pt-primary);
    margin-bottom: 0.7rem;
}
.pt-instruction-list {
    margin: 0;
    padding-inline-start: 1.2rem;
    color: var(--pt-text-muted);
    font-size: 0.875rem;
    line-height: 1.75;
}
.pt-instruction-list :deep(code),
.pt-instruction-list :deep(strong) {
    color: var(--pt-text);
    font-weight: 600;
}
.pt-download-link {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    margin-top: 0.9rem;
    font-size: 0.86rem;
    font-weight: 600;
    color: var(--pt-primary);
    text-decoration: none;
    transition: opacity 0.15s ease;
}
.pt-download-link:hover {
    opacity: 0.72;
    text-decoration: underline;
}

/* Upload */
.pt-hidden-input {
    display: none;
}

.pt-dropzone {
    border: 1.5px dashed var(--pt-border);
    border-radius: 14px;
    background: var(--pt-card);
    padding: 2.5rem 1.5rem;
    text-align: center;
    cursor: pointer;
    transition:
        border-color 0.18s ease,
        background 0.18s ease;
}
.pt-dropzone:hover,
.pt-dropzone.is-dragging {
    border-color: var(--pt-primary);
    background: rgba(var(--pt-primary-rgb), 0.04);
}
.pt-dropzone.has-file {
    cursor: default;
    padding: 1.1rem;
    background: rgba(var(--pt-primary-rgb), 0.04);
    border-style: solid;
    border-color: rgba(var(--pt-primary-rgb), 0.25);
}
.pt-dropzone-icon {
    width: 52px;
    height: 52px;
    margin: 0 auto 0.85rem;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: rgba(var(--pt-primary-rgb), 0.09);
    color: var(--pt-primary);
}
.pt-dropzone-text {
    margin: 0 0 0.3rem;
    font-size: 0.92rem;
    color: var(--pt-text);
}
.pt-dropzone-accent {
    color: var(--pt-primary);
    font-weight: 600;
}
.pt-dropzone-hint {
    margin: 0;
    font-size: 0.8rem;
    color: var(--pt-text-muted);
}

/* File chip */
.pt-file-chip {
    display: flex;
    align-items: center;
    gap: 0.85rem;
    text-align: start;
    cursor: default;
}
.pt-file-chip-icon {
    flex-shrink: 0;
    width: 42px;
    height: 42px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 10px;
    background: var(--pt-primary);
    color: #fff;
}
.pt-file-chip-info {
    display: flex;
    flex-direction: column;
    min-width: 0;
    flex: 1;
}
.pt-file-chip-name {
    font-weight: 600;
    font-size: 0.9rem;
    color: var(--pt-text);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.pt-file-chip-size {
    font-size: 0.8rem;
    color: var(--pt-text-muted);
}
.pt-file-chip-remove {
    flex-shrink: 0;
    border: none;
    background: rgba(var(--pt-primary-rgb), 0.08);
    color: var(--pt-text-muted);
    width: 30px;
    height: 30px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition:
        background 0.15s ease,
        color 0.15s ease;
}
.pt-file-chip-remove:hover {
    background: rgba(var(--theme-error-rgb, 224, 92, 92), 0.14);
    color: var(--theme-error, #e05c5c);
}

/* Submit */
.pt-submit-btn {
    width: 100%;
    margin-top: 1.5rem;
    padding: 0.8rem 1rem;
    border: none;
    border-radius: 11px;
    font-size: 0.95rem;
    font-weight: 600;
    color: #fff;
    background: var(--pt-primary);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition:
        filter 0.15s ease,
        transform 0.1s ease;
}
.pt-submit-btn:hover:not(:disabled) {
    filter: brightness(1.08);
}
.pt-submit-btn:active:not(:disabled) {
    transform: translateY(1px);
}
.pt-submit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

@media (max-width: 560px) {
    .pt-import-body {
        padding: 1.5rem 1.25rem 1.6rem;
    }
    .pt-import-header {
        padding: 1.4rem 1.35rem;
    }
}
</style>
