<script setup>
import { onBeforeMount } from "@vue/runtime-core";
import { ref } from "vue";
import { urlGenerator } from "@/utilities/urlGenerator.js";

const companyLogoUrl = ref("");
const getCompanyLogo = () => {
    const storedLogo = urlGenerator(
        window.localStorage.getItem("company_logo"),
    );
    if (storedLogo) {
        companyLogoUrl.value = storedLogo;
        return storedLogo;
    } else {
        // Handle the case when 'company_logo' is not found in localStorage
        return null;
    }
};

onBeforeMount(() => {
    getCompanyLogo();
});
</script>

<template>
    <span class="align-middle">
        <img style="height: 50px" :src="companyLogoUrl" alt="Company logo" />
    </span>
</template>

<style scoped></style>
