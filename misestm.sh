#!/bin/bash

echo -e "\033[0;40m"
echo " :'######::'##:::'##:'##:::'##:'##::: ##:'########:'########:  ";
echo " '##... ##: ##::'##::. ##:'##:: ###:: ##: ##.....::... ##..::  ";
echo "  ##:::..:: ##:'##::::. ####::: ####: ##: ##:::::::::: ##::::  ";
echo " :. ######:: #####::::::.##:::: ## ## ##: ######:::::: ##::::  ";
echo " '##::: ##: ##:. ##::::: ##:::: ##:. ###: ##:::::::::: ##::::  ";
echo " . ######:: ##::. ##:::: ##:::: ##::. ##: ########:::: ##::::  ";
echo " CREDIT : VANZZDARK SKYNET | SPECIAL THANKS TO : MAMAD PINROCK ";
echo -e "\e[0m"


sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export CHAIN_ID=mainnet" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
git clone https://github.com/mises-id/mises-tm/
cd mises-tm/
git checkout main
make install

# config
misestmd config chain-id $CHAIN_ID
misestmd config keyring-backend test
misestmd config node node tcp://127.0.0.1:26657

# init
misestmd init $NODENAME --chain-id CHAIN_ID

# download genesis
curl https://e1.mises.site:443/genesis | jq .result.genesis > ~/.misestm/config/genesis.json

# set peers and seeds
SEEDS=""
PERSISTENT_PEERS="40a8318fa18fa9d900f4b0d967df7b1020689fa0@e1.mises.site:26656"
sed -i.bak -E "s|^(persistent_peers[[:space:]]+=[[:space:]]+).*$|\1\"$PERSISTENT_PEERS\"|"  ~/.misestm/config/config.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0umis\"/" $HOME/.misestm/config/app.toml

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/misestmd.service > /dev/null <<EOF
[Unit]
Description=Mises Daemon
Network=online.target

[Service]
Type=simple
User=root
ExecStart=/root/go/bin/misestmd start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable misestmd
sudo systemctl start misestmd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u misestmd -f -o cat\e[0m'
