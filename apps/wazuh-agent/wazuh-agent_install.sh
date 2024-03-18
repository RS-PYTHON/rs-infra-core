#!/bin/bash

set -x

## Variables ##############################################
#  See editor configuration 
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

# Authd password  / secret "wazuh-authd-pass"
WAZUH_REGISTRATION_PASSWORD=$3


    # Content ############################################


      FX_ubuntu_wazuh-agent_dl () {


       nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
       
       /usr/bin/wget -P /tmp https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_${WAZUH_AGENT_VERSION}_amd64.deb
       
      sleep 20s

        "
        }

      FX_ubuntu_wazuh-agent_inst () {


       nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
       
       
       /usr/bin/dpkg -i /tmp/wazuh-agent_${WAZUH_AGENT_VERSION}_amd64.deb
       
       sleep 20s

        "
        }

       FX_ubuntu_wazuh-agent_conf () {

       nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
       
       
        /usr/bin/sed -i 's/MANAGER_IP/wazuh.wazuh.svc.cluster.local/g' /var/ossec/etc/ossec.conf
        
        /usr/bin/grep -i address  /var/ossec/etc/ossec.conf

        /usr/bin/grep -i port  /var/ossec/etc/ossec.conf

        "
        }



      FX_ubuntu_wazuh-agent_reg () {


       nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
       
       
        /var/ossec/bin/agent-auth  -m ${WAZUH_MANAGER} -p 1515 -P ${WAZUH_REGISTRATION_PASSWORD} -d


        "
        }

      

        
      FX_ubuntu_wazuh-agent_svc () {

       nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
       
       
        /usr/bin/systemctl enable wazuh-agent
        
        /usr/bin/sudo systemctl start wazuh-agent

    
        "
        }

      FX_ubuntu_wazuh-agent_chkinst () {

       nsenter --target 1 --mount --uts --ipc --net /bin/bash -c "
       
       
      /var/ossec/bin/manage_agents -V
      
      /var/ossec/bin/manage_agents -l

      /var/ossec/bin/wazuh-control status

      /usr/bin/systemctl status wazuh-agent
  
        "
        }


              FX_ubuntu_wazuh-agent_dl
              FX_ubuntu_wazuh-agent_inst
              FX_ubuntu_wazuh-agent_conf
              FX_ubuntu_wazuh-agent_reg
              FX_ubuntu_wazuh-agent_svc
              FX_ubuntu_wazuh-agent_chkinst
        
