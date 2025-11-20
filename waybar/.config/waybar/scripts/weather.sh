#!/bin/bash

CACHE_FILE="$HOME/.cache/weather.json"
CACHE_DURATION=$((2 * 3600 + 30 * 60)) # 2 hours 30 minutes in seconds

# --- Check if cache exists and is fresh ---
if [[ -f "$CACHE_FILE" ]]; then
  now=$(date +%s)
  mtime=$(stat -c %Y "$CACHE_FILE")
  age=$((now - mtime))
  if ((age < CACHE_DURATION)); then
    weather_json=$(cat "$CACHE_FILE")
  fi
fi

# Function to get icon from weather code
# https://github.com/open-meteo/open-meteo/issues/789 # Weather codes reference in the discussions

get_weather_icon() {
  case $1 in
  0) echo "☀️" ;;
  1) echo "🌤️" ;;
  2) echo "⛅️" ;;
  3) echo "☁️" ;;
  45 | 48) echo "🌫️" ;;
  51 | 53 | 55 | 80) echo "🌦️" ;;
  56 | 57) echo "🌧️" ;;
  61 | 63 | 81) echo "🌦️" ;;
  65 | 82) echo "🌧️" ;;
  66 | 67 | 71 | 73 | 75 | 77 | 85 | 86) echo "🌨️" ;;
  95 | 96 | 99) echo "⛈️" ;;
  *) echo "❓" ;;
  esac
}

# Function to get text description from weather code
get_weather_text() {
  case $1 in
  0) echo "Clear Sky" ;;
  1) echo "Mostly Clear" ;;
  2) echo "Partly Cloudy" ;;
  3) echo "Overcast" ;;
  45 | 48) echo "Fog" ;;
  51 | 53 | 55 | 80) echo "Drizzle" ;;
  56 | 57) echo "Freezing Drizzle" ;;
  61 | 63 | 81) echo "Rain" ;;
  65 | 82) echo "Heavy Rain" ;;
  66 | 67 | 71 | 73 | 75 | 77 | 85 | 86) echo "Snow" ;;
  95 | 96 | 99) echo "Thunderstorm" ;;
  *) echo "Unknown" ;;
  esac
}
# --- If no fresh cache, fetch new data ---
if [[ -z "$weather_json" ]]; then
  # Get public IP location
  info=$(curl -s "https://ipinfo.io/")

  # Extract latitude and longitude from IP info
  latitude=$(echo $info | jq -r '.loc | split(",")[0]')
  longitude=$(echo $info | jq -r '.loc | split(",")[1]')

  # get weather data
  weather_json=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather")
  # Save to cache
  mkdir -p "$(dirname "$CACHE_FILE")"
  echo "$weather_json" >"$CACHE_FILE"
fi
# Extract data
weather_code=$(echo "$weather_json" | jq -r '.current_weather.weathercode')
temperature=$(echo "$weather_json" | jq -r '.current_weather.temperature')
# Get icon and text separately
icon=$(get_weather_icon "$weather_code")
text=$(get_weather_text "$weather_code")

# Output JSON for Waybar
echo "{\"text\": \"$icon $temperature°C\", \"tooltip\": \"$text\"}"
