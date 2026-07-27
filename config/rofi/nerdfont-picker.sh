#!/usr/bin/env bash
# Nerd Font Icon Picker for Rofi
# Searches nerd font icons and copies the selected one to clipboard

ICON_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-nerdfont-icons.txt"
ICON_URL="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/css/nerd-fonts-generated.css"

# Download and parse icons if cache doesn't exist or is older than 30 days
if [[ ! -f "$ICON_FILE" ]] || [[ $(find "$ICON_FILE" -mtime +30 -print) ]]; then
    # Download the CSS and extract icon names + codepoints
    css_content=$(curl -sf "$ICON_URL")
    if [[ -z "$css_content" ]]; then
        notify-send "Nerd Font Picker" "Failed to download icon list" -u critical
        exit 1
    fi

    # Parse CSS: extract .nf-NAME:before { content: "\XXXX" } patterns
    echo "$css_content" | \
        grep -oP '\.nf-\K[^:]+(?=:before)' > /tmp/nf_names.txt
    echo "$css_content" | \
        grep -oP 'content:\s*"\\?\K[0-9a-fA-F]+' > /tmp/nf_codes.txt

    # Combine into "icon name" format
    paste -d' ' /tmp/nf_codes.txt /tmp/nf_names.txt | \
        while read -r code name; do
            # Convert hex codepoint to unicode character
            printf "%b %s\n" "\\U$code" "$name"
        done > "$ICON_FILE"

    rm -f /tmp/nf_names.txt /tmp/nf_codes.txt
fi

# Show rofi picker
selected=$(rofi -dmenu \
    -i \
    -p "Nerd Font" \
    -theme-str 'entry { placeholder: "Search icons..."; }' \
    -theme-str 'listview { lines: 12; }' \
    -theme-str 'window { width: 600px; }' \
    < "$ICON_FILE")

# Exit if nothing selected
[[ -z "$selected" ]] && exit 0

# Extract just the icon character (first character — a single unicode glyph)
icon=$(echo "$selected" | cut -c1)

# Copy to clipboard
if command -v wl-copy &>/dev/null; then
    wl-copy -- "$icon"
elif command -v xclip &>/dev/null; then
    printf "%s" "$icon" | xclip -selection clipboard
elif command -v xsel &>/dev/null; then
    printf "%s" "$icon" | xsel --clipboard --input
else
    notify-send "Nerd Font Picker" "No clipboard tool found (need wl-copy, xclip, or xsel)" -u critical
    exit 1
fi

notify-send "Nerd Font Picker" "Copied: $icon" -t 2000
