#!/bin/bash
#
# ========================================================================
#  Copyright (c) 2025
#  Author: Vahid Heidari
#
#  Description:
#    This script automatically scans a public `/index` directory-style
#    webpage, extracts direct links to downloadable files, and downloads
#    them using wget.
#
#    Supported file extensions include:
#    Documents: pdf, epub, djvu, doc, docx, txt, rtf, odt, odp, ods,
#               ppt, pptx, xls, xlsx, csv, md
#    Source/Code: asm, s, c, h, cpp, cc, hh, hpp, ps1, vb, bat, whl
#    Archives: gz, rar, zip, 7z, z, bz2, xz, lzh, tar, zipx, 7a
#    Disk/Installer Images: vhd, vmdk, img, deb, rpm, jar, apk, ios
#    Media: mp4, flv, mov, wmv, avi, mkv, m4a, mp3
#    Images: jpg, png, webp, bmp, svg
#
#    Use responsibly and ensure you have permission to download content.
# ========================================================================

# ------------------------
# Define Colors
# ------------------------
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"


# ------------------------
# Help / Usage Information
# ------------------------
show_help() {
    cat <<EOF

IndexOf Downloader — Automated File Extractor & Downloader
----------------------------------------------------------

Usage:
    $(basename "$0") <URL> [TARGET_DIRECTORY]

Parameters:
    URL                Required. The /index-style URL to scan for files.
    TARGET_DIRECTORY   Optional. Directory where downloaded files will be stored.
                       If omitted, the script generates a random directory name.

Examples:
    $(basename "$0") "https://example.com/files/"
    $(basename "$0") "https://example.com/files/" my_downloads

Description:
    The script retrieves the index webpage, extracts links matching a large
    set of known downloadable file extensions, writes them to a list file,
    and downloads each file using wget. If a system-wide HTTP proxy is
    configured, it will be used automatically.

EOF
}


# -----------------------------------
# Show help if no arguments were given
# -----------------------------------
if [[ -z "$1" ]]; then
    show_help
    exit 1
fi


# ------------------------
# Argument Parsing
# ------------------------
URL="$1"
TARGET="$2"

# Detect system proxy settings and configure wget/curl to use them if found
USEPROXY=""
if [[ -n "$http_proxy" ]]; then
    USEPROXY="--proxy $http_proxy"
fi

# If no target directory was provided, generate one with a random suffix
if [[ -z "$TARGET" ]]; then
    TARGET="Download_$(( RANDOM % 10000 ))"
fi


# ------------------------
# Extract File Links
# ------------------------
echo -e "${GREEN}[+] Extracting file links from: $URL ${RESET}"
echo -e "${GREEN}[+] Output file list will be: ${TARGET}.txt ${RESET}"

curl -s $USEPROXY $URL \
    | grep -Eoi 'href="[^"]+\.(pdf|epub|djvu|docx?|txt|rtf|odt|odp|ods|ppt|pptx|xls|xlsx|csv|md|asm|s|c|h|c(pp|c)|h(pp|h)|gz|rar|zip|7z|z|bz2|xz|lzh|tar|zipx|7a|vhd|vmdk|jar|apk|ios|img|deb|rpm|whl|ps1|vb|bat|mp4|flv|mov|wmv|avi|mkv|m4a|mp3|jpg|png|webp|bmp|svg)"' \
    | sed -E 's/^href="//; s/"$//' \
    | sed "s|^|$URL|" \
    > "${TARGET}.txt"


# ------------------------
# Download Section
# ------------------------
if [[ -s "${TARGET}.txt" ]]; then

    echo "------------------------------------------------------------"
    echo -e "${GREEN}  IndexOf Downloader — Download Session ${RESET}"
    echo "------------------------------------------------------------"
    echo -e "${CYAN}✔ File list generated : ${TARGET}.txt ${RESET}"
    echo -e "${CYAN}✔ Download directory  : ${TARGET} ${RESET}"
    echo ""
    echo -e "${GREEN}Starting download... ${RESET}"
    echo "------------------------------------------------------------"

    mkdir -p "$TARGET"

    # Download each file with retry logic enabled
    while IFS= read -r item; do
        wget -c --tries=5 --retry-connrefused --timeout=10 "$item" -P "$TARGET"
    done < "${TARGET}.txt"

    echo ""
    echo "------------------------------------------------------------"
    echo "${GREEN} ✔ All downloads completed successfully.${RESET}"
    echo "------------------------------------------------------------"

else
    echo -e "${RED}✖ No downloadable file links were found at: ${URL} ${RESET}"
    echo -e "${YELLOW}Note: Please verify that the provided URL is correct and accessible.${RESET}"
    echo -e "${YELLOW}Note: If you’re sure the target URL: ${URL} is correct, you should check your proxy settings. Sometimes, some proxies like Lantern block certain URLs.${RESET}"
fi

