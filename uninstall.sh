#!/usr/bin/env bash

set -e

# PROMPT COLOURS
readonly RESET='\033[0;0m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'

executable="save2git"
install_dir="/bin/"

echo -e "${BLUE}Uninstall ${YELLOW}${executable}${BLUE}:${RESET}"

rm "${install_dir}${executable}"

echo -e "${YELLOW}${executable}${GREEN} was removed with success.${RESET}"
