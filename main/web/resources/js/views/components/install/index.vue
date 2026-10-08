<template>
    <div class="installer-page">
        <div class="installer-wrapper">
            <div class="installer-header">
                <h1 class="installer-title">Application Installer</h1>
                <p class="installer-subtitle">
                    Follow the steps below to set up your application
                </p>
            </div>

            <StepIndicator :current-step="1" />

            <div class="notice-banner mb-4">
                <div class="notice-icon">
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="18"
                        height="18"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                    >
                        <path
                            d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"
                        />
                    </svg>
                </div>
                <div class="notice-text">
                    Before proceeding, ensure your server meets the required PHP
                    version, extensions, and file permissions.
                    <a
                        href="https://zabi.theme29.com/documentation"
                        target="_blank"
                        rel="noopener noreferrer"
                        >View documentation</a
                    >
                </div>
            </div>

            <!-- Server Requirements -->
            <div class="installer-card mb-4">
                <div class="section-title">
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="15"
                        height="15"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                    >
                        <path
                            d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v1H0V4zm0 3h16v5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V7zm3 2a.5.5 0 0 0 0 1h2a.5.5 0 0 0 0-1H3zm4 0a.5.5 0 0 0 0 1h4a.5.5 0 0 0 0-1H7z"
                        />
                    </svg>
                    Server Requirements
                </div>
                <div class="table-responsive">
                    <table class="req-table">
                        <thead>
                            <tr>
                                <th>Requirement</th>
                                <th>Required</th>
                                <th>Current</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-if="checkPhpVersion">
                                <td>PHP Version</td>
                                <td>{{ checkPhpVersion.minimum_version }}</td>
                                <td>{{ checkPhpVersion.current_version }}</td>
                                <td>
                                    <span
                                        class="status-badge"
                                        :class="
                                            checkPhpVersion.status
                                                ? 'pass'
                                                : 'fail'
                                        "
                                        >{{
                                            checkPhpVersion.status
                                                ? "✓ Passed"
                                                : "✗ Failed"
                                        }}</span
                                    >
                                </td>
                            </tr>
                            <tr v-if="checkMysqlVersion">
                                <td>MySQL Version</td>
                                <td>{{ checkMysqlVersion.minimum_version }}</td>
                                <td>{{ checkMysqlVersion.current_version }}</td>
                                <td>
                                    <span
                                        class="status-badge"
                                        :class="
                                            checkMysqlVersion.status
                                                ? 'pass'
                                                : 'fail'
                                        "
                                        >{{
                                            checkMysqlVersion.status
                                                ? "✓ Passed"
                                                : "✗ Failed"
                                        }}</span
                                    >
                                </td>
                            </tr>
                            <template v-if="phpRequirements">
                                <tr
                                    v-for="(enabled, name) in phpRequirements"
                                    :key="name"
                                >
                                    <td>{{ name }}</td>
                                    <td>Enabled</td>
                                    <td>
                                        <span
                                            :class="
                                                enabled
                                                    ? 'text-pass'
                                                    : 'text-fail'
                                            "
                                            >{{
                                                enabled ? "Enabled" : "Disabled"
                                            }}</span
                                        >
                                    </td>
                                    <td>
                                        <span
                                            class="status-badge"
                                            :class="enabled ? 'pass' : 'fail'"
                                            >{{
                                                enabled
                                                    ? "✓ Passed"
                                                    : "✗ Failed"
                                            }}</span
                                        >
                                    </td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Folder Permissions -->
            <div class="installer-card mb-4">
                <div class="section-title">
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="15"
                        height="15"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                    >
                        <path
                            d="M9.828 3h3.982a2 2 0 0 1 1.992 2.181l-.637 7A2 2 0 0 1 13.174 14H2.826a2 2 0 0 1-1.991-1.819l-.637-7a1.99 1.99 0 0 1 .342-1.31L.5 3a2 2 0 0 1 2-2h3.672a2 2 0 0 1 1.414.586l.828.828A2 2 0 0 0 9.828 3zm-8.322.12C1.72 3.042 1.95 3 2.19 3h5.396l-.707-.707A1 1 0 0 0 6.172 2H2.5a1 1 0 0 0-1 .981l.006.139z"
                        />
                    </svg>
                    File &amp; Folder Permissions
                </div>
                <div class="table-responsive">
                    <table class="req-table">
                        <thead>
                            <tr>
                                <th>Path</th>
                                <th>Required</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="perm in folderPermissions"
                                :key="perm.folder"
                            >
                                <td class="mono">{{ perm.folder }}</td>
                                <td>{{ perm.permission }}</td>
                                <td>
                                    <span
                                        class="status-badge"
                                        :class="perm.isSet ? 'pass' : 'fail'"
                                        >{{
                                            perm.isSet ? "✓ Passed" : "✗ Failed"
                                        }}</span
                                    >
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="installer-actions">
                <button v-if="hasNext" class="btn-main" @click.prevent="next">
                    Continue
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="15"
                        height="15"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                    >
                        <path
                            fill-rule="evenodd"
                            d="M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708z"
                        />
                    </svg>
                </button>
                <button v-else class="btn-danger" @click.prevent="retry">
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="15"
                        height="15"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                    >
                        <path
                            fill-rule="evenodd"
                            d="M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2v1z"
                        />
                        <path
                            d="M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 0 1 8 4.466z"
                        />
                    </svg>
                    Retry Check
                </button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import Axios from "@/services/axios/index.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import StepIndicator from "./StepIndicator.vue";

