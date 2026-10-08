<template>
    <div class="installer-steps">
        <div class="steps-wrapper">
            <div v-for="(step, i) in steps" :key="i" class="step-item">
                <div
                    v-if="i > 0"
                    class="step-connector"
                    :class="{ completed: i + 1 <= currentStep }"
                ></div>
                <div
                    class="step-bubble"
                    :class="{
                        active: i + 1 === currentStep,
                        completed: i + 1 < currentStep,
                    }"
                >
                    <svg
                        v-if="i + 1 < currentStep"
                        xmlns="http://www.w3.org/2000/svg"
                        width="14"
                        height="14"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                    >
                        <path
                            d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z"
                        />
                    </svg>
                    <span v-else>{{ i + 1 }}</span>
                </div>
                <div
                    class="step-label"
                    :class="{
                        active: i + 1 === currentStep,
                        completed: i + 1 < currentStep,
                    }"
                >
                    {{ step }}
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
defineProps({
    currentStep: { type: Number, required: true },
    steps: {
        type: Array,
        default: () => [
            "Requirements",
            "Purchase Code",
            "Database",
            "User Info",
            "Company",
            "Email",
        ],
    },
});
</script>

<style scoped>
.installer-steps {
    width: 100%;
    padding: 0 16px;
    margin-bottom: 2rem;
}
.steps-wrapper {
    display: flex;
    align-items: flex-start;
    justify-content: center;
    position: relative;
}
.step-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    flex: 1;
    position: relative;
    min-width: 0;
}
.step-connector {
    position: absolute;
    top: 18px;
    right: 50%;
    width: 100%;
    height: 2px;
    background-color: #dee2e6;
    z-index: 0;
    transition: background-color 0.3s ease;
}
.step-connector.completed {
    background-color: var(--theme-primary);
}
.step-bubble {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background-color: #f1f3f5;
    border: 2px solid #dee2e6;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 600;
    color: #868e96;
    position: relative;
    z-index: 1;
    transition: all 0.3s ease;
    flex-shrink: 0;
}
.step-bubble.active {
    background-color: var(--theme-primary);
    border-color: var(--theme-primary);
    color: #fff;
    box-shadow: 0 0 0 4px rgba(var(--theme-primary-rgb), 0.18);
}
.step-bubble.completed {
    background-color: var(--theme-primary);
    border-color: var(--theme-primary);
    color: #fff;
}
.step-label {
    margin-top: 8px;
    font-size: 11px;
    color: #adb5bd;
    font-weight: 500;
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 80px;
    transition: color 0.3s ease;
}
.step-label.active {
    color: var(--theme-primary);
    font-weight: 600;
}
.step-label.completed {
    color: var(--theme-primary);
}
@media (max-width: 576px) {
    .step-label {
        display: none;
    }
    .step-bubble {
        width: 28px;
        height: 28px;
        font-size: 11px;
    }
    .step-connector {
        top: 14px;
    }
}
</style>
