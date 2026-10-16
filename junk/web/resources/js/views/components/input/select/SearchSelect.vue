<template>
    <div class="dropdown">
        <div
            class="dropdown-toggle d-flex justify-content-between align-items-center cursor-pointer text-truncate custom-search-select"
            :class="{ open: isOpen }"
            @click="isOpen = !isOpen"
        >
            {{
                selectedOption
                    ? selectedOption[data.labelName]
                    : data.chooseLabel
            }}
        </div>
        <div
            class="dropdown-menu custom-dropdown-menu-width"
            :class="{ show: isOpen }"
        >
            <input
                class="form-control mb-2 custom-dropdown-search-input"
                v-model="searchQuery"
                type="text"
                placeholder="Search..."
            />
            <div class="dropdown-items-container custom-dropdown-menu-height">
                <a
                    v-for="(option, index) in searchResultQuery"
                    :key="index"
                    class="dropdown-item"
                    @click="selectItem(option, index)"
                >
                    {{ option[data.labelName] || "No label" }}
                </a>
                <div
                    v-if="searchResultQuery.length === 0"
                    class="item text-center"
                >
                    {{ "No result found" }}
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from "vue";

const emit = defineEmits(["selectInput"]);

const props = defineProps({
    value: {},
    data: {},
});

const activeIndex = ref(0);
const searchQuery = ref("");
const searchResultQuery = computed(() => {
    if (searchQuery.value) {
        return props.data.options.filter((item) => {
            activeIndex.value = 0;
            return item[props.data.labelName]
                .toLowerCase()
                .includes(searchQuery.value.toLowerCase());
        });
    } else {
        return props.data.options;
    }
});

const selectedOption = computed(() =>
    props.data.options.find(
        (item) => item[props.data.keyField] === props.value,
    ),
);

const selectItem = (item, i) => {
    emit("selectInput", item);
    isOpen.value = false;
    activeIndex.value = i;
};

// Dropdown state
const isOpen = ref(false);

// Close dropdown when clicking outside
onMounted(() => {
    document.addEventListener("click", handleClickOutside);
});

const handleClickOutside = (event) => {
    if (!event.target.closest(".dropdown")) {
        isOpen.value = false;
    }
};

// Cleanup event listener
onUnmounted(() => {
    document.removeEventListener("click", handleClickOutside);
});
</script>

<style>
.custom-dropdown-menu-height {
    max-height: 200px;
    overflow-y: auto;
}
.dropdown-menu.show {
    display: block;
}
.custom-search-select {
    background: var(--theme-card);
    padding: 0.3rem 0.85rem;
    border: 1px solid #dee2e6;
}
.custom-dropdown-menu-width {
    width: 100%;
}
.custom-dropdown-search-input {
    border: none;
}
.custom-dropdown-search-input:focus {
    box-shadow: none;
}
</style>
