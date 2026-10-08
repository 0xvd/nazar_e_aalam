<template>
    <main class="content db-content">
        <div class="container-fluid p-0">
            <!-- ══ WELCOME BANNER ══════════════════════════════════════════ -->
            <div class="db-welcome">
                <div class="db-welcome__pattern"></div>
                <div class="db-welcome__left">
                    <div class="db-welcome__bismillah">
                        بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ
                    </div>
                    <h2 class="db-welcome__title">
                        {{ $t("dashboard.welcome.greeting") }} 👋
                    </h2>
                    <p class="db-welcome__sub" v-if="settingInfo.mosque_name">
                        {{ $t("dashboard.welcome.managing_pre") }}
                        <span class="db-welcome__app-name">{{
                            settingInfo.mosque_name
                        }}</span>
                        {{ $t("dashboard.welcome.managing_post") }}
                    </p>
                    <p class="db-welcome__sub" v-else>
                        {{ $t("dashboard.welcome.fallback_pre") }}
                        <span class="db-welcome__app-name">Zabi</span>
                        {{ $t("dashboard.welcome.fallback_post") }}
                    </p>
                    <div class="db-welcome__badges">
                        <span class="db-badge db-badge--gold">
                            <svg
                                width="12"
                                height="12"
                                viewBox="0 0 16 16"
                                fill="currentColor"
                            >
                                <path
                                    d="M8 1a7 7 0 100 14A7 7 0 008 1zm.75 10.5h-1.5v-4.5h1.5v4.5zm0-6h-1.5v-1.5h1.5v1.5z"
                                />
                            </svg>
                            {{ today }}
                        </span>
                        <span class="db-badge db-badge--green">
                            <span class="db-dot"></span>
                            {{ $t("dashboard.welcome.panel_active") }}
                        </span>
                    </div>
                </div>
                <div class="db-welcome__right">
                    <div class="db-welcome__icon-wrap">
                        <svg
                            width="52"
                            height="52"
                            viewBox="0 0 80 80"
                            fill="none"
                            xmlns="http://www.w3.org/2000/svg"
                        >
                            <!-- Mosque dome -->
                            <path
                                d="M40 8C30 8 22 18 22 28H58C58 18 50 8 40 8Z"
                                fill="rgba(255,255,255,0.15)"
                            />
                            <rect
                                x="16"
                                y="28"
                                width="48"
                                height="4"
                                rx="2"
                                fill="rgba(255,255,255,0.2)"
                            />
                            <rect
                                x="10"
                                y="32"
                                width="60"
                                height="32"
                                rx="4"
                                fill="rgba(255,255,255,0.12)"
                            />
                            <rect
                                x="30"
                                y="44"
                                width="20"
                                height="20"
                                rx="3"
                                fill="rgba(255,255,255,0.18)"
                            />
                            <!-- Minaret left -->
                            <rect
                                x="12"
                                y="20"
                                width="8"
                                height="44"
                                rx="2"
                                fill="rgba(255,255,255,0.1)"
                            />
                            <path
                                d="M12 20 L16 10 L20 20Z"
                                fill="rgba(255,255,255,0.15)"
                            />
                            <!-- Minaret right -->
                            <rect
                                x="60"
                                y="20"
                                width="8"
                                height="44"
                                rx="2"
                                fill="rgba(255,255,255,0.1)"
                            />
                            <path
                                d="M60 20 L64 10 L68 20Z"
                                fill="rgba(255,255,255,0.15)"
                            />
                            <!-- Crescent on top -->
                            <path
                                d="M40 4C37 4 35 7 36 10C37.5 8.5 39.5 8 42 9C41 6 40 4 40 4Z"
                                fill="rgba(212,168,67,0.8)"
                            />
                            <circle
                                cx="38"
                                cy="7"
                                r="2"
                                fill="rgba(212,168,67,0.6)"
                            />
                            <!-- Star -->
                            <path
                                d="M55 15L56.2 18.6H60L57 20.8L58.1 24.4L55 22.2L51.9 24.4L53 20.8L50 18.6H53.8Z"
                                fill="rgba(212,168,67,0.5)"
                            />
                        </svg>
                    </div>
                </div>
            </div>

            <!-- ══ SETUP ALERTS ════════════════════════════════════════════ -->
            <div
                class="db-alerts"
                v-if="
                    !dataSetList.chapter ||
                    (!dataSetList.isSetTransliteration &&
                        dataSetList.chapter > 0)
                "
            >
                <div
                    class="db-alert db-alert--danger"
                    v-if="!dataSetList.chapter"
                >
                    <app-loader v-if="chapterLoader" />
                    <template v-else>
                        <div class="db-alert__icon">⚠️</div>
                        <div class="db-alert__body">
                            <div class="db-alert__title">
                                {{
                                    $t("dashboard.alerts.quran_setup_required")
                                }}
                            </div>
                            <div class="db-alert__text">
                                {{ $t("dashboard.alerts.quran_setup_text") }}
                            </div>
                        </div>
                        <button class="db-alert__btn" @click="finishSetup">
                            {{ $t("dashboard.alerts.finish_setup") }} →
                        </button>
                    </template>
                </div>
                <div
                    class="db-alert db-alert--warning"
                    v-if="
                        !dataSetList.isSetTransliteration &&
                        dataSetList.chapter > 0
                    "
                >
                    <app-loader v-if="transliterationLoader" />
                    <template v-else>
                        <div class="db-alert__icon">📝</div>
                        <div class="db-alert__body">
                            <div class="db-alert__title">
                                {{
                                    $t(
                                        "dashboard.alerts.transliteration_pending",
                                    )
                                }}
                            </div>
                            <div class="db-alert__text">
                                {{
                                    $t("dashboard.alerts.transliteration_text")
                                }}
                            </div>
                        </div>
                        <button
                            class="db-alert__btn db-alert__btn--warning"
                            @click="finishTransliteration"
                        >
                            {{ $t("dashboard.alerts.complete") }} →
                        </button>
                    </template>
                </div>
            </div>

            <!-- ══ SECTION LABEL ══════════════════════════════════════════ -->
            <div class="db-section-label">
                <span>{{
                    $t("dashboard.sections.islamic_content_overview")
                }}</span>
                <span class="db-section-label__line"></span>
            </div>

            <!-- ══ PRIMARY STAT CARDS (row 1 — Islamic content) ══════════ -->
            <div class="row g-3 mb-3">
                <!-- Quran -->
                <div class="col-6 col-sm-3">
                    <div class="stat-card stat-card--featured stat-green">
                        <div class="stat-card__bg-icon">📖</div>
                        <div class="stat-card__top">
                            <div
                                class="stat-card__icon-wrap stat-card__icon-wrap--white"
                            >
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/surah.svg',
                                        )
                                    "
                                    alt="Surah"
                                />
                            </div>
                            <span
                                class="stat-card__trend stat-card__trend--up"
                                >{{
                                    $t("dashboard.stats.max", { count: 114 })
                                }}</span
                            >
                        </div>
                        <div class="stat-card__value">
                            {{ dataSetList.chapter ?? 0 }}
                        </div>
                        <div class="stat-card__label">
                            {{ $t("dashboard.stats.total_surah") }}
                        </div>
                        <div class="stat-card__bar">
                            <div
                                class="stat-card__bar-fill"
                                :style="{
                                    width:
                                        Math.min(
                                            (dataSetList.chapter / 114) * 100,
                                            100,
                                        ) + '%',
                                }"
                            ></div>
                        </div>
                    </div>
                </div>
                <!-- Dua -->
                <div class="col-6 col-sm-3">
                    <div class="stat-card stat-teal">
                        <div class="stat-card__bg-icon">🤲</div>
                        <div class="stat-card__top">
                            <div class="stat-card__icon-wrap">
                                <img
                                    :src="
                                        urlGenerator('assets/img/icons/dua.svg')
                                    "
                                    alt="Dua"
                                />
                            </div>
                        </div>
                        <div class="stat-card__value">
                            {{ dataSetList.dua ?? 0 }}
                        </div>
                        <div class="stat-card__label">
                            {{ $t("dashboard.stats.total_dua") }}
                        </div>
                    </div>
                </div>
                <!-- Dhikr -->
                <div class="col-6 col-sm-3">
                    <div class="stat-card stat-amber">
                        <div class="stat-card__bg-icon">📿</div>
                        <div class="stat-card__top">
                            <div class="stat-card__icon-wrap">
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/dhikr.svg',
                                        )
                                    "
                                    alt="Dhikr"
                                />
                            </div>
                        </div>
                        <div class="stat-card__value">
                            {{ dataSetList.dhikr ?? 0 }}
                        </div>
                        <div class="stat-card__label">
                            {{ $t("dashboard.stats.total_dhikr") }}
                        </div>
                    </div>
                </div>
                <!-- Allah Names -->
                <div class="col-6 col-sm-3">
                    <div class="stat-card stat-purple">
                        <div class="stat-card__bg-icon">✨</div>
                        <div class="stat-card__top">
                            <div class="stat-card__icon-wrap">
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/allah_icon.svg',
                                        )
                                    "
                                    alt="Allah Icon"
                                />
                            </div>
                            <span
                                class="stat-card__trend stat-card__trend--up"
                                >{{
                                    $t("dashboard.stats.max", { count: 99 })
                                }}</span
                            >
                        </div>
                        <div class="stat-card__value">
                            {{ dataSetList.sifatName ?? 0 }}
                        </div>
                        <div class="stat-card__label">
                            {{ $t("dashboard.stats.allah_names") }}
                        </div>
                    </div>
                </div>
            </div>

            <!-- ══ SECONDARY STAT CARDS (row 2 — operations) ════════════ -->
            <div class="db-section-label">
                <span>{{ $t("dashboard.sections.operations_finance") }}</span>
                <span class="db-section-label__line"></span>
            </div>

            <div class="row g-3 mb-4">
                <div class="col-6 col-sm-3">
                    <div class="stat-card stat-coral">
                        <div class="stat-card__bg-icon">🚫</div>
                        <div class="stat-card__top">
                            <div class="stat-card__icon-wrap">
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/haram.svg',
                                        )
                                    "
                                    alt="Haram Code"
                                />
                            </div>
                        </div>
                        <div class="stat-card__value">
                            {{ dataSetList.haramCode ?? 0 }}
                        </div>
                        <div class="stat-card__label">
                            {{ $t("dashboard.stats.haram_codes") }}
                        </div>
                    </div>
                </div>
                <div class="col-6 col-sm-3">
                    <div class="stat-card stat-blue">
                        <div class="stat-card__bg-icon">👥</div>
                        <div class="stat-card__top">
                            <div class="stat-card__icon-wrap">
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/users.svg',
                                        )
                                    "
                                    alt="Users"
                                />
                            </div>
                        </div>
                        <div class="stat-card__value">
                            {{ dataSetList.users ?? 0 }}
                        </div>
                        <div class="stat-card__label">
                            {{ $t("dashboard.stats.total_users") }}
                        </div>
                    </div>
                </div>
                <div class="col-6 col-sm-3">
                    <div class="stat-card stat-pink">
                        <div class="stat-card__bg-icon">💝</div>
                        <div class="stat-card__top">
                            <div class="stat-card__icon-wrap">
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/donation.svg',
                                        )
                                    "
                                    alt="Donation"
                                />
                            </div>
                        </div>
                        <div class="stat-card__value stat-card__value--sm">
                            {{ dataSetList.donationAmount ?? 0 }}
                        </div>
                        <div class="stat-card__label">
                            {{ $t("dashboard.stats.donations") }}
                        </div>
                    </div>
                </div>
                <div class="col-6 col-sm-3">
                    <div class="stat-card stat-slate">
                        <div class="stat-card__bg-icon">💳</div>
                        <div class="stat-card__top">
                            <div class="stat-card__icon-wrap">
                                <img
                                    :src="
                                        urlGenerator(
                                            'assets/img/icons/payment-method.png',
                                        )
                                    "
                                    alt="Payment"
                                />
                            </div>
                        </div>
                        <div class="stat-card__value">
                            {{ dataSetList.paymentMethods ?? 0 }}
                        </div>
                        <div class="stat-card__label">
                            {{ $t("dashboard.stats.payment_methods") }}
                        </div>
                    </div>
                </div>
            </div>

            <!-- ══ CHARTS ══════════════════════════════════════════════════ -->
            <div class="db-section-label">
                <span>{{ $t("dashboard.sections.analytics") }}</span>
                <span class="db-section-label__line"></span>
            </div>

            <div class="row g-3 mb-4">
                <!-- Bar chart -->
                <div class="col-lg-8">
                    <div class="chart-card">
                        <div class="chart-card__header">
                            <div class="chart-card__title-wrap">
                                <div class="chart-card__icon">🌍</div>
                                <div>
                                    <h5 class="chart-card__title">
                                        {{
                                            $t("dashboard.charts.country_title")
                                        }}
                                    </h5>
                                    <p class="chart-card__subtitle">
                                        {{
                                            $t(
                                                "dashboard.charts.country_subtitle",
                                            )
                                        }}
                                    </p>
                                </div>
                            </div>
                            <div class="chart-legend">
                                <span
                                    v-for="(color, label) in barLegend"
                                    :key="label"
                                    class="legend-item"
                                >
                                    <span
                                        class="legend-dot"
                                        :style="{ background: color }"
                                    ></span>
                                    {{ label }}
                                </span>
                            </div>
                        </div>
                        <div
                            class="chart-card__body"
                            style="height: 260px; position: relative"
                        >
                            <Bar
                                id="bar-chart"
                                :options="barChartOptions"
                                :data="barChartData"
                            />
                        </div>
                    </div>
                </div>

                <!-- Doughnut chart -->
                <div class="col-lg-4">
                    <div class="chart-card">
                        <div class="chart-card__header">
                            <div class="chart-card__title-wrap">
                                <div class="chart-card__icon">📱</div>
                                <div>
                                    <h5 class="chart-card__title">
                                        {{
                                            $t(
                                                "dashboard.charts.platform_title",
                                            )
                                        }}
                                    </h5>
                                    <p class="chart-card__subtitle">
                                        {{
                                            $t(
                                                "dashboard.charts.platform_subtitle",
                                            )
                                        }}
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div
                            class="chart-card__body"
                            style="
                                height: 200px;
                                position: relative;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                            "
                        >
                            <Doughnut
                                id="doughnut-chart"
                                :options="doughnutChartOptions"
                                :data="doughnutChartData"
                            />
                        </div>
                        <div class="doughnut-legend">
                            <div
                                v-for="(item, index) in doughnutLegend"
                                :key="index"
                                class="doughnut-legend__item"
                            >
                                <span
                                    class="doughnut-legend__dot"
                                    :style="{ background: item.color }"
                                ></span>
                                <span class="doughnut-legend__label">{{
                                    item.label
                                }}</span>
                                <span class="doughnut-legend__pct">
                                    {{
                                        doughnutChartData.datasets[0]?.data[
                                            index
                                        ] ?? "—"
                                    }}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ══════════════════════════════════════════════
             NOOR AI — FLOATING CHATBOT
        ══════════════════════════════════════════════ -->
        <button
            class="chat-fab"
            :class="{
                'chat-fab--open': chatOpen,
                'chat-fab--loading': !groqApiKey && !apiKeyError,
            }"
            @click="toggleChat"
            aria-label="Open Noor AI assistant"
        >
            <span class="chat-fab__icon chat-fab__icon--closed">
                <svg width="26" height="26" viewBox="0 0 26 26" fill="none">
                    <rect
                        x="6"
                        y="8"
                        width="14"
                        height="12"
                        rx="3"
                        fill="white"
                    />
                    <circle cx="10.5" cy="13" r="1.5" fill="#1a5c38" />
                    <circle cx="15.5" cy="13" r="1.5" fill="#1a5c38" />
                    <rect
                        x="11"
                        y="16"
                        width="4"
                        height="1.5"
                        rx="0.75"
                        fill="#1a5c38"
                    />
                    <line
                        x1="13"
                        y1="8"
                        x2="13"
                        y2="5"
                        stroke="white"
                        stroke-width="1.2"
                    />
                    <circle cx="13" cy="4.5" r="1.2" fill="#d4a843" />
                    <rect
                        x="4.5"
                        y="11"
                        width="1.5"
                        height="3"
                        rx="0.5"
                        fill="white"
                    />
                    <rect
                        x="20"
                        y="11"
                        width="1.5"
                        height="3"
                        rx="0.5"
                        fill="white"
                    />
                </svg>
            </span>
            <span class="chat-fab__icon chat-fab__icon--open">
                <svg width="18" height="18" viewBox="0 0 20 20" fill="none">
                    <path
                        d="M4 4L16 16M16 4L4 16"
                        stroke="white"
                        stroke-width="2.5"
                        stroke-linecap="round"
                    />
                </svg>
            </span>
            <span class="chat-fab__badge" v-if="!chatOpen && unreadCount > 0">{{
                unreadCount
            }}</span>
            <span
                class="chat-fab__spinner"
                v-if="!groqApiKey && !apiKeyError && !chatOpen"
            ></span>
        </button>

        <transition name="chat-slide">
            <div class="chat-window" v-if="chatOpen">
                <div class="chat-header">
                    <div class="chat-header__avatar">
                        <svg
                            width="20"
                            height="20"
                            viewBox="0 0 26 26"
                            fill="none"
                        >
                            <path
                                d="M13 3C8.03 3 4 7.03 4 12C4 16.97 8.03 21 13 21C15.5 21 17.76 19.97 19.39 18.3C18.6 18.51 17.77 18.62 16.91 18.62C12.28 18.62 8.53 14.87 8.53 10.24C8.53 7.43 9.95 4.96 12.12 3.47C12.41 3.17 12.71 3 13 3Z"
                                fill="white"
                            />
                            <circle cx="19" cy="7" r="2" fill="white" />
                        </svg>
                    </div>
                    <div class="chat-header__info">
                        <div class="chat-header__name">Noor AI</div>
                        <div class="chat-header__status">
                            <span
                                class="status-dot"
                                :class="
                                    groqApiKey
                                        ? 'status-dot--online'
                                        : 'status-dot--loading'
                                "
                            ></span>
                            {{
                                groqApiKey
                                    ? $t("dashboard.chat.status_ready")
                                    : apiKeyError
                                      ? $t("dashboard.chat.status_error")
                                      : $t("dashboard.chat.status_connecting")
                            }}
                        </div>
                    </div>
                    <div class="chat-header__actions">
                        <button
                            class="chat-icon-btn"
                            @click="clearChat"
                            :title="$t('dashboard.chat.clear_conversation')"
                        >
                            <svg
                                width="14"
                                height="14"
                                viewBox="0 0 20 20"
                                fill="none"
                            >
                                <path
                                    d="M3 6h14M8 6V4h4v2M19 6l-1 11a2 2 0 01-2 2H4a2 2 0 01-2-2L1 6"
                                    stroke="currentColor"
                                    stroke-width="1.8"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                />
                            </svg>
                        </button>
                        <button
                            class="chat-icon-btn"
                            @click="toggleChat"
                            :title="$t('dashboard.chat.close')"
                        >
                            <svg
                                width="14"
                                height="14"
                                viewBox="0 0 20 20"
                                fill="none"
                            >
                                <path
                                    d="M4 4L16 16M16 4L4 16"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                />
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="chat-error-banner" v-if="apiKeyError">
                    ⚠️ {{ $t("dashboard.chat.error_banner_pre") }}
                    <code>api/settings</code>.
                    {{
                        $t("dashboard.chat.error_banner_post", {
                            key: "islamic_name_api_key",
                        })
                    }}
                </div>

                <div
                    class="chat-welcome-screen"
                    v-if="messages.length === 0 && !apiKeyError"
                >
                    <div class="chat-welcome">
                        <div class="chat-welcome__crescent">☪️</div>
                        <p class="chat-welcome__title">
                            {{ $t("dashboard.chat.welcome_title") }}
                        </p>
                        <p class="chat-welcome__sub">
                            {{ $t("dashboard.chat.welcome_subtitle") }}
                        </p>
                    </div>
                    <div class="suggestions-grid">
                        <button
                            class="suggestion-chip"
                            v-for="s in suggestions"
                            :key="s"
                            @click="sendSuggestion(s)"
                        >
                            {{ s }}
                        </button>
                    </div>
                </div>

                <div
                    class="chat-messages"
                    ref="messagesContainer"
                    v-else-if="messages.length > 0"
                >
                    <div
                        v-for="(msg, i) in messages"
                        :key="i"
                        class="chat-msg"
                        :class="
                            msg.role === 'user'
                                ? 'chat-msg--user'
                                : 'chat-msg--ai'
                        "
                    >
                        <div
                            class="chat-msg__avatar"
                            v-if="msg.role === 'assistant'"
                        >
                            <svg
                                width="13"
                                height="13"
                                viewBox="0 0 26 26"
                                fill="none"
                            >
                                <path
                                    d="M13 3C8.03 3 4 7.03 4 12C4 16.97 8.03 21 13 21C15.5 21 17.76 19.97 19.39 18.3C18.6 18.51 17.77 18.62 16.91 18.62C12.28 18.62 8.53 14.87 8.53 10.24C8.53 7.43 9.95 4.96 12.12 3.47C12.41 3.17 12.71 3 13 3Z"
                                    fill="white"
                                />
                                <circle cx="19" cy="7" r="2" fill="white" />
                            </svg>
                        </div>
                        <div
                            class="chat-msg__bubble"
                            v-html="formatMessage(msg.content)"
                        ></div>
                    </div>
                    <div class="chat-msg chat-msg--ai" v-if="isTyping">
                        <div class="chat-msg__avatar">
                            <svg
                                width="13"
                                height="13"
                                viewBox="0 0 26 26"
                                fill="none"
                            >
                                <path
                                    d="M13 3C8.03 3 4 7.03 4 12C4 16.97 8.03 21 13 21C15.5 21 17.76 19.97 19.39 18.3C18.6 18.51 17.77 18.62 16.91 18.62C12.28 18.62 8.53 14.87 8.53 10.24C8.53 7.43 9.95 4.96 12.12 3.47C12.41 3.17 12.71 3 13 3Z"
                                    fill="white"
                                />
                                <circle cx="19" cy="7" r="2" fill="white" />
                            </svg>
                        </div>
                        <div class="chat-msg__bubble chat-msg__bubble--typing">
                            <span></span><span></span><span></span>
                        </div>
                    </div>
                </div>

                <div class="chat-input-area">
                    <div
                        class="chat-input-wrap"
                        :class="{ 'chat-input-wrap--disabled': !groqApiKey }"
                    >
                        <textarea
                            ref="inputRef"
                            v-model="userInput"
                            class="chat-input"
                            :placeholder="
                                groqApiKey
                                    ? $t('dashboard.chat.placeholder_ready')
                                    : $t('dashboard.chat.placeholder_waiting')
                            "
                            :disabled="!groqApiKey || isTyping"
                            rows="1"
                            @keydown.enter.exact.prevent="sendMessage"
                            @input="autoResize"
                        ></textarea>
                        <button
                            class="chat-send-btn"
                            @click="sendMessage"
                            :disabled="
                                isTyping || !userInput.trim() || !groqApiKey
                            "
                        >
                            <svg
                                width="15"
                                height="15"
                                viewBox="0 0 20 20"
                                fill="none"
                            >
                                <path
                                    d="M2 10L18 2L12 18L10 11L2 10Z"
                                    fill="currentColor"
                                />
                            </svg>
                        </button>
                    </div>
                    <p class="chat-powered">
                        {{ $t("dashboard.chat.powered_by") }}
                    </p>
                </div>
            </div>
        </transition>
    </main>
