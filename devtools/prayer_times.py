import re
import json
import time
import requests
import itertools
import os
import sys

from bs4 import BeautifulSoup
from html import unescape

Countries_map = {
    "India": "IN",
    "Afghanistan": "AF",
    "Bangladesh": "BD",
    "Maldives": "MV",
    "Nepal": "NP",
    "Pakistan": "PK",
    "Sri-Lanka": "LK",
    "Brunei": "BN",
    "Cambodia": "KH",
    "Indonesia": "ID",
    "Malaysia": "MY",
    "Myanmar": "MM",
    "Philippines": "PH",
    "Singapore": "SG",
    "Thailand": "TH",
    "Vietnam": "VN",
    "Azerbaijan": "AZ",
    "Kazakhstan": "KZ",
    "Kyrgyzstan": "KG",
    "Tajikistan": "TJ",
    "Turkmenistan": "TM",
    "Uzbekistan": "UZ",
    "Bahrain": "BH",
    "Iran": "IR",
    "Iraq": "IQ",
    "Israel": "IL",
    "Jordan": "JO",
    "Kuwait": "KW",
    "Lebanon": "LB",
    "Oman": "OM",
    "Palestine": "PS",
    "Qatar": "QA",
    "Saudi-Arabia": "SA",
    "Syria": "SY",
    "Turkey": "TR",
    "United-Arab-Emirates": "AE",
    "Yemen": "YE",
    "Algeria": "DZ",
    "Egypt": "EG",
    "Libya": "LY",
    "Morocco": "MA",
    "Sudan": "SD",
    "Tunisia": "TN",
    "Burkina-Faso": "BF",
    "Gambia": "GM",
    "Ghana": "GH",
    "Guinea": "GN",
    "Guinea-Bissau": "GW",
    "Ivory-Coast": "CI",
    "Mali": "ML",
    "Mauritania": "MR",
    "Niger": "NE",
    "Nigeria": "NG",
    "Senegal": "SN",
    "Sierra-Leone": "SL",
    "Togo": "TG",
    "Burundi": "BI",
    "Cameroon": "CM",
    "Chad": "TD",
    "Comoros": "KM",
    "Djibouti": "DJ",
    "Eritrea": "ER",
    "Ethiopia": "ET",
    "Kenya": "KE",
    "Somalia": "SO",
    "South-Sudan": "SS",
    "Tanzania": "TZ",
    "Uganda": "UG",
    "Malawi": "MW",
    "Mozambique": "MZ",
    "South-Africa": "ZA",
    "Zambia": "ZM",
    "Zimbabwe": "ZW",
    "Albania": "AL",
    "Austria": "AT",
    "Belgium": "BE",
    "Bosnia-and-Herzegovina": "BA",
    "Bulgaria": "BG",
    "Croatia": "HR",
    "Cyprus": "CY",
    "Czech-Republic": "CZ",
    "Denmark": "DK",
    "Finland": "FI",
    "France": "FR",
    "Germany": "DE",
    "Greece": "GR",
    "Hungary": "HU",
    "Ireland": "IE",
    "Italy": "IT",
    "Kosovo": "XK",
    "Luxembourg": "LU",
    "Macedonia": "MK",
    "Montenegro": "ME",
    "Netherlands": "NL",
    "Norway": "NO",
    "Poland": "PL",
    "Portugal": "PT",
    "Romania": "RO",
    "Russia": "RU",
    "Serbia": "RS",
    "Slovakia": "SK",
    "Slovenia": "SI",
    "Spain": "ES",
    "Sweden": "SE",
    "Switzerland": "CH",
    "Ukraine": "UA",
    "United-Kingdom": "GB",
    "Canada": "CA",
    "Mexico": "MX",
    "United-States": "US",
    "Costa-Rica": "CR",
    "Cuba": "CU",
    "Dominican-Republic": "DO",
    "Guatemala": "GT",
    "Haiti": "HT",
    "Honduras": "HN",
    "Jamaica": "JM",
    "Panama": "PA",
    "Trinidad-and-Tobago": "TT",
    "Argentina": "AR",
    "Bolivia": "BO",
    "Brazil": "BR",
    "Chile": "CL",
    "Colombia": "CO",
    "Ecuador": "EC",
    "Guyana": "GY",
    "Paraguay": "PY",
    "Peru": "PE",
    "Suriname": "SR",
    "Uruguay": "UY",
    "Venezuela": "VE",
    "China": "CN",
    "Hong-Kong": "HK",
    "Japan": "JP",
    "Macao": "MO",
    "Mongolia": "MN",
    "South-Korea": "KR",
    "Taiwan": "TW",
    "Australia": "AU",
    "Fiji": "FJ",
    "New-Zealand": "NZ",
}

