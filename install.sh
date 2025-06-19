#!/usr/bin/env bash
source lib/colors.sh
source lib/config.sh
source lib/utils.sh

show_banner
confirm_dangerous_action "$(lsblk)" XD