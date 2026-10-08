<template>
    <RenderlessPagination
        :data="data"
        :limit="limit"
        :keep-length="keepLength"
        @pagination-change-page="$emit('pagination-change-page', $event)"
        v-slot="slotProps"
    >
        <ul
            v-bind="$attrs"
            class="pagination"
            :class="{
                'pagination-sm': size === 'small',
                'pagination-lg': size === 'large',
                'justify-content-center': align === 'center',
                'justify-content-end': align === 'right',
            }"
            v-if="slotProps.computed.total > slotProps.computed.perPage"
        >
            <li
                class="page-item pagination-prev-nav"
                :class="{ disabled: !slotProps.computed.prevPageUrl }"
                v-if="slotProps.computed.prevPageUrl || showDisabled"
            >
                <a
                    class="page-link"
                    href="#"
                    aria-label="Previous"
                    :tabindex="!slotProps.computed.prevPageUrl && -1"
                    v-on="slotProps.prevButtonEvents"
                >
                    <span aria-hidden="true">&laquo;</span>
                </a>
            </li>

            <li
                class="page-item pagination-page-nav"
                v-for="(page, key) in slotProps.computed.pageRange"
                :key="key"
                :class="{ active: page == slotProps.computed.currentPage }"
            >
                <a
                    class="page-link"
                    href="#"
                    v-on="slotProps.pageButtonEvents(page)"
                    :aria-current="
                        page == slotProps.computed.currentPage ? 'page' : null
                    "
                >
                    {{ localizeDigits(page) }}
                </a>
            </li>

            <li
                class="page-item pagination-next-nav"
                :class="{ disabled: !slotProps.computed.nextPageUrl }"
                v-if="slotProps.computed.nextPageUrl || showDisabled"
            >
                <a
                    class="page-link"
                    href="#"
                    aria-label="Next"
                    :tabindex="!slotProps.computed.nextPageUrl && -1"
                    v-on="slotProps.nextButtonEvents"
                >
                    <span aria-hidden="true">&raquo;</span>
                </a>
            </li>
        </ul>
    </RenderlessPagination>
</template>

<script setup>
import { useI18n } from "vue-i18n";
import { RenderlessPagination } from "laravel-vue-pagination";
import { toLocaleDigits } from "@/utilities/numberFormatter.js";

defineOptions({ inheritAttrs: false });

defineProps({
    data: { type: Object, default: () => ({}) },
    limit: { type: Number, default: 0 },
    showDisabled: { type: Boolean, default: false },
    keepLength: { type: Boolean, default: false },
    size: { type: String, default: "default" },
    align: { type: String, default: "left" },
});
defineEmits(["pagination-change-page"]);

const { locale } = useI18n();
const localizeDigits = (page) => toLocaleDigits(page, locale.value);
</script>