</template>

<script setup>
import { onMounted, ref, computed, nextTick } from "vue";
import { useI18n } from "vue-i18n";
import Axios from "@/services/axios/index.js";
import { urlGenerator } from "@/utilities/urlGenerator.js";
import { Doughnut, Bar } from "vue-chartjs";
import {
    Chart as ChartJS,
    Title,
    Tooltip,
    Legend,
    ArcElement,
    CategoryScale,
    LinearScale,
    BarElement,
} from "chart.js";

ChartJS.register(
    ArcElement,
    Tooltip,
    Legend,
    CategoryScale,
    LinearScale,
    BarElement,
    Title,
);

// ─── Date helper ─────────────────────────────────────────────────────────────
const today = computed(() => {
    return new Date().toLocaleDateString("en-US", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
    });
});

// ─── Dashboard data ───────────────────────────────────────────────────────────
const chapterLoader = ref(false);
const transliterationLoader = ref(false);
const dataSetList = ref({});

const finishSetup = () => {
    window.location = urlGenerator("finish-setup");
};
const finishTransliteration = () => {
    window.location = urlGenerator("finish-transliteration");
};

const getServerData = () => {
    chapterLoader.value = true;
    Axios.get("api/dashboard")
        .then(({ data }) => {
            dataSetList.value = data.data;
        })
        .finally(() => {
            chapterLoader.value = false;
        });
};

