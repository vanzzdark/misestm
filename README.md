![image](https://user-images.githubusercontent.com/47944160/204105922-50678552-77a7-4fc8-b1a0-95df22ca5976.png)

# The Mises Chain
Mises is a social network protocol based on blockchain technology, it helps developer build decentralized social media applications on blockchain.

# Hardware requirements?
The following requirements are recommended for running Mises:
- At least 300 mbps of network bandwidth
- 4 core or higher CPU
- 32GB RAM
- 2TB NVME storage
- At least 300mbps network bandwidth

OFFICIAL EXPLORER : https://gw.mises.site/

# FULLNODE SETUP
```
wget -O misestm.sh https://raw.githubusercontent.com/vanzzdark/misestm/main/misestm.sh && chmod +x misestm.sh && ./misestm.sh
```

## Post installation
```
source $HOME/.bash_profile
```
use command below to check synchronization status
```
misestmd status 2>&1 | jq .SyncInfo
```

# State Sync
```
N/A
```

Recover your wallet using seed phrase
```
misestm keys add $WALLET --recover
```
# Save wallet info
Add wallet and valoper address into variables 
```
MISES_WALLET_ADDRESS=$(misestmd keys show $WALLET -a)
MISES_VALOPER_ADDRESS=$(misestmd keys show $WALLET --bech val -a)
echo 'export MISES_WALLET_ADDRESS='${$MISES_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export MISES_VALOPER_ADDRESS='${MISES_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```

# Create validator
To create your validator run command below
```
misestmd tx staking create-validator \
  --amount 1000000umis \
  --from $WALLET \
  --commission-max-change-rate "0.2" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(misestmd tendermint show-validator) \
  --moniker $NODENAME\
  --chain-id $CHAIN_ID
```

# Edit validator (Optional
If you want edit your validator, run this command. 
```
misestmd tx staking edit-validator \
  --moniker=YourMonikerName \
  --identity=YourKeybaseId \
  --website="yourwebsite" \
  --details="Yourdetails" \
  --chain-id $CHAIN_ID \
  --from $WALLET
```

# Usefull commands
Check logs
```
journalctl -fu misestmd -o cat
```

Start service
```
sudo systemctl start misestmd
```

Stop service
```
sudo systemctl stop misestmd
```

Restart service
```
sudo systemctl restart misestmd
```

# Node info
Synchronization info
```
misestmd status 2>&1 | jq .SyncInfo
```

Validator info
```
misestmd status 2>&1 | jq .ValidatorInfo
```

Node info
```
misestmd status 2>&1 | jq .NodeInfo
```

Show node id
```
misestmd tendermint show-node-id
```

# Delete Node
```
sudo systemctl stop misestmd && \
sudo systemctl disable misestmd && \
rm /etc/systemd/system/misestmd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf mises-tm && \
rm -rf mises.sh && \
rm -rf .misestm && \
rm -rf $(which misestmd)
````
