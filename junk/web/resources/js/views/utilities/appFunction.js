export default class appFunction {
    static baseUrl() {
        const app_url = window.localStorage.getItem("base_url");
        if (app_url) {
            try {
                if (new URL(app_url).protocol === window.location.protocol) {
                    return app_url;
                }
            } catch (e) {
                // fall through to clear the invalid stored value
            }
            window.localStorage.removeItem("base_url");
        }
        return window.location.origin;
    }

    static getAppUrl(path) {
        return `${this.baseUrl()}/${path}`;
    }

    static getQueryStringValue(key) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(key);
    }

    static isFunction(func) {
        return typeof func === "function";
    }

    static isUndefined(obj) {
        return typeof obj === "undefined";
    }

    static splitNameBySlas(item) {
        if (item.includes("/")) {
            let itemArr = item.split("/");
            return itemArr[itemArr.length - 1];
        }
        return item;
    }
}
