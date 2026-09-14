#!/bin/bash
# Orchestrates the full SD -> SSD migration: partitioning, data copy, boot config.
# Runs make_partitions.sh -> copy_partitions.sh -> configure_ssd_boot.sh from this directory,
# stopping immediately if any step fails. Each underlying script has its own (y/N) confirmation
# before touching the destination disk.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE="/dev/mmcblk0"
DESTINATION="/dev/nvme0n1"

usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo
    echo "Migrate a running Jetson SD-card install onto an SSD and configure it to boot."
    echo
    echo "Options:"
    echo "  -s, --source      Source disk (default: $SOURCE)"
    echo "  -d, --destination Destination disk (default: $DESTINATION)"
    echo "  -h, --help        Show this help message and exit"
    exit 0
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -s|--source)
            SOURCE="$2"
            shift 2
            ;;
        -d|--destination)
            DESTINATION="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)." >&2
    exit 1
fi

for dev in "$SOURCE" "$DESTINATION"; do
    if [[ ! -b "$dev" ]]; then
        echo "Error: $dev is not a block device. Check it's connected and unmounted." >&2
        exit 1
    fi
done

echo "=== Jetson SD -> SSD migration ==="
echo "Source (current SD card):  $SOURCE"
echo "Destination (SSD, will be WIPED): $DESTINATION"
echo
lsblk "$SOURCE" "$DESTINATION"
echo
echo "This will erase everything currently on $DESTINATION."
read -r -p "Continue with all three migration steps? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 1
fi

echo
echo "--- Step 1/3: make_partitions.sh ---"
bash "$SCRIPT_DIR/make_partitions.sh" -s "$SOURCE" -d "$DESTINATION"

echo
echo "--- Step 2/3: copy_partitions.sh ---"
bash "$SCRIPT_DIR/copy_partitions.sh" -s "$SOURCE" -d "$DESTINATION"

echo
echo "--- Step 3/3: configure_ssd_boot.sh ---"
bash "$SCRIPT_DIR/configure_ssd_boot.sh" -d "$DESTINATION"

echo
echo "=== Migration complete ==="
echo "Reboot to boot from the SSD. If it boots back to the SD card, press Esc at the"
echo "NVIDIA splash screen and set $DESTINATION first in Boot Maintenance Manager -> Change Boot Order."
