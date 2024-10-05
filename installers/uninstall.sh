#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'skyport-uninstaller'                                                      #
#                                                                                    #
# Copyright (C) 2024 - 2024, ItzLoghotXD, <itzloghotxd@gmail.com>                    #
#                                                                                    #
#   Permission is hereby granted, free of charge, to any person obtaining a copy     #
#   of this software and associated documentation files (the "Software"), to deal    #
#   in the Software without restriction, including without limitation the rights     #
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell        #
#   copies of the Software, and to permit persons to whom the Software is            #
#   furnished to do so, subject to the following conditions:                         #
#                                                                                    #
#   The above copyright notice and this permission notice shall be included in all   #
#   copies or substantial portions of the Software.                                  #
#                                                                                    #
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR       #
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,         #
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE      #
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER           #
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,    #
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE    #
#   SOFTWARE.                                                                        #
#                                                                                    #
# https://github.com/ItzLoghotXd/blob/main/LICENSE                                   #
#                                                                                    #
######################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

output() {
  echo -e "* $1"
}

success() {
  echo -e "* ${GREEN}$1${NC}"
}

error() {
  echo ""
  echo -e "* ${RED}ERROR${NC}: $1" 1>&2
  echo ""
}

# Root Check
if [ "$EUID" -ne 0 ]; then 
  error "Please run as root"
  exit
fi

# Function to uninstall Skyport Panel
uninstall_panel() {
    output "Uninstalling Skyport Panel..."
    if [ -d "/etc/skyport/panel" ]; then
        rm -rf /etc/skyport/panel
        success "Skyport Panel uninstalled successfully."
    else
        error "Skyport Panel is not installed."
    fi
}

# Function to uninstall Skyport Daemon
uninstall_daemon() {
    output "Uninstalling Skyport Daemon..."
    if docker ps -a | grep -q "skyport_daemon"; then
        docker stop skyport_daemon && docker rm skyport_daemon
        success "Skyport Daemon stopped and removed."
    else
        error "Skyport Daemon container not found."
    fi
    if [ -d "/etc/skyport/daemon" ]; then
        rm -rf /etc/skyport/daemon
        success "Skyport Daemon files removed."
    else
        error "Skyport Daemon is not installed."
    fi
}

execute() {
  if [[ "$1" == "panel" ]]; then
    output "Uninstalling Skyport Panel..."
    uninstall_panel
    output "Thankyou for using my script. I think that this script might have some issues, feel free to open an issue at https://github.com/ItzLoghotXD/Skyport/issues."
    output "If you want to support me and if you can then please support me with crypto here(https://github.com/ItzLoghotXD/Skyport/blob/main/README.md#donationssupport)"
  elif [[ "$1" == "deamon" ]]; then
    output "Uninstalling Skyport Daemon..."
    uninstall_daemon
    output "Thankyou for using my script. I think that this script might have some issues, feel free to open an issue at https://github.com/ItzLoghotXD/Skyport/issues."
    output "If you want to support me and if you can then please support me with crypto here(https://github.com/ItzLoghotXD/Skyport/blob/main/README.md#donationssupport)"
  elif [[ "$1" == "exit" ]]; then
    output "Thankyou for using my script. I think that this script might have some issues, feel free to open an issue at https://github.com/ItzLoghotXD/Skyport/issues."
    output "If you want to support me and if you can then please support me with crypto here(https://github.com/ItzLoghotXD/Skyport/blob/main/README.md#donationssupport)"
    exit
  fi

  if [[ -n $2 ]]; then
    echo -e -n "* Uninstallation of $1 completed. Do you want to proceed to $2 uninstallation? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ [Yy] ]]; then
      execute "$2"
      output "Thankyou for using my script. I think that this script might have some issues, feel free to open an issue at https://github.com/ItzLoghotXD/Skyport/issues."
    output "If you want to support me and if you can then please support me with crypto here(https://github.com/ItzLoghotXD/Skyport/blob/main/README.md#donationssupport)"
    else
      error "Uninstallation of $2 aborted."
      output "Thankyou for using my script. I think that this script might have some issues, feel free to open an issue at https://github.com/ItzLoghotXD/Skyport/issues."
      output "If you want to support me and if you can then please support me with crypto here(https://github.com/ItzLoghotXD/Skyport/blob/main/README.md#donationssupport)"
      exit 1
    fi
  fi
}

done=false
while [ "$done" == false ]; do
  options=(
    "Uninstall the panel"
    "Uninstall deamon"
    "Uninstall both"
    "exit"
  )

  actions=(
    "panel"
    "deamon"
    "panel;deamon"
    "exit"
  )

  output "What do you want to uninstall?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && execute "$i1" "$i2"
done