const checkPhpVersion = ref({});
const checkMysqlVersion = ref({});
const phpRequirements = ref({});
const phpRequirementsErrors = ref({});
const folderPermissions = ref([]);
const folderPermissionsErrors = ref(null);

const getRequirement = () => {
    Axios.get(`installation/requirements`).then((response) => {
        if (
            !response?.data?.checkPhpVersion &&
            !response?.data?.requirements?.requirements?.php
        ) {
            // requirements not met
        } else {
            checkPhpVersion.value = response?.data?.checkPhpVersion;
            checkMysqlVersion.value = response?.data?.mysqlVersion;
            phpRequirements.value =
                response?.data?.requirements?.requirements?.php;
            phpRequirementsErrors.value = response?.data?.requirements?.errors;
            folderPermissions.value = response?.data?.permissions?.permissions;
            folderPermissionsErrors.value = response?.data?.permissions?.errors;
        }
    });
};

const hasNext = computed(() => {
    if (phpRequirements.value && Object.keys(phpRequirements.value).length) {
        for (const key in phpRequirements.value) {
            if (!phpRequirements.value[key]) return false;
        }
        return (
            checkPhpVersion.value.status &&
            checkMysqlVersion.value.status &&
            folderPermissionsErrors.value === null &&
            !phpRequirementsErrors.value
        );
    }
    return false;
});

const next = () => location.replace(urlGenerator("/purchase-code"));
const retry = () => location.replace(urlGenerator("/install"));

onMounted(() => getRequirement());
</script>

<style scoped>
.installer-page {
    min-height: 100vh;
    background: var(--theme-muted-bg);
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding: 40px 16px 60px;
    font-family: "DM Sans", sans-serif;
}
.installer-wrapper {
    width: 100%;
    max-width: 860px;
}
.installer-header {
    text-align: center;
    margin-bottom: 2rem;
}
.installer-title {
    font-size: 1.75rem;
    font-weight: 700;
    color: var(--theme-text);
    margin: 0 0 4px;
}
.installer-subtitle {
    color: #6c757d;
    font-size: 0.95rem;
    margin: 0;
}
.notice-banner {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    background: #f0faf4;
    border: 1px solid #a7d7bc;
    border-left: 4px solid var(--theme-primary);
    border-radius: 8px;
    padding: 14px 18px;
    font-size: 0.875rem;
    color: #1a3d2e;
}
.notice-icon {
    color: var(--theme-primary);
    flex-shrink: 0;
    margin-top: 2px;
}
.notice-text a {
    color: var(--theme-primary);
    font-weight: 600;
    text-decoration: none;
    margin-left: 4px;
}
.notice-text a:hover {
    text-decoration: underline;
}
.installer-card {
    background: var(--theme-card);
    border-radius: 12px;
    box-shadow:
        0 1px 3px rgba(0, 0, 0, 0.06),
        0 4px 16px rgba(0, 0, 0, 0.04);
    overflow: hidden;
}
.section-title {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 14px 20px;
    font-size: 0.8rem;
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: #6b7280;
    border-bottom: 1px solid #f3f4f6;
    background: #fafafa;
}
.req-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.875rem;
}
.req-table thead tr {
    background: #f9fafb;
}
.req-table th {
    padding: 10px 20px;
    text-align: left;
    font-size: 0.72rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--theme-text-faint);
    border-bottom: 1px solid #e5e7eb;
}
.req-table td {
    padding: 11px 20px;
    color: #374151;
    border-bottom: 1px solid #f3f4f6;
}
.req-table tbody tr:last-child td {
    border-bottom: none;
}
.req-table tbody tr:hover {
    background: #f9fafb;
}
.mono {
    font-family: monospace;
    font-size: 0.82rem;
    color: #6b7280;
}
.status-badge {
    display: inline-flex;
    align-items: center;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 0.78rem;
    font-weight: 600;
}
.status-badge.pass {
    background: #ecfdf5;
    color: #065f46;
}
.status-badge.fail {
    background: #fef2f2;
    color: #991b1b;
}
.text-pass {
    color: #059669;
    font-weight: 500;
}
.text-fail {
    color: #dc2626;
    font-weight: 500;
}
.installer-actions {
    display: flex;
    justify-content: center;
    margin-top: 1.5rem;
}
.btn-main,
.btn-danger {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 11px 32px;
    border: none;
    border-radius: 8px;
    font-size: 0.95rem;
    font-weight: 600;
    font-family: "DM Sans", sans-serif;
    cursor: pointer;
    transition: all 0.2s ease;
}
.btn-main {
    background: var(--theme-primary);
    color: #fff;
}
.btn-main:hover {
    background: var(--theme-secondary);
    transform: translateY(-1px);
    box-shadow: 0 4px 14px rgba(var(--theme-primary-rgb), 0.28);
}
.btn-danger {
    background: #ef4444;
    color: #fff;
}
.btn-danger:hover {
    background: #dc2626;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}
</style>
