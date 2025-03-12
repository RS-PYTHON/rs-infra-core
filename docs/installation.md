# Infrastructure - Installation
## Overview

![Infrastructure overview](./media/RSPY_infra_smallres.png)

> **Admin's machine is called BASTION in the rest of the installation manual**

## _Bastion_ requirements

- miniforge
- git
- jq

## Dependencies

### Terraform

This project exploits Terraform to deploy the infrastructure on the Cloud Provider.  
The fully detailed documentation and configuration options are available on its page: [https://www.terraform.io/](https://www.terraform.io/)

### Kubespray

This project exploits Kubespray to deploy Kubernetes.  
The fully detailed documentation and configuration options are available on its page: [https://kubespray.io/](https://kubespray.io/)

### HashiCorp Vault (optional)

This project can integrate credentials from a custom `HashiCorp Vault` instance, see the specific documentation: [how to/Credentials](./how-to/Credentials.md)

### Openstack CLI

This project exploits Openstack CLI to manage the state of the infrastructure on the Cloud Provider.  
The fully detailled documentation and configuration options are available on its page: [https://docs.openstack.org/newton/user-guide/cli.html](https://docs.openstack.org/newton/user-guide/cli.html)

## Quickstart

### 1. Get the rs-infra-core repository

```shellsession
git clone https://github.com/RS-PYTHON/rs-infra-core.git
cd rs-infra-core
```

### 2. Install requirements

```shellsession
# Install miniforge
mkdir -p ~/miniforge3
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" -O ~/miniforge3/miniforge.sh
bash ~/miniforge3/miniforge.sh -b -u -p ~/miniforge3
rm -f ~/miniforge3/miniforge.sh

# Init conda depending on your shell
~/miniforge3/bin/conda init bash
~/miniforge3/bin/conda init zsh

# Create conda env with python=3.11 and activate it
conda create -y -n rspy python=3.11
conda activate rspy

# Install Ansible, Terraform, Openstackclient
conda install conda-forge::ansible
conda install conda-forge::terraform
conda install conda-forge::python-openstackclient
conda install conda-forge::passlib
conda install conda-forge::boto3

# Init Kubespray collection with remote
git submodule update --init --remote

ansible-galaxy collection install \
    openstack.cloud \
    amazon.aws
```

### 3. Copy the sample inventory

```shellsession
cp -rfp inventory/sample inventory/mycluster
```

### 4. Review and change the default configuration to match your needs

```shellsession
cp -rfp inventory/mycluster/.env.template inventory/mycluster/.env
```

Copy the openrc.sh.template into openrc.sh and change the values inside to match your configuration :

```shellsession
cp -rfp inventory/mycluster/openrc.sh.template inventory/mycluster/openrc.sh
```

- Credentials, domain name, the stash license, S3 endpoints in `inventory/mycluster/host_vars/setup/main.yaml`
- Credentials in `roles/terraform/cluster/tasks/.env`
- Credentials, domain name in `inventory/mycluster/openrc.sh`
- Node groups, Network sizing, S3 buckets in `inventory/mycluster/cluster.tfvars`
- S3 backend for terraform in `inventory/mycluster/backend.tfvars`
- Values for custom parameters in `inventory/mycluster/host_vars/setup/apps.yml`
- Values for `all.hosts.setup.ansible_python_interpreter` and `all.hosts.localhost.ansible_python_interpreter` in `inventory/mycluster/hosts.yaml`

```shellsession
ansible-playbook generate_inventory.yaml \
    -i inventory/mycluster/hosts.yaml
```

### 5. Create and configure machines

```shellsession
ansible-playbook cluster.yaml \
    -i inventory/mycluster/hosts.yaml
```

### 6. Deploy the apps

Connect on the bastion with ssh and go into the ~/rs-infra-core repository :

```shellsession
ssh -i inventory/mycluster/privatekey.pem ubuntu@<BASTION_IP>
cd ~/rs-infra-core
```

Deploy the rs-infra-core apps :

```shellsession
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml
```

!!! warning "Note: DNS configuration"
    At this point, you should configure your domain name to point to the Kubernetes `ingress-nginx-controller` service (Type LoadBalancer) external's IP (`kubectl -n ingress-nginx get svc ingress-nginx-controller`).

(Optionnal) : Deploy the rs-infra-security, rs-infra-monitoring, rs-workflow-env or rs-server-deployment :

(still on the bastion)

!!! warning "Pre-requirement: JupyterHub token"
    Because Dask is configured to use JupyterHub authentication, you need to generated a token from JupyterHub and configure rs-server-staging with this token, so it can uses the Dask cluster.
    See **_"Prerequisite"_** in the [how-to/Dask Gateway](./how-to/dask-gateway.md).

!!! warning "Disclaimer: For Prefect-Worker post-configuration"
    See **_"2. set `Concurrency Limit` on workpool _on-demand-k8s-pool_"_** in the [how-to/Prefect-Worker](./how-to/Prefect-Worker.md) after deploy the app.

!!! warning "Disclaimer: For Wazuh Server installation"
    See **_"B. Post-Install: Apply modifications set during installation process (new credentials and SSO)"_** in the [how-to/Wazuh-Server_Install](./how-to/Wazuh-Server_Install.md) and execute scripts after deploy the app.

!!! warning "Disclaimer: For Neuvector post-configuration"
    See **_"Enable SSO"_** in the [how-to/Neuvector](./how-to/Neuvector.md) after deploy the app.
```shellsession

cd ~ ;

git clone https://github.com/RS-PYTHON/rs-infra-security.git ;
git clone https://github.com/RS-PYTHON/rs-infra-monitoring.git ;
git clone https://github.com/RS-PYTHON/rs-workflow-env.git ;
git clone https://github.com/RS-PYTHON/rs-server-deployment.git ;

cd ~/rs-infra-core ;

ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e '{"package_paths": ["~/rs-infra-security/apps/"]}' ;

ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e '{"package_paths": ["~/rs-infra-monitoring/apps/"]}' ;

ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e '{"package_paths": ["~/rs-workflow-env/apps/"]}' ;

ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e '{"package_paths": ["~/rs-server-deployment/apps/"]}' ;
```

# Copyright and license

The Reference System Software as a whole is distributed under the Apache License, version 2.0. A copy of this license is available in the [LICENSE](../LICENSE) file. Reference System Software depends on third-party components and code snippets released under their own license (obviously, all compatible with the one of the Reference System Software). These dependencies are listed in the [NOTICE](../NOTICE.md) file.

<br> <br>
![](media/banner_logo.jpg)
<!---
Centering the banner logo image is not rendered by the mkdocs inside the rs-documentation repository
-->
<!---
<p align="center">
 <img src="/docs/media/banner_logo.jpg" width="71%" height="71%" />
</p>
-->
<p align="center">This project is funded by the EU and ESA.</p>
<br> <br>
