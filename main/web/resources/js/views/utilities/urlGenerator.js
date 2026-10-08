import appFunction from "@/utilities/appFunction.js";

export const urlGenerator = (url) => {
    return url.includes(appFunction.baseUrl())
        ? url
        : `${appFunction.baseUrl()}/${url
              .split("/")
              .filter((d) => d)
              .join("/")}`;
};
