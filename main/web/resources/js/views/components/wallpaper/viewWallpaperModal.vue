<template>
    <app-modal
        :modal-id="modalId"
        modal-size="large"
        :title="$t('wallpaper.view_modal.title')"
        :preloader="preloader"
        :show-save-button="false"
        @close="closeModal"
    >
        <template v-slot:body>
            <div class="view-wallpaper">
                <div class="view-wallpaper-meta">
                    <h2 class="view-wallpaper-name">{{ data.name }}</h2>
                    <p
                        v-if="data.category?.name"
                        class="view-wallpaper-category"
                    >
                        {{ data.category.name }}
                    </p>
                </div>
                <div class="view-wallpaper-frame">
                    <img
                        :src="urlGenerator(data.image)"
                        :alt="data.name || 'Wallpaper preview'"
                        class="view-wallpaper-img"
                    />
                </div>
            </div>
        </template>
    </app-modal>
</template>

<script setup>
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { useSubmitForm } from "@/composable/useSubmitForm.js";
const props = defineProps({
    modalId: String,
    data: Object,
});

const emit = defineEmits(["close"]);

const { preloader, closeModal } = useSubmitForm(props, emit);
</script>

<style scoped>
.view-wallpaper {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.view-wallpaper-meta {
    text-align: center;
}

.view-wallpaper-name {
    margin: 0 0 0.25rem;
    font-size: 1.25rem;
    font-weight: 700;
    color: #111827;
    letter-spacing: -0.02em;
}

.view-wallpaper-category {
    margin: 0;
    font-size: 0.875rem;
    color: #6b7280;
}

.view-wallpaper-frame {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 0.75rem;
    background: linear-gradient(180deg, #f9fafb 0%, #f3f4f6 100%);
    border-radius: 12px;
    border: 1px solid #e5e7eb;
    min-height: 200px;
}

.view-wallpaper-img {
    max-width: 100%;
    max-height: min(70vh, 640px);
    width: auto;
    height: auto;
    object-fit: contain;
    border-radius: 8px;
    box-shadow: 0 8px 30px rgba(15, 23, 42, 0.12);
}
</style>
