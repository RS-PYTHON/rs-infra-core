# Wazuh Server Installation


##  1. Enable Bcrypt encryption for installation


Backup original file `encrypt.py` to `encrypt.py.ori` 

```
mv ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py.ori
```

Download library [Passlib library](https://raw.githubusercontent.com/ansible/ansible/3f74bc08cefccec791c9dc5315185d2396e5c5ac/lib/ansible/utils/encrypt.py)


`wget https://raw.githubusercontent.com/ansible/ansible/3f74bc08cefccec791c9dc5315185d2396e5c5ac/lib/ansible/utils/encrypt.py -O ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py`


##  2. Genereate self-signed certificates


Generate SSL certificates [Kubernetes deployments](https://documentation.wazuh.com/current/deployment-options/deploying-with-kubernetes/kubernetes-deployment.html#setup-ssl-certificates)


### 2.1 Generate certificates for dashboard  

```
./apps/wazuh-server/wazuh/certs/dashboard_http/generate_certs.sh
```

*Two files should be generated*  : 


`cert.pem`
`key.pem`

*into folder*

`./apps/wazuh-server/wazuh/certs/dashboard_http`



### 2.2 Generate certificates for all other nodes 

```
./apps/wazuh-server/wazuh/certs/indexer_cluster/generate_certs.sh
```

*Several files should be generated* 


`admin-key-temp.pem`
`admin-key.pem`
`admin.csr`
`admin.pem`
`dashboard-key-temp.pem`
`dashboard-key.pem`
`dashboard.csr`
`dashboard.pem`
`filebeat-key-temp.pem`
`filebeat-key.pem`
`filebeat.csr`
`filebeat.pem`
`node-key-temp.pem`
`node-key.pem`
`node.csr`
`node.pem`
`root-ca-key.pem`
`root-ca.pem`
`root-ca.srl`


*into folder :* 

`./apps/wazuh-server/wazuh/certs/indexer_cluster`


##  3. Apply credentials

> [!IMPORTANT]  
> After Wazuh Server application is installed

In order to apply cerdentials set during installation process

Regarding Wazuh editor documentation : 
Kubernetes deployments [Update accounts credentials](https://github.com/wazuh/wazuh-documentation/blob/v4.7.2/source/deployment-options/deploying-with-kubernetes/kubernetes-deployment.rst#applying-the-changes)

### 3.1 Open intercative session to indexer pod 0  


```
kubectl exec -it wazuh-indexer-0 -n wazuh -- /bin/bash
```

### 3.2 Set variables 

```
export INSTALLATION_DIR=/usr/share/wazuh-indexer
CACERT=$INSTALLATION_DIR/certs/root-ca.pem
KEY=$INSTALLATION_DIR/certs/admin-key.pem
CERT=$INSTALLATION_DIR/certs/admin.pem
export JAVA_HOME=/usr/share/wazuh-indexer/jdk
```

### 3.3 Run command  





```

bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh -cd /usr/share/wazuh-indexer/opensearch-security/ -nhnv -cacert  $CACERT -cert $CERT -key $KEY -p 9200 -icl -h $NODE_NAME

```


> [!NOTE]  
> Note: Wait a little bit that cluster should be ready to execute command. Anyway If status is not ready command is relaunch automatically until that cluster be ready. 

`Clusterstate: GREEN`


*Test to login to Web UI with new credentials to validate oepration*

 




