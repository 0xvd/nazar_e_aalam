<template>
    <Teleport to="body">
        <div
            class="modal fade"
            :id="modalId"
            tabindex="-1"
            :aria-labelledby="`${modalId}ModalLabel`"
            aria-hidden="true"
        >
            <div
                class="modal-dialog"
                :class="[
                    { 'modal-dialog-scrollable': scrollable },
                    { 'modal-dialog-centered': verticallyCentered },
                    checkModalSize,
                ]"
            >
                <div class="modal-content border-0 rounded-default">
                    <div
                        v-if="showHeader"
                        class="modal-header rounded-top"
                        :class="headerClasses"
                    >
                        <h5
                            class="modal-title"
                            v-if="showTitle"
                            :id="`${modalId}ModalLabel`"
                        >
                            {{ title }}
                        </h5>
                        <i
                            class="bi bi-x-circle modal-close"
                            v-if="showCloseIcon"
                            @click.prevent="closeModal"
                            aria-label="Close"
                        ></i>
                    </div>
                    <div
                        class="modal-body custom-scrollbar"
                        :class="
                            (bodyClasses, { 'overflow-x-hidden': scrollable })
                        "
                    >
                        <slot name="body"></slot>
                    </div>
                    <div
                        v-if="showFooter"
                        class="modal-footer rounded-bottom"
                        :class="footerClasses"
                    >
                        <button
                            type="button"
                            class="btn btn-outline-primary me-2 fw-bold"
                            data-bs-dismiss="modal"
                            @click.prevent="closeModal"
                        >
                            {{ cancelButtonLabel }}
                        </button>
                        <template v-if="showSaveButton">
                            <button
                                v-if="permission"
                                type="submit"
                                class="btn btn-primary fw-bold d-flex align-items-center gap-2"
                                @click.prevent="submit"
                                :disabled="preloader"
                            >
                                <app-button-loader v-if="preloader" />
                                <i
                                    class="d-inline-flex bi"
                                    :class="saveButtonIcon"
                                ></i>
                                {{ saveButtonLabel }}
                            </button>
                        </template>
                    </div>
                    <template v-else>
                        <div
                            class="modal-footer rounded-bottom"
                            :class="footerClasses"
                        >
                            <slot name="footer"></slot>
                        </div>
                    </template>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<script setup>
import { computed, onMounted } from "vue";
import { Modal } from "bootstrap";
import { i18n } from "~/i18n.js";

const props = defineProps({
    modalId: {
        type: String,
        required: true,
    },
    title: {
        type: String,
        default: "Title",
    },
    width: {
        type: String,
    },
    showFooter: {
        type: Boolean,
        default: true,
    },
    preloader: {
        type: Boolean,
        default: false,
    },
    showSaveButton: {
        type: Boolean,
        default: true,
    },
    saveButtonLabel: {
        type: String,
        default: function () {
            return i18n.global.t("common.save");
        },
    },
    saveButtonIcon: {
        type: String,
        default: function () {
            return "bi-download";
        },
    },
    cancelButtonLabel: {
        type: String,
        default: function () {
            return i18n.global.t("common.cancel");
        },
    },
    scrollable: {
        type: Boolean,
        default: false,
    },
    verticallyCentered: {
        type: Boolean,
        default: false,
    },
    modalSize: {
        type: String,
        default: "default",
    },
    permission: {
        type: Boolean,
        default: true,
    },
    showHeader: {
        type: Boolean,
        default: true,
    },
    showTitle: {
        type: Boolean,
        default: true,
    },
    showCloseIcon: {
        type: Boolean,
        default: true,
    },
    bodyClasses: String,
    headerClasses: String,
    footerClasses: String,
});

const emit = defineEmits(["submit", "close"]);

const checkModalSize = computed(() => {
    if (props.modalSize === "default") return "";
    else if (props.modalSize === "small") return "modal-sm";
    else if (props.modalSize === "large") return "modal-lg";
    else if (props.modalSize === "extra-large") return "modal-xl";
    else if (props.modalSize === "fullscreen") return "modal-fullscreen";
    else return "";
});

const submit = () => {
    emit("submit");
};
const openModal = () => {
    let modal = document.getElementById(props.modalId),
        appModal = new Modal(modal);
    appModal.show();
};
const closeModal = () => {
    emit("close");
};
onMounted(() => {
    openModal();
    let modal = document.getElementById(props.modalId),
        html = document.getElementsByTagName("html")[0];

    modal.addEventListener("hidden.bs.modal", () => {
        emit("close");
        html.style.overflowY = "auto";
    });

    modal.addEventListener("shown.bs.modal", () => {
        html.style.overflowY = "hidden";
    });
});
</script>
