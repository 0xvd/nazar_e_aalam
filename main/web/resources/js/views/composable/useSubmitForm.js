import { ref, onMounted } from "vue";
import { Modal } from "bootstrap";
import Axios from "@/services/axios/index.js";
import useEmitter from "@/composable/useEmitter.js";
import { toast } from "vue3-toastify";

export const useSubmitForm = (props, emit, editData = "yes") => {
    //const toast = useToast();
    const emitter = useEmitter();
    const errors = ref({});
    const formData = ref({});
    const preloader = ref(false);

    const save = (url, formData, type = "patch", event = null) => {
        errors.value = {};
        preloader.value = true;
        if (props.selectedUrl) {
            if (type === "patch") {
                Axios.patch(url, formData)
                    .then((response) => {
                        afterSuccess(response, event);
                    })
                    .catch(({ response }) => {
                        afterError(response);
                    })
                    .finally(() => afterFinalResponse());
            } else {
                Axios.put(url, formData)
                    .then((response) => {
                        afterSuccess(response, event);
                    })
                    .catch(({ response }) => {
                        afterError(response);
                    })
                    .finally(() => afterFinalResponse());
            }
        } else {
            Axios.post(url, formData)
                .then((response) => {
                    afterSuccess(response, event);
                })
                .catch(({ response }) => {
                    afterError(response);
                })
                .finally(() => afterFinalResponse());
        }
    };
    const afterError = (response) => {
        if (response?.status === 422) errors.value = response?.data?.errors;
        else {
            errors.value = {};
            toast.error(response?.data?.message);
        }
    };
    const afterSuccess = (response, event) => {
        toast.success(response?.data?.message);
        emitter.emit("reload-table");
        if (event) {
            emit("success");
        }
        closeModal();
    };

    const afterFinalResponse = () => {
        preloader.value = false;
    };

    const closeModal = () => {
        let modal = Modal.getInstance(document.getElementById(props.modalId));
        modal.hide();
        emit("close");
    };

    const pageLoader = ref(false);
    const getEditData = () => {
        pageLoader.value = true;
        Axios.get(props.selectedUrl)
            .then(({ data }) => {
                formData.value = data;
            })
            .finally(() => (pageLoader.value = false));
    };

    onMounted(() => {
        if (props.selectedUrl && editData === "yes") {
            getEditData();
        }
    });

    return {
        preloader,
        pageLoader,
        formData,
        errors,
        save,
        closeModal,
        getEditData,
        afterSuccess,
        afterError,
        afterFinalResponse,
    };
};
