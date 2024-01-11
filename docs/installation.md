# Infrastructure - Installation
## Overview

![Infrastructure overview](./media/RSPY_infra_smallres.png)

> **Admin's machine is called BASTION in the rest of the installation manual**

## _Bastion_ requirements

- ansible
- python3
- python3-pip
- git
- jq
- terraform

## Dependencies

### Terraform

This project exploits Terraform to deploy the infrastructure on the Cloud Provider.  
The fully detailed documentation and configuration options are available on its page: [https://www.terraform.io/](https://www.terraform.io/)

### Kubespray

This project exploits Kubespray to deploy Kubernetes.  
The fully detailed documentation and configuration options are available on its page: [https://kubespray.io/](https://kubespray.io/)

### HashiCorp Vault (optional)

This project can integrate credentials from a custom `HashiCorp Vault` instance, see the specific documentation: [how to/Credentials](./how-to/Credentials.md)

## Quickstart

### X. Get the rs-infrastructure repository

```shellsession
git clone https://github.com/RS-PYTHON/rs-infrastructure.git
```

### X. Install requirements

```shellsession
cd rs-infrastructure

git submodule update --init

VENVDIR=kubespray-venv
KUBESPRAYDIR=collections/kubespray
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
pip install -U pyOpenSSL ecdsa -r $KUBESPRAYDIR/requirements.txt

ansible-galaxy collection install \
    kubernetes.core \
    openstack.cloud
```

### X. Copy the sample inventory

```shellsession
cp -rfp inventory/sample inventory/mycluster
```

### X. Review and change the default configuration to match your needs

```shellsession
cp -rfp roles/terraform/create-cluster/tasks/.env.template roles/terraform/create-cluster/tasks/.env
```
 - Credentials, domain name, the stash license, S3 endpoints in `rs-infrastructure/inventory/mycluster/host_vars/setup/main.yaml`
 - Credentials in `roles/terraform/create-cluster/tasks/.env`
 - Node groups, Network sizing, S3 buckets in `rs-infrastructure/inventory/mycluster/cluster.tfvars`
 - Optimization for well-known zones and/or internal-only domains, i.e. VPN/Object Storage for internal networks in `inventory/mycluster/host_vars/setup/kubespray.yaml`
 
```shellsession
ansible-playbook generate_inventory.yaml \
    -i inventory/mycluster/hosts.yaml
```

### X. Create and configure machines

```shellsession
ansible-playbook cluster.yaml \
    -i inventory/mycluster/hosts.yaml
```

### X. Install security services

```shellsession
ansible-playbook security.yaml \
    -i inventory/mycluster/hosts.yaml \
    --become
```

### X. Deploy kubernetes with `kubespray`

```shellsession
# The option `--become` is required, for example writing SSL keys in /etc/,
# installing packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!

ansible-playbook collections/kubespray/cluster.yml \
    -i inventory/mycluster/hosts.yaml \
    --become
```

### X. Enable pod security policies (PSP) on the cluster

```shellsession
# /!\ create first the PSP and ClusterRoleBinding resources
# before enabling the admission plugin

ansible-playbook collections/kubespray/upgrade-cluster.yml \
    -i inventory/mycluster/hosts.yaml \
    --tags cluster-roles \
    -e podsecuritypolicy_enabled=true \
    --become

ansible-playbook collections/kubespray/upgrade-cluster.yml \
    -i inventory/mycluster/hosts.yaml \
    --tags master \
    -e podsecuritypolicy_enabled=true \
    --become
```

### X. Setup RS specifics

```shellsession
ansible-playbook rs-setup.yaml \
    -i inventory/mycluster/hosts.yaml
```

### X. Add the providerID spec to the nodes for the autoscaling

```shellsession
ansible-playbook cluster.yaml -i inventory/mycluster/hosts.yaml -t providerids
```

### X. Deploy the apps

```shellsession
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml
```

# Copyright and license

The Reference System Software as a whole is distributed under the Apache License, version 2.0. A copy of this license is available in the [LICENSE](LICENSE) file. Reference System Software depends on third-party components and code snippets released under their own license (obviously, all compatible with the one of the Reference System Software). These dependencies are listed in the [NOTICE](NOTICE.md) file.
