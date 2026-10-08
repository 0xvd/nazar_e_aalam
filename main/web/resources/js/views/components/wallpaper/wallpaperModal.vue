<template>
    <app-modal
        :modal-id="modalId"
        modal-size="large"
        :title="
            selectedUrl
                ? $t('common.update_item', { item: $t('wallpaper.singular') })
                : $t('common.add_item', { item: $t('wallpaper.singular') })
        "
        :preloader="preloader"
        @submit="submit"
        @close="closeModal"
    >
        <template v-slot:body>
            <app-loader v-if="pageLoader" />
            <form v-else class="wallpaper-form-shell">
                <div class="mb-3">
                    <label class="name"
                        >{{ $t("wallpaper.modal.name_label")
                        }}<span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="name"
                        v-model="formData.name"
                        class="form-control"
                        :placeholder="$t('wallpaper.modal.name_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.name">{{
                        errors.name[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label class="category"
                        >{{ $t("wallpaper.modal.category_label") }}
                        <span class="text-danger">*</span></label
                    >
                    <select
                        id="category"
                        v-model="formData.category_id"
                        class="form-control"
                    >
                        <option value="">
                            {{ $t("wallpaper.modal.category_placeholder") }}
                        </option>
                        <option
                            v-for="category in categoryList"
                            :value="category.id"
                        >
                            {{ category.name }}
                        </option>
                    </select>
                    <small class="text-danger" v-if="errors.category_id">{{
                        errors.category_id[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label for="image">{{
                        $t("wallpaper.modal.image_label")
                    }}</label>
                    <input
                        type="file"
                        id="image"
                        @change="handleFileUpload"
                        class="form-control"
                    />
                    <small class="text-danger" v-if="errors.image">{{
                        errors.image[0]
                    }}</small>
                </div>
            </form>
        </template>
    </app-modal>
</template>

<script setup>
import { useSubmitForm } from "@/composable/useSubmitForm.js";
import { ref, onMounted, watch } from "vue";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import Axios from "@/services/axios/index.js";

const props = defineProps({
    modalId: String,
    selectedUrl: String,
});

const emit = defineEmits(["close"]);

// Fetch category list from server
const categoryList = ref([]);

const handleFileUpload = (event) => {
    const selectedFile = event.target.files[0];
    if (!selectedFile) return;

    formData.value.image = selectedFile; // Save the file for submission
};

onMounted(async () => {
    const response = await Axios.get(urlGenerator("api/wallpaper-category"));
    categoryList.value = response.data;
});

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
    category_id: "",
    image: "",
});

const submit = async () => {
    preloader.value = true;

    try {
        const submitData = new FormData();
        submitData.append("name", formData.value.name);
        submitData.append("category_id", formData.value.category_id);
        submitData.append("image", formData.value.image);

        if (props.selectedUrl) {
            submitData.append("id", formData.value.id);
            submitData.append("_method", "PATCH");
        }

        // Ensure that this request is always triggered, regardless of file size
        await Axios.post(props.selectedUrl || "wallpaper", submitData, {
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
            .finally(() => afterFinalResponse());
    } catch (error) {
        console.error("Submission Error:", error);
        afterError(error.response);
    } finally {
        afterFinalResponse();
    }
};

const fetchFormData = async () => {
    if (props.selectedUrl) {
        preloader.value = true;
        try {
            const response = await Axios.get(props.selectedUrl);
            formData.value = response.data;
        } catch (error) {
            console.error("Fetch Error:", error);
        } finally {
            preloader.value = false;
        }
    }
};

watch(() => props.selectedUrl, fetchFormData, { immediate: true });
</script>

<style scoped>
.wallpaper-form-shell :deep(label) {
    font-weight: 600;
    font-size: 0.875rem;
    color: #374151;
    margin-bottom: 0.35rem;
}

.wallpaper-form-shell :deep(.form-control) {
    border-radius: 8px;
    border-color: #e5e7eb;
}

.wallpaper-form-shell :deep(.form-control:focus) {
    border-color: #93c5fd;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.18);
}
</style>
