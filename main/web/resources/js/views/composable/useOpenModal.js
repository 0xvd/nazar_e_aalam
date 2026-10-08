import { ref } from "vue";

export const useOpenModal = () => {
    const isModalActive = ref(false);
    const selectedData = ref("");

    const closeModal = () => {
        isModalActive.value = false;
        selectedData.value = "";
    };

    return { isModalActive, selectedData, closeModal };
};
