import axios from "axios";
import appFunction from "@/utilities/appFunction.js";

const instance = axios.create({
    headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
    },
});

instance.defaults.timeout = 10000;
instance.defaults.baseURL = appFunction.baseUrl();

instance.interceptors.response.use(
    function (response) {
        // Any status code that lie within the range of 2xx cause this function to trigger
        // Do something with response data
        return response;
    },
    function (error) {
        if (error.response && error.response.status === 401) {
            // logout();
        }
        // if (error.response.status === 404) {
        //     window.location.replace(hostUrl('404'))
        // }
        // if (error.response.status === 424) {
        //     window.location.replace(hostUrl('424'))
        // }
        // if (error.response.status === 403) {
        //     window.location.replace(hostUrl('403'))
        // }
        // if (error.response.status === 419) {
        //     window.location.replace(hostUrl('419'))
        // }
        // if (error.response.status === 426) {
        //     window.location.replace(hostUrl('plan-and-billing'))
        // }
        // Any status codes that falls outside the range of 2xx cause this function to trigger
        // Do something with response error
        return Promise.reject(error);
    },
);

export default instance;
