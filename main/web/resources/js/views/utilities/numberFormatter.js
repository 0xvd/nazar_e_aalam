const EASTERN_ARABIC_DIGITS = [
    "٠",
    "١",
    "٢",
    "٣",
    "٤",
    "٥",
    "٦",
    "٧",
    "٨",
    "٩",
];

export const toArabicDigits = (value) =>
    String(value).replace(/[0-9]/g, (digit) => EASTERN_ARABIC_DIGITS[digit]);

export const toLocaleDigits = (value, locale) =>
    locale === "ar" ? toArabicDigits(value) : String(value);
