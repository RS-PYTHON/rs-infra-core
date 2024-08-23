# Wazuh Server Installation

## 1. Enable Bcrypt encryption for installation

Backup original file `encrypt.py` to `encrypt.py.ori`

```bash
mv ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py.ori
```

Download library [Passlib library](https://raw.githubusercontent.com/ansible/ansible/3f74bc08cefccec791c9dc5315185d2396e5c5ac/lib/ansible/utils/encrypt.py)

```bash
wget https://raw.githubusercontent.com/ansible/ansible/3f74bc08cefccec791c9dc5315185d2396e5c5ac/lib/ansible/utils/encrypt.py -O ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py
```

## X. Apply credentials

> [!IMPORTANT]  
> After Wazuh Server application is installed

In order to apply credentials set during installation process

Regarding Wazuh editor documentation :
Kubernetes deployments [Update accounts credentials](https://github.com/wazuh/wazuh-documentation/blob/v4.7.2/source/deployment-options/deploying-with-kubernetes/kubernetes-deployment.rst#applying-the-changes)

### X.1 Open interactive session to indexer pod 0

```bash
kubectl exec -it wazuh-indexer-0 -n security -- /bin/bash
```

### X.2 Set variables

```bash
export INSTALLATION_DIR=/usr/share/wazuh-indexer

CACERT_ADMIN=$INSTALLATION_DIR/certs/admin/ca.crt
KEY_ADMIN=$INSTALLATION_DIR/certs/admin/tls.key
CERT_ADMIN=$INSTALLATION_DIR/certs/admin/tls.crt

export JAVA_HOME=/usr/share/wazuh-indexer/jdk
```

### X.3 Run command

```bash
bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh -cd /usr/share/wazuh-indexer/opensearch-security/ -nhnv -cacert  $CACERT_ADMIN -cert $CERT_ADMIN -key $KEY_ADMIN -p 9200 -icl -h $NODE_NAME
```

> [!NOTE]  
> Note: Wait a little bit that cluster should be ready to execute command. Anyway If status is not ready command is relaunch automatically until that cluster be ready.

`Clusterstate: GREEN`

Test to login to Web UI with new credentials to validate operation.
