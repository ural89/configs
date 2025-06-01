#!/bin/bash

# --- Configuration ---
DEFAULT_MAIN_LANG="en"
DEFAULT_OTHER_LANG="auto"
DEFAULT_WRAP_LEN=70 # Wrap length for display in Rofi's message area
USER_AGENT="Mozilla/5.0 (Android 9; Mobile; rv:67.0.3) Gecko/67.0.3 Firefox/67.0.3"
BASE_URL="http://translate.google.com/m"

# --- Check Core Dependencies ---
if ! command -v rofi &> /dev/null; then echo "Error: rofi is not installed." >&2; exit 1; fi
if ! command -v curl &> /dev/null; then echo "Error: curl is not installed." >&2; exit 1; fi
if ! command -v fold &> /dev/null; then echo "Error: fold is not installed." >&2; exit 1; fi
if ! command -v xclip &> /dev/null; then echo "Error: xclip is not installed. Cannot copy to clipboard." >&2; exit 1; fi
if ! command -v notify-send &> /dev/null; then echo "Error: notify-send is not installed. Cannot show notifications." >&2; exit 1; fi


URL_ENCODER_CMD=""
if command -v jq &> /dev/null; then
    URL_ENCODER_CMD="jq -sRr @uri"
elif command -v perl &> /dev/null; then
    if perl -MURI::Escape -e "exit 0" &>/dev/null; then
        URL_ENCODER_CMD="perl -MURI::Escape -ne 'chomp; print uri_escape(\$_)'"
    else
        echo "Perl is found, but URI::Escape module is missing or problematic. Trying to continue without robust URL encoding if jq also missing." >&2
    fi
fi

if [[ -z "$URL_ENCODER_CMD" ]]; then
    rofi -e "Error: Neither jq nor a working Perl with URI::Escape is available for URL encoding. Please install one of them."
    exit 1
fi

# --- Get User Input via Rofi (Step 1) ---
USER_INPUT=$(echo "" | rofi -dmenu -p "Translate (e.g., :en text or fr:en text)")

if [[ -z "$USER_INPUT" ]]; then
    exit 0
fi

