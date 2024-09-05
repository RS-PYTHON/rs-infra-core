# Wazuh Server Installation

## A. Pre-Install

### 1. Enable Bcrypt encryption for installation

Backup original file `encrypt.py` to `encrypt.py.ori`

```bash
mv ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py.ori
```

Download library [Passlib library](https://raw.githubusercontent.com/ansible/ansible/3f74bc08cefccec791c9dc5315185d2396e5c5ac/lib/ansible/utils/encrypt.py)

```bash
wget https://raw.githubusercontent.com/ansible/ansible/3f74bc08cefccec791c9dc5315185d2396e5c5ac/lib/ansible/utils/encrypt.py -O ~/miniforge3/envs/rspy/lib/python3.11/site-packages/ansible/utils/encrypt.py
```


> [!IMPORTANT]  
> `idp-metadata.xml` and `sp-metadata.xml` should be rightly formated into XML format. The original XML files are 1 line and it may cause issues. You can use the following command based on [xmllint](https://gitlab.gnome.org/GNOME/libxml2):
>
> ```bash
> cat <file.xml> | XMLLINT_INDENT= xmllint --format - | tail -n +2 > <new_file.xml>
> ```

## B. Post-Install: Apply modifications set during installation process (new credentials and SSO)

> [!IMPORTANT]  
> After Wazuh Server application is installed (PODs are 'running' and UI is reachable).

Only for information, you can find below usefull documentation from Wazuh. The actual commands to run are in [1. Open interactive session to indexer pod 0](#1-open-interactive-session-to-indexer-pod-0).

- [Update accounts credentials](https://github.com/wazuh/wazuh-documentation/blob/v4.7.2/source/deployment-options/deploying-with-kubernetes/kubernetes-deployment.rst#applying-the-changes) from step : `2. Start a bash shell in wazuh-indexer-0 once more`

- [Enable SSO configuration](https://documentation.wazuh.com/current/user-manual/user-administration/single-sign-on/administrator/keycloak.html#wazuh-indexer-configuration)

### 1.1 Open interactive session to indexer pod 0

```bash
kubectl exec -it wazuh-indexer-0 -n security -- /bin/bash
```

### 1.2 Set variables

```bash
export INSTALLATION_DIR=/usr/share/wazuh-indexer

CACERT_ADMIN=$INSTALLATION_DIR/certs/admin/ca.crt
KEY_ADMIN=$INSTALLATION_DIR/certs/admin/tls.key
CERT_ADMIN=$INSTALLATION_DIR/certs/admin/tls.crt

export JAVA_HOME=/usr/share/wazuh-indexer/jdk
```

### 1.3 Run command

Check buitlin variables

```bash
echo $NODE_NAME
wazuh-indexer-0

echo $CLUSTER_NAME
wazuh

echo $NETWORK_HOST
0.0.0.0
```

Set required variables

```bash
export INSTALLATION_DIR=/usr/share/wazuh-indexer
```

```bash
CACERT=$INSTALLATION_DIR/certs/root-ca.pem
KEY=$INSTALLATION_DIR/certs/admin-key.pem
CERT=$INSTALLATION_DIR/certs/admin.pem
```

```bash
export JAVA_HOME=/usr/share/wazuh-indexer/jdk
```

#### 1.3.3 Execute commands

Verify OpenSearch status.

```bash
bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh -nhnv -cacert  $CACERT -cert $CERT -key $KEY -p 9200 -icl -h $NODE_NAME --
show-info
Security Admin v7
Will connect to wazuh-indexer-0:9200 ... done
Connected as "CN=admin,O=Company,L=California,C=US"
OpenSearch Version: 2.8.0
```

Apply new credentials.

```bash
bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh -cd /usr/share/wazuh-indexer/opensearch-security/ -nhnv -cacert  $CACERT_ADMIN -cert $CERT_ADMIN -key $KEY_ADMIN -p 9200 -icl -h $NODE_NAME
```

Apply SSO settings.

```bash
bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh -f /usr/share/wazuh-indexer/opensearch-security/config.yml -icl -key $KEY -cert $CERT -cacert $CACERT -h 127.0.0.1 -nhnv
```

```bash
bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh -f /usr/share/wazuh-indexer/opensearch-security/roles_mapping.yml -icl -key $KEY -cert $CERT -cacert $CACERT -h 127.0.0.1 -nhnv
```

```bash
bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/securityadmin.sh -f /usr/share/wazuh-indexer/opensearch-security/roles.yml -icl -key $KEY -cert $CERT -cacert $CACERT-h 127.0.0.1 -nhnv
```

> [!NOTE]  
> Note: Wait a little bit for the cluster to be ready to execute command. Anyway If the status is not ready the command is re-executed automatically until the cluster is ready.

`Clusterstate: GREEN`

> [!NOTE]  
> Note: All commands should be finished with ending line :  
> `Done with success`

#### 1.3.4 Restart Indexer et Dashboard pods

Restart Indexer pod

```bash
kubectl -n security delete pod wazuh-indexer-0
```

Restart Dashboard pod

```bash
kubectl -n security delete pod wazuh-dashboard-XYZ
```

#### 1.3.5 Testing result

Test to login throuh Web UI with new credentials of technical accounts to validate operation.
Test to login throuh Web UI with SSO credentials.

## B. Install Agent App

Once Wazuh is completly restrated up and running, Wazuh agent installation can be launched.
