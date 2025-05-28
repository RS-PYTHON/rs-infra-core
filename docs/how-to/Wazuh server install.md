# Wazuh Server Installation

## A. Pre-Install

### 1. Generate self-signed certificates

Generate SSL certificates [Kubernetes deployments](https://documentation.wazuh.com/current/deployment-options/deploying-with-kubernetes/kubernetes-deployment.html#setup-ssl-certificates)

#### 1.1 Generate certificates for dashboard

```bash
./apps/01-wazuh-server/wazuh/certs/dashboard_http/generate_certs.sh
```

*Two files should be generated:*

`cert.pem`
`key.pem`

*In the following folder:*

`./apps/01-wazuh-server/wazuh/certs/dashboard_http`

#### 1.2 Generate certificates for all other nodes

```bash
./apps/01-wazuh-server/wazuh/certs/indexer_cluster/generate_certs.sh
```

*Several files should be generated:*

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

`./apps/01-wazuh-server/wazuh/certs/indexer_cluster`

### 2. Setup SSO (Keycloak SAML)

#### 2.1 Download required files from Keycloak

Regarding Wazuh editor documentation : [Keycloak](https://documentation.wazuh.com/current/user-manual/user-administration/single-sign-on/administrator/keycloak.html)

See Section `8. Note the necessary parameters from the SAML settings of Keycloak.`

Dowload file from Keycloak in one single file after

- Go to the Keycloak web admin page: <https://iam.example.com/admin/master/console/>
- Choose your realm (default: rspy) on the top left drop-down panel
- Click on `Clients` under the Manage panel
- Click on the wazuh client (default: wazuh-saml)
- Click on the `Action` button on the top right of the wazuh client panel and select `Download adaptor configs`
- Select `Mod Auth Mellon files` and click on Download

The downloaded archive contains two files:

- idp-metadata.xml
- sp-metadata.xml

#### 2.2 Import the Keycloak configuration files

From the previous downloaded archive, extract the files `idp-metadata.xml` and `sp-metadata.xml` and copy them to `./apps/01-wazuh-server/`

## B. Install Agent App

Once all Wazuh server components are up and running, Wazuh agent installation can be launched.
