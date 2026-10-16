import { createI18n } from "vue-i18n";
import en from "~/lang/en.json";
import ar from "~/lang/ar.json";
import { getLocale } from "~/utilities/locale.js";

const enModules = import.meta.glob("./lang/modules/*.en.json", { eager: true });
const arModules = import.meta.glob("./lang/modules/*.ar.json", { eager: true });

const mergeModules = (base, modules) =>
    Object.values(modules).reduce(
        (acc, mod) => Object.assign(acc, mod.default ?? mod),
        { ...base },
    );

export const i18n = createI18n({
    legacy: false,
    locale: getLocale(),
    fallbackLocale: "en",
    messages: {
        en: mergeModules(en, enModules),
        ar: mergeModules(ar, arModules),
    },
});
