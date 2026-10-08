<template>
    <div>
        <vue-select
            :options="options"
            v-model="internalValue"
            label="name"
            :placeholder="placeholder"
        />
    </div>
</template>

<script>
import { defineComponent, ref, watch } from "vue";
import VueSelect from "vue3-select";
import "vue3-select/dist/vue3-select.css";

export default defineComponent({
    name: "Select2",
    components: {
        VueSelect,
    },
    props: {
        modelValue: String, // Store only the text (Sura name)
        options: {
            type: Array,
            required: true,
        },
        placeholder: {
            type: String,
            default: "",
        },
    },
    setup(props, { emit }) {
        const internalValue = ref(null); // Initial value for v-model

        // Watch for changes in modelValue (parent prop) and update internalValue
        watch(
            () => props.modelValue,
            (newValue) => {
                internalValue.value =
                    props.options.find((option) => option.name === newValue) ||
                    null;
            },
        );

        // Watch for changes in internalValue and emit the selected name to parent
        watch(internalValue, (newValue) => {
            if (newValue && typeof newValue === "object") {
                // Emit the name (Sura name) to the parent component
                emit("update:modelValue", newValue.name);
            } else {
                emit("update:modelValue", null);
            }
        });

        return {
            internalValue,
            options: props.options,
            placeholder: props.placeholder,
        };
    },
});
</script>
