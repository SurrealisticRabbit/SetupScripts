#!/bin/bash
set -e

# Ensure you are running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Source the functions
source scripts/functions.sh

# Main installation process
main() {
    run_part '01-partition' scripts/01-partition.sh
    run_part '02-filesystem' scripts/02-filesystem.sh
    run_part '03-install' scripts/03-install.sh
    run_part '04-configure' scripts/04-configure.sh
}

main
