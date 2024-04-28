#!/bin/bash


# Detect if you are using ubuntu; if not, this script will not work for you. 

if [ "$(cat /etc/os-release | grep -w ID | cut -d '=' -f 2)" != "ubuntu" ]; then
    echo "This script is only for Ubuntu"
    echo "To follow the tutorial please visit the manual install at: https://github.com/ruby-network/byod-bot#nginx"
    exit 1
fi 

sudo apt update && sudo apt install lsb-release -y

# Detect if you are running ubuntu 22, if your not running ubuntu codename "jammy jellyfish" this script will not work for you.

if [ "$(lsb_release -c -s)" != "jammy" ]; then
    echo "This script is only for Ubuntu 22: jammy jellyfish"
    echo "You are running: $(lsb_release -c -s)"
    echo "To follow the tutorial please visit the manual install at:  https://github.com/ruby-network/byod-bot#nginx"
    exit 1
fi

echo "Stopping NGINX"
sudo systemctl stop nginx 
sudo systemctl disable nginx 

echo "Installing needed deps"
sudo apt -y install wget gnupg ca-certificates lsb-release

echo "Adding Openresty repo"
wget -O - https://openresty.org/package/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/openresty.gpg 

# Detect if we are running x86_64 or arm64 and aarch64
if [ "$(dpkg --print-architecture)" = "amd64" ]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null
elif [ "$(dpkg --print-architecture)" = "arm64" ] || [ "$(dpkg --print-architecture)" = "aarch64" ]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/arm64/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null
else
    echo "Unsupported architecture"
    exit 1
fi

echo "Updating package list"
sudo apt update

echo "Installing Openresty"
sudo apt -y install openresty 

sudo su -
echo "Installing extra needed modules..."
opm install fffonion/lua-resty-acme

echo "generating fallback certificates"
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out /etc/openresty/account.key
openssl req -newkey rsa:2048 -nodes -keyout /etc/openresty/default.key -x509 -days 365 -out /etc/openresty/default.pem 

echo "Done!"
echo ""
echo "To finish the setup, please follow the guide: https://github.com/ruby-network/byod-bot#nginx (skip steps 1 - 3)"
