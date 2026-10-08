<template>
    <app-modal
        :modal-id="modalId"
        modal-size="large"
        :title="
            selectedUrl
                ? $t('common.update_item', { item: $t('sifat.singular') })
                : $t('common.add_item', { item: $t('sifat.singular') })
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
                        >{{ $t("sifat.form.name_en_label") }}
                        <span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="name"
                        v-model="formData.name"
                        class="form-control"
                        :placeholder="$t('sifat.form.name_en_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.name">{{
                        errors.name[0]
                    }}</small>
                </div>
                <div class="mb-3">
                    <label class="ar_name"
                        >{{ $t("sifat.form.name_ar_label") }}
                        <span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="ar_name"
                        v-model="formData.ar_name"
                        class="form-control"
                        :placeholder="$t('sifat.form.name_ar_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.ar_name">{{
                        errors.ar_name[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label class="translated_name"
                        >{{ $t("sifat.form.translated_name_label") }}
                        <span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="translated_name"
                        v-model="formData.translated_name"
                        class="form-control"
                        :placeholder="
                            $t('sifat.form.translated_name_placeholder')
                        "
                    />
                    <small class="text-danger" v-if="errors.translated_name">{{
                        errors.translated_name[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label class="meaning">{{
                        $t("sifat.form.meaning_label")
                    }}</label>
                    <input
                        type="text"
                        id="meaning"
                        v-model="formData.meaning"
                        class="form-control"
                        :placeholder="$t('sifat.form.meaning_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.meaning">{{
                        errors.meaning[0]
                    }}</small>
                </div>
                <div class="mb-3">
                    <label class="name_benefits">{{
                        $t("sifat.form.name_benefits_label")
                    }}</label>
                    <input
                        type="text"
                        id="name_benefits"
                        v-model="formData.name_benefits"
                        class="form-control"
                        :placeholder="
                            $t('sifat.form.name_benefits_placeholder')
                        "
                    />
                    <small class="text-danger" v-if="errors.name_benefits">{{
                        errors.name_benefits[0]
                    }}</small>
                </div>
                <div class="mb-3">
                    <label class="position">{{ $t("common.position") }}</label>
                    <input
                        type="text"
                        id="position"
                        v-model="formData.position"
                        class="form-control"
                        :placeholder="$t('sifat.form.position_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.position">{{
                        errors.position[0]
                    }}</small>
                </div>
            </form>
        </template>
    </app-modal>
</template>

<script setup>
import { useSubmitForm } from "@/composable/useSubmitForm.js";

const props = defineProps({
    modalId: String,
    selectedUrl: String,
});

const emit = defineEmits(["close"]);

const { preloader, errors, save, formData, closeModal, pageLoader } =
    useSubmitForm(props, emit);
const submit = () => {
    save(props.selectedUrl ? props.selectedUrl : "sifats", formData.value);
};
</script>
