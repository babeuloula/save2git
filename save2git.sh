#!/usr/bin/env bash

set -e

# PROMPT COLOURS
readonly RESET='\033[0;0m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'

function ask_value() {
    local message=$1
    local value

    echo -e "${CYAN}${message}: ${RESET}" > /dev/tty
    read value < /dev/tty

    if [[ -z ${value} ]]; then
        value=$(ask_value "${message}")
    fi

    echo "${value}"
}

function init_repo() {
    local ssh_key_path="$(pwd)/.ssh/"
    local ssh_key_file="id_rsa"

    if [ -f "${ssh_key_path}${ssh_key_file}" ]; then
        echo -e "${BLUE}SSH key already exist in: ${YELLOW}${ssh_key_path}${ssh_key_file}${RESET}\n"
    else
        local ssh_key_email=$(ask_value "Enter your SSH keygen email")

        mkdir -p "$ssh_key_path"

        ssh-keygen -t rsa -b 4096 -C "${ssh_key_email}" -f "${ssh_key_path}${ssh_key_file}"

        echo -e "${GREEN}Your ssh key was store in: ${YELLOW}${ssh_key_path}${ssh_key_file}${RESET}\n"
        echo -e "${GREEN}Copy your RSA public key into your GitHub account:${RESET}\n"
        echo -e "${PURPLE}$(cat ${ssh_key_path}${ssh_key_file}.pub)${RESET}\n"

        local continue=$(ask_value "It's OK? We can continue? (y/n)")

        if [ "y" != $continue ]; then
            echo -e "${RED}OK, fine! Goodbye!${RESET}"
            exit 1
        fi
    fi
    
    ssh-add "${ssh_key_path}${ssh_key_file}"

    git init

    local git_email=$(ask_value "Enter your git email")
    git config user.email "${git_email}"
    local git_name=$(ask_value "Enter your git name")
    git config user.name "${git_name}"

    local git_repository_url=$(ask_value "Enter git repository URL")

    echo ".git_tmp" > ".gitignore"
    echo ".ssh" >> ".gitignore"
    echo "vendor" >> ".gitignore"
    echo "node_modules" >> ".gitignore"
    echo "cache" >> ".gitignore"
    echo "logs" >> ".gitignore"

    git remote add origin "${git_repository_url}"
}

function invalid_option() {
    echo -e "${RED}Incorrect option provided. Use ${YELLOW}$(basename "$0") --help${RED} for more information.${RESET}"
    exit 1
}

function start_sync() {
    local start=$(date +%s)

    echo -e "\n${BLUE}Begin synchronization: ${YELLOW}${WORKING_PATH}${BLUE}!${RESET}\n"

    rename_dot_git
    push_repo
    revert_rename_got_git

    local end=$(date +%s)
    local duration=$(($end - $start))

    echo -e "${GREEN}Synchronization done in ${duration}s!${RESET}\n"
    exit 0
}

function rename_dot_git() {
    for folder in $(find . -type d -name "*.git"); do
        if [ $folder != './.git' ]; then
            echo -e "${CYAN}Rename folder: ${YELLOW}${folder}${RESET}"
            mv $folder "${folder}_tmp"
        fi
    done

    for file in $(find . -type f -name "*.gitignore"); do
        if [ $file != './.gitignore' ]; then
            echo -e "${CYAN}Rename file: ${YELLOW}${file}${RESET}"
            mv $file "${file}_tmp"
        fi
    done

    echo -e "${GREEN}.git directories was renamed successfully!${RESET}\n"
}

function push_repo() {
    echo -e "${GREEN}Add untracked files and push to repository${RESET}"

    git add .
    git commit -m "Sync $(date)"
    git push -u origin master

    echo -e "${GREEN}The repository is now up to date!${RESET}\n"
}

function revert_rename_got_git() {
    for folder in $(find . -type d -name "*.git_tmp"); do
        echo -e "${CYAN}Revert folder: ${YELLOW}${folder}${RESET}"
        mv $folder "${folder/.git_tmp/.git}"
    done

    for file in $(find . -type f -name "*.gitignore_tmp"); do
        echo -e "${CYAN}Rename file: ${YELLOW}${file}${RESET}"
        mv $file "${file/.gitignore_tmp/.gitignore}"
    done

    echo -e "${GREEN}.git directories was reverted successfully!${RESET}\n"
}

function display_help() {
    cat <<-END
Save2Git: Allow to push a directory to a git repository.

Usage:
    $(basename "$0") options -m|--mode  -p|--path <path to sync>

Options:
    -m, --mode <init|push>      Select mode between init or push
        --init                  Alias of "--mode init"
        --push                  Alias of "--mode push"

    -p, --path <path to sync>   Path to synchronize

        --help                  Display help

END
    exit 0
}

function main()
{
    eval set -- $(getopt -q -o m:p --long help,init,push,mode:,path: -n "Save2Git" -- "$@")
    while true; do
        case "$1" in
            -m|--mode)
                shift
                MODE=$1
                ;;

            --init)
                MODE='init'
                ;;

            --push)
                MODE='push'
                ;;

            -p|--path)
                shift
                WORKING_PATH=$1
                ;;
            --help)
                display_help
                ;;
            --)
                shift
                break
                ;;
        esac
        shift
    done

    if [ "" = "$WORKING_PATH" ]; then
        echo -e ${RED}You need to specify a path.${RESET}
        exit 1
    fi

    cd $WORKING_PATH

    if [ "init" = "$MODE" ]; then
        init_repo
    elif [ "push" = "$MODE" ]; then
        start_sync
    else
        echo -e "${RED}You need to choose a mode [init or push].${RESET}"
        exit 1
    fi
}

main $0 "$@"
