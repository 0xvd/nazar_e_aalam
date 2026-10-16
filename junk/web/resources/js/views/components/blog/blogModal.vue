<template>
    <app-modal
        :modal-id="modalId"
        modal-size="extra-large"
        :title="
            selectedUrl
                ? $t('common.update_item', { item: $t('blog.singular') })
                : $t('common.add_item', { item: $t('blog.singular') })
        "
        :preloader="preloader"
        @submit="submit"
        @close="closeModal"
    >
        <template v-slot:body>
            <app-loader v-if="pageLoader" />
            <form v-else>
                <div class="mb-3">
                    <label
                        >{{ $t("blog.form.title_label") }}
                        <span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        v-model="formData.title"
                        @input="autoSlug"
                        class="form-control"
                        :placeholder="$t('blog.form.title_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.title">{{
                        errors.title[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label>{{ $t("blog.form.slug_label") }}</label>
                    <input
                        type="text"
                        v-model="formData.slug"
                        class="form-control"
                        :placeholder="$t('blog.form.slug_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.slug">{{
                        errors.slug[0]
                    }}</small>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label>{{ $t("blog.form.category_label") }}</label>
                        <input
                            type="text"
                            v-model="formData.category"
                            class="form-control"
                            :placeholder="$t('blog.form.category_placeholder')"
                        />
                    </div>
                    <div class="col-md-6 mb-3">
                        <label
                            >{{ $t("blog.form.status_label") }}
                            <span class="text-danger">*</span></label
                        >
                        <select v-model="formData.status" class="form-control">
                            <option value="draft">
                                {{ $t("blog.form.status_draft") }}
                            </option>
                            <option value="published">
                                {{ $t("blog.form.status_published") }}
                            </option>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label
                        >{{ $t("blog.form.excerpt_label") }}
                        <small class="text-muted">{{
                            $t("blog.form.excerpt_hint")
                        }}</small></label
                    >
                    <textarea
                        v-model="formData.excerpt"
                        class="form-control"
                        rows="2"
                        :placeholder="$t('blog.form.excerpt_placeholder')"
                    ></textarea>
                    <small class="text-danger" v-if="errors.excerpt">{{
                        errors.excerpt[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label
                        >{{ $t("blog.form.content_label") }}
                        <span class="text-danger">*</span></label
                    >
                    <div
                        class="editor-wrapper"
                        :class="{ 'editor-fullscreen': isFullscreen }"
                        ref="editorWrapper"
                    >
                        <button
                            type="button"
                            class="fullscreen-btn"
                            @click="isFullscreen = !isFullscreen"
                        >
                            <svg
                                width="14"
                                height="14"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2"
                            >
                                <path
                                    v-if="!isFullscreen"
                                    d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3M3 16v3a2 2 0 0 0 2 2h3m11-5v3a2 2 0 0 1-2 2h-3"
                                />
                                <path
                                    v-else
                                    d="M9 3v3a2 2 0 0 1-2 2H4M3 16h3a2 2 0 0 1 2 2v3m11-5h-3a2 2 0 0 0-2 2v3M15 3v3a2 2 0 0 0 2 2h3"
                                />
                            </svg>
                            {{
                                isFullscreen
                                    ? $t("blog.form.fullscreen_exit")
                                    : $t("blog.form.fullscreen_enter")
                            }}
                        </button>
                        <QuillEditor
                            v-model:content="editorContent"
                            content-type="html"
                            :options="quillOptions"
                            :placeholder="$t('blog.form.content_placeholder')"
                            @text-change="formData.content = editorContent"
                            @ready="onEditorReady"
                        />
                    </div>
                    <small class="text-danger" v-if="errors.content">{{
                        errors.content[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label
                        >{{ $t("blog.form.thumbnail_label") }}
                        <small class="text-muted">{{
                            $t("blog.form.thumbnail_hint")
                        }}</small></label
                    >
                    <input
                        type="file"
                        accept="image/*"
                        @change="handleFileUpload"
                        class="form-control"
                        :disabled="thumbUpload.isUploading"
                    />
                    <div v-if="thumbPreview" class="mt-2">
                        <img
                            :src="thumbPreview"
                            alt="preview"
                            style="
                                width: 120px;
                                height: 72px;
                                object-fit: cover;
                                border-radius: 6px;
                                border: 1px solid #dee2e6;
                            "
                        />
                    </div>
                    <div
                        v-if="thumbUpload.isUploading"
                        class="progress mt-2"
                        style="height: 6px"
                    >
                        <div
                            class="progress-bar"
                            role="progressbar"
                            :style="{ width: thumbUpload.progress + '%' }"
                        ></div>
                    </div>
                    <small
                        class="text-muted d-block"
                        v-if="thumbUpload.isUploading"
                    >
                        {{
                            $t("blog.form.thumbnail_uploading", {
                                progress: thumbUpload.progress,
                            })
                        }}
                    </small>
                    <small
                        class="text-danger d-block"
                        v-if="thumbUpload.hasFailed"
                    >
                        {{ $t("blog.form.thumbnail_upload_failed") }}
                        <a href="#" @click.prevent="retryThumbnailUpload">{{
                            $t("blog.form.thumbnail_retry")
                        }}</a>
                    </small>
                    <small class="text-danger" v-if="errors.thumbnail">{{
                        errors.thumbnail[0]
                    }}</small>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label
                            >{{ $t("blog.form.meta_title_label") }}
                            <small class="text-muted">{{
                                $t("blog.form.seo_hint")
                            }}</small></label
                        >
                        <input
                            type="text"
                            v-model="formData.meta_title"
                            class="form-control"
                            :placeholder="
                                $t('blog.form.meta_title_placeholder')
                            "
                        />
                    </div>
                    <div class="col-md-6 mb-3">
                        <label
                            >{{ $t("blog.form.meta_description_label") }}
                            <small class="text-muted">{{
                                $t("blog.form.seo_hint")
                            }}</small></label
                        >
                        <input
                            type="text"
                            v-model="formData.meta_description"
                            class="form-control"
                            :placeholder="
                                $t('blog.form.meta_description_placeholder')
                            "
                        />
                    </div>
                </div>
            </form>
        </template>
    </app-modal>
</template>

<script setup>
import { ref, watch, onBeforeUnmount } from "vue";
import { useI18n } from "vue-i18n";
import { toast } from "vue3-toastify";
import Axios from "@/services/axios/index.js";
import { useSubmitForm } from "@/composable/useSubmitForm.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { QuillEditor } from "@vueup/vue-quill";
import "@vueup/vue-quill/dist/vue-quill.snow.css";

const props = defineProps({
    modalId: String,
    selectedUrl: String,
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

const thumbFile = ref(null);
const thumbPreview = ref("");
const isFullscreen = ref(false);
const editorContent = ref("<p></p>");

const THUMB_CHUNK_SIZE = 1024 * 1000; // ~1MB per chunk
const MAX_THUMBNAIL_SIZE = 3072 * 1024; // matches backend's max:3072 (KB) rule
const MAX_CHUNK_RETRIES = 3;

const thumbUpload = ref({ isUploading: false, progress: 0, hasFailed: false });
// Promise for the in-flight thumbnail chunk upload, so submit() can wait for it
// before sending the rest of the form.
let thumbUploadPromise = null;
let activeThumbUploadId = null;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const cancelActiveThumbUpload = () => {
    if (activeThumbUploadId) {
        Axios.delete("blog-posts-upload-chunk", {
            params: { uploadId: activeThumbUploadId },
        }).catch(() => {});
        activeThumbUploadId = null;
    }
};

const uploadThumbChunkWithRetry = async (chunkForm) => {
    let attempt = 0;
    while (true) {
        try {
            return await Axios.post("blog-posts-upload-chunk", chunkForm, {
                headers: { "Content-Type": "multipart/form-data" },
                timeout: 30000,
            });
        } catch (error) {
            const status = error.response?.status;
            const isRetryable = !error.response || status >= 500;
            attempt++;
            if (!isRetryable || attempt > MAX_CHUNK_RETRIES) throw error;
            await sleep(Math.min(1000 * 2 ** (attempt - 1), 6000));
        }
    }
};

// Uploads the thumbnail one small chunk at a time so a large/raw image never
// has to pass through the main save request (or trip server body-size limits)
// in one piece. Resolves once the assembled image is stored server-side.
const uploadThumbnailInChunks = async (file) => {
    const totalChunks = Math.ceil(file.size / THUMB_CHUNK_SIZE);
    const uploadId = crypto.randomUUID().replace(/-/g, "");
    activeThumbUploadId = uploadId;

    thumbUpload.value = { isUploading: true, progress: 0, hasFailed: false };

    try {
        for (let chunkNumber = 1; chunkNumber <= totalChunks; chunkNumber++) {
            const start = (chunkNumber - 1) * THUMB_CHUNK_SIZE;
            const chunk = file.slice(start, start + THUMB_CHUNK_SIZE);
            const chunkForm = new FormData();
            chunkForm.append("file", chunk, `${file.name}.part`);
            chunkForm.append("uploadId", uploadId);
            chunkForm.append("chunkNumber", chunkNumber);
            chunkForm.append("totalChunks", totalChunks);
            chunkForm.append("fileName", file.name);

            await uploadThumbChunkWithRetry(chunkForm);
            thumbUpload.value.progress = Math.round(
                (chunkNumber / totalChunks) * 100,
            );
        }

        const { data } = await Axios.post("blog-posts-upload-chunk/complete", {
            uploadId,
            totalChunks,
            fileName: file.name,
        });

        activeThumbUploadId = null;
        thumbUpload.value.isUploading = false;
        formData.value.thumbnail = data.path;
    } catch (error) {
        thumbUpload.value.isUploading = false;
        thumbUpload.value.hasFailed = true;
        toast.error(
            error.response?.data?.message ||
                t("blog.form.thumbnail_upload_failed"),
        );
    }
};

const retryThumbnailUpload = () => {
    if (!thumbFile.value) return;
    thumbUploadPromise = uploadThumbnailInChunks(thumbFile.value);
};

const uploadEditorImage = async (file) => {
    const payload = new FormData();
    payload.append("image", file);
    const { data } = await Axios.post("blog-posts-upload-image", payload, {
        headers: { "Content-Type": "multipart/form-data" },
    });
    return urlGenerator(data.url);
};

const insertUploadedImage = async (quill, file) => {
    const range = quill.getSelection(true);
    const placeholder = "Uploading image...";
    quill.insertText(range.index, placeholder, { italic: true });
    try {
        const url = await uploadEditorImage(file);
        quill.deleteText(range.index, placeholder.length);
        quill.insertEmbed(range.index, "image", url);
        quill.setSelection(range.index + 1);
    } catch (e) {
        quill.deleteText(range.index, placeholder.length);
    }
};

let quillInstance = null;
const editorWrapper = ref(null);

// Browsers paste clipboard images into Quill as inline base64 data URIs,
// which can blow up the content payload to tens of MB. Intercept the paste
// on the wrapper in the capture phase (before it reaches Quill's own paste
// handler on quill.root) and upload the image instead, same as the toolbar
// image button does.
const handleEditorPaste = (e) => {
    const file = Array.from(e.clipboardData?.files || []).find((f) =>
        f.type.startsWith("image/"),
    );
    if (!file || !quillInstance) return;
    e.preventDefault();
    e.stopPropagation();
    insertUploadedImage(quillInstance, file);
};

const onEditorReady = (quill) => {
    quillInstance = quill;
    editorWrapper.value?.addEventListener("paste", handleEditorPaste, true);
};

onBeforeUnmount(() => {
    editorWrapper.value?.removeEventListener("paste", handleEditorPaste, true);
    cancelActiveThumbUpload();
});

const quillOptions = {
    modules: {
        toolbar: {
            container: [
                [{ header: [1, 2, 3, false] }],
                ["bold", "italic", "underline", "strike"],
                [{ color: [] }, { background: [] }],
                [{ script: "sub" }, { script: "super" }],
                ["blockquote", "code-block"],
                [{ list: "ordered" }, { list: "bullet" }],
                [{ indent: "-1" }, { indent: "+1" }],
                [{ align: [] }],
                [{ direction: "rtl" }],
                ["link", "image", "video"],
                ["clean"],
            ],
            handlers: {
                image() {
                    const quill = this.quill;
                    const input = document.createElement("input");
                    input.setAttribute("type", "file");
                    input.setAttribute("accept", "image/*");
                    input.click();
                    input.onchange = async () => {
                        const file = input.files[0];
                        if (file) await insertUploadedImage(quill, file);
                    };
                },
            },
        },
    },
};

const formData = ref({
    title: "",
    slug: "",
    category: "General",
    excerpt: "",
    content: "",
    meta_title: "",
    meta_description: "",
    status: "draft",
});

const slugify = (str) =>
    str
        .toLowerCase()
        .trim()
        .replace(/[^\w\s-]/g, "")
        .replace(/[\s_-]+/g, "-")
        .replace(/^-+|-+$/g, "");

const autoSlug = () => {
    if (!props.selectedUrl) formData.value.slug = slugify(formData.value.title);
};

const handleFileUpload = (event) => {
    cancelActiveThumbUpload();
    thumbUpload.value = { isUploading: false, progress: 0, hasFailed: false };

    const selected = event.target.files[0] || null;
    thumbFile.value = selected;
    if (!selected) return;

    thumbPreview.value = URL.createObjectURL(selected);

    if (selected.size > MAX_THUMBNAIL_SIZE) {
        toast.error(
            t("blog.form.thumbnail_max_size", {
                size: `${MAX_THUMBNAIL_SIZE / (1024 * 1024)}MB`,
            }),
        );
        thumbFile.value = null;
        thumbPreview.value = "";
        event.target.value = "";
        return;
    }

    thumbUploadPromise = uploadThumbnailInChunks(selected);
};

const submit = async () => {
    preloader.value = true;
    if (thumbUploadPromise) await thumbUploadPromise;
    if (thumbUpload.value.hasFailed) {
        toast.error(t("blog.form.thumbnail_retry_before_save"));
        preloader.value = false;
        return;
    }

    const payload = new FormData();
    Object.entries(formData.value).forEach(([k, v]) => {
        if (v !== null && v !== undefined) payload.append(k, v);
    });
    if (props.selectedUrl) payload.append("_method", "PATCH");

    await Axios.post(props.selectedUrl || "blog-posts", payload, {
        headers: { "Content-Type": "multipart/form-data" },
    })
        .then((response) => {
            afterSuccess(response);
        })
        .catch(({ response }) => {
            afterError(response);
        })
        .finally(() => afterFinalResponse());
};

const fetchFormData = async () => {
    if (props.selectedUrl) {
        pageLoader.value = true;
        try {
            const { data } = await Axios.get(props.selectedUrl);
            formData.value = { ...data };
            thumbPreview.value = data.thumbnail
                ? urlGenerator(data.thumbnail)
                : "";
        } finally {
            pageLoader.value = false;
        }
    }
};

watch(() => props.selectedUrl, fetchFormData, { immediate: true });
watch(
    () => formData.value.content,
    (val) => {
        editorContent.value = val || "<p></p>";
    },
    { immediate: true },
);
</script>

<style scoped>
.editor-wrapper {
    display: flex;
    flex-direction: column;
    border-radius: 6px;
    border: 1px solid #dee2e6;
    overflow: hidden;
}

.fullscreen-btn {
    display: inline-flex;
    align-items: center;
    align-self: flex-end;
    gap: 5px;
    margin: 6px 8px 0;
    border: 1px solid #dee2e6;
    background: var(--theme-card);
    border-radius: 6px;
    padding: 3px 9px;
    font-size: 0.78rem;
    color: #495057;
    cursor: pointer;
}

.fullscreen-btn:hover {
    background: #f8f9fa;
}

.editor-wrapper :deep(.ql-container) {
    min-height: 260px;
    max-height: 480px;
    overflow-y: auto;
}

.editor-wrapper.editor-fullscreen {
    position: fixed;
    inset: 0;
    z-index: 1070;
    border-radius: 0;
    background: var(--theme-card);
}

.editor-wrapper.editor-fullscreen :deep(.ql-container) {
    flex: 1;
    max-height: none;
}
</style>
