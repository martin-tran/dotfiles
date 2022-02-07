#!/usr/bin/env bash

WORKING_DIR="/home/thereca/Videos/VTuber/NijiEN/Rosemi Lovelock/archive"
CHANNEL_URL="https://www.youtube.com/channel/UC4WvIIAo89_AzGUh1AZ6Dkg/live"
LOG_FILE="${working_dir}/monitor.log"

if [[ -f "${log_file}" ]]; then
    rm -v "${log_file}"
    if [[ "$1" == "-v" ]]; then
        echo "[INFO] Removed previous log file" >> "$log_file"
    fi
fi

if [[ "$1" == "-v" ]]; then
    yt-dlp -S 'ext' --embed-metadata --embed-thumbnail --write-thumbnail \
           --write-description --wait-for-video 5\
           --cookies-from-browser=chromium+kwallet "${CHANNEL_URL}" \
           >> "${LOG_FILE}" 2>&1
else
    yt-dlp -S 'ext' --embed-metadata --embed-thumbnail --write-thumbnail \
           --write-description --wait-for-video 5\
           --cookies-from-browser=chromium+kwallet "${CHANNEL_URL}"
fi

if [[ $(compgen -G "${WORKING_DIR}/*.mp4") ]]; then
    local cur_date
    cur_date=$(date -I)
    mkdir "${WORKING_DIR}/${cur_date}"
    mv "${WORKING_DIR}/*.mp4" "${WORKING_DIR}/${cur_date}"
    mv "${WORKING_DIR}/*.description" "${WORKING_DIR}/${cur_date}"
    mv "${WORKING_DIR}/*.webp" "${WORKING_DIR}/${cur_date}"
fi
