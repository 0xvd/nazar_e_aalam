<template>
    <main class="content">
        <!-- Header -->
        <div
            class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-4"
        >
            <div>
                <h1 class="h3 mb-0 fw-bold">{{ $t("donation.title") }}</h1>
                <p class="text-muted small mb-0 mt-1">
                    {{ $t("donation.subtitle") }}
                </p>
            </div>
            <button
                class="btn btn-outline-secondary d-flex align-items-center gap-2"
                @click="exportCsv"
                :disabled="!dataSetList.data?.length"
            >
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="15"
                    height="15"
                    fill="currentColor"
                    viewBox="0 0 16 16"
                >
                    <path
                        d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z"
                    />
                    <path
                        d="M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z"
                    />
                </svg>
                {{ $t("donation.export_csv") }}
            </button>
        </div>

        <!-- Stats Cards -->
        <div class="row g-4 mb-4">
            <div class="col-6 col-xl-3">
                <div class="stat-card">
                    <div
                        class="stat-card-accent"
                        style="background: #6c757d"
                    ></div>
                    <div class="stat-card-body">
                        <p class="stat-label">
                            {{ $t("donation.stats.total_donations") }}
                        </p>
                        <p class="stat-value">{{ stats.total ?? 0 }}</p>
                        <p class="stat-sub">
                            {{ $t("donation.stats.all_time_records") }}
                        </p>
                    </div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="stat-card">
                    <div
                        class="stat-card-accent"
                        style="background: #198754"
                    ></div>
                    <div class="stat-card-body">
                        <p class="stat-label">
                            {{ $t("donation.stats.total_collected") }}
                        </p>
                        <p class="stat-value text-success">
                            {{ formatAmount(stats.total_amount) }}
                        </p>
                        <p class="stat-sub">
                            {{ $t("donation.stats.from_completed_only") }}
                        </p>
                    </div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="stat-card">
                    <div
                        class="stat-card-accent"
                        style="background: #0d6efd"
                    ></div>
                    <div class="stat-card-body">
                        <p class="stat-label">
                            {{ $t("donation.stats.completed") }}
                        </p>
                        <p class="stat-value text-primary">
                            {{ stats.completed ?? 0 }}
                        </p>
                        <p class="stat-sub">
                            {{ $t("donation.stats.successfully_processed") }}
                        </p>
                    </div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="stat-card">
                    <div
                        class="stat-card-accent"
                        style="background: #ffc107"
                    ></div>
                    <div class="stat-card-body">
                        <p class="stat-label">
                            {{ $t("donation.stats.pending") }}
                        </p>
                        <p class="stat-value" style="color: #e6a800">
                            {{ stats.pending ?? 0 }}
                        </p>
                        <p class="stat-sub">
                            {{ $t("donation.stats.awaiting_confirmation") }}
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Table Card -->
        <div class="card shadow-sm border-0 rounded-3">
            <!-- Toolbar -->
            <div class="card-header bg-white border-bottom-0 pt-4 pb-3 px-4">
                <div class="d-flex flex-wrap align-items-center gap-3">
                    <!-- Status tabs -->
                    <div class="status-tabs d-flex gap-2 flex-wrap">
                        <button
                            v-for="tab in statusTabs"
                            :key="tab.value"
                            class="status-tab-btn"
                            :class="{ active: activeStatus === tab.value }"
                            @click="setStatus(tab.value)"
                        >
                            {{ tab.label }}
                            <span class="tab-count">{{
                                tabCount(tab.value)
                            }}</span>
                        </button>
                    </div>

                    <div
                        class="ms-auto d-flex align-items-center gap-2 flex-wrap"
                    >
                        <!-- Gateway filter -->
                        <div class="gateway-filter-wrap">
                            <div
                                class="gateway-filter-toggle"
                                @click="gwDropOpen = !gwDropOpen"
                                :class="{ active: activeGateway }"
                            >
                                <span
                                    v-if="activeGateway"
                                    class="gateway-badge me-1"
                                    :class="'gw-' + activeGateway"
                                    style="padding: 2px 8px; font-size: 11px"
                                >
                                    {{ GATEWAY_LABELS[activeGateway] }}
                                </span>
                                <span v-else class="text-muted">{{
                                    $t("donation.all_gateways")
                                }}</span>
                                <svg
                                    class="ms-1"
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="12"
                                    height="12"
                                    fill="currentColor"
                                    viewBox="0 0 16 16"
                                >
                                    <path
                                        d="M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z"
                                    />
                                </svg>
                            </div>
                            <div class="gateway-filter-menu" v-if="gwDropOpen">
                                <div
                                    class="gw-menu-item"
                                    :class="{ selected: activeGateway === '' }"
                                    @click="setGateway('')"
                                >
                                    <span class="gw-all-dot"></span>
                                    {{ $t("donation.all_gateways") }}
                                </div>
                                <div
                                    v-for="gw in gatewayOptions"
                                    :key="gw.value"
                                    class="gw-menu-item"
                                    :class="{
                                        selected: activeGateway === gw.value,
                                    }"
                                    @click="setGateway(gw.value)"
                                >
                                    <span
                                        class="gateway-badge"
                                        :class="'gw-' + gw.value"
                                        style="
                                            padding: 2px 8px;
                                            font-size: 11px;
                                        "
                                        >{{ gw.label }}</span
                                    >
                                </div>
                            </div>
                        </div>

                        <select
                            class="form-select form-select-sm"
                            style="width: 130px"
                            v-model="perPage"
                            @change="getServerData(1)"
                        >
                            <option value="10">
                                {{ $t("donation.per_page", { count: 10 }) }}
                            </option>
                            <option value="25">
                                {{ $t("donation.per_page", { count: 25 }) }}
                            </option>
                            <option value="50">
                                {{ $t("donation.per_page", { count: 50 }) }}
                            </option>
                        </select>
                        <div class="search-box">
                            <svg
                                class="search-icon"
                                xmlns="http://www.w3.org/2000/svg"
                                width="14"
                                height="14"
                                fill="currentColor"
                                viewBox="0 0 16 16"
                            >
                                <path
                                    d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.099zm-5.242 1.156a5.5 5.5 0 1 1 0-11 5.5 5.5 0 0 1 0 11z"
                                />
                            </svg>
                            <input
                                type="text"
                                class="form-control form-control-sm search-input"
                                v-model="search"
                                @input="onSearch"
                                :placeholder="$t('donation.search_placeholder')"
                            />
                        </div>
                    </div>
                </div>
            </div>

            <div class="px-4 pb-1">
                <div class="border-bottom"></div>
            </div>

            <!-- Table -->
            <div class="card-body p-0">
                <app-loader v-if="preloader" />
                <template v-else>
                    <div class="table-responsive">
                        <table class="table donation-table mb-0">
                            <thead>
                                <tr>
                                    <th class="ps-4" style="width: 50px">#</th>
                                    <th style="min-width: 220px">
                                        {{ $t("donation.table.donor") }}
                                    </th>
                                    <th style="min-width: 120px">
                                        {{ $t("donation.table.category") }}
                                    </th>
                                    <th style="min-width: 130px">
                                        {{ $t("donation.table.gateway") }}
                                    </th>
                                    <th style="min-width: 120px">
                                        {{ $t("donation.table.amount") }}
                                    </th>
                                    <th style="min-width: 120px">
                                        {{ $t("common.status") }}
                                    </th>
                                    <th style="min-width: 160px">
                                        {{ $t("donation.table.date") }}
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <template v-if="dataSetList.data?.length">
                                    <tr
                                        v-for="(row, index) in dataSetList.data"
                                        :key="row.id"
                                    >
                                        <td
                                            class="ps-4 text-muted small fw-medium"
                                        >
                                            {{
                                                (dataSetList.current_page - 1) *
                                                    dataSetList.per_page +
                                                index +
                                                1
                                            }}
                                        </td>

                                        <td>
                                            <div
                                                class="d-flex align-items-center gap-3"
                                            >
                                                <div class="donor-avatar">
                                                    {{
                                                        avatarInitial(
                                                            row.name ||
                                                                row.email,
                                                        )
                                                    }}
                                                </div>
                                                <div>
                                                    <div
                                                        class="fw-semibold text-dark lh-sm"
                                                    >
                                                        {{ row.name || "—" }}
                                                    </div>
                                                    <div
                                                        class="text-muted small mt-1"
                                                    >
                                                        {{ row.email }}
                                                    </div>
                                                </div>
                                            </div>
                                        </td>

                                        <td>
                                            <span
                                                v-if="row.category?.name"
                                                class="category-tag"
                                            >
                                                {{ row.category.name }}
                                            </span>
                                            <span v-else class="text-muted"
                                                >—</span
                                            >
                                        </td>

                                        <td>
                                            <span
                                                class="gateway-badge"
                                                :class="'gw-' + gatewayKey(row)"
                                            >
                                                {{ gatewayLabel(row) }}
                                            </span>
                                        </td>

                                        <td>
                                            <span class="fw-semibold text-dark">
                                                {{ row.currency || "USD" }}
                                                {{
                                                    row.transaction?.amount
                                                        ? Number(
                                                              row.transaction
                                                                  .amount,
                                                          ).toLocaleString(
                                                              "en",
                                                              {
                                                                  minimumFractionDigits: 2,
                                                                  maximumFractionDigits: 2,
                                                              },
                                                          )
                                                        : "—"
                                                }}
                                            </span>
                                        </td>

                                        <td>
                                            <span
                                                class="status-badge"
                                                :class="
                                                    'status-' +
                                                    (row.status || 'pending')
                                                "
                                            >
                                                <span class="status-dot"></span>
                                                {{ row.status || "pending" }}
                                            </span>
                                        </td>

                                        <td class="text-muted small">
                                            {{
                                                row.transaction?.date ||
                                                formatDate(row.created_at) ||
                                                "—"
                                            }}
                                        </td>
                                    </tr>
                                </template>

                                <tr v-else>
                                    <td colspan="7" class="text-center py-5">
                                        <div class="empty-state">
                                            <div class="empty-icon">🪙</div>
                                            <div
                                                class="fw-semibold text-dark mt-3"
                                            >
                                                {{ $t("donation.empty.title") }}
                                            </div>
                                            <div class="text-muted small mt-1">
                                                {{
                                                    search
                                                        ? $t(
                                                              "donation.empty.try_adjusting_search",
                                                          )
                                                        : activeStatus
                                                          ? $t(
                                                                "donation.empty.no_status_donations",
                                                                {
                                                                    status: activeStatus,
                                                                },
                                                            )
                                                          : $t(
                                                                "donation.empty.will_appear_here",
                                                            )
                                                }}
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Footer -->
                    <div
                        class="px-4 py-3 border-top d-flex align-items-center justify-content-between flex-wrap gap-2"
                    >
                        <div class="text-muted small">
                            <template v-if="dataSetList.total">
                                {{
                                    $t("donation.showing_range", {
                                        from: dataSetList.from,
                                        to: dataSetList.to,
                                        total: dataSetList.total,
                                    })
                                }}
                            </template>
                        </div>
                        <app-pagination
                            :data="dataSetList"
                            @pagination-change-page="getServerData"
                        />
                    </div>
                </template>
            </div>
        </div>
    </main>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from "vue";
