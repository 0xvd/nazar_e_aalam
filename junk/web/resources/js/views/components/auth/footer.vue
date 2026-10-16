<script setup>
import { onBeforeMount } from "@vue/runtime-core";
import { ref } from "vue";

const companyName = ref("");
const getCompanyName = () => {
    const storedName = window.localStorage.getItem("company_name");
    if (storedName) {
        companyName.value = storedName;
        return storedName;
    } else {
        return null;
    }
};
const currentYear = ref("");
const getYear = () => {
    return (currentYear.value = new Date().getFullYear());
};
onBeforeMount(() => {
    getYear();
    getCompanyName();
});
</script>

<template>
    <div>
        <div class="copyright">
            &copy; {{ currentYear }} {{ companyName }}. All rights reserved.
        </div>

        <div class="links mb-5">
            <a :href="'privacy-policy'" class="link">Privacy Policy</a>
            <span class="separator">|</span>
            <a :href="'terms-and-conditions'" class="link"
                >Terms & Conditions</a
            >
            <span class="separator">|</span>
            <a :href="'support'" class="link">Support</a>
        </div>
    </div>
</template>

<style scoped>
.copyright {
    text-align: center;
    margin-top: 1.25rem;
    margin-bottom: 0.6rem;
    font-size: 12px;
    color: rgba(255, 255, 255, 0.38);
}

.links {
    text-align: center;
}

.link {
    text-decoration: none;
    color: rgba(255, 255, 255, 0.45);
    font-size: 12px;
    font-weight: 500;
    transition: color 0.2s;
}

.link:hover {
    color: rgba(var(--theme-accent-rgb), 0.85);
}

.separator {
    margin: 0 8px;
    color: rgba(255, 255, 255, 0.2);
}
</style>
