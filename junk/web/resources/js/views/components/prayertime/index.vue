<template>
    <main class="content">
        <div class="container-fluid p-0">
            <div
                class="mb-3 d-flex flex-wrap justify-content-between align-items-center gap-2"
            >
                <h1 class="h3 mb-0">
                    <strong>{{ $t("prayer_time.list.title") }}</strong>
                </h1>
                <a
                    :href="urlGenerator('prayer-time/create')"
                    class="btn btn-primary"
                    v-if="$canAccess('create_prayer_times')"
                    >{{ $t("prayer_time.list.add") }}</a
                >
            </div>

            <div
                class="prayer-toolbar d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3"
            >
                <select
                    class="form-select prayer-city-select"
                    v-model="selectedCity"
                    @change="filterByCity"
                >
                    <option value="">
                        {{ $t("prayer_time.list.select_city") }}
                    </option>
                    <option v-for="city in cities" :key="city" :value="city">
                        {{ city }}
                    </option>
                </select>
                <button
                    class="btn btn-danger"
                    @click.prevent="deleteCityPrayerTime"
                    v-if="selectedCity && $canAccess('delete_prayer_times')"
                >
                    {{
                        $t("prayer_time.list.delete_city_prayer_time", {
                            city: selectedCity,
                        })
                    }}
                </button>
            </div>
        </div>

        <div class="row">
            <div class="col-md-2 mb-3">
                <div class="card month-nav">
                    <ul class="nav nav-pills flex-column">
                        <li
                            class="nav-item"
                            v-for="month in Object.keys(dataSetList)"
                            :key="month"
                        >
                            <a
                                :class="`nav-link ${moment().format('MMMM') === month ? 'active' : ''}`"
                                :id="`${month}-tab`"
                                data-bs-toggle="pill"
                                :href="`#${month}-content`"
                            >
                                {{ month }}
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="col-md-10">
                <app-loader v-if="preloader" />
                <div class="tab-content" v-else>
                    <template
                        v-for="monthData in Object.keys(dataSetList)"
                        :key="monthData"
                    >
                        <div
                            :class="`tab-pane fade ${moment().format('MMMM') === monthData ? 'active show' : ''}`"
                            :id="`${monthData}-content`"
                        >
                            <h3 class="mb-3">
                                {{
                                    $t("prayer_time.list.month_prayer_time", {
                                        month: monthData,
                                    })
                                }}
                            </h3>

                            <div class="card">
                                <div class="table-responsive">
                                    <table class="table prayer-table mb-3">
                                        <thead>
                                            <tr>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.city",
                                                        )
                                                    }}
                                                </th>
                                                <th style="width: 10%">
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.date",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.imsak",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.sunrise",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.fajr_start",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.zuhr_start",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.asr_start",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.maghrib_start",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.isha_start",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.iftar_start",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{
                                                        $t(
                                                            "prayer_time.list.table.sehri_start",
                                                        )
                                                    }}
                                                </th>
                                                <th>
                                                    {{ $t("common.action") }}
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <template
                                                v-for="prayerTime in dataSetList[
                                                    monthData
                                                ]"
                                                :key="prayerTime.id"
                                            >
                                                <tr
                                                    :class="`${moment(prayerTime.date).format('YYYY-MM-DD') === moment().format('YYYY-MM-DD') ? 'table-info' : ''}`"
                                                >
                                                    <td>
                                                        {{ prayerTime.city }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            moment(
                                                                prayerTime.date,
                                                            ).format(
                                                                "DD.MM.YYYY",
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.imsak,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.sunrise,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.fajr_start,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.zuhr_start,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.asr_start,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.maghrib_start,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.isha_start,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.iftar,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        {{
                                                            formatToAmPm(
                                                                prayerTime.sehri,
                                                            )
                                                        }}
                                                    </td>
                                                    <td>
                                                        <a
                                                            :href="
                                                                urlGenerator(
                                                                    'prayer-time/' +
                                                                        prayerTime.id +
                                                                        '/edit',
                                                                )
                                                            "
                                                            class="text-decoration-none"
                                                            v-if="
                                                                $canAccess(
                                                                    'update_prayer_times',
                                                                )
                                                            "
                                                        >
                                                            <img
                                                                class="action_icon"
                                                                :src="
                                                                    urlGenerator(
                                                                        'assets/img/icons/edit.svg',
                                                                    )
                                                                "
                                                                alt="Icon"
                                                            />
                                                        </a>
                                                        <a
                                                            href="javascript:void(0)"
                                                            @click="
                                                                deletePrayerTime(
                                                                    prayerTime,
                                                                )
                                                            "
                                                            class="text-decoration-none"
                                                            v-if="
                                                                $canAccess(
                                                                    'delete_prayer_times',
                                                                )
                                                            "
                                                        >
                                                            <img
                                                                class="action_icon"
                                                                :src="
                                                                    urlGenerator(
                                                                        'assets/img/icons/trash.svg',
                                                                    )
                                                                "
                                                                alt="Icon"
                                                            />
                                                        </a>
                                                    </td>
                                                </tr>
                                            </template>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </template>
                </div>
            </div>
        </div>
        <app-delete-modal
            v-if="isDeleteModal"
            :selected-url="deleteUrl"
            @cancelled="cancelled"
            @confirmSuccess="handleDeleteSuccess"
            :call-back-emit="true"
        />
    </main>
</template>

<script setup>
import { onMounted, ref } from "vue";
import Axios from "@/services/axios/index.js";
import useEmitter from "@/composable/useEmitter.js";
import moment from "moment";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { useDeleteModal } from "@/composable/useDeleteModal.js";

const { isDeleteModal, deleteUrl, cancelled } = useDeleteModal();

const dataSetList = ref({});
const preloader = ref(false);

// Get Prayer Times based on the selected city
const getServerData = () => {
    preloader.value = true;
    Axios.get(`prayer-times?city=${selectedCity.value}`)
        .then((data) => {
            dataSetList.value = data.data;
        })
        .finally(() => (preloader.value = false));
};
const deleteType = ref(""); // Tracks the type of delete

const deletePrayerTime = (row) => {
    isDeleteModal.value = true;
    deleteUrl.value = `prayer-times/${row.id}`;
    deleteType.value = "single"; // Mark this as a single entry delete
};
const deleteCityPrayerTime = () => {
    isDeleteModal.value = true;
    deleteUrl.value = `delete-prayer-times?city=${selectedCity.value}`;
    deleteType.value = "city"; // Mark this as a city-wise delete
};

const handleDeleteSuccess = () => {
    if (deleteType.value === "city") {
        getCities(); // Refresh cities after deletion
        selectedCity.value = cities.value.length > 0 ? cities.value[0] : ""; // Reset selection for city-wise delete
        filterByCity();
    } else {
        getServerData(); // Reload current data for single delete
    }
    isDeleteModal.value = false; // Close the modal state
    deleteType.value = ""; // Reset delete type
};

const emitter = useEmitter();
const reloadDataTable = () => {
    emitter.on("reload-table", (value = true) => {
        if (value) {
            getServerData();
        }
    });
};

const cities = ref([]);
const selectedCity = ref("");

// Get the list of cities
const getCities = () => {
    Axios.get("get-cities").then((response) => {
        cities.value = response.data;
        if (cities.value.length > 0) {
            selectedCity.value = cities.value[0];
            filterByCity();
        }
    });
};

// Filter Prayer Times based on the selected city
const filterByCity = () => {
    if (selectedCity.value) {
        Axios.get(`prayer-times?city=${selectedCity.value}`).then((data) => {
            dataSetList.value = data.data;
        });
    } else {
        getServerData();
    }
};

const formatToAmPm = (time) => {
    const [hour, minute] = time.split(":").map(Number);
    const ampm = hour >= 12 ? "PM" : "AM";
    const hour12 = hour % 12 || 12;
    return `${hour12}:${minute.toString().padStart(2, "0")} ${ampm}`;
};

onMounted(() => {
    getCities();
    reloadDataTable();
});
</script>

<style scoped>
.prayer-city-select {
    max-width: 260px;
}

.month-nav {
    padding: 0.5rem;
    position: sticky;
    top: 1rem;
}

.month-nav .nav-link {
    border-radius: var(--z-radius-sm);
    padding: 0.6rem 1rem;
    margin-bottom: 0.15rem;
    font-size: 0.875rem;
    font-weight: 500;
}

.month-nav .nav-link:hover {
    background: var(--z-green-50);
}

.prayer-table th,
.prayer-table td {
    white-space: nowrap;
}

.prayer-table > :not(caption) > * > * {
    padding-left: 0.75rem;
    padding-right: 0.75rem;
}

.prayer-table td:first-child,
.prayer-table th:first-child {
    padding-left: 1.1rem;
}

.prayer-table td:last-child,
.prayer-table th:last-child {
    padding-right: 1.1rem;
}
</style>
