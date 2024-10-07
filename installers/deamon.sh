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

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  error "curl is required in order for this script to work."
  error "install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

execute() {
  if [[ "$1" == "sdeamon" ]]; then

    # Dependency Installation
    output "Installing dependencies"

    # Check if Docker is installed
    output "Installing Docker for the Skyport Daemon..."
    if ! command -v docker &> /dev/null; then
        curl -sSL https://get.docker.com/ | CHANNEL=stable bash
        success "Docker installed."
    else
        output "Docker is already installed, skipping installation..."
    fi

    # Check if the NodeSource GPG key and repository are already set up
    output "Setting up Node.js repository..."
    if [ ! -f /etc/apt/keyrings/nodesource.gpg ]; then
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
        success "Set up Node.js repository. Done!"
    else
        output "Node.js repository is already set up, skipping..."
    fi

    apt update
    apt install -y nodejs git

    # Deamon Installation
    output "Installing Skyport Deamon files"
    mkdir /etc/Skyport
    cd /etc

    if [ -d "Skyport/deamon" ]; then
        output "Directory 'deamon' already exists, skipping cloning."
    else
        mkdir tempspdir
        cd tempspdir
        git clone https://github.com/ItzLoghotXD/Skyport
        cd Skyport
        mv /etc/tempspdir/Skyport/deamon /etc/Skyport/deamon
        cd /etc
        rm -rf tempspdir
        success "Cloned deamon files."
    fi

    cd /etc/Skyport/deamon
    output "Installing packages."
    npm install && npm install axios
    success "Packages installed"
    success "Deamon installed. Create and configure a node in the panel, paste the token here, then use 'cd /etc/skyport/skyportd/ && node .' command as root to start the deamon."
    output "Open/Forword these ports - 3000, 3001, 3002, and 3003"

  elif [[ "$1" == "deamon" ]]; then

    # Dependency Installation
    output "Installing dependencies"

    # Check if Docker is installed
    output "Installing Docker for the Skyport Daemon..."
    if ! command -v docker &> /dev/null; then
        curl -sSL https://get.docker.com/ | CHANNEL=stable bash
        success "Docker installed."
    else
        output "Docker is already installed, skipping installation..."
    fi

    # Check if the NodeSource GPG key and repository are already set up
    output "Setting up Node.js repository..."
    if [ ! -f /etc/apt/keyrings/nodesource.gpg ]; then
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
        success "Set up Node.js repository. Done!"
    else
        output "Node.js repository is already set up, skipping..."
    fi

    apt update
    apt install -y nodejs git

    # Deamon Installation
    output "Installing Skyport Deamon files"
    mkdir -p /etc/skyport
    cd /etc/skyport

    if [ -d "skyportd" ]; then
        output "Directory 'skyportd' already exists, skipping cloning."
    else
        git clone https://github.com/skyportlabs/skyportd
        success "Cloned deamon files."
    fi

    cd skyportd
    output "Installing packages."
    npm install && npm install axios
    success "Packages installed"
    success "Deamon installed. Create and configure a node in the panel, paste the token here, then use 'cd /etc/skyport/skyportd/ && node .' command as root to start the deamon."
    output "Open/Forword these ports - 3000, 3001, 3002, and 3003"

  elif [[ "$1" == "exit" ]]; then
    exit
  fi
}

done=false
while [ "$done" == false ]; do
  options=(
    "Install the latest stable version of deamon (unofficial)"
    "Install latest version of deamon (official)"
    "exit"
  )

  actions=(
    "sdeamon"
    "deamon"
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
