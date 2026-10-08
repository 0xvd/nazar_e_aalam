import { ref } from "vue";

export const useDeleteModal = () => {
    const deleteUrl = ref("");
    const isDeleteModal = ref(false);

    const cancelled = () => {
        isDeleteModal.value = false;
        deleteUrl.value = "";
    };
    return { deleteUrl, isDeleteModal, cancelled };
};
