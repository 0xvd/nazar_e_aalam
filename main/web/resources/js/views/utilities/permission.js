export const canAccess = (permissionName) => {
    let permission = getPermission();
    if (permission && permission.is_app_admin) {
        return true;
    }
    if (!permission || !permission[permissionName]) return false;
    return permission[permissionName];
};

export const isSupperAdmin = () => {
    let permission = getPermission();
    if (permission) {
        return permission.is_app_admin;
    }
};

export const getPermission = () => {
    return JSON.parse(localStorage.getItem("permissions"));
};