QUERY_TEXT_FULL=$(echo "$USER_INPUT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [[ -z "$QUERY_TEXT_FULL" ]]; then
    rofi -e "No input provided."
    exit 0
fi

# --- Parse Language Codes and Text ---
MAIN_LANG="${TRANSLATE_MAIN_LANG:-$DEFAULT_MAIN_LANG}"
OTHER_LANG="${TRANSLATE_OTHER_LANG:-$DEFAULT_OTHER_LANG}"
WRAP_LEN="${TRANSLATE_WRAP_LEN:-$DEFAULT_WRAP_LEN}"

FROM_LANG="$OTHER_LANG"
TO_LANG="$MAIN_LANG"
TEXT_TO_TRANSLATE="$QUERY_TEXT_FULL"

if [[ "${QUERY_TEXT_FULL:0:1}" == ":" && ${#QUERY_TEXT_FULL} -gt 2 ]]; then
    TO_LANG="${QUERY_TEXT_FULL:1:2}"
    FROM_LANG="auto"
    TEXT_TO_TRANSLATE="${QUERY_TEXT_FULL:3}"
elif [[ "${QUERY_TEXT_FULL:2:1}" == ":" && ${#QUERY_TEXT_FULL} -gt 4 ]]; then
    FROM_LANG="${QUERY_TEXT_FULL:0:2}"
    TO_LANG="${QUERY_TEXT_FULL:3:2}"
    TEXT_TO_TRANSLATE="${QUERY_TEXT_FULL:5}"
fi

TEXT_TO_TRANSLATE=$(echo "$TEXT_TO_TRANSLATE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [[ -z "$TEXT_TO_TRANSLATE" ]]; then
    rofi -e "No actual text found to translate after parsing."
    exit 0
fi

# --- URL Encode Text ---
ENCODED_TEXT=$(echo -n "$TEXT_TO_TRANSLATE" | eval "$URL_ENCODER_CMD")

if [[ -n "$TEXT_TO_TRANSLATE" && -z "$ENCODED_TEXT" ]]; then
    rofi -e "URL encoding failed. Ensure Perl or JQ is working correctly."
    exit 1
fi

# --- Perform Translation ---
REQUEST_URL="${BASE_URL}?tl=${TO_LANG}&sl=${FROM_LANG}&q=${ENCODED_TEXT}"
RAW_HTML_RESPONSE=$(curl -s -L -A "$USER_AGENT" "$REQUEST_URL")

if [[ -z "$RAW_HTML_RESPONSE" ]]; then
    rofi -e "Failed to fetch translation. Check internet or API."
    exit 1
fi

# --- Extract Translation from HTML ---
EXTRACTED_TRANSLATION=$(echo "$RAW_HTML_RESPONSE" | grep -oP 'class="result-container">\K[^<]*')
if [[ -z "$EXTRACTED_TRANSLATION" ]]; then
    EXTRACTED_TRANSLATION=$(echo "$RAW_HTML_RESPONSE" | sed -n 's/.*class="result-container">\([^<]*\)<.*/\1/p')
fi

# --- HTML Unescape Result ---
UNESCAPED_TEXT=""
if [[ -n "$EXTRACTED_TRANSLATION" ]]; then
    UNESCAPED_TEXT=$(echo "$EXTRACTED_TRANSLATION" | sed \
        -e 's/&amp;/\&/g' -e 's/&lt;/</g' -e 's/&gt;/>/g' \
        -e 's/&quot;/"/g' -e 's/&#39;/'"'"'/g' -e 's/&apos;/'"'"'/g' \
        -e 's/&nbsp;/ /g')
fi

# --- Display Result in Rofi (Step 2) and Handle Action ---
if [[ -n "$UNESCAPED_TEXT" ]]; then
    DISPLAY_INPUT_SNIPPET="$QUERY_TEXT_FULL"
    MAX_LEN_INPUT_SNIPPET=70
    if ((${#DISPLAY_INPUT_SNIPPET} > MAX_LEN_INPUT_SNIPPET)); then
        DISPLAY_INPUT_SNIPPET="${DISPLAY_INPUT_SNIPPET:0:$MAX_LEN_INPUT_SNIPPET}..."
    fi

    WRAPPED_TRANSLATION_FOR_DISPLAY=$(echo "$UNESCAPED_TEXT" | fold -s -w "$WRAP_LEN")

    # Use printf to build the ROFI_MESSAGE with actual newlines
    ROFI_MESSAGE=$(printf "Original Input: %s\nDetected Languages: %s ➤ %s\n\nTranslation:\n%s" \
                            "$DISPLAY_INPUT_SNIPPET" \
                            "$FROM_LANG" \
                            "$TO_LANG" \
                            "$WRAPPED_TRANSLATION_FOR_DISPLAY")
    
    ROFI_OPTIONS="Copy translation\nClose"
    USER_CHOICE=$(echo -e "$ROFI_OPTIONS" | rofi -dmenu -p "Translation Result" -mesg "$ROFI_MESSAGE")

    if [[ "$USER_CHOICE" == "Copy translation" ]]; then
        echo -n "$UNESCAPED_TEXT" | wl-copy
        notify-send "Translator" "Translation copied to clipboard." -a "Rofi Translate" -i "edit-copy"
    fi
else
    DISPLAY_INPUT_SNIPPET="$QUERY_TEXT_FULL"
    MAX_LEN_INPUT_SNIPPET=70
     if ((${#DISPLAY_INPUT_SNIPPET} > MAX_LEN_INPUT_SNIPPET)); then
        DISPLAY_INPUT_SNIPPET="${DISPLAY_INPUT_SNIPPET:0:$MAX_LEN_INPUT_SNIPPET}..."
    fi
    # Use printf here too for consistency, though rofi -e might handle literal \n better.
    # However, rofi -e's primary argument is the message itself.
    NO_TRANSLATION_MESSAGE=$(printf "No translation found for:\n'%s'\n(Attempted: %s ➤ %s)" \
                                    "$DISPLAY_INPUT_SNIPPET" \
                                    "$FROM_LANG" \
                                    "$TO_LANG")
    rofi -e "$NO_TRANSLATION_MESSAGE"
fi

exit 0
