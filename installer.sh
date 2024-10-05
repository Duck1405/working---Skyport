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

# Function to print status
function print_status() {
    echo -e "${GREEN}[*] $1${NC}"
}

# Root Check
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}Please run as root${NC}"
  exit
fi

# Dependency Installation
print_status "Installing dependencies (Node.js, Git)..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt update
apt install -y nodejs git

# Panel Installation
print_status "Installing Skyport Panel..."
mkdir -p /etc/skyport
cd /etc/skyport
git clone https://github.com/skyportlabs/panel
cd panel
npm install && npm install axios
npm run seed
npm run createUser
print_status "Panel installed. Use 'node .' command in the panel directory to run it."

# Deamon Installation
print_status "Installing Docker for the Skyport Deamon..."
curl -sSL https://get.docker.com/ | CHANNEL=stable bash

# Install Deamon Dependencies
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt update
apt install -y nodejs git

# Deamon Installation
print_status "Installing Skyport Deamon..."
cd /etc/skyport
git clone https://github.com/skyportlabs/skyportd
cd skyportd
npm install && npm install axios
print_status "Deamon installed. Create and configure a node in the panel, paste the token here, then use 'node .' command in the deamon directory to run it."

# Final Message
print_status "Installation completed!"