MONTHS = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
]

BASE_URL = "https://www.dawateislami.net/prayer-times"
BASE_HEADERS = {
    "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36",
    "x-requested-with": "XMLHttpRequest",
}

STATE_FILE = "scrape_state.json"
OUTPUT_FILE = "all_prayers.json"


def normalize_country_or_city(value: str) -> str:
    normed = re.sub(r"[-,\s]+", "-", value.strip().lower()).strip("-")
    return normed.replace("'", '')

def save_state(state):
    tmp = STATE_FILE + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2)
    os.replace(tmp, STATE_FILE)

def load_state():
    if not os.path.exists(STATE_FILE):
        return {
            "country_index": 0,
            "city_index": 0,
            "month_index": 0,
            "data": [],
        }

    with open(STATE_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def save_output(data):
    tmp = OUTPUT_FILE + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    os.replace(tmp, OUTPUT_FILE)

def get_all_cities(country: str):
    all_cities = []

    print(f"Finding Cities for country {country}")

    for page in itertools.count(1):
        print(f"Fetching Page {page}")

        response = requests.get(
            f"{BASE_URL}/world/{normalize_country_or_city(country).capitalize()}",
            params={"pn": page, "ajax": True},
            headers=BASE_HEADERS,
            timeout=30,
        )

        response.raise_for_status()

        for city in re.findall(
            r'<a[^>]+city[^>]+href="[^"]+"(?:[^>]+)?>\s*([A-Za-z1-9-\s,()&#;\']+)(?:[^<]+)?<',
            response.text,
        ):
            city = unescape(city)
            if city:
                if '(' in city:
                    city = city.replace('(', '-')
                    city = city.replace(')', '')
                all_cities.append(city.strip().capitalize())

        total_pages = re.search(
            r'<[^>]+dataTables_info[^>]+>\s*\d{1,2}\s*\w+\s*(\d{1,2})(?:[^<]+)?<',
            response.text,
        )

        if not total_pages:
            break

        total_pages = int(total_pages.group(1))

        if page == total_pages:
            break

    print(f"Total Cities Found for {country}: {len(all_cities)}")
    return all_cities

def parse_prayer_table(html: str, month: int, country: str, city: str):
    header_map = {
        "Fajr": "fajr",
        "Sunrise": "sunrise",
        "Dahwa-e-Kubra": "dahwa_e_kubra",
        "Zuhr": "zuhr",
        "Asr(Hanafi)": "asr",
        "Maghrib": "maghrib",
        "Isha(Hanafi)": "isha",
    }

    soup = BeautifulSoup(html, "html.parser")
    table = soup.find("table")

    if not table:
        print(f"Prayer table not found: {country} / {city} / {month}")
        return []

    headers = [th.get_text(" ", strip=True) for th in table.select("thead th")]
    rows = []

    for tr in table.select("tbody tr"):
        cells = [td.get_text(" ", strip=True) for td in tr.select("td")]

        if len(cells) != len(headers):
            continue

        row = dict(zip(headers, cells))
        day = int(row[headers[0]])

        result = {"date": f"{month:02d}-{day:02d}"}

        for source_name, internal_name in header_map.items():
            result[internal_name] = row.get(source_name) #type: ignore

        rows.append(result)

    return rows

def get_month_count(month: str) -> int:
    return MONTHS.index(month) + 1

class RetryLimitReached(Exception):
    pass

def fetch_month_prayer(
    country_code: str,
    city: str,
    month: str,
    tried=1,
    use_proxy=False,
):
    url = (
        f"{BASE_URL}/share/{country_code}/"
        f"{normalize_country_or_city(city)}"
        f"?ajax=true&month={month}&year=2026"
    )

    proxies = {
        "http": "http://pdlwwwks-rotate:yiusdjeifdky@p.webshare.io:80",
        "https": "http://pdlwwwks-rotate:yiusdjeifdky@p.webshare.io:80",
    }

    try:
        response = requests.get(
            url,
            headers=BASE_HEADERS,
            proxies=proxies if use_proxy else None,
            timeout=30,
        )
    except requests.RequestException as e:
        print(f"Request error {tried}/10: {e}")

        if tried >= 10:
            raise RetryLimitReached(
                f"10 retries reached: {country_code} / {city} / {month}"
            )

        if tried >= 8 and not use_proxy:
            print("Sleeping for 60 seconds")
            time.sleep(60)
            return fetch_month_prayer(
                country_code,
                city,
                month,
                tried + 1,
                True,
            )

        time.sleep(3)

        return fetch_month_prayer(
            country_code,
            city,
            month,
            tried + 1,
            use_proxy,
        )

    if "ajax" not in response.url:
        print(f"Retrying {tried}/10")

        if tried >= 10:
            raise RetryLimitReached(
                f"10 retries reached: {country_code} / {city} / {month}"
            )

        if tried >= 8 and not use_proxy:
            print("Sleeping for 60 seconds")
            time.sleep(60)

            return fetch_month_prayer(
                country_code,
                city,
                month,
                tried + 1,
                True,
            )

        time.sleep(3)

        return fetch_month_prayer(
            country_code,
            city,
            month,
            tried + 1,
            use_proxy,
        )

    return parse_prayer_table(
        response.text,
        get_month_count(month),
        country_code,
        city,
    )


def get_all_prayers():
    state = load_state()
    data = state.get("data", [])

    countries = list(Countries_map.keys())

    for country_index in range(state["country_index"], len(countries)):
        country = countries[country_index]
        cities = get_all_cities(country)

        city_start = state["city_index"] if country_index == state["country_index"] else 0

        for city_index in range(city_start, len(cities)):
            city = cities[city_index]
            if 'vadodara' in city.lower():
                city = 'vadodara-gujarat'
            elif 'iganga' in city.lower():
                city = 'iganga-1'

            month_start = (
                state["month_index"]
                if country_index == state["country_index"]
                and city_index == state["city_index"]
                else 0
            )

            print(f"\nFinding Prayer Times for {city}, {country}")

            country_data = next(
                (
                    item[country]
                    for item in data
                    if country in item
                ),
                None,
            )

            if country_data is None:
                country_data = {}
                data.append({country: country_data})

            city_data = country_data.setdefault(city, [])

            for month_index in range(month_start, len(MONTHS)):
                month = MONTHS[month_index]

                print(
                    f"Scraping {country} / {city} / "
                    f"{month} ({month_index + 1}/12)"
                )

                try:
                    prayers = fetch_month_prayer(
                        Countries_map[country],
                        city,
                        month,
                    )

                except RetryLimitReached as e:
                    print(f"\nFAILED: {e}")
                    print("Saving checkpoint...")
                    
                    state.update({
                        "country_index": country_index,
                        "city_index": city_index,
                        "month_index": month_index,
                        "data": data,
                    })

                    save_output(data)
                    save_state(state)

                    print(
                        f"Checkpoint saved: "
                        f"{country} / {city} / {month}"
                    )

                    print("Restarting...\n")

                    os.execv(sys.executable, [sys.executable] + sys.argv)

                city_data.extend(prayers)

                state.update({
                    "country_index": country_index,
                    "city_index": city_index,
                    "month_index": month_index + 1,
                    "data": data,
                })

                save_output(data)
                save_state(state)

                print(f"Saved: {country} / {city} / {month}")

            state["month_index"] = 0
            state["city_index"] = city_index + 1
            save_state(state)

        state["city_index"] = 0
        state["country_index"] = country_index + 1
        save_state(state)

    print(f"Completed. Dumped in {OUTPUT_FILE}")

    if os.path.exists(STATE_FILE):
        os.remove(STATE_FILE)

    return True


if __name__ == "__main__":
    get_all_prayers()