#!/bin/bash
# Remove wazuh-agent from .deb install 


## List wazuh-agent 

dpkg -l | grep wazuh-agent

## Remove wazuh-agent 

dpkg -r wazuh-agent

# dpkg -r --force-all wazuh-agent

# dpkg --purge wazuh-agent

## Purge dpkg cache

rm -rf /var/lib/dpkg/info/wazuh-agent.*

## Clean respositories

rm -rf /var/ossec

## Disable and delete service 

systemctl disable wazuh-agent

systemctl daemon-reload