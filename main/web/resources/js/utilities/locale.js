const SUPPORTED_LOCALES = ["en", "ar"];
const DEFAULT_LOCALE = "en";

export const getLocale = () => {
    const stored = window.localStorage.getItem("locale");
    return SUPPORTED_LOCALES.includes(stored) ? stored : DEFAULT_LOCALE;
};

export const setLocale = (locale) => {
    if (!SUPPORTED_LOCALES.includes(locale)) return;
    window.localStorage.setItem("locale", locale);
    document.cookie = `locale=${locale};path=/;max-age=31536000`;
    window.location.reload();
};
