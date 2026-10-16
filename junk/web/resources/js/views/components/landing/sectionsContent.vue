<template>
    <app-loader v-if="pageLoader" />
    <div v-else class="lp-wrapper">
        <div class="lp-header">
            <div class="lp-header-icon">📝</div>
            <div>
                <h2 class="lp-title">{{ $t("landing_sections.title") }}</h2>
                <p class="lp-subtitle">{{ $t("landing_sections.subtitle") }}</p>
            </div>
            <a href="/" target="_blank" class="preview-btn"
                >{{ $t("landing_sections.preview_page") }} ↗</a
            >
        </div>

        <form @submit.prevent="submit">
            <!-- Quran -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span> 📖
                    {{ $t("landing_sections.section.quran") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_sections.form.title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_sections.form.quran_title_placeholder',
                                )
                            "
                            v-model="form.quran_title"
                        />
                    </div>
                    <div class="field-group">
                        <label class="field-label"
                            >{{
                                $t(
                                    "landing_sections.form.title_highlight_label",
                                )
                            }}
                            <span class="hint"
                                >({{
                                    $t(
                                        "landing_sections.form.green_colored_part",
                                    )
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_sections.form.quran_title_highlight_placeholder',
                                )
                            "
                            v-model="form.quran_title_highlight"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="3"
                            v-model="form.quran_description"
                        ></textarea>
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.quran_offline_note_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_sections.form.quran_offline_note_placeholder',
                                )
                            "
                            v-model="form.quran_offline_note"
                        />
                    </div>
                </div>
            </div>

            <!-- Prayer -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span> 🕌
                    {{ $t("landing_sections.section.prayer") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_sections.form.title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_sections.form.prayer_title_placeholder',
                                )
                            "
                            v-model="form.prayer_title"
                        />
                    </div>
                    <div class="field-group">
                        <label class="field-label"
                            >{{
                                $t(
                                    "landing_sections.form.title_highlight_label",
                                )
                            }}
                            <span class="hint"
                                >({{
                                    $t(
                                        "landing_sections.form.green_colored_part",
                                    )
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_sections.form.prayer_title_highlight_placeholder',
                                )
                            "
                            v-model="form.prayer_title_highlight"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="3"
                            v-model="form.prayer_description"
                        ></textarea>
                    </div>
                </div>
            </div>

            <!-- AI -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span> 🤖
                    {{ $t("landing_sections.section.ai") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.section_title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t('landing_sections.form.ai_title_placeholder')
                            "
                            v-model="form.ai_title"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            v-model="form.ai_description"
                        ></textarea>
                    </div>
                </div>

                <p class="sub-label">
                    {{ $t("landing_sections.form.ai_chat_card_label") }}
                </p>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_sections.form.title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.ai_chat_card_title"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            v-model="form.ai_chat_card_description"
                        ></textarea>
                    </div>
                </div>

                <p class="sub-label">
                    {{ $t("landing_sections.form.ai_name_card_label") }}
                </p>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_sections.form.title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.ai_name_card_title"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            v-model="form.ai_name_card_description"
                        ></textarea>
                    </div>
                </div>
            </div>

            <!-- Dhikr -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span> 📿
                    {{ $t("landing_sections.section.dhikr") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.section_title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_sections.form.dhikr_title_placeholder',
                                )
                            "
                            v-model="form.dhikr_title"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            v-model="form.dhikr_description"
                        ></textarea>
                    </div>
                </div>
            </div>

            <!-- Donation -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span> 💰
                    {{ $t("landing_sections.section.donation") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.section_title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            :placeholder="
                                $t(
                                    'landing_sections.form.donation_title_placeholder',
                                )
                            "
                            v-model="form.donation_title"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            :placeholder="
                                $t(
                                    'landing_sections.form.donation_description_placeholder',
                                )
                            "
                            v-model="form.donation_description"
                        ></textarea>
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t(
                                "landing_sections.form.donation_verse_arabic_label",
                            )
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            dir="rtl"
                            v-model="form.donation_verse_arabic"
                        ></textarea>
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t(
                                "landing_sections.form.donation_verse_translation_label",
                            )
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.donation_verse_translation"
                        />
                    </div>
                </div>

                <p class="sub-label">
                    {{ $t("landing_sections.form.donation_why_label") }}
                </p>
                <div
                    class="repeat-item"
                    v-for="(item, i) in donationWhy"
                    :key="i"
                >
                    <div class="repeat-header">
                        {{ $t("landing_features.card_label", { n: i + 1 }) }}
                    </div>
                    <div class="fields-grid">
                        <div class="field-group">
                            <label class="field-label">{{
                                $t("landing_features.form.icon_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.icon"
                                maxlength="4"
                            />
                        </div>
                        <div class="field-group">
                            <label class="field-label">{{
                                $t("landing_features.form.title_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.title"
                            />
                        </div>
                        <div class="field-group full">
                            <label class="field-label">{{
                                $t("landing_sections.form.description_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.description"
                            />
                        </div>
                    </div>
                </div>

                <div class="fields-grid" style="margin-top: 14px">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t(
                                "landing_sections.form.donation_accepted_label_label",
                            )
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.donation_accepted_label"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label"
                            >{{
                                $t(
                                    "landing_sections.form.donation_gateways_label",
                                )
                            }}
                            <span class="hint"
                                >({{
                                    $t("landing_features.form.one_per_line")
                                }})</span
                            ></label
                        >
                        <textarea
                            class="field-input field-textarea"
                            rows="3"
                            v-model="form.donation_gateways"
                        ></textarea>
                    </div>
                </div>
            </div>

            <!-- AI Chat Demo -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span> 🎙️
                    {{ $t("landing_sections.section.ai_chat") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.ai_chat_badge_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.ai_chat_badge"
                        />
                    </div>
                    <div class="field-group">
                        <label class="field-label">{{
                            $t(
                                "landing_sections.form.ai_chat_title_line1_label",
                            )
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.ai_chat_title_line1"
                        />
                    </div>
                    <div class="field-group">
                        <label class="field-label"
                            >{{
                                $t(
                                    "landing_sections.form.ai_chat_title_line2_label",
                                )
                            }}
                            <span class="hint"
                                >({{
                                    $t(
                                        "landing_sections.form.gold_colored_part",
                                    )
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.ai_chat_title_line2"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            v-model="form.ai_chat_description"
                        ></textarea>
                    </div>
                </div>

                <p class="sub-label">
                    {{ $t("landing_sections.form.ai_chat_features_label") }}
                </p>
                <div
                    class="repeat-item"
                    v-for="(item, i) in aiChatFeatures"
                    :key="i"
                >
                    <div class="repeat-header">
                        {{ $t("landing_features.card_label", { n: i + 1 }) }}
                    </div>
                    <div class="fields-grid">
                        <div class="field-group">
                            <label class="field-label">{{
                                $t("landing_features.form.icon_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.icon"
                                maxlength="4"
                            />
                        </div>
                        <div class="field-group">
                            <label class="field-label">{{
                                $t("landing_features.form.title_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.title"
                            />
                        </div>
                        <div class="field-group full">
                            <label class="field-label">{{
                                $t("landing_sections.form.description_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.description"
                            />
                        </div>
                    </div>
                </div>

                <div class="fields-grid" style="margin-top: 14px">
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.ai_chat_try_label_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.ai_chat_try_label"
                        />
                    </div>
                </div>

                <p class="sub-label">
                    {{ $t("landing_sections.form.ai_chat_suggestions_label") }}
                </p>
                <div
                    class="repeat-item"
                    v-for="(item, i) in aiChatSuggestions"
                    :key="i"
                >
                    <div class="repeat-header">
                        {{ $t("landing_features.card_label", { n: i + 1 }) }}
                    </div>
                    <div class="fields-grid">
                        <div class="field-group">
                            <label class="field-label">{{
                                $t(
                                    "landing_sections.form.suggestion_label_label",
                                )
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.label"
                            />
                        </div>
                        <div class="field-group">
                            <label class="field-label">{{
                                $t(
                                    "landing_sections.form.suggestion_question_label",
                                )
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.question"
                            />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Name Generator -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span> ✨
                    {{ $t("landing_sections.section.name_gen") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group">
                        <label class="field-label">{{
                            $t("landing_sections.form.title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.name_gen_title"
                        />
                    </div>
                    <div class="field-group">
                        <label class="field-label"
                            >{{
                                $t(
                                    "landing_sections.form.title_highlight_label",
                                )
                            }}
                            <span class="hint"
                                >({{
                                    $t(
                                        "landing_sections.form.green_colored_part",
                                    )
                                }})</span
                            ></label
                        >
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.name_gen_title_highlight"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.description_label")
                        }}</label>
                        <textarea
                            class="field-input field-textarea"
                            rows="2"
                            v-model="form.name_gen_description"
                        ></textarea>
                    </div>
                </div>
            </div>

            <!-- Tech Specs -->
            <div class="lp-card">
                <div class="card-label">
                    <span class="dot"></span> 🚀
                    {{ $t("landing_sections.section.tech") }}
                </div>
                <div class="fields-grid">
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.section_title_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.tech_title"
                        />
                    </div>
                    <div class="field-group full">
                        <label class="field-label">{{
                            $t("landing_sections.form.tech_subtitle_label")
                        }}</label>
                        <input
                            class="field-input"
                            type="text"
                            v-model="form.tech_subtitle"
                        />
                    </div>
                </div>

                <p class="sub-label">
                    {{ $t("landing_sections.form.tech_specs_label") }}
                </p>
                <div
                    class="repeat-item"
                    v-for="(item, i) in techSpecs"
                    :key="i"
                >
                    <div class="repeat-header">
                        {{ $t("landing_features.card_label", { n: i + 1 }) }}
                    </div>
                    <div class="fields-grid">
                        <div class="field-group">
                            <label class="field-label">{{
                                $t("landing_features.form.icon_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.icon"
                                maxlength="4"
                            />
                        </div>
                        <div class="field-group">
                            <label class="field-label">{{
                                $t("landing_features.form.title_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.title"
                            />
                        </div>
                        <div class="field-group full">
                            <label class="field-label">{{
                                $t("landing_sections.form.description_label")
                            }}</label>
                            <input
                                class="field-input"
                                type="text"
                                v-model="item.description"
                            />
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="save-btn" :disabled="saving">
                    <app-button-loader v-if="saving" />
                    <svg
                        v-else
                        width="16"
                        height="16"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2.5"
                    >
                        <polyline points="20 6 9 17 4 12" />
                    </svg>
                    {{ $t("common.save") }}
                </button>
            </div>
        </form>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import Axios from "@/services/axios/index.js";
import { toast } from "vue3-toastify";
import { useI18n } from "vue-i18n";

const { t } = useI18n();

const pageLoader = ref(false);
const saving = ref(false);
const errors = ref({});
const sectionFields = [
    "quran_title",
    "quran_title_highlight",
    "quran_description",
    "quran_offline_note",
    "prayer_title",
    "prayer_title_highlight",
    "prayer_description",
    "ai_title",
    "ai_description",
    "ai_chat_card_title",
    "ai_chat_card_description",
    "ai_name_card_title",
    "ai_name_card_description",
    "dhikr_title",
    "dhikr_description",
    "donation_title",
    "donation_description",
    "donation_verse_arabic",
    "donation_verse_translation",
    "donation_accepted_label",
    "donation_gateways",
    "ai_chat_badge",
    "ai_chat_title_line1",
    "ai_chat_title_line2",
    "ai_chat_description",
    "ai_chat_try_label",
    "name_gen_title",
    "name_gen_title_highlight",
    "name_gen_description",
    "tech_title",
    "tech_subtitle",
];

const form = ref({
    quran_title: "",
    quran_title_highlight: "",
    quran_description: "",
    quran_offline_note: "",
    prayer_title: "",
    prayer_title_highlight: "",
    prayer_description: "",
    ai_title: "",
    ai_description: "",
    ai_chat_card_title: "",
    ai_chat_card_description: "",
    ai_name_card_title: "",
    ai_name_card_description: "",
    dhikr_title: "",
    dhikr_description: "",
    donation_title: "",
    donation_description: "",
    donation_verse_arabic: "",
    donation_verse_translation: "",
    donation_accepted_label: "",
    donation_gateways: "",
    ai_chat_badge: "",
    ai_chat_title_line1: "",
    ai_chat_title_line2: "",
    ai_chat_description: "",
    ai_chat_try_label: "",
    name_gen_title: "",
    name_gen_title_highlight: "",
    name_gen_description: "",
    tech_title: "",
    tech_subtitle: "",
});

const donationWhy = ref([
    {
        icon: "📱",
        title: "Free App Forever",
        description: "Keeps the app free for millions of Muslims globally.",
    },
    {
        icon: "🌍",
        title: "Global Infrastructure",
        description: "Funds servers, CDN, and 24/7 uptime for all users.",
    },
    {
        icon: "✨",
        title: "New Features",
        description: "Enables development of new Islamic tools and content.",
    },
    {
        icon: "🛡️",
        title: "Privacy & Security",
        description: "Maintains privacy-first infrastructure with no ads.",
    },
]);

const aiChatFeatures = ref([
    {
        icon: "⚡",
        title: "Sub-second Responses",
        description: "Groq LPU technology delivers answers in milliseconds",
    },
    {
        icon: "📚",
        title: "Quran & Hadith Referenced",
        description:
            "Answers include Arabic text and authentic source citations",
    },
    {
        icon: "📱",
        title: "Full Experience in the App",
        description: "Chat history, offline access, and more inside Zabi",
    },
]);

const aiChatSuggestions = ref([
    {
        label: "Dua before sleeping",
        question: "What is the dua before sleeping?",
    },
    { label: "Pillars of Islam", question: "What are the pillars of Islam?" },
    { label: "How to do Wudu", question: "How to perform Wudu correctly?" },
    {
        label: "Ramadan fasting rules",
        question: "What is the ruling on fasting in Ramadan?",
    },
    {
        label: "Zakat explained",
        question: "What is Zakat and how is it calculated?",
    },
]);

const techSpecs = ref([
    {
        icon: "⚡",
        title: "Flutter Framework",
        description:
            "Built with Flutter & Dart 3.1.5 for smooth 60fps performance",
    },
    {
        icon: "📱",
        title: "Cross-Platform",
        description: "One codebase, native performance on both iOS and Android",
    },
    {
        icon: "🔄",
        title: "Free Updates",
        description: "Regular feature updates and bug fixes at no extra cost",
    },
    {
        icon: "🛡️",
        title: "Privacy First",
        description:
            "Your data stays private with minimal permissions required",
    },
]);

const parseJsonList = (value, current) => {
    if (!value) return;
    try {
        const parsed = JSON.parse(value);
        if (Array.isArray(parsed) && parsed.length) current.value = parsed;
    } catch {}
};

const load = () => {
    pageLoader.value = true;
    Axios.get("landing-settings")
        .then(({ data }) => {
            Object.assign(form.value, data);
            parseJsonList(data.donation_why_json, donationWhy);
            parseJsonList(data.ai_chat_features_json, aiChatFeatures);
            parseJsonList(data.ai_chat_suggestions_json, aiChatSuggestions);
            parseJsonList(data.tech_specs_json, techSpecs);
        })
        .finally(() => {
            pageLoader.value = false;
        });
};

const submit = () => {
    saving.value = true;
    errors.value = {};
    const payload = Object.fromEntries(
        sectionFields.map((k) => [k, form.value[k]]),
    );
    payload.donation_why_json = JSON.stringify(donationWhy.value);
    payload.ai_chat_features_json = JSON.stringify(aiChatFeatures.value);
    payload.ai_chat_suggestions_json = JSON.stringify(aiChatSuggestions.value);
    payload.tech_specs_json = JSON.stringify(techSpecs.value);
    Axios.post("landing-settings", payload)
        .then(({ data }) => toast.success(data.message))
        .catch(({ response }) => {
            if (response?.status === 422) errors.value = response.data.errors;
            else
                toast.error(
                    response?.data?.message ??
                        t("landing_sections.error_saving"),
                );
        })
        .finally(() => {
            saving.value = false;
        });
};

onMounted(load);
</script>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&display=swap");
.lp-wrapper {
    font-family: "DM Sans", sans-serif;
    max-width: 860px;
    padding-bottom: 48px;
    color: var(--theme-text);
}
.lp-header {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 28px;
}
.lp-header-icon {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    background: var(--theme-primary);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
}
.lp-title {
    font-size: 1.3rem;
    font-weight: 600;
    margin: 0;
}
.lp-subtitle {
    font-size: 0.82rem;
    color: var(--theme-text-faint);
    margin: 2px 0 0;
}
.preview-btn {
    margin-left: auto;
    padding: 8px 16px;
    border-radius: 8px;
    border: 1.5px solid var(--theme-border);
    font-size: 0.8rem;
    font-weight: 500;
    color: var(--theme-primary);
    text-decoration: none;
}
.preview-btn:hover {
    background: #f0faf4;
}
.lp-card {
    background: var(--theme-card);
    border-radius: 14px;
    border: 1px solid var(--theme-border);
    padding: 24px 26px;
    margin-bottom: 14px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}
.card-label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.7rem;
    font-weight: 600;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--theme-text-faint);
    margin-bottom: 18px;
}
.dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--theme-primary);
    flex-shrink: 0;
}
.fields-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
}
.full {
    grid-column: 1 / -1;
}
.field-group {
    display: flex;
    flex-direction: column;
    gap: 5px;
}
.field-label {
    font-size: 0.82rem;
    font-weight: 500;
    color: var(--theme-text-muted);
}
.hint {
    font-size: 0.75rem;
    font-weight: 400;
    color: #b0b9cc;
}
.field-input {
    font-family: "DM Sans", sans-serif;
    font-size: 0.9rem;
    color: var(--theme-text);
    background: var(--theme-muted-bg);
    border: 1.5px solid var(--theme-border);
    border-radius: 9px;
    padding: 10px 13px;
    outline: none;
    width: 100%;
    box-sizing: border-box;
    transition:
        border-color 0.18s,
        background 0.18s;
}
.field-input:focus {
    border-color: var(--theme-secondary);
    background: var(--theme-card);
    box-shadow: 0 0 0 3px rgba(var(--theme-secondary-rgb), 0.1);
}
.field-input::placeholder {
    color: #b0b9cc;
}
.field-textarea {
    resize: vertical;
    min-height: 80px;
    line-height: 1.6;
}
.sub-label {
    font-size: 0.7rem;
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: #b0b9cc;
    margin: 18px 0 10px;
}
.repeat-item {
    background: #f9fafc;
    border: 1px solid var(--theme-border);
    border-radius: 10px;
    padding: 14px 16px;
    margin-bottom: 10px;
}
.repeat-item:last-child {
    margin-bottom: 0;
}
.repeat-header {
    font-size: 0.72rem;
    font-weight: 600;
    color: var(--theme-text-faint);
    margin-bottom: 10px;
}
.form-actions {
    display: flex;
    justify-content: flex-end;
    margin-top: 4px;
}
.save-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 11px 26px;
    background: var(--theme-primary);
    color: #fff;
    font-family: "DM Sans", sans-serif;
    font-size: 0.9rem;
    font-weight: 600;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(var(--theme-primary-rgb), 0.28);
    transition:
        background 0.18s,
        transform 0.18s;
}
.save-btn:hover:not(:disabled) {
    background: var(--theme-secondary);
    transform: translateY(-1px);
}
.save-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}
@media (max-width: 640px) {
    .fields-grid {
        grid-template-columns: 1fr;
    }
}
</style>