import Axios from "@/services/axios/index.js";
import useEmitter from "@/composable/useEmitter.js";
import { debounce as _debounce } from "lodash";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const dataSetList = ref({});
const stats = ref({});
const preloader = ref(false);
const search = ref("");
const activeStatus = ref("");
const activeGateway = ref("");
const gwDropOpen = ref(false);
const perPage = ref("10");

const GATEWAY_LABELS = {
    stripe: "Stripe",
    paypal: "PayPal",
    razorpay: "Razorpay",
    paystack: "Paystack",
    sslcommerz: "SSLCommerz",
};

const gatewayOptions = [
    { value: "stripe", label: "Stripe" },
    { value: "paypal", label: "PayPal" },
    { value: "razorpay", label: "Razorpay" },
    { value: "paystack", label: "Paystack" },
    { value: "sslcommerz", label: "SSLCommerz" },
];

const statusTabs = [
    { label: t("donation.status.all"), value: "" },
    { label: t("donation.status.completed"), value: "completed" },
    { label: t("donation.status.pending"), value: "pending" },
    { label: t("donation.status.cancelled"), value: "cancelled" },
];

const tabCount = (val) => {
    if (val === "") return stats.value.total ?? 0;
    if (val === "completed") return stats.value.completed ?? 0;
    if (val === "pending") return stats.value.pending ?? 0;
    if (val === "cancelled") return stats.value.cancelled ?? 0;
    return 0;
};

