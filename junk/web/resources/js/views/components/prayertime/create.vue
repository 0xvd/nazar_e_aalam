<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div class="mb-3">
                <h1 class="h3 d-inline align-middle">
                    <strong v-if="selectedUrl">{{
                        $t("prayer_time.create.update_title")
                    }}</strong>
                    <strong v-else>{{ $t("prayer_time.create.title") }}</strong>
                </h1>
                <a
                    :href="urlGenerator('prayer-time/list')"
                    class="btn bg-primary text-white float-end"
                >
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="24"
                        height="24"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        class="feather feather-arrow-left align-middle me-2"
                    >
                        <line x1="19" y1="12" x2="5" y2="12"></line>
                        <polyline points="12 19 5 12 12 5"></polyline>
                    </svg>
                    {{ $t("prayer_time.create.back") }}
                </a>
            </div>
        </div>

        <div class="row">
            <div class="card">
                <div class="card-body">
                    <app-loader v-if="pageLoader" />
                    <form v-else>
                        <div class="row">
                            <div class="col-md-2"></div>
                            <div class="col-md-8">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.city_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <select
                                                v-if="selectedUrl"
                                                v-model="formData.city"
                                                class="form-control"
                                                disabled
                                            >
                                                <option value="">
                                                    {{
                                                        $t(
                                                            "prayer_time.create.select_city",
                                                        )
                                                    }}
                                                </option>
                                                <option
                                                    v-for="city in cities"
                                                    :key="city"
                                                    :value="city"
                                                    :selected="
                                                        city === formData.city
                                                    "
                                                >
                                                    {{ city }}
                                                </option>
                                            </select>
                                            <select
                                                v-else
                                                v-model="formData.city"
                                                class="form-control"
                                            >
                                                <option value="">
                                                    {{
                                                        $t(
                                                            "prayer_time.create.select_city",
                                                        )
                                                    }}
                                                </option>
                                                <option
                                                    v-for="city in cities"
                                                    :key="city"
                                                    :value="city"
                                                    :selected="
                                                        city === formData.city
                                                    "
                                                >
                                                    {{ city }}
                                                </option>
                                            </select>
                                            <small
                                                class="text-danger"
                                                v-if="errors.city"
                                                >{{ errors.city[0] }}</small
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.date_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >

                                            <input
                                                type="date"
                                                name="date"
                                                class="form-control"
                                                v-model="formData.date"
                                                v-if="selectedUrl"
                                                readonly
                                            />

                                            <input
                                                v-else
                                                type="date"
                                                name="date"
                                                class="form-control"
                                                v-model="formData.date"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.date"
                                                >{{ errors.date[0] }}</small
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.imsak_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="imsak"
                                                class="form-control"
                                                v-model="formData.imsak"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.imsak"
                                                >{{ errors.imsak[0] }}</small
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.sunrise_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="sunrise"
                                                class="form-control"
                                                v-model="formData.sunrise"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.sunrise"
                                                >{{ errors.sunrise[0] }}</small
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.fajr_start_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="fajr_start"
                                                class="form-control"
                                                v-model="formData.fajr_start"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.fajr_start"
                                                >{{
                                                    errors.fajr_start[0]
                                                }}</small
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.zuhr_start_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="zuhr_start"
                                                class="form-control"
                                                v-model="formData.zuhr_start"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.zuhr_start"
                                                >{{
                                                    errors.zuhr_start[0]
                                                }}</small
                                            >
                                        </div>
                                    </div>

                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.asr_start_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="asr_start"
                                                class="form-control"
                                                v-model="formData.asr_start"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.asr_start"
                                                >{{
                                                    errors.asr_start[0]
                                                }}</small
                                            >
                                        </div>
                                    </div>

                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.maghrib_start_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="maghrib_start"
                                                class="form-control"
                                                v-model="formData.maghrib_start"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.maghrib_start"
                                                >{{
                                                    errors.maghrib_start[0]
                                                }}</small
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.isha_start_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="isha_start"
                                                class="form-control"
                                                v-model="formData.isha_start"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.isha_start"
                                                >{{
                                                    errors.isha_start[0]
                                                }}</small
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.iftar_start_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="iftar"
                                                class="form-control"
                                                v-model="formData.iftar"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.iftar"
                                                >{{ errors.iftar[0] }}</small
                                            >
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label"
                                                >{{
                                                    $t(
                                                        "prayer_time.create.sehri_start_label",
                                                    )
                                                }}<span class="text-danger"
                                                    >*</span
                                                ></label
                                            >
                                            <input
                                                type="time"
                                                name="sehri"
                                                class="form-control"
                                                v-model="formData.sehri"
                                            />

                                            <small
                                                class="text-danger"
                                                v-if="errors.sehri"
                                                >{{ errors.sehri[0] }}</small
                                            >
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-4"></div>
                                    <div
                                        class="col-md-4 col-sm-12 text-center d-grid gap-2"
                                    >
                                        <button
                                            type="submit"
                                            class="btn btn-primary"
                                            @click.prevent="submit"
                                        >
                                            <app-button-loader
                                                v-if="preloader"
                                            />
                                            {{
                                                $t("prayer_time.create.submit")
                                            }}
                                        </button>
                                    </div>
                                    <div class="col-md-4"></div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</template>

<script setup>
import { onMounted, ref } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";
import { urlGenerator } from "@/utilities/urlGenerator.js";

const props = defineProps({
    selectedUrl: {
        type: String,
    },
});
const preloader = ref(false);
const formData = ref({
    city: "",
});
const errors = ref({});

const submit = () => {
    preloader.value = true;
    errors.value = {};
    if (props.selectedUrl) {
        Axios.patch(props.selectedUrl, formData.value)
            .then((data) => {
                toast.success(data.data.message);
            })
            .catch(({ response }) => {
                if (response.status === 422) {
                    errors.value = response.data.errors;
                } else {
                    toast.error(response.data.message);
                }
            })
            .finally(() => (preloader.value = false));
    } else {
        Axios.post("prayer-times", formData.value)
            .then((data) => {
                toast.success(data.data.message);
                formData.value = {};
            })
            .catch(({ response }) => {
                if (response.status === 422) {
                    errors.value = response.data.errors;
                } else {
                    toast.error(response.data.message);
                }
            })
            .finally(() => (preloader.value = false));
    }
};

const pageLoader = ref(false);
const getEditData = () => {
    pageLoader.value = true;
    Axios.get(props.selectedUrl)
        .then((data) => {
            formData.value = data.data;
        })
        .finally(() => (pageLoader.value = false));
};

const cities = ref([]); // List of cities
const selectedCity = ref(""); // Selected city for filter

// Get the list of cities
const getCities = () => {
    Axios.get("get-cities") // Assuming 'get-cities' is the correct endpoint
        .then((response) => {
            cities.value = response.data; // Populate the cities list
        });
};

onMounted(() => {
    getCities(); // Fetch cities list when the component is mounted
    if (props.selectedUrl) {
        getEditData();
    }
});
</script>
