#!/bin/bash

# This script sets the variables and runs the installation.

# Ensure you are running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Run the main installation script
bash install.sh