// ─── Bar chart ────────────────────────────────────────────────────────────────
const BAR_COLORS = [
    "#1a5c38",
    "#d4a843",
    "#2980b9",
    "#7F77DD",
    "#D85A30",
    "#52bb82",
];
const barChartData = ref({
    labels: [],
    datasets: [
        {
            label: "Users",
            backgroundColor: BAR_COLORS,
            borderRadius: 8,
            borderSkipped: false,
            data: [],
        },
    ],
});
const barChartOptions = ref({
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
        legend: { display: false },
        tooltip: {
            backgroundColor: "#1c2b24",
            titleColor: "#d4a843",
            bodyColor: "#fff",
            padding: 10,
            cornerRadius: 8,
            callbacks: { label: (v) => `  ${v.raw} users` },
        },
    },
    scales: {
        x: {
            grid: { display: false },
            ticks: { font: { size: 11, family: "Inter" }, color: "#6b7c74" },
            border: { display: false },
        },
        y: {
            grid: { color: "rgba(26, 92, 56, 0.07)", drawBorder: false },
            ticks: { font: { size: 11, family: "Inter" }, color: "#6b7c74" },
            border: { display: false },
            beginAtZero: true,
        },
    },
});
const barLegend = ref({});
const getCountryData = () => {
    Axios.get(urlGenerator("api/get-country-info")).then(({ data }) => {
        const { labels, series } = data.data;
        barChartData.value = {
            labels,
            datasets: [
                {
                    label: "Users",
                    backgroundColor: BAR_COLORS.slice(0, labels.length),
                    borderRadius: 8,
                    borderSkipped: false,
                    data: series,
                },
            ],
        };
        barLegend.value = Object.fromEntries(
            labels.map((l, i) => [l, BAR_COLORS[i] ?? "#888780"]),
        );
    });
};

