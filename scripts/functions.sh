#!/bin/bash

# Function to run a part of the installation
run_part() {
    local name=$1
    local script=$2
    echo ">> Running $name"
    bash "$script"
    echo ">> $name finished"
}