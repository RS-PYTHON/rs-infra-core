# Infrastructure - Installation
## Overview

![Infrastructure overview](./media/RSPY_infra_smallres.png)

> **Admin's machine is called BASTION in the rest of the installation manual**

## _Bastion_ requirements

- miniconda
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

### 1. Get the rs-infrastructure repository

```shellsession
git clone https://github.com/RS-PYTHON/rs-infrastructure.git
cd rs-infrastructure
```

### 2. Install requirements

```shellsession
# Install miniconda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh

# Init conda depending on your shell
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

# Create conda env with python=3.11 and activate it
conda create -y -n rspy python=3.11
conda activate rspy

# Install Ansible, Terraform, Openstackclient
conda install conda-forge::ansible
conda install conda-forge::terraform
conda install conda-forge::python-openstackclient

# Init Kubespray collection with remote
git submodule update --init --remote


pip install -U pyOpenSSL ecdsa -r collections/kubespray/requirements.txt

ansible-galaxy collection install \
    kubernetes.core \
    openstack.cloud
```

### 3. Copy the sample inventory

```shellsession
cp -rfp inventory/sample inventory/mycluster
```

### 4. Review and change the default configuration to match your needs

```shellsession
cp -rfp roles/terraform/create-cluster/tasks/.env.template roles/terraform/create-cluster/tasks/.env
```

Copy the openrc.sh.template into openrc.sh and change the values inside to match your configuration :

```shellsession
cp -rfp inventory/mycluster/openrc.sh.template inventory/mycluster/openrc.sh
```

- Credentials, domain name, the stash license, S3 endpoints in `inventory/mycluster/host_vars/setup/main.yaml`
- Credentials in `roles/terraform/create-cluster/tasks/.env`
- Credentials, domain name in `inventory/mycluster/openrc.sh`
- Node groups, Network sizing, S3 buckets in `inventory/mycluster/cluster.tfvars`
- Optimization for well-known zones and/or internal-only domains, i.e. VPN/Object Storage for internal networks in `inventory/mycluster/host_vars/setup/kubespray.yaml`

### 5. Create and configure machines

```shellsession
ansible-playbook cluster.yaml \
    -i inventory/mycluster/hosts.yaml
```


### 6. Deploy Kubernetes with `kubespray`

```shellsession
ansible-playbook kubernetes.yaml \
    -i inventory/mycluster/hosts.yaml \
```

### 7. Deploy the apps

```shellsession
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml
```

# Copyright and license

The Reference System Software as a whole is distributed under the Apache License, version 2.0. A copy of this license is available in the [LICENSE](LICENSE) file. Reference System Software depends on third-party components and code snippets released under their own license (obviously, all compatible with the one of the Reference System Software). These dependencies are listed in the [NOTICE](NOTICE.md) file.
