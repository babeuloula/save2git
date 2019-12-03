#!/usr/bin/env bash

set -e

# PROMPT COLOURS
readonly RESET='\033[0;0m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'

executable="save2git"

echo -e "${BLUE}Download ${YELLOW}${executable}.sh${BLUE}:${RESET}"
wget "https://raw.githubusercontent.com/babeuloula/save2git/master/${executable}.sh"

install_dir="/bin/"

echo -e "${BLUE}Install in ${YELLOW}${install_dir}${executable}${BLUE}:${RESET}"
mv "${executable}.sh" "${install_dir}${executable}"
chmod +x "${install_dir}${executable}"

echo -e "${GREEN}Installation done, you can now use ${YELLOW}${executable} --help${BLUE}:${RESET}"
