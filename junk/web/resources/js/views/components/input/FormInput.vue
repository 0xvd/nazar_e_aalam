<template>
    <select-input
        v-if="type === 'select'"
        :value="modelValue"
        :data="$props"
        @selectInput="
            (value) =>
                $emit('update:modelValue', value ? value[keyField] : null)
        "
        v-bind="$attrs"
    />

    <quill-editor
        v-else-if="type === 'editor'"
        ref="quill"
        v-model:content="contentData"
        contentType="html"
        @textChange="$emit('update:modelValue', contentData)"
        v-bind="$attrs"
    />
</template>

<script setup>
import { ref, watch } from "vue";
import SelectInput from "@/components/input/select/SearchSelect.vue";
import { QuillEditor } from "@vueup/vue-quill";
import "@vueup/vue-quill/dist/vue-quill.snow.css";
const props = defineProps({
    type: {
        type: String,
        default: "text",
    },
    modelValue: {},
    labelName: {
        type: String,
        default: "value",
    },
    keyField: {
        type: String,
        default: "id",
    },
    chooseLabel: {
        type: String,
        default: "Choose Option",
    },
    options: {
        type: Array,
    },
});

const contentData = ref("");
const quill = ref();
watch(
    () => props.modelValue,
    (newValue) => {
        if (newValue) {
            contentData.value = newValue;
        } else {
            contentData.value = "<p></p>";
        }
    },
    { immediate: true, deep: true },
);
defineExpose({
    quill,
});
</script>