// ─── Doughnut chart ───────────────────────────────────────────────────────────
const DOUGHNUT_COLORS = ["#1a5c38", "#d4a843", "#2980b9", "#7F77DD"];
const doughnutChartData = ref({
    labels: [],
    datasets: [{ backgroundColor: DOUGHNUT_COLORS, borderWidth: 0, data: [] }],
});
const doughnutChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    cutout: "72%",
    plugins: {
        legend: { display: false },
        tooltip: {
            backgroundColor: "#1c2b24",
            titleColor: "#d4a843",
            bodyColor: "#fff",
            padding: 10,
            cornerRadius: 8,
        },
    },
};
const doughnutLegend = ref([]);
const getRegionData = () => {
    Axios.get(urlGenerator("api/get-region-info")).then(({ data }) => {
        const { labels, series } = data.data;
        doughnutChartData.value = {
            labels,
            datasets: [
                {
                    backgroundColor: DOUGHNUT_COLORS.slice(0, labels.length),
                    borderWidth: 0,
                    data: series,
                },
            ],
        };
        doughnutLegend.value = labels.map((l, i) => ({
            label: l,
            color: DOUGHNUT_COLORS[i] ?? "#888780",
        }));
    });
};

// ─── Settings / Groq API key ──────────────────────────────────────────────────
const groqApiKey = ref("");
const apiKeyError = ref(false);
const GROQ_MODEL = "llama-3.3-70b-versatile";
const settingInfo = ref({});
const loadApiKey = () => {
    Axios.get("api/settings")
        .then(({ data }) => {
            settingInfo.value = data?.data;
            const key = data?.data?.islamic_name_api_key ?? "";
            if (key) {
                groqApiKey.value = key;
            } else {
                apiKeyError.value = true;
            }
        })
        .catch(() => {
            apiKeyError.value = true;
        });
};

