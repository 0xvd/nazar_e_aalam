<template>
    <app-modal
        :modal-id="modalId"
        modal-size="large"
        :title="
            selectedUrl
                ? $t('common.update_item', { item: $t('role.singular') })
                : $t('common.add_item', { item: $t('role.singular') })
        "
        :preloader="preloader"
        @submit="submit"
        @close="closeModal"
    >
        <template v-slot:body>
            <app-loader v-if="pageLoader" />
            <form v-else>
                <!-- Role Name + Select All -->
                <div class="role-form-header mb-4">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-8">
                            <label class="form-label role-label">
                                {{ $t("role.form.name_label") }}
                                <span class="text-danger">*</span>
                            </label>
                            <input
                                type="text"
                                v-model="formData.name"
                                class="form-control role-input"
                                :placeholder="$t('role.form.name_placeholder')"
                                required
                            />
                            <small class="role-error" v-if="errors.name">{{
                                errors.name[0]
                            }}</small>
                        </div>
                        <div class="col-md-4">
                            <div class="select-all-box">
                                <label class="select-all-toggle" for="all">
                                    <input
                                        id="all"
                                        class="role-checkbox"
                                        type="checkbox"
                                        :checked="
                                            formData.permissions.length ===
                                            permissionLength
                                        "
                                        @click="selectAll($event)"
                                        name="all_check"
                                    />
                                    <span class="select-all-text">{{
                                        $t("role.form.select_all")
                                    }}</span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <small class="role-error" v-if="errors.permissions">{{
                        errors.permissions[0]
                    }}</small>
                </div>

                <!-- Permissions Grid -->
                <div v-if="Object.keys(data.permissions).length">
                    <div class="permissions-section-title mb-3">
                        <i class="fas fa-shield-alt me-2"></i
                        >{{ $t("role.form.permissions_title") }}
                        <span class="permission-count ms-2">{{
                            $t("role.form.selected_count", {
                                selected: formData.permissions.length,
                                total: permissionLength,
                            })
                        }}</span>
                    </div>
                    <div class="row g-3">
                        <div
                            class="col-md-4"
                            v-for="permissionGroupName in Object.keys(
                                data.permissions,
                            )"
                            :key="permissionGroupName"
                        >
                            <div class="permission-card">
                                <div class="permission-card-header">
                                    <label
                                        :for="`single-checkbox-${permissionGroupName}`"
                                        class="permission-group-label"
                                    >
                                        <input
                                            :id="`single-checkbox-${permissionGroupName}`"
                                            class="role-checkbox"
                                            type="checkbox"
                                            :checked="
                                                groupIsChecked(
                                                    data.permissions[
                                                        permissionGroupName
                                                    ],
                                                )
                                            "
                                            @click="selectGroup($event)"
                                            :name="permissionGroupName"
                                        />
                                        <span>{{
                                            handlePermissionName(
                                                permissionGroupName,
                                            )
                                        }}</span>
                                    </label>
                                </div>
                                <div class="permission-card-body">
                                    <div
                                        class="permission-item"
                                        v-for="permission in data.permissions[
                                            permissionGroupName
                                        ]"
                                        :key="permission.id"
                                    >
                                        <label
                                            class="permission-item-label"
                                            :for="permission.id"
                                        >
                                            <input
                                                :id="permission.id"
                                                type="checkbox"
                                                class="role-checkbox"
                                                name="permissions"
                                                v-model="formData.permissions"
                                                :value="permission.id"
                                            />
                                            <span>{{
                                                handlePermissionName(
                                                    permission.name,
                                                )
                                            }}</span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </template>
    </app-modal>
</template>

<style scoped>
/* ── Role Input ─────────────────────────────── */
.role-label {
    font-size: 0.8125rem;
    font-weight: 600;
    color: var(--z-text);
    margin-bottom: 0.35rem;
}

.role-input {
    border: 1.5px solid var(--z-border-md);
    border-radius: var(--z-radius-sm);
    padding: 0.55rem 0.9rem;
    font-size: 0.9rem;
    color: var(--z-text);
    background: var(--z-surface);
    transition:
        border-color 0.15s,
        box-shadow 0.15s;
}

.role-input:focus {
    border-color: var(--z-green-400);
    box-shadow: 0 0 0 3px rgba(26, 92, 56, 0.12);
    outline: none;
}

.role-input::placeholder {
    color: #b0bcb8;
}

.role-error {
    display: block;
    font-size: 0.78rem;
    color: #dc3545;
    margin-top: 0.3rem;
}

/* ── Select All Box ─────────────────────────── */
.select-all-box {
    background: var(--z-green-50);
    border: 1.5px solid var(--z-border-md);
    border-radius: var(--z-radius-sm);
    padding: 0.55rem 0.9rem;
}

.select-all-toggle {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    cursor: pointer;
    margin: 0;
    font-weight: 600;
    font-size: 0.8125rem;
    color: var(--z-green-700);
    user-select: none;
}

.select-all-text {
    line-height: 1;
}

