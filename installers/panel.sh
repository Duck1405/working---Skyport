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

# Dependency Installation
output "Installing dependencies"
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

# Panel Installation
output "Installing Skyport Panel files"
mkdir -p /etc/skyport
cd /etc/skyport

if [ -d "panel" ]; then
    output "Directory 'panel' already exists, skipping cloning."
else
    git clone https://github.com/skyportlabs/panel
    success "Cloned panel files."
fi

cd panel
output "Installing packages."
npm install && npm install axios
success "Packages installed"
npm run seed

read -p "Do you want to create an account? (yes/no): " create_user
if [[ "$create_user" == "yes" || "$create_user" == "y" ]]; then
    npm run createUser
    success "User account created."
else
    output "User account creation skipped."
fi

success "Panel installed. Use 'node /etc/skyport/panel/index.js' command as root to run panel."