const getServerData = (page = 1) => {
    preloader.value = true;
    const params = new URLSearchParams({
        page,
        per_page: perPage.value,
        ...(search.value && { search: search.value }),
        ...(activeStatus.value && { status: activeStatus.value }),
        ...(activeGateway.value && { gateway: activeGateway.value }),
    });
    Axios.get(`donation-list?${params}`)
        .then(({ data }) => {
            dataSetList.value = data.data;
            stats.value = data.stats ?? {};
        })
        .finally(() => (preloader.value = false));
};

const onSearch = _debounce(() => getServerData(1), 400);
const setStatus = (val) => {
    activeStatus.value = val;
    getServerData(1);
};
const setGateway = (val) => {
    activeGateway.value = val;
    gwDropOpen.value = false;
    getServerData(1);
};

// ── Helpers ──────────────────────────────────────────────────
const gatewayKey = (row) =>
    row.payment_gateway || (row.payment_method?.type ?? "other");
const gatewayLabel = (row) =>
    GATEWAY_LABELS[gatewayKey(row)] ||
    (row.payment_method?.name ?? gatewayKey(row));
const avatarInitial = (str) => (str ? str.trim()[0].toUpperCase() : "?");

const formatAmount = (val) =>
    Number(val || 0).toLocaleString("en", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    });

