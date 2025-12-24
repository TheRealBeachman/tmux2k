#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

# Errexit & nounset ausschalten, damit das Script nicht bei Kleinigkeiten stirbt
set +e
set +u

get_percent() {
    case "$(uname -s)" in
    Linux)
        ...
        ;;

    Darwin)
        # Seitengröße (Bytes)
        page_size=$(vm_stat 2>/dev/null | awk '/page size of/ {print $8}') || page_size=
        [ -z "$page_size" ] && page_size=4096

        # "Pages active"
        active_pages=$(vm_stat 2>/dev/null | awk '/Pages active/ {gsub("\\.","",$3); print $3}') || active_pages=""

        # "Pages wired down"
        wired_pages=$(vm_stat 2>/dev/null | awk '/Pages wired down/ {gsub("\\.","",$4); print $4}') || wired_pages=""

        # Gesamtspeicher in Bytes
        total_mem_bytes=$(sysctl -n hw.memsize 2>/dev/null) || total_mem_bytes=""

        if [ -n "$active_pages" ] && [ -n "$wired_pages" ] && \
           [ -n "$total_mem_bytes" ] && [ "$total_mem_bytes" -gt 0 ] 2>/dev/null; then

            used_bytes=$(( (active_pages + wired_pages) * page_size ))
            memory_percent=$(( used_bytes * 100 / total_mem_bytes ))
        else
            memory_percent=0
        fi

        normalize_padding "${memory_percent}%"
        ;;

    FreeBSD)
        ...
        ;;
    esac
}


main() {
    ram_icon=$(get_tmux_option "@tmux2k-ram-icon" "")
    ram_percent=$(get_percent 2>/dev/null || echo "0%")

    # Falls aus irgendeinem Grund trotzdem leer:
    [ -z "$ram_percent" ] && ram_percent="0%"

    echo "$ram_icon $ram_percent"
}


main



