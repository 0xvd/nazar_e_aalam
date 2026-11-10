import math

CITIES: dict[str, dict] = {
    "nadiad": {"name": "Nadiad", "lat": 22.6939, "lon": 72.8616, "tz": "Asia/Kolkata"},
    "ahmedabad": {
        "name": "Ahmedabad",
        "lat": 23.0225,
        "lon": 72.5714,
        "tz": "Asia/Kolkata",
    },
    "surat": {"name": "Surat", "lat": 21.1702, "lon": 72.8311, "tz": "Asia/Kolkata"},
    "vadodara": {
        "name": "Vadodara",
        "lat": 22.3072,
        "lon": 73.1812,
        "tz": "Asia/Kolkata",
    },
    "rajkot": {"name": "Rajkot", "lat": 22.3039, "lon": 70.8022, "tz": "Asia/Kolkata"},
    "bhavnagar": {
        "name": "Bhavnagar",
        "lat": 21.7645,
        "lon": 72.1519,
        "tz": "Asia/Kolkata",
    },
    "jamnagar": {
        "name": "Jamnagar",
        "lat": 22.4707,
        "lon": 70.0577,
        "tz": "Asia/Kolkata",
    },
    "gandhinagar": {
        "name": "Gandhinagar",
        "lat": 23.2156,
        "lon": 72.6369,
        "tz": "Asia/Kolkata",
    },
    "junagadh": {
        "name": "Junagadh",
        "lat": 21.5222,
        "lon": 70.4579,
        "tz": "Asia/Kolkata",
    },
    "anand": {"name": "Anand", "lat": 22.5645, "lon": 72.9289, "tz": "Asia/Kolkata"},
    "mumbai": {"name": "Mumbai", "lat": 19.0760, "lon": 72.8777, "tz": "Asia/Kolkata"},
    "delhi": {"name": "Delhi", "lat": 28.6139, "lon": 77.2090, "tz": "Asia/Kolkata"},
    "bangalore": {
        "name": "Bangalore",
        "lat": 12.9716,
        "lon": 77.5946,
        "tz": "Asia/Kolkata",
    },
    "hyderabad": {
        "name": "Hyderabad",
        "lat": 17.3850,
        "lon": 78.4867,
        "tz": "Asia/Kolkata",
    },
    "chennai": {
        "name": "Chennai",
        "lat": 13.0827,
        "lon": 80.2707,
        "tz": "Asia/Kolkata",
    },
    "london": {"name": "London", "lat": 51.5074, "lon": -0.1278, "tz": "Europe/London"},
    "birmingham": {
        "name": "Birmingham",
        "lat": 52.4862,
        "lon": -1.8904,
        "tz": "Europe/London",
    },
    "manchester": {
        "name": "Manchester",
        "lat": 53.4808,
        "lon": -2.2426,
        "tz": "Europe/London",
    },
    "bradford": {
        "name": "Bradford",
        "lat": 53.7960,
        "lon": -1.7594,
        "tz": "Europe/London",
    },
    "leicester": {
        "name": "Leicester",
        "lat": 52.6369,
        "lon": -1.1398,
        "tz": "Europe/London",
    },
    "glasgow": {
        "name": "Glasgow",
        "lat": 55.8642,
        "lon": -4.2518,
        "tz": "Europe/London",
    },
    "leeds": {"name": "Leeds", "lat": 53.8008, "lon": -1.5491, "tz": "Europe/London"},
    "liverpool": {
        "name": "Liverpool",
        "lat": 53.4084,
        "lon": -2.9916,
        "tz": "Europe/London",
    },
    "bristol": {
        "name": "Bristol",
        "lat": 51.4545,
        "lon": -2.5879,
        "tz": "Europe/London",
    },
    "edinburgh": {
        "name": "Edinburgh",
        "lat": 55.9533,
        "lon": -3.1883,
        "tz": "Europe/London",
    },
    "toronto": {
        "name": "Toronto",
        "lat": 43.6532,
        "lon": -79.3832,
        "tz": "America/Toronto",
    },
    "montreal": {
        "name": "Montreal",
        "lat": 45.5017,
        "lon": -73.5673,
        "tz": "America/Toronto",
    },
    "ottawa": {
        "name": "Ottawa",
        "lat": 45.4215,
        "lon": -75.6972,
        "tz": "America/Toronto",
    },
    "mississauga": {
        "name": "Mississauga",
        "lat": 43.5890,
        "lon": -79.6441,
        "tz": "America/Toronto",
    },
    "vancouver": {
        "name": "Vancouver",
        "lat": 49.2827,
        "lon": -123.1207,
        "tz": "America/Vancouver",
    },
    "calgary": {
        "name": "Calgary",
        "lat": 51.0447,
        "lon": -114.0719,
        "tz": "America/Edmonton",
    },
    "edmonton": {
        "name": "Edmonton",
        "lat": 53.5461,
        "lon": -113.4938,
        "tz": "America/Edmonton",
    },
    "winnipeg": {
        "name": "Winnipeg",
        "lat": 49.8951,
        "lon": -97.1384,
        "tz": "America/Winnipeg",
    },
    "berlin": {"name": "Berlin", "lat": 52.5200, "lon": 13.4050, "tz": "Europe/Berlin"},
    "munich": {"name": "Munich", "lat": 48.1351, "lon": 11.5820, "tz": "Europe/Berlin"},
    "frankfurt": {
        "name": "Frankfurt",
        "lat": 50.1109,
        "lon": 8.6821,
        "tz": "Europe/Berlin",
    },
    "hamburg": {
        "name": "Hamburg",
        "lat": 53.5511,
        "lon": 9.9937,
        "tz": "Europe/Berlin",
    },
    "cologne": {
        "name": "Cologne",
        "lat": 50.9375,
        "lon": 6.9603,
        "tz": "Europe/Berlin",
    },
    "stuttgart": {
        "name": "Stuttgart",
        "lat": 48.7758,
        "lon": 9.1829,
        "tz": "Europe/Berlin",
    },
    "dusseldorf": {
        "name": "Düsseldorf",
        "lat": 51.2277,
        "lon": 6.7735,
        "tz": "Europe/Berlin",
    },
    "dortmund": {
        "name": "Dortmund",
        "lat": 51.5136,
        "lon": 7.4653,
        "tz": "Europe/Berlin",
    },
}


def get(city_key: str) -> dict | None:
    return CITIES.get(city_key.strip().lower())


def all_keys() -> list[str]:
    return list(CITIES)


def nearest(lat: float, lon: float) -> tuple[str, float] | None:
    """
    Return (city_key, distance_km) of the closest curated city.
    Returns None if the CITIES dict is empty.
    """
    if not CITIES:
        return None

    def dist(la1, lo1, la2, lo2):

        R = 6371.0
        dlat = math.radians(la2 - la1)
        dlon = math.radians(lo2 - lo1)
        a = (
            math.sin(dlat / 2) ** 2
            + math.cos(math.radians(la1))
            * math.cos(math.radians(la2))
            * math.sin(dlon / 2) ** 2
        )
        return R * 2 * math.asin(math.sqrt(a))

    best_key, best_d = None, float("inf")
    for key, info in CITIES.items():
        d = dist(lat, lon, info["lat"], info["lon"])
        if d < best_d:
            best_d = d
            best_key = key
    return (best_key, best_d) if best_key else None