/* ── Section Title ──────────────────────────── */
.permissions-section-title {
    font-size: 0.8125rem;
    font-weight: 700;
    color: var(--z-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    display: flex;
    align-items: center;
}

.permission-count {
    background: var(--z-green-100);
    color: var(--z-green-700);
    font-size: 0.72rem;
    font-weight: 600;
    padding: 0.1rem 0.5rem;
    border-radius: 20px;
    letter-spacing: 0;
    text-transform: none;
}

/* ── Permission Cards ───────────────────────── */
.permission-card {
    border: 1.5px solid var(--z-border-md);
    border-radius: var(--z-radius);
    overflow: hidden;
    background: var(--z-surface);
    box-shadow: var(--z-shadow-sm);
    transition: box-shadow 0.15s;
}

.permission-card:hover {
    box-shadow: var(--z-shadow);
}

.permission-card-header {
    background: linear-gradient(135deg, var(--z-green-700), var(--z-green-600));
    padding: 0.6rem 0.9rem;
}

.permission-group-label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    cursor: pointer;
    margin: 0;
    color: #ffffff;
    font-weight: 600;
    font-size: 0.8125rem;
    user-select: none;
}

.permission-card-body {
    padding: 0.5rem 0.9rem 0.75rem;
}

.permission-item {
    padding: 0.3rem 0;
    border-bottom: 1px solid var(--z-border);
}

.permission-item:last-child {
    border-bottom: none;
}

.permission-item-label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    cursor: pointer;
    margin: 0;
    font-size: 0.8125rem;
    color: var(--z-text);
    user-select: none;
}

/* ── Custom Checkbox ────────────────────────── */
.role-checkbox {
    appearance: none;
    -webkit-appearance: none;
    width: 15px;
    height: 15px;
    min-width: 15px;
    border: 1.5px solid rgba(255, 255, 255, 0.6);
    border-radius: 4px;
    background: rgba(255, 255, 255, 0.15);
    cursor: pointer;
    position: relative;
    transition:
        background 0.15s,
        border-color 0.15s;
    flex-shrink: 0;
}

.permission-card-body .role-checkbox,
.select-all-box .role-checkbox {
    border-color: var(--z-border-md);
    background: var(--z-surface);
}

.role-checkbox:checked {
    background: var(--z-gold-500);
    border-color: var(--z-gold-600);
}

.permission-card-body .role-checkbox:checked,
.select-all-box .role-checkbox:checked {
    background: var(--z-green-500);
    border-color: var(--z-green-600);
}

.role-checkbox:checked::after {
    content: "";
    position: absolute;
    top: 1px;
    left: 4px;
    width: 4px;
    height: 7px;
    border: 2px solid #fff;
    border-top: none;
    border-left: none;
    transform: rotate(45deg);
}
</style>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useSubmitForm } from "@/composable/useSubmitForm.js";
import Axios from "@/services/axios/index.js";

const props = defineProps({
    modalId: String,
    selectedUrl: String,
    data: {
        default: function () {
            return {
                permissions: {},
            };
        },
    },
});
const handlePermissionName = (param) => {
    return param.replace(/_/g, " ").replace(/^\w/, (c) => c.toUpperCase());
};

const emit = defineEmits(["close"]);

const formData = ref({
    permissions: [],
});

const { preloader, errors, save, closeModal } = useSubmitForm(
    props,
    emit,
    "no",
);
const submit = () => {
    save(props.selectedUrl ? props.selectedUrl : "roles", formData.value);
};

const permissionLength = computed(() => {
    let i = 0;
    for (let permissionGroup in props.data.permissions) {
        i += props.data.permissions[permissionGroup].length;
    }
    return i;
});

const selectAll = (event) => {
    if (event.target.checked) {
        for (let permissionGroup in props.data.permissions) {
            for (let permission in props.data.permissions[permissionGroup]) {
                formData.value.permissions.push(
                    props.data.permissions[permissionGroup][permission].id,
                );
            }
        }
    } else {
        formData.value.permissions = [];
    }
};

const selectGroup = (event) => {
    let groupName = event.target.name;
    if (event.target.checked) {
        assignGroupPermission(
            getPermissionValues(props.data.permissions[groupName], "id"),
        );
    } else {
        detachGroupPermission(
            getPermissionValues(props.data.permissions[groupName], "id"),
        );
    }
};

const getPermissionValues = (data, key) => {
    let value = [];
    for (let index in data) {
        value.push(data[index][key]);
    }
    return value;
};
const assignGroupPermission = (permissions) => {
    for (let index in permissions) {
        if (!formData.value.permissions.includes(permissions[index])) {
            formData.value.permissions.push(permissions[index]);
        }
    }
};
const detachGroupPermission = (permissions) => {
    for (let index in permissions) {
        let indexOf = formData.value.permissions.indexOf(permissions[index]);
        formData.value.permissions.splice(indexOf, 1);
    }
};
const groupIsChecked = (groupPermissions) => {
    let groupPermissionCheck = true;
    groupPermissions.forEach((item) => {
        if (!formData.value.permissions.includes(item.id)) {
            groupPermissionCheck = false;
        }
    });
    return groupPermissionCheck;
};

const pageLoader = ref(false);
const getEditData = () => {
    if (props.selectedUrl) {
        pageLoader.value = true;
        Axios.get(props.selectedUrl)
            .then(({ data }) => {
                formData.value = data;
                formData.value.permissions = data.permissions.map(
                    (item) => item.id,
                );
            })
            .finally(() => (pageLoader.value = false));
    }
};
onMounted(() => {
    if (props.selectedUrl) {
        getEditData();
    }
});
</script>
