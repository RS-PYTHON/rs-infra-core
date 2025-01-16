#!/bin/bash
# Copyright 2024 CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.#set -x

## Variables ##############################################
# See editor configuration 
# https://documentation.wazuh.com/current/user-manual/deployment-variables/deployment-variables-linux.html 

# Wazuh Agent version that should be download and install
WAZUH_AGENT_VERSION=$1

# IP address or FQDN of Wazuh Registration Server
#WAZUH_REGISTRATION_SERVER=

# By default 1514
#WAZUH_MANAGER_PORT=1514

# By default 1515
#WAZUH_REGISTRATION_PORT=1515

# IP address or FQDN of Wazuh Manager Server
WAZUH_MANAGER=$2

# Authd password / secret "wazuh-authd-pass"
WAZUH_REGISTRATION_PASSWORD=$3

# API credentials / secret "wazuh-api-cred"
WAZUH_API_USER=$4
WAZUH_API_PASSWORD=$5

# Content ############################################
FX_ubuntu_wazuh-agent_dl () {
 printf "\n\t\t\t FX Wazuh dl pkg\n\n"

 nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
  /usr/bin/wget -P /tmp https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_${WAZUH_AGENT_VERSION}_amd64.deb
  sleep 20s
 "
}

FX_ubuntu_wazuh-agent_dpkg () {
 printf "\n\t\t\t FX Wazuh inst dpkg\n\n"

 nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
  /usr/bin/dpkg -i /tmp/wazuh-agent_${WAZUH_AGENT_VERSION}_amd64.deb
  sleep 20s
 "
}

FX_ubuntu_wazuh-agent_conf () {
 printf "\n\t\t\t FX Wazuh agent conf\n\n" 

 nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
  /usr/bin/sed -i 's/MANAGER_IP/wazuh.security.svc.cluster.local/g' /var/ossec/etc/ossec.conf
  /usr/bin/grep -i address /var/ossec/etc/ossec.conf
  /usr/bin/grep -i port /var/ossec/etc/ossec.conf
 "
}

FX_ubuntu_wazuh-agent_reg () {
  printf "\n\t\t\t FX Wazuh agent reg\n\n" 

  nsenter --target 1 --mount --uts --ipc --net /bin/bash -c " 
    /var/ossec/bin/agent-auth -m ${WAZUH_MANAGER} -p 1515 -P ${WAZUH_REGISTRATION_PASSWORD} -d
  "
}

FX_ubuntu_wazuh-agent_unreg () {
  printf "\n\t\t\t FX Wazuh agent unreg\n\n" 

  TOKEN=$(curl -u '${WAZUH_API_USER}:${WAZUH_API_PASSWORD}' -sk -X GET "https://wazuh.security.svc.cluster.local:55000/security/user/authenticate?raw=true")
  getid="curl -sk -X GET \"https://wazuh.security.svc.cluster.local:55000/agents?pretty=true&sort=-ip,name\" -H \"Authorization: Bearer $TOKEN\" | jq -r '.data.affected_items[] | select(.name == \"$(hostname)\").id'"
  eval ${getid}
  removeid="curl -k -X DELETE \"https://wazuh.security.svc.cluster.local:55000/agents?pretty=true&older_than=0s&agents_list=${id}&status=all\" -H \"Authorization: Bearer $TOKEN\""
  eval ${removeid}
}
 
FX_ubuntu_wazuh-agent_svc () {
  printf "\n\t\t\t FX Wazuh agent svc\n\n" 

  nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
    /usr/bin/systemctl enable wazuh-agent
    /usr/bin/systemctl start wazuh-agent
  "
}

FX_ubuntu_wazuh-agent_rssvc () {
  printf "\n\t\t\t FX Wazuh agent rssvc\n\n"

  agent_status=$(nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "grep \"status=\" /var/ossec/var/run/wazuh-agentd.state")

  if [ $(echo ${agent_status} | grep connected) != "" ] ;
  then
    printf "\n\t\t\t\t Wazuh agent status Connected service restart"

    nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
      /usr/bin/systemctl restart wazuh-agent
    "
  fi
}

FX_ubuntu_wazuh-agent_rssvc2 () {
  nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
    /usr/bin/systemctl restart wazuh-agent
  "
}

FX_ubuntu_wazuh-agent_chkinst () {
  printf "\n\t\t\t FX Wazuh agent chkinst\n\n"
  printf "\n\n\t\t--------------\n\n"

  nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
    var/ossec/bin/manage_agents -V
  "

  printf "\n\n\t\t--------------\n\n"

  nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
    /var/ossec/bin/manage_agents -l
  "

  printf "\n\n\t\t--------------\n\n"

  nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
    /var/ossec/bin/wazuh-control status
  "

  printf "\n\n\t\t--------------\n\n"

  nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
    /usr/bin/systemctl status wazuh-agent 
  "
}

FX_ubuntu_wazuh-agent_inst () {
  printf "\n\t\t Wazuh agent Installation\n\n"

  FX_ubuntu_wazuh-agent_dl
  FX_ubuntu_wazuh-agent_dpkg
  FX_ubuntu_wazuh-agent_conf
  FX_ubuntu_wazuh-agent_reg
  FX_ubuntu_wazuh-agent_svc
  FX_ubuntu_wazuh-agent_rssvc2
  FX_ubuntu_wazuh-agent_chkinst
}

FX_ubuntu_wazuh-agent_uninst () {
  printf "\n\t\t Wazuh agent UN-Installation\n\n"

  nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
    dpkg -r wazuh-agent
    rm -rf /var/lib/dpkg/info/wazuh-agent.*
    rm -rf /var/ossec
    systemctl disable wazuh-agent
    systemctl daemon-reload
  "
}
 
 
FX_ubuntu_wazuh-agent_reinst () {
  printf "\n\t\t Wazuh agent RE-Installation\n\n"

  FX_ubuntu_wazuh-agent_unreg
  FX_ubuntu_wazuh-agent_dl
  FX_ubuntu_wazuh-agent_dpkg
  FX_ubuntu_wazuh-agent_conf
  FX_ubuntu_wazuh-agent_reg
  FX_ubuntu_wazuh-agent_svc
  FX_ubuntu_wazuh-agent_rssvco
  FX_ubuntu_wazuh-agent_chkinst
} 

####################################
# Check if Wazuh-agent is already install
 
WAZUH_AGENT_VERSION_TR=$(echo $WAZUH_AGENT_VERSION | tr -d " ")

agent_inst=$(nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "ls /var/ossec")
agent_inst2=$?
 

if [ "$agent_inst2" -eq 2 ] ;
then
  printf "\n\n\t MAIN Wazuh Agent is not installed on node yet\n\n"

  FX_ubuntu_wazuh-agent_inst
else
  printf "\n\n\t MAIN Wazuh agent already installed Check version\n\n"

  agent_version=$(nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "dpkg -s wazuh-agent | grep -i version | cut -d ":" -f 2")  
  agent_version_tr=$(echo $agent_version | tr -d " ")
  
  if [ "$WAZUH_AGENT_VERSION_TR" == "$agent_version_tr" ] ;
  then
    printf "\n\n\t MAIN Wazuh agent already installed into expected version\n\n"
    
    exit 0
  else 

    printf "\n\n\t MAIN Wazuh agent already installed but NOT into expected version\n\n"

    FX_ubuntu_wazuh-agent_uninst
    FX_ubuntu_wazuh-agent_reinst
  fi
fi