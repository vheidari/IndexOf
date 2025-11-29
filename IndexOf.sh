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
# Console Colors
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

# ------------------------
# UI Helpers
# ------------------------
print_line() {
    empty=$1 
    if [[ $empty == "" ]]; then
        echo ""
    else 
        echo "---------------------------------------------------------------------------"
    fi
}


console_log() {
    local message="$1"
    local type="$2"

    case "$type" in
        error)      echo -e "❌ ${RED}${message}${RESET}";;
        warning)    echo -e "⚠️  ${YELLOW}${message}${RESET}";;
        success)    echo -e "🟢 ${GREEN}${message}${RESET}";;
        primary)    echo -e "💡 ${CYAN}${message}${RESET}";;

        # short versions (no emoji)
        s_error)    echo -e "${RED}${message}${RESET}";;
        s_warning)  echo -e "${YELLOW}${message}${RESET}";;
        s_success)  echo -e "${GREEN}${message}${RESET}";;
        s_primary)  echo -e "${CYAN}${message}${RESET}";;

        *)          echo -e "$message";;
    esac
}


# ------------------------
# Parse wget exit status
# ------------------------
wget_exit_status() {
    case "$1" in
        1) echo "wget: Generic error code.";;
        2) echo "wget: Command-line usage error.";;
        3) echo "wget: File read/write error.";;
        4) echo "wget: Network failure.";;
        5) echo "wget: SSL verification failure.";;
        6) echo "wget: Authentication failure.";;
        7) echo "wget: Protocol error.";;
        8) echo "wget: Server returned an error response.";;
        *) echo "wget: Successfully downloaded file.";;
    esac
}


# ------------------------
# Download task
# ------------------------

# Track download_files call depth
TRACK_DOWNLOAD_FILES_DEPTH=0

download_files() {
    
    local arg_one="$1"

    # Default Download
    local target="$arg_one"
    local file_list="${target}.txt"
    local failed="Failed_$target"
    local failed_list="${failed}.txt"

    # Pars input 
    if [[ $arg_one == --download_failed=* ]]; then
        # get target name and remove --download_failed= part then update all local variables
        target=${arg_one#"--download_failed="}
        failed="Failed_$target"
        failed_list="${failed}.txt"
        file_list="$failed_list"
    fi



    if [[ -s "$file_list" ]]; then

        print_line
        console_log "🔥 IndexOf Downloader — Download Session" s_success
        print_line
        console_log "📄 Extracted file list : ${file_list}" s_primary
        console_log "📂 Download directory  : ${target}" s_primary
        print_line ""
        console_log "🚀 Starting download..." s_success
        print_line

        mkdir -p "$target"

        # Counters
        local index=0
        local success_count=0
        local fail_count=0

        while IFS= read -r url; do
            wget -c --tries=5 --retry-connrefused --timeout=10 "$url" -P "$target"
            status=$?

            if (( status != 0 )); then
                echo "$url" >> "$failed_list"

                console_log "Failed to download link #$index. Saved to $failed_list" error
                console_log "$(wget_exit_status "$status")" warning

                ((fail_count++))
            else
                ((success_count++))
            fi

            ((index++))

        done < "$file_list"

        print_line
        console_log "🎯 Total links processed     : $index" s_success
        console_log "🌟 Successful downloads      : $success_count" s_success
        console_log "💔 Failed downloads          : $fail_count" s_error
        print_line
        console_log "📂 Files saved in directory : $target" s_primary
        print_line        

        
        # Increase download_files call recursivly
        ((TRACK_DOWNLOAD_FILES_DEPTH++))
        
        # If calling download_files more then 1 exit 
        if ((TRACK_DOWNLOAD_FILES_DEPTH > 1)); then
            console_log "Download attempt failed, preventing recursive retry loop." error
            console_log "Aborting to prevent an infinite retry process. Please try downloading the file manually using the following command: ./IndexOf --download_failed=$failed_list"
            exit 2
        fi

        # Handle Failed Download 
        if (( fail_count > 0 )); then 
            console_log "Unfortunately You have $fail_count Failed downloads. \n Would you like to retry downloading the failed files? [y/n]" error
            read -r user_input
            if [[ "$user_input" == "y" ]]; then
                # Download Failed files
                download_files "--download_failed=$target"
            else
                exit 1
            fi
        fi


    else
        print_line
        console_log "No downloadable links were found." error
        console_log "Please check the URL: $URL" warning
        console_log "If the URL is correct, review your proxy settings. Some proxies can block downloads." warning
        print_line
    fi


}

# ------------------------
# Extract File Links
# ------------------------
extract_links() {
    local url="$1"
    local target="$2"
    local file_list="${target}.txt"

    local proxy=""
    [[ -n "$http_proxy" ]] && proxy="--proxy $http_proxy"

    console_log "[+] Extracting file links from: $url" s_success
    console_log "[+] Saving output to: $file_list" s_success

    curl -s $proxy "$url" \
        | grep -Eoi 'href="[^"]+\.(pdf|epub|djvu|docx?|txt|srt|rtf|odt|odp|ods|ppt|pptx|xls|xlsx|csv|md|asm|s|c|h|c(pp|c)|h(pp|h)|gz|rar|zip|7z|z|bz2|xz|lzh|tar|zipx|7a|vhd|vmdk|jar|apk|ios|img|deb|rpm|whl|ps1|vb|bat|mp4|flv|mov|wmv|avi|mkv|m4a|mp3|jpg|png|webp|bmp|svg)"' \
        | sed -E 's/^href="//; s/"$//' \
        | sed "s|^|$url|" \
        > "$file_list"
}


# -----------------------------------
# Show help if no arguments were given
# -----------------------------------
if [[ -z "$1" ]]; then
    show_help
    exit 0
fi


# ------------------------
# Argument Parsing
# ------------------------
URL="$1"
TARGET="${2:-Download_$(( RANDOM % 10000 ))}"
FAIL="Failed_$TARGET"


# ------------------------
# Main Script Execution
# --------------------------
extract_links "$URL" "$TARGET"
download_files "${TARGET}"