const formatDate = (iso) =>
    iso
        ? new Date(iso).toLocaleDateString("en-GB", {
              day: "2-digit",
              month: "short",
              year: "numeric",
          })
        : null;

const exportCsv = () => {
    const rows = dataSetList.value.data ?? [];
    if (!rows.length) return;
    const headers = [
        "#",
        "Name",
        "Email",
        "Category",
        "Gateway",
        "Currency",
        "Amount",
        "Status",
        "Date",
    ];
    const lines = rows.map((r, i) =>
        [
            (dataSetList.value.current_page - 1) * dataSetList.value.per_page +
                i +
                1,
            r.name || "",
            r.email,
            r.category?.name || "",
            gatewayLabel(r),
            r.currency || "USD",
            r.transaction?.amount ?? "",
            r.status || "pending",
            r.transaction?.date || formatDate(r.created_at) || "",
        ]
            .map((v) => `"${String(v).replace(/"/g, '""')}"`)
            .join(","),
    );
    const csv = [headers.join(","), ...lines].join("\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "donations.csv";
    a.click();
    URL.revokeObjectURL(url);
};

const closeGwDrop = (e) => {
    const wrap = document.querySelector(".gateway-filter-wrap");
    if (wrap && !wrap.contains(e.target)) gwDropOpen.value = false;
};

onMounted(() => {
    getServerData();
    useEmitter().on("reload-table", (v = true) => {
        if (v) getServerData();
    });
    document.addEventListener("click", closeGwDrop);
});

onUnmounted(() => {
    document.removeEventListener("click", closeGwDrop);
});
</script>

<style scoped>
/* ── Stat Cards ─────────────────────────────────────────────── */
.stat-card {
    background: var(--theme-card);
    border-radius: 12px;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.07);
    overflow: hidden;
    display: flex;
    min-height: 110px;
}
.stat-card-accent {
    width: 5px;
    flex-shrink: 0;
}
.stat-card-body {
    padding: 20px 20px 16px;
    flex: 1;
}
.stat-label {
    font-size: 12px;
    color: #6c757d;
    margin: 0 0 6px;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.4px;
}
.stat-value {
    font-size: 26px;
    font-weight: 700;
    margin: 0 0 4px;
    line-height: 1;
    color: #212529;
}
.stat-sub {
    font-size: 11px;
    color: #adb5bd;
    margin: 0;
}

/* ── Status tabs ────────────────────────────────────────────── */
.status-tab-btn {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 6px 14px;
    border-radius: 8px;
    border: 1.5px solid #dee2e6;
    background: var(--theme-card);
    color: #6c757d;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.15s;
    white-space: nowrap;
}
.status-tab-btn:hover {
    border-color: #adb5bd;
    color: #343a40;
}
.status-tab-btn.active {
    background: #212529;
    border-color: #212529;
    color: #fff;
}
.tab-count {
    background: rgba(0, 0, 0, 0.12);
    color: inherit;
    border-radius: 20px;
    padding: 1px 7px;
    font-size: 11px;
    font-weight: 600;
}
.status-tab-btn.active .tab-count {
    background: rgba(255, 255, 255, 0.25);
}

