#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e 's/^/[Base]['${1}'] /'
    else
        sed -e 's/^/[Base] /'
    fi
}

# Store arguments in variables
args_timezone="${1}"
args_swap="${2}"

# Use apt mirror based on geographical location
cat > /etc/apt/sources.list.d/geo-mirror <<- EOL
    deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
    deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
    deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
    deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse
EOL

# Setting Timezone to to ${args_timezone} & Locale to en_US.UTF-8
sudo echo "${args_timezone}" > /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata | prefix "Timezone"
sudo apt-get install -qq language-pack-en | prefix "Timezone"
sudo locale-gen en_US | prefix "Timezone"
sudo update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 | prefix "Timezone"

# Updating system
sudo apt-get update | prefix "Updates"
sudo apt-get upgrade -qq | prefix "Updates"

# Installing Base Packages
sudo apt-get install -qq curl unzip git build-essential | prefix "Packages"

# Check if arguments are set
if [[ ! ${args_swap} =~ false && ${args_swap} =~ ^[0-9]*$ ]]; then
    # Setting up memory swap
    sudo fallocate -l $2M /swapfile | prefix "Swap"
    sudo chmod 600 /swapfile | prefix "Swap"
    sudo mkswap /swapfile | prefix "Swap"
    sudo swapon /swapfile | prefix "Swap"
    sudo echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
    sudo echo "vm.swappiness=0" >> /etc/sysctl.conf
    sudo sysctl -p | prefix "Swap"
fi