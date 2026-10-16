<template>
    <app-modal
        :modal-id="modalId"
        modal-size="large"
        :title="
            selectedUrl
                ? $t('common.update_item', { item: $t('dua.singular') })
                : $t('common.add_item', { item: $t('dua.singular') })
        "
        :preloader="preloader"
        @submit="submit"
        @close="closeModal"
    >
        <template v-slot:body>
            <app-loader v-if="pageLoader" />
            <form v-else>
                <div class="mb-3">
                    <label class="en_short_name"
                        >{{ $t("dua.form.short_name_en_label") }}
                        <span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="en_short_name"
                        v-model="formData.en_short_name"
                        class="form-control"
                        :placeholder="$t('dua.form.short_name_en_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.en_short_name">{{
                        errors.en_short_name[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label class="en_full_name"
                        >{{ $t("dua.form.full_dua_en_label") }}
                        <span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="en_full_name"
                        v-model="formData.en_full_name"
                        class="form-control"
                        :placeholder="$t('dua.form.full_dua_en_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.en_full_name">{{
                        errors.en_full_name[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label class="ar_short_name"
                        >{{ $t("dua.form.short_name_ar_label")
                        }}<span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="ar_short_name"
                        v-model="formData.ar_short_name"
                        class="form-control"
                        :placeholder="$t('dua.form.short_name_ar_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.ar_short_name">{{
                        errors.ar_short_name[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label class="ar_full_name"
                        >{{ $t("dua.form.full_dua_ar_label")
                        }}<span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="ar_short_name"
                        v-model="formData.ar_full_name"
                        class="form-control"
                        :placeholder="$t('dua.form.full_dua_ar_placeholder')"
                    />
                    <small class="text-danger" v-if="errors.ar_full_name">{{
                        errors.ar_full_name[0]
                    }}</small>
                </div>

                <div class="mb-3">
                    <label class="position">{{ $t("common.position") }}</label>
                    <input
                        type="number"
                        id="position"
                        v-model="formData.position"
                        class="form-control"
                        :placeholder="$t('dua.form.position_placeholder')"
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

const { preloader, pageLoader, errors, save, formData, closeModal } =
    useSubmitForm(props, emit);
const submit = () => {
    save(props.selectedUrl ? props.selectedUrl : "dua", formData.value);
};
</script>
