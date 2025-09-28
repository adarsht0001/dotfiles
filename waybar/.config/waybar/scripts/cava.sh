#!/bin/bash
bar="⣀⣄⣤⣦⣶⣷⣿"
dict="s/;//g;"

# creating "dictionary" to replace char with bar
i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i=i+1))
done

# Configuration
total_bars=10
bars_per_side=$((total_bars / 2))

# write cava config
config_file="/tmp/cava_config"
echo "
[general]
bars = $total_bars
framerate = 12
sleep_timer = 1
[input]
method = pulse
source = auto
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 6
[smoothing]
monstercat = 1
waves = 1
gravity = 100
ignore = 0
" > $config_file

# function to escape JSON strings
escape_json() {
    local str="$1"
    # First decode HTML entities to regular chars
    str="${str//&quot;/}"     # Remove quotes entirely
    str="${str//&#39;/}"      # Remove apostrophes entirely
    str="${str//&amp;/&}"
    str="${str//&lt;/<}"
    str="${str//&gt;/>}"

    # Remove any remaining quotes
    str="${str//\"/}"         # Remove all remaining quotes

    # Then escape for JSON (backslashes and control chars)
    str="${str//\\/\\\\}"     # \ -> \\
    str="${str//$'\b'/\\b}"   # backspace
    str="${str//$'\f'/\\f}"   # form feed
    str="${str//$'\n'/\\n}"   # newline
    str="${str//$'\r'/\\r}"   # carriage return
    str="${str//$'\t'/\\t}"   # tab
    echo "$str"
}
# function  to check player status
check_player_status() {
  if playerctl status >/dev/null 2>&1; then
    if [ -n "$playerctl metadata title" ]; then
      return 0    # success — player is running and we have a title
    fi
  fi

  return 1        # failure — no player / no title
}

# function to get player tooltip info
get_player_tooltip() {
    local player_name=$(playerctl metadata --player="%any" --format "{{playerName}}" 2>/dev/null)
    local artist=$(playerctl metadata --player="%any" --format "{{artist}}" 2>/dev/null)
    local title=$(playerctl metadata --player="%any" --format "{{markup_escape(title)}}" 2>/dev/null)
    local album=$(playerctl metadata --player="%any" --format "{{album}}" 2>/dev/null)
    local status=$(playerctl status 2>/dev/null)
    local position=$(playerctl metadata --player="%any" --format "{{duration(position)}}" 2>/dev/null)
    local length=$(playerctl metadata --player="%any" --format "{{duration(mpris:length)}}" 2>/dev/null)

    # Build detailed tooltip
    local tooltip="🎵 Audio Visualizer\\n"
    if [ -n "$player_name" ]; then
        tooltip+="🎧 Player: $(escape_json "$player_name")\\n"
    fi
    if [ -n "$artist" ]; then
        tooltip+="🎨 Artist: $(escape_json "$artist")\\n"
    fi
    if [ -n "$title" ]; then
        tooltip+="🎤 Title: $(escape_json "$title")\\n"
    fi
    if [ -n "$album" ]; then
        tooltip+="💿 Album: $(escape_json "$album")\\n"
    fi
    if [ -n "$status" ]; then
        tooltip+="⏯️ Status: $(escape_json "$status")\\n"
    fi
    if [ -n "$position" ] && [ -n "$length" ]; then
        tooltip+="⏱️ Position: $position / $length"
    fi

    echo "$tooltip"
}

# player display info
get_player_info(){
    local artist=$(playerctl metadata --player="%any" --format "{{artist}}" 2>/dev/null | head -c 50)
    local title=$(playerctl metadata --player="%any" --format "{{title}}" 2>/dev/null | head -c 50)

    if [ -n "$artist" ] && [ -n "$title" ]; then
        local display_text="$title - $artist"
        if [ ${#display_text} -gt 25 ]; then
            display_text="${display_text:0:22}..."
        fi
        echo "$display_text"
    else
        echo "♪"
    fi
}

# read stdout from cava
cava -p $config_file | while read -r line; do
	# Convert numbers to bars
    processed=$(echo $line | sed $dict)
    # Split and display
    left_side=${processed:0:$bars_per_side}
    right_side=${processed:$bars_per_side:$bars_per_side}

	tooltip=$(get_player_tooltip)
	player_info=$(get_player_info)

    # Output JSON format
    display_text="♪ ${left_side} ${player_info} ${right_side} ♪"
    escaped_display_text=$(escape_json "$display_text")

    if check_player_status; then
        echo "{\"text\": \"$escaped_display_text\", \"tooltip\": \"$tooltip\"}"
    else
        echo ""
    fi
done
