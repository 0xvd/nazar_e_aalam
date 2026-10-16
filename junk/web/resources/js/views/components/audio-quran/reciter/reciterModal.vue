<template>
    <app-modal
        :modal-id="modalId"
        modal-size="large"
        :title="
            selectedUrl
                ? $t('common.update_item', { item: $t('reciter.singular') })
                : $t('common.add_item', { item: $t('reciter.singular') })
        "
        :preloader="preloader"
        @submit="submit"
        @close="closeModal"
    >
        <template v-slot:body>
            <app-loader v-if="pageLoader" />
            <form v-else>
                <div class="mb-3">
                    <label class="name"
                        >{{ $t("common.name") }}
                        <span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="name"
                        v-model="formData.name"
                        class="form-control"
                        :placeholder="$t('reciter.form.name_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.name">{{
                        errors.name[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label class="position">{{ $t("common.position") }}</label>
                    <input
                        type="number"
                        id="position"
                        v-model="formData.position"
                        class="form-control"
                        :placeholder="$t('reciter.form.position_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.position">{{
                        errors.position[0]
                    }}</small>
                </div>

                <div class="form-group row mb-3 mt-3">
                    <label for="image" class="col-sm-2 col-form-label">{{
                        $t("reciter.form.profile_picture")
                    }}</label>
                    <p></p>
                    <div class="col-sm-10">
                        <div>
                            <div
                                class="custom-image-upload-wrapper"
                                style="width: 150px; height: 100px"
                            >
                                <div
                                    class="image-area d-flex"
                                    style="width: 150px; height: 100px"
                                >
                                    <img
                                        id="bruh"
                                        style="width: 150px"
                                        :src="profileAvatar"
                                        alt="profile picture"
                                        class="img-fluid mx-auto my-auto"
                                    />
                                </div>

                                <div class="input-area" style="width: 150px">
                                    <label
                                        id="upload-label"
                                        for="profile_picture"
                                    >
                                        {{ $t("reciter.form.upload_picture") }}
                                    </label>
                                    <input
                                        id="profile_picture"
                                        name="profile_picture"
                                        type="file"
                                        class="form-control d-none"
                                        @change="onFileChange($event)"
                                    />
                                </div>
                            </div>
                        </div>
                        <small
                            class="text-danger"
                            v-if="errors.profile_picture"
                            >{{ errors.profile_picture[0] }}</small
                        >
                    </div>
                </div>
            </form>
        </template>
    </app-modal>
</template>

<script setup>
import { useSubmitForm } from "@/composable/useSubmitForm.js";
import { ref } from "vue";
import { formDataAssigner } from "@/utilities/helper.js";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";
import { urlGenerator } from "@/utilities/urlGenerator.js";

const props = defineProps({
    modalId: String,
    selectedUrl: String,
});

const emit = defineEmits(["close"]);

const {
    preloader,
    pageLoader,
    errors,
    afterSuccess,
    afterError,
    afterFinalResponse,
    formData,
    closeModal,
} = useSubmitForm(props, emit);

const file = ref(null);
const onFileChange = (event) => {
    file.value = event.target.files[0];
    profileAvatar.value = URL.createObjectURL(file.value);
};

const submit = () => {
    preloader.value = true;
    errors.value = {};
    delete formData.value?.profile;
    if (file.value) {
        formData.value.profile_picture = file.value;
    } else {
        delete formData.value?.profile_picture;
    }

    if (props.selectedUrl) {
        formData.value._method = "PATCH";
    }

    let data = formDataAssigner(new FormData(), formData.value);
    Axios.post(props.selectedUrl ? props.selectedUrl : "reciter", data, {
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
};

const profileAvatar = ref(urlGenerator("assets/img/avatar.png"));
</script>
