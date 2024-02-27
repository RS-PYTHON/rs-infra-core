#!/bin/bash

set -x

## Variables ##############################################

WAZUH_AGENT_VERSION=$1
WAZUH_MANAGER=$2
WAZUH_REGISTRATION_PASSWORD=$3

## Check root ############################################


## Functions ###########################################


        prereq_wa_all() {

          sudo nsenter --target 1 --mount --uts --ipc --net /bin/bash
        
        }


        wa_dl_ubunt() {

          wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.2-1_amd64.deb

        
        }

        wa_dl_rhel() {

          wget https://packages.wazuh.com/4.x/yum/wazuh-agent-4.7.2-1.x86_64.rpm

        
        }

        wa_inst_ubunt() {

          sudo dpkg -i ./wazuh-agent_4.7.2-1_amd64.deb

        
        }

        

        wa_inst_rhel() {

          rpm -i wazuh-agent-4.7.2-1.x86_64.rpm

        
        }

        wa_setvars_all() {
    
          WAZUH_MANAGER='127.0.0.1'
          WAZUH_REGISTRATION_PASSWORD=**************

        }


        wa_regwa_all() {

           sudo /var/ossec/bin/agent-auth  -m 127.0.0.1 cd -p 32605 -P **************
           
        }

        wa_confvars_all() {

           sed -i 's/MANAGER_IP/127.0.0.1/g' /var/ossec/etc/ossec.conf
           sed -i 's/1514/31169/g' /var/ossec/etc/ossec.conf

        }

        wa_checkinst_all() {

           sudo /var/ossec/bin/manage_agents -V
           sudo /var/ossec/bin/manage_agents -L

        }


        wa_svc_all() {

           sudo systemctl enable wazuh-agent
           sudo systemctl start wazuh-agent

        }

        ## Exec ##################################

        if [ "$(grep -Ei 'ubuntu' /etc/*release)" ]
            then

              #echo " It's a Ubuntu based system"
              prereq_wa_all
              wa_dl_ubunt
              wa_inst_ubunt
              wa_setvars_all
              wa_regwa_all
              wa_confvars_all
              wa_checkinst_all
              wa_svc_all

        
        elif [ "$(grep -Ei 'redhat' /etc/*release)" ]
            then
            
              #echo "It's a RHEL based system."
              prereq_wa_all
              wa_dl_rhel
              wa_inst_rhel
              wa_setvars_all
              wa_regwa_all
              wa_confvars_all
              wa_checkinst_all
              wa_svc_all
        
        fi