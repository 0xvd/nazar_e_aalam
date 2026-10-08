<template>
    <app-modal
        :modal-id="modalId"
        modal-size="large"
        :title="
            selectedUrl
                ? $t('common.update_item', {
                      item: $t('payment_method.singular'),
                  })
                : $t('common.add_item', { item: $t('payment_method.singular') })
        "
        :preloader="preloader"
        @submit="submit"
        @close="closeModal"
    >
        <template v-slot:body>
            <div class="mb-4">
                <label for="type"
                    >{{ $t("payment_method.form.payment_method_label") }}
                    <span class="text-danger">*</span></label
                >
                <select class="form-control" id="type" v-model="formData.type">
                    <option value="" selected>
                        {{ $t("payment_method.form.choose_one") }}
                    </option>
                    <option value="paypal">Paypal</option>
                    <option value="stripe">Stripe</option>
                    <option value="paystack">Paystack</option>
                    <option value="razorpay">Razorpay</option>
                    <option value="sslcommerz">SslCommerz</option>
                </select>
                <small class="text-danger" v-if="errors.type">{{
                    errors.type[0]
                }}</small>
            </div>

            <div
                class="mb-4"
                v-if="
                    formData.type === 'paypal' || formData.type === 'sslcommerz'
                "
            >
                <label for="payment_mode"
                    >{{ $t("payment_method.form.payment_mode_label") }}
                    <span class="text-danger">*</span></label
                >
                <select
                    class="form-control"
                    id="payment_mode"
                    v-model="formData.payment_mode"
                >
                    <option value="" selected>
                        {{ $t("payment_method.form.choose_one") }}
                    </option>
                    <option value="sandbox">
                        {{ $t("payment_method.form.sandbox") }}
                    </option>
                    <option value="live">
                        {{ $t("payment_method.form.live") }}
                    </option>
                </select>
                <small class="text-danger" v-if="errors.payment_mode">{{
                    errors.payment_mode[0]
                }}</small>
            </div>

            <template
                v-if="
                    formData.type === 'paypal' ||
                    formData.type === 'stripe' ||
                    formData.type === 'razorpay' ||
                    formData.type === 'paystack' ||
                    formData.type === 'sslcommerz'
                "
            >
                <div class="mb-4">
                    <label for="type"
                        >{{ $t("common.name") }}
                        <span class="text-danger">*</span></label
                    >
                    <input
                        type="text"
                        id="name"
                        class="form-control"
                        :placeholder="
                            $t('payment_method.form.name_placeholder')
                        "
                        v-model="formData.name"
                    />
                    <small class="text-danger" v-if="errors.name">{{
                        errors.name[0]
                    }}</small>
                </div>

                <div class="mb-4">
                    <label for="api_key">
                        {{
                            formData.type === "sslcommerz"
                                ? $t("payment_method.form.store_id_label")
                                : $t("payment_method.form.api_key_label")
                        }}
                        <span class="text-danger">*</span>
                    </label>
                    <input
                        type="text"
                        id="api_key"
                        class="form-control"
                        :placeholder="
                            formData.type === 'sslcommerz'
                                ? $t('payment_method.form.store_id_placeholder')
                                : $t('payment_method.form.api_key_placeholder')
                        "
                        v-model="formData.api_key"
                    />
                    <small class="text-danger" v-if="errors.api_key">{{
                        errors.api_key[0]
                    }}</small>
                </div>

                <div class="mb-4">
                    <label for="api_secret">
                        {{
                            formData.type === "sslcommerz"
                                ? $t("payment_method.form.store_password_label")
                                : $t("payment_method.form.api_secret_label")
                        }}
                        <span class="text-danger">*</span>
                    </label>
                    <input
                        type="password"
                        id="api_secret"
                        class="form-control"
                        :placeholder="
                            formData.type === 'sslcommerz'
                                ? $t(
                                      'payment_method.form.store_password_placeholder',
                                  )
                                : $t(
                                      'payment_method.form.api_secret_placeholder',
                                  )
                        "
                        v-model="formData.api_secret"
                    />
                    <small class="text-danger" v-if="errors.api_secret">{{
                        errors.api_secret[0]
                    }}</small>
                </div>
            </template>
        </template>
    </app-modal>
</template>

<script setup>
import { onMounted, ref } from "vue";
import Axios from "@/services/axios/index.js";
import { useSubmitForm } from "@/composable/useSubmitForm.js";

const props = defineProps({
    modalId: String,
    tableId: String,
    selectedUrl: String,
});

const emit = defineEmits(["close"]);

const formData = ref({
    type: "",
    payment_mode: "",
});
const { preloader, errors, save, closeModal } = useSubmitForm(props, emit);
const submit = () => {
    save(
        props.selectedUrl ? props.selectedUrl : "payment-method",
        formData.value,
    );
};

const getEditData = () => {
    Axios.get(props.selectedUrl).then(({ data }) => {
        formData.value = data;

        data.settings.length
            ? data.settings.map((item) => {
                  if (item.name === "api_key") {
                      formData.value.api_key = item.value;
                  }

                  if (item.name === "api_secret") {
                      formData.value.api_secret = item.value;
                  }

                  if (item.name === "payment_mode") {
                      formData.value.payment_mode = item.value;
                  }
              })
            : [];
    });
};
onMounted(() => {
    if (props.selectedUrl) {
        getEditData();
    }
});
</script>