// ─── Chatbot ──────────────────────────────────────────────────────────────────
const chatOpen = ref(false);
const userInput = ref("");
const messages = ref([]);
const isTyping = ref(false);
const unreadCount = ref(0);
const messagesContainer = ref(null);
const inputRef = ref(null);

const SYSTEM_PROMPT = `You are Noor, a warm and knowledgeable Islamic AI assistant embedded in the ZABI Quran admin dashboard.
Your knowledge covers the Holy Quran, Duas, Dhikr, the 99 Names of Allah, Islamic concepts, Fiqh basics, and Seerah.
ZABI Dashboard modules: Dashboard, Prayer Times, Audio Quran, Dua, Dhikr, Wallpaper, Sifat Name, Haram Code, Donation, Settings.
Tone: Warm, knowledgeable, respectful. Use Islamic greetings. Keep answers concise with bullet points for multi-step guidance.`;

const { t } = useI18n();
const suggestions = computed(() => [
    t("dashboard.chat.suggestions.fatiha"),
    t("dashboard.chat.suggestions.add_dua"),
    t("dashboard.chat.suggestions.names_of_allah"),
    t("dashboard.chat.suggestions.prayer_times"),
    t("dashboard.chat.suggestions.morning_dhikr"),
    t("dashboard.chat.suggestions.donations"),
]);

const toggleChat = () => {
    chatOpen.value = !chatOpen.value;
    if (chatOpen.value) {
        unreadCount.value = 0;
        nextTick(() => inputRef.value?.focus());
    }
};
const clearChat = () => {
    messages.value = [];
};
const sendSuggestion = (text) => {
    userInput.value = text;
    sendMessage();
};
const autoResize = () => {
    const el = inputRef.value;
    if (!el) return;
    el.style.height = "auto";
    el.style.height = Math.min(el.scrollHeight, 120) + "px";
};
const scrollToBottom = () => {
    nextTick(() => {
        if (messagesContainer.value)
            messagesContainer.value.scrollTop =
                messagesContainer.value.scrollHeight;
    });
};
const formatMessage = (text) => {
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
        .replace(/`([^`]+)`/g, "<code>$1</code>")
        .replace(/\n/g, "<br>");
};
const sendMessage = async () => {
    const text = userInput.value.trim();
    if (!text || isTyping.value || !groqApiKey.value) return;
    messages.value.push({ role: "user", content: text });
    userInput.value = "";
    if (inputRef.value) inputRef.value.style.height = "auto";
    isTyping.value = true;
    scrollToBottom();
    try {
        const res = await fetch(
            "https://api.groq.com/openai/v1/chat/completions",
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${groqApiKey.value}`,
                },
                body: JSON.stringify({
                    model: GROQ_MODEL,
                    temperature: 0.7,
                    max_tokens: 1024,
                    messages: [
                        { role: "system", content: SYSTEM_PROMPT },
                        ...messages.value.map((m) => ({
                            role: m.role,
                            content: m.content,
                        })),
                    ],
                }),
            },
        );
        if (!res.ok) {
            const err = await res.json().catch(() => ({}));
            throw new Error(err?.error?.message ?? `HTTP ${res.status}`);
        }
        const data = await res.json();
        const reply =
            data.choices?.[0]?.message?.content ??
            "Sorry, I received an empty response.";
        messages.value.push({ role: "assistant", content: reply });
        if (!chatOpen.value) unreadCount.value++;
    } catch (err) {
        messages.value.push({
            role: "assistant",
            content: `⚠️ **Error:** ${err.message}. Please try again.`,
        });
    } finally {
        isTyping.value = false;
        scrollToBottom();
    }
};

onMounted(() => {
    getServerData();
    getCountryData();
    getRegionData();
    loadApiKey();
});
</script>

<style scoped>
/* ══════════════════════════════════════════════════════════
   DASHBOARD — WELCOME BANNER
══════════════════════════════════════════════════════════ */
.db-content {
    padding: 1.75rem 2rem;
}

.db-welcome {
    position: relative;
    background: linear-gradient(
        130deg,
        #072417 0%,
        #0d3a22 40%,
        #1a5c38 80%,
        #22794a 100%
    );
    border-radius: 16px;
    padding: 1.1rem 1.75rem;
    margin-bottom: 1.25rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    overflow: hidden;
    box-shadow: 0 6px 24px rgba(7, 36, 23, 0.24);
}

