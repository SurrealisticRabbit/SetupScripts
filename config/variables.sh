#!/bin/bash

# Disk to partition
export DISK="${DISK:-/dev/sda}"

# Partitions
export EFI_PARTITION="${EFI_PARTITION:-/dev/sda1}"
export ROOT_PARTITION="${ROOT_PARTITION:-/dev/sda2}"

# User settings
export HOSTNAME="${HOSTNAME:-ducky}"
export USERNAME="${USERNAME:-ducky}"
export USER_PASSWORD="${USER_PASSWORD:-your_password}"
export ROOT_PASSWORD="${ROOT_PASSWORD:-your_root_password}"

# Network settings
if [ -f config/SSID ] && [ -f config/PASS ]; then
    export WIFI_SSID=$(cat config/SSID)
    export WIFI_PASSWORD=$(cat config/PASS)
else
    export WIFI_SSID=""
    export WIFI_PASSWORD=""
fi