/* ── Search box ─────────────────────────────────────────────── */
.search-box {
    position: relative;
}
.search-icon {
    position: absolute;
    inset-inline-start: 10px;
    top: 50%;
    transform: translateY(-50%);
    color: #adb5bd;
    pointer-events: none;
}
.search-input {
    padding-inline-start: 30px;
    width: 210px;
}

/* ── Table ──────────────────────────────────────────────────── */
.donation-table thead th {
    background: #f8f9fa;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #6c757d;
    padding: 14px 16px;
    border-bottom: 1px solid #dee2e6;
    white-space: nowrap;
}
.donation-table tbody td {
    padding: 18px 16px;
    vertical-align: middle;
    border-bottom: 1px solid #f1f3f5;
}
.donation-table tbody tr:last-child td {
    border-bottom: none;
}
.donation-table tbody tr:hover td {
    background: #fafbfc;
}

/* ── Donor avatar ───────────────────────────────────────────── */
.donor-avatar {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: linear-gradient(135deg, #495057, #868e96);
    color: #fff;
    font-size: 14px;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

/* ── Category tag ───────────────────────────────────────────── */
.category-tag {
    display: inline-block;
    padding: 4px 10px;
    background: #f1f3f5;
    color: #495057;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 500;
}

/* ── Gateway badge ──────────────────────────────────────────── */
.gateway-badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}
.gw-stripe {
    background: #ede9ff;
    color: #5b4ccc;
}
.gw-paypal {
    background: #e3f0ff;
    color: #003087;
}
.gw-razorpay {
    background: #e8eaf6;
    color: #1a237e;
}
.gw-paystack {
    background: #e0f2f1;
    color: #00695c;
}
.gw-sslcommerz {
    background: #fce4ec;
    color: #b71c1c;
}
.gw-other {
    background: #f5f5f5;
    color: #555;
}

/* ── Status badge ───────────────────────────────────────────── */
.status-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-transform: capitalize;
}
.status-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    flex-shrink: 0;
}
.status-completed {
    background: #d1fae5;
    color: #065f46;
}
.status-completed .status-dot {
    background: #059669;
}
.status-pending {
    background: #fef9c3;
    color: #854d0e;
}
.status-pending .status-dot {
    background: #ca8a04;
}
.status-cancelled {
    background: #fee2e2;
    color: #991b1b;
}
.status-cancelled .status-dot {
    background: #dc2626;
}

/* ── Empty state ────────────────────────────────────────────── */
.empty-state {
    padding: 20px 0;
}
.empty-icon {
    font-size: 2.5rem;
}

/* ── Gateway filter dropdown ────────────────────────────────── */
.gateway-filter-wrap {
    position: relative;
}
.gateway-filter-toggle {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 5px 12px;
    border: 1.5px solid #dee2e6;
    border-radius: 8px;
    background: var(--theme-card);
    cursor: pointer;
    font-size: 13px;
    color: #495057;
    white-space: nowrap;
    transition: border-color 0.15s;
    user-select: none;
}
.gateway-filter-toggle:hover {
    border-color: #adb5bd;
}
.gateway-filter-toggle.active {
    border-color: #6c757d;
    background: #f8f9fa;
}

.gateway-filter-menu {
    position: absolute;
    top: calc(100% + 6px);
    inset-inline-end: 0;
    min-width: 170px;
    background: var(--theme-card);
    border: 1px solid #e9ecef;
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
    z-index: 100;
    overflow: hidden;
    padding: 6px;
}
.gw-menu-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 10px;
    border-radius: 7px;
    font-size: 13px;
    cursor: pointer;
    color: #495057;
    transition: background 0.12s;
}
.gw-menu-item:hover {
    background: #f8f9fa;
}
.gw-menu-item.selected {
    background: #f1f3f5;
    font-weight: 600;
}
.gw-all-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #adb5bd;
    flex-shrink: 0;
}
</style>