/* Geometric pattern overlay */
.db-welcome__pattern {
    position: absolute;
    inset: 0;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='60' height='60' viewBox='0 0 60 60'%3E%3Cg fill='none' stroke='%23ffffff06' stroke-width='1'%3E%3Cpath d='M30 0 L60 30 L30 60 L0 30 Z'/%3E%3Ccircle cx='30' cy='30' r='15'/%3E%3C/g%3E%3C/svg%3E");
    pointer-events: none;
}

.db-welcome__left {
    position: relative;
    flex: 1;
}

.db-welcome__bismillah {
    font-family: "Amiri", "Times New Roman", serif;
    font-size: 1.05rem;
    color: rgba(var(--theme-accent-rgb), 0.85);
    margin-bottom: 0.25rem;
    letter-spacing: 0.03em;
}

.db-welcome__title {
    font-size: 1.2rem;
    font-weight: 800;
    color: #fff;
    margin: 0 0 0.2rem;
    line-height: 1.2;
}

.db-welcome__sub {
    font-size: 0.82rem;
    color: rgba(255, 255, 255, 0.65);
    margin: 0 0 0.6rem;
}

.db-welcome__app-name {
    color: var(--theme-accent);
    font-weight: 600;
}

.db-welcome__badges {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
}

.db-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    padding: 0.3rem 0.75rem;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 600;
}

.db-badge--gold {
    background: rgba(var(--theme-accent-rgb), 0.18);
    color: var(--theme-accent);
    border: 1px solid rgba(var(--theme-accent-rgb), 0.3);
}

.db-badge--green {
    background: rgba(255, 255, 255, 0.1);
    color: rgba(255, 255, 255, 0.85);
    border: 1px solid rgba(255, 255, 255, 0.15);
}

.db-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #4ade80;
    animation: pulse-dot 2s ease-in-out infinite;
}

@keyframes pulse-dot {
    0%,
    100% {
        opacity: 1;
    }
    50% {
        opacity: 0.5;
    }
}

.db-welcome__right {
    position: relative;
    flex-shrink: 0;
    padding-left: 1.25rem;
}

.db-welcome__icon-wrap {
    width: 72px;
    height: 72px;
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.06);
    border: 1px solid rgba(255, 255, 255, 0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    backdrop-filter: blur(4px);
}

/* ══ SETUP ALERTS ══════════════════════════════════════════ */
.db-alerts {
    display: flex;
    flex-direction: column;
    gap: 0.6rem;
    margin-bottom: 1.5rem;
}

.db-alert {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem 1.25rem;
    border-radius: 14px;
    font-size: 0.875rem;
}

.db-alert--danger {
    background: #fef2f2;
    border: 1px solid #fecaca;
    color: #991b1b;
}

.db-alert--warning {
    background: #fffbeb;
    border: 1px solid #fde68a;
    color: #92400e;
}

.db-alert__icon {
    font-size: 1.25rem;
    flex-shrink: 0;
}

.db-alert__body {
    flex: 1;
    min-width: 0;
}
.db-alert__title {
    font-weight: 700;
    margin-bottom: 2px;
}
.db-alert__text {
    font-size: 0.8rem;
    opacity: 0.8;
}

.db-alert__btn {
    flex-shrink: 0;
    padding: 0.4rem 1rem;
    border-radius: 8px;
    border: none;
    background: #c0392b;
    color: #fff;
    font-size: 0.8rem;
    font-weight: 600;
    cursor: pointer;
    transition: opacity 0.15s;
}
.db-alert__btn:hover {
    opacity: 0.88;
}
.db-alert__btn--warning {
    background: #b45309;
}

/* ══ SECTION LABELS ════════════════════════════════════════ */
.db-section-label {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 0.6rem;
    font-size: 0.68rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: #6b7c74;
}

.db-section-label__line {
    flex: 1;
    height: 1px;
    background: rgba(26, 92, 56, 0.12);
}

/* ══ STAT CARDS ════════════════════════════════════════════ */
.stat-card {
    background: var(--theme-card);
    border-radius: 14px;
    padding: 0.85rem 1rem;
    position: relative;
    overflow: hidden;
    border: 1px solid rgba(26, 92, 56, 0.09);
    box-shadow: 0 2px 10px rgba(10, 46, 30, 0.06);
    transition:
        transform 0.22s ease,
        box-shadow 0.22s ease;
    cursor: default;
}

.stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 32px rgba(10, 46, 30, 0.13);
}

/* Left accent border */
.stat-card::before {
    content: "";
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    width: 4px;
    border-radius: 16px 0 0 16px;
}

/* Big emoji watermark */
.stat-card__bg-icon {
    position: absolute;
    bottom: -6px;
    right: -2px;
    font-size: 2.8rem;
    opacity: 0.07;
    pointer-events: none;
    line-height: 1;
    user-select: none;
}

/* Top row */
.stat-card__top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 0.55rem;
}

