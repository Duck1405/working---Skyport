#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'skyport-installer'                                                        #
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
#   You should have received a copy of the MIT License                               #
#   along with this program. If not, see <https://choosealicense.com/licenses/mit/>. #
#                                                                                    #
# https://github.com/ItzLoghotXd/blob/main/LICENSE                                   #
#                                                                                    #
# This script is not associated with the official SkyPort Project.                   #
# OFFICIAL - https://github.com/skyportlabs/                                         #
# MY - https://github.com/ItzLoghotXD/Skyport                                        #
#                                                                                    #
######################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
LOG_PATH="/var/log/skyport-installer.log"

output() {
  echo -e "* $1"
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

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  error "curl is required in order for this script to work."
  error "install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

execute() {
  echo -e "\n\n* skyport-installer $(date) \n\n" >>$LOG_PATH

  if [[ "$1" == "panel" ]]; then
    output "Installing Skyport Panel..."
    bash <(curl -s https://raw.githubusercontent.com/ItzLoghotXD/Skyport/main/installers/panel.sh)
  elif [[ "$1" == "deamon" ]]; then
    output "Installing Skyport Daemon..."
    bash <(curl -s https://raw.githubusercontent.com/ItzLoghotXD/Skyport/main/installers/deamon.sh)
  elif [[ "$1" == "uninstall" ]]; then
    output "Uninstalling Skyport Panel/Daemon..."
    bash <(curl -s https://raw.githubusercontent.com/ItzLoghotXD/Skyport/main/installers/uninstall.sh)
    output "Thankyou for using my script. I think that this script might have some issues, feel free to open an issue at https://github.com/ItzLoghotXD/Skyport/issues."
    output "If you want to support me and if you can then please support me with crypto here(https://github.com/ItzLoghotXD/Skyport/blob/main/README.md#donationssupport)"
  elif [[ "$1" == "exit" ]]; then
    exit
  fi

  if [[ -n $2 ]]; then
    echo -e -n "* Installation of $1 completed. Do you want to proceed to $2 installation? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ [Yy] ]]; then
      execute "$2"
    else
      error "Installation of $2 aborted."
      exit 1
    fi
  fi
}

done=false
while [ "$done" == false ]; do
  options=(
    "Install the panel"
    "Install deamon"
    "Install both [0] and [1] on the same machine (deamon script runs after panel)"
    # "Uninstall panel or deamon\n"

    "Uninstall panel or deamon"
    "exit"
  )

  actions=(
    "panel"
    "deamon"
    "panel;deamon"
    # "uninstall"

    "uninstall"
    "exit"
  )

  output "What would you like to do?"

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