.stat-card__icon-wrap {
    width: 34px;
    height: 34px;
    border-radius: 9px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.stat-card__icon-wrap img {
    width: 17px;
    height: 17px;
    object-fit: contain;
}

.stat-card__trend {
    font-size: 0.65rem;
    font-weight: 600;
    padding: 0.15rem 0.45rem;
    border-radius: 20px;
}
.stat-card__trend--up {
    background: rgba(26, 92, 56, 0.1);
    color: #1a5c38;
}

/* Value */
.stat-card__value {
    font-size: 1.65rem;
    font-weight: 900;
    line-height: 1;
    letter-spacing: -0.03em;
    margin-bottom: 0.15rem;
    color: #1c2b24;
}

.stat-card__value--sm {
    font-size: 1.15rem;
    word-break: break-all;
}

.stat-card__label {
    font-size: 0.68rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #7a8e84;
    margin-bottom: 0.4rem;
}

/* Progress bar (only on featured cards) */
.stat-card__bar {
    height: 3px;
    background: rgba(0, 0, 0, 0.06);
    border-radius: 2px;
    overflow: hidden;
}
.stat-card__bar-fill {
    height: 100%;
    border-radius: 2px;
    background: currentColor;
    transition: width 0.8s ease;
}

/* ── Color variants ─────────────────────────────────────── */
/* Featured (prominent) */
.stat-card--featured {
    background: linear-gradient(135deg, #0d3a22 0%, #1a5c38 100%);
}
.stat-card--featured .stat-card__value {
    color: #fff;
}
.stat-card--featured .stat-card__label {
    color: rgba(255, 255, 255, 0.65);
}
.stat-card--featured .stat-card__bg-icon {
    opacity: 0.12;
}
.stat-card--featured .stat-card__trend--up {
    background: rgba(255, 255, 255, 0.15);
    color: var(--theme-accent);
}
.stat-card--featured .stat-card__bar {
    background: rgba(255, 255, 255, 0.15);
}
.stat-card--featured .stat-card__bar-fill {
    background: var(--theme-accent);
}
.stat-card--featured::before {
    display: none;
}

/* Green */
.stat-green::before {
    background: linear-gradient(180deg, #1a5c38, #2d9960);
}
.stat-green .stat-card__icon-wrap {
    background: #e0f0e8;
}
.stat-green .stat-card__icon-wrap--white {
    background: rgba(255, 255, 255, 0.18);
}

/* Teal */
.stat-teal::before {
    background: linear-gradient(180deg, #1d9e75, #52c89a);
}
.stat-teal .stat-card__icon-wrap {
    background: #e0f5ec;
}
.stat-teal .stat-card__value {
    color: #0f6e56;
}

/* Amber / Gold */
.stat-amber::before {
    background: linear-gradient(
        180deg,
        var(--theme-accent),
        var(--theme-accent)
    );
}
.stat-amber .stat-card__icon-wrap {
    background: #fdf0dc;
}
.stat-amber .stat-card__value {
    color: #92400e;
}

/* Purple */
.stat-purple::before {
    background: linear-gradient(180deg, #7f77dd, #a59de8);
}
.stat-purple .stat-card__icon-wrap {
    background: #eeeefe;
}
.stat-purple .stat-card__value {
    color: #4c1d95;
}

/* Coral */
.stat-coral::before {
    background: linear-gradient(180deg, #d85a30, #e8795a);
}
.stat-coral .stat-card__icon-wrap {
    background: #fbeae4;
}
.stat-coral .stat-card__value {
    color: #9b2c2c;
}

/* Blue */
.stat-blue::before {
    background: linear-gradient(180deg, #2980b9, #5ba3e8);
}
.stat-blue .stat-card__icon-wrap {
    background: #e3f0fc;
}
.stat-blue .stat-card__value {
    color: #1e3a5f;
}

/* Pink */
.stat-pink::before {
    background: linear-gradient(180deg, #d4537e, #e87aa0);
}
.stat-pink .stat-card__icon-wrap {
    background: #fce8f0;
}
.stat-pink .stat-card__value {
    color: #831843;
}

/* Slate */
.stat-slate::before {
    background: linear-gradient(180deg, #64748b, #94a3b8);
}
.stat-slate .stat-card__icon-wrap {
    background: #f1f5f9;
}
.stat-slate .stat-card__value {
    color: #334155;
}

/* ══ CHART CARDS ═══════════════════════════════════════════ */
.chart-card {
    background: var(--theme-card);
    border: 1px solid rgba(26, 92, 56, 0.1);
    border-radius: 16px;
    padding: 1.4rem 1.5rem;
    height: 100%;
    box-shadow: 0 2px 10px rgba(10, 46, 30, 0.06);
}

.chart-card__header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 0.75rem;
    margin-bottom: 1.25rem;
}

.chart-card__title-wrap {
    display: flex;
    align-items: flex-start;
    gap: 0.75rem;
}

.chart-card__icon {
    font-size: 1.5rem;
    line-height: 1;
    flex-shrink: 0;
    margin-top: 2px;
}

.chart-card__title {
    font-size: 0.9375rem;
    font-weight: 700;
    color: #1c2b24;
    margin: 0 0 3px;
}

.chart-card__subtitle {
    font-size: 0.78rem;
    color: #6b7c74;
    margin: 0;
}

.chart-card__body {
    margin-top: 0.5rem;
}

.chart-legend {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem 0.9rem;
    align-items: center;
}

.legend-item {
    display: flex;
    align-items: center;
    gap: 5px;
    font-size: 0.75rem;
    color: #6b7c74;
    font-weight: 500;
}

.legend-dot {
    width: 8px;
    height: 8px;
    border-radius: 2px;
    flex-shrink: 0;
}

/* Doughnut legend */
.doughnut-legend {
    margin-top: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.doughnut-legend__item {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    font-size: 0.8rem;
}

.doughnut-legend__dot {
    width: 10px;
    height: 10px;
    border-radius: 3px;
    flex-shrink: 0;
}

.doughnut-legend__label {
    flex: 1;
    color: #4b5563;
    font-weight: 500;
}
.doughnut-legend__pct {
    font-weight: 700;
    color: #1c2b24;
    font-size: 0.85rem;
}

/* ══ NOOR AI CHATBOT ═══════════════════════════════════════ */
.chat-fab {
    position: fixed;
    bottom: 28px;
    right: 28px;
    width: 58px;
    height: 58px;
    border-radius: 50%;
    background: linear-gradient(135deg, #1a5c38, #0d3a22);
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 6px 24px rgba(10, 46, 30, 0.45);
    transition:
        transform 0.2s ease,
        box-shadow 0.2s ease;
    z-index: 1050;
}
.chat-fab:hover {
    transform: scale(1.08);
    box-shadow: 0 8px 32px rgba(10, 46, 30, 0.55);
}
.chat-fab--open {
    background: linear-gradient(135deg, #1c2b24, #0a2e1e);
}

.chat-fab__icon {
    position: absolute;
    transition:
        opacity 0.2s,
        transform 0.2s;
}
.chat-fab__icon--closed {
    opacity: 1;
    transform: scale(1) rotate(0deg);
}
.chat-fab__icon--open {
    opacity: 0;
    transform: scale(0.5) rotate(-90deg);
}
.chat-fab--open .chat-fab__icon--closed {
    opacity: 0;
    transform: scale(0.5) rotate(90deg);
}
.chat-fab--open .chat-fab__icon--open {
    opacity: 1;
    transform: scale(1) rotate(0deg);
}

.chat-fab__spinner {
    position: absolute;
    inset: -4px;
    border-radius: 50%;
    border: 2px solid transparent;
    border-top-color: rgba(255, 255, 255, 0.6);
    animation: fabSpin 1s linear infinite;
    pointer-events: none;
}
@keyframes fabSpin {
    to {
        transform: rotate(360deg);
    }
}

.chat-fab__badge {
    position: absolute;
    top: -3px;
    right: -3px;
    min-width: 20px;
    height: 20px;
    border-radius: 10px;
    background: #d85a30;
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    padding: 0 5px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid #fff;
}

.chat-window {
    position: fixed;
    bottom: 100px;
    right: 28px;
    width: 375px;
    height: 555px;
    background: var(--theme-card);
    border-radius: 20px;
    box-shadow:
        0 20px 70px rgba(0, 0, 0, 0.18),
        0 4px 20px rgba(0, 0, 0, 0.08);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    z-index: 1049;
    border: 1px solid rgba(26, 92, 56, 0.12);
}

.chat-slide-enter-active,
.chat-slide-leave-active {
    transition:
        opacity 0.25s ease,
        transform 0.25s ease;
}
.chat-slide-enter-from,
.chat-slide-leave-to {
    opacity: 0;
    transform: translateY(20px) scale(0.96);
}

.chat-header {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 14px 16px;
    flex-shrink: 0;
    background: linear-gradient(135deg, #0d3a22, #1a5c38);
}

.chat-header__avatar {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.15);
    border: 1.5px solid rgba(255, 255, 255, 0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.chat-header__info {
    flex: 1;
    min-width: 0;
}
.chat-header__name {
    font-size: 14px;
    font-weight: 600;
    color: #fff;
}
.chat-header__status {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.75);
    display: flex;
    align-items: center;
    gap: 5px;
    margin-top: 2px;
}
.status-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    flex-shrink: 0;
}
.status-dot--online {
    background: #4ade80;
}
.status-dot--loading {
    background: #fbbf24;
    animation: statusPulse 1.2s ease-in-out infinite;
}
@keyframes statusPulse {
    0%,
    100% {
        opacity: 1;
    }
    50% {
        opacity: 0.3;
    }
}

.chat-header__actions {
    display: flex;
    gap: 5px;
}
.chat-icon-btn {
    width: 30px;
    height: 30px;
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.15);
    border: none;
    cursor: pointer;
    color: rgba(255, 255, 255, 0.9);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.15s;
}
.chat-icon-btn:hover {
    background: rgba(255, 255, 255, 0.28);
}

.chat-error-banner {
    background: #fff5f5;
    border-bottom: 1px solid #fdd;
    color: #933;
    font-size: 12px;
    padding: 10px 16px;
    line-height: 1.5;
    flex-shrink: 0;
}
.chat-error-banner code {
    background: #fde;
    padding: 1px 4px;
    border-radius: 3px;
    font-family: monospace;
}

.chat-welcome-screen {
    flex: 1;
    overflow-y: auto;
    padding: 20px 16px 16px;
}
.chat-welcome {
    text-align: center;
    margin-bottom: 22px;
    padding: 0 8px;
}
.chat-welcome__crescent {
    font-size: 38px;
    margin-bottom: 10px;
    display: block;
}
.chat-welcome__title {
    font-size: 16px;
    font-weight: 600;
    color: #1c2b24;
    margin: 0 0 8px;
}
.chat-welcome__sub {
    font-size: 13px;
    color: #6b7c74;
    margin: 0;
    line-height: 1.55;
}

.suggestions-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
}
.suggestion-chip {
    background: #f0faf5;
    border: 1px solid #b3dfc8;
    border-radius: 10px;
    padding: 10px;
    font-size: 12px;
    color: #0f6e56;
    cursor: pointer;
    text-align: left;
    line-height: 1.4;
    font-family: inherit;
    transition:
        background 0.15s,
        border-color 0.15s,
        transform 0.1s;
}
.suggestion-chip:hover {
    background: #d4f0e3;
    border-color: #1a5c38;
    transform: translateY(-1px);
}

.chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 14px;
    display: flex;
    flex-direction: column;
    gap: 10px;
}
.chat-messages::-webkit-scrollbar {
    width: 3px;
}
.chat-messages::-webkit-scrollbar-thumb {
    background: #e0e0e0;
    border-radius: 3px;
}

.chat-msg {
    display: flex;
    align-items: flex-end;
    gap: 7px;
}
.chat-msg--user {
    flex-direction: row-reverse;
}
.chat-msg__avatar {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: linear-gradient(135deg, #1a5c38, #0d3a22);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.chat-msg__bubble {
    max-width: 80%;
    padding: 10px 13px;
    border-radius: 16px;
    font-size: 13px;
    line-height: 1.55;
    word-break: break-word;
}
.chat-msg--ai .chat-msg__bubble {
    background: #f2f4f3;
    color: #1c2b24;
    border-bottom-left-radius: 4px;
}
.chat-msg--user .chat-msg__bubble {
    background: linear-gradient(135deg, #1a5c38, #0d3a22);
    color: #fff;
    border-bottom-right-radius: 4px;
}
.chat-msg__bubble :deep(strong) {
    font-weight: 600;
}
.chat-msg__bubble :deep(code) {
    background: rgba(0, 0, 0, 0.08);
    padding: 1px 5px;
    border-radius: 4px;
    font-size: 12px;
    font-family: monospace;
}
.chat-msg--user .chat-msg__bubble :deep(code) {
    background: rgba(255, 255, 255, 0.2);
}

.chat-msg__bubble--typing {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 13px 16px;
    min-width: 56px;
}
.chat-msg__bubble--typing span {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #1a5c38;
    animation: typingBounce 1.3s infinite ease-in-out;
}
.chat-msg__bubble--typing span:nth-child(2) {
    animation-delay: 0.18s;
}
.chat-msg__bubble--typing span:nth-child(3) {
    animation-delay: 0.36s;
}
@keyframes typingBounce {
    0%,
    60%,
    100% {
        transform: translateY(0);
        opacity: 0.45;
    }
    30% {
        transform: translateY(-6px);
        opacity: 1;
    }
}

.chat-input-area {
    padding: 11px 13px 10px;
    border-top: 1px solid #f0f0f0;
    flex-shrink: 0;
}
.chat-input-wrap {
    display: flex;
    align-items: flex-end;
    gap: 8px;
    background: #f5f8f6;
    border-radius: 14px;
    padding: 8px 8px 8px 13px;
    border: 1px solid rgba(26, 92, 56, 0.15);
    transition: border-color 0.15s;
}
.chat-input-wrap:focus-within {
    border-color: #1a5c38;
}
.chat-input-wrap--disabled {
    opacity: 0.6;
}
.chat-input {
    flex: 1;
    background: transparent;
    border: none;
    outline: none;
    font-size: 13px;
    color: #1c2b24;
    resize: none;
    line-height: 1.5;
    max-height: 120px;
    min-height: 22px;
    font-family: inherit;
}
.chat-input::placeholder {
    color: #b0bcb8;
}
.chat-input:disabled {
    cursor: not-allowed;
}
.chat-send-btn {
    width: 34px;
    height: 34px;
    border-radius: 10px;
    flex-shrink: 0;
    background: linear-gradient(135deg, #1a5c38, #0d3a22);
    border: none;
    cursor: pointer;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    transition:
        opacity 0.15s,
        transform 0.15s;
}
.chat-send-btn:hover:not(:disabled) {
    transform: scale(1.07);
}
.chat-send-btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
}
.chat-powered {
    font-size: 10px;
    color: #c0c0c0;
    text-align: center;
    margin: 6px 0 0;
    letter-spacing: 0.2px;
}
</style>
