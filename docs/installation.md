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

# Create conda env with python=3.<change_with_version> and activate it
conda create -y -n rspy python=3.xx.y
conda activate rspy

# Install Ansible, Terraform, Openstackclient
conda run conda install -y -c conda-forge "ansible<12" terraform python-openstackclient passlib boto3 kubernetes-helm kubernetes-client python-kubernetes

conda run ansible-galaxy collection install kubernetes.core openstack.cloud amazon.aws
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
- Node groups, Network sizing, S3 buckets, public docker hub account (optionnal) in `inventory/mycluster/cluster.tfvars`
- S3 backend for terraform in `inventory/mycluster/backend.tfvars`
- Values for custom parameters in `inventory/mycluster/host_vars/setup/apps.yml`
- Values for `all.hosts.setup.ansible_python_interpreter` and `all.hosts.localhost.ansible_python_interpreter` in `inventory/mycluster/hosts.yaml`

### 5. Deploy the managed private docker registry (optionnal)

You can opt-in to deploy a managed private docker registry. It can be used later to avoid pulling multiple time the docker images from the public docker hub (docker.io). It will deploy an a private harbor registry configured as a ([proxy cache](https://goharbor.io/docs/2.4.0/administration/configure-proxy-cache/)).

```shellsession
ansible-playbook registry.yaml \
    -i inventory/mycluster/hosts.yaml
```

Note: if you want to use the managed private docker registry with the rest of the deployment, set the flag private_registry to true when calling the `apps.yaml` ansible playbooks.

### 6. Generate the inventory

```shellsession
ansible-playbook generate_inventory.yaml \
    -i inventory/mycluster/hosts.yaml
```

### 7. Create and configure machines

```shellsession
ansible-playbook cluster.yaml \
    -i inventory/mycluster/hosts.yaml
```

### 8. Deploy the apps

Connect on the bastion with ssh and go into the ~/rs-infra-core repository :

```shellsession
ssh -i inventory/mycluster/privatekey.pem ubuntu@<BASTION_IP>
cd ~/rs-infra-core
```

Deploy the rs-infra-core apps :

```shellsession
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml
    -e private_registry=true
```

(Optional) : You can add a flag to enable of disable the usage of the managed private docker registry. By default it's disabled : `-e private_registry=false`

(Optional) : You can change the default wait timeouts by adding one of these flags. Values are expressed in seconds:
- `-e crd_wait_timeout=30` for `CustomResourceDefinition`
- `-e job_wait_timeout=180` for `Job`
- `-e custom_wait_timeout=180` for `Certificate`, `Cluster`, `ClusterIssuer`, `Keycloak` and `KeycloakRealmImport`
- `-e native_wait_timeout=360` for `Pod`, `Deployment`, `StatefulSet` and `DaemonSet`

!!! warning "Note: DNS configuration"
    At this point, you should configure your domain name to point to the Kubernetes `ingress-nginx-controller` service (Type LoadBalancer) external's IP (`kubectl -n ingress-nginx get svc ingress-nginx-controller`).

(Optional) : Deploy the rs-infra-monitoring, rs-workflow-env or rs-server-deployment :

(still on the bastion)

```shellsession
cd ~ ;

git clone https://github.com/RS-PYTHON/rs-infra-monitoring.git ;
git clone https://github.com/RS-PYTHON/rs-workflow-env.git ;
git clone https://github.com/RS-PYTHON/rs-server-deployment.git ;

cd ~/rs-infra-core ;
```

```shellsession
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e '{"package_paths": ["~/rs-infra-monitoring/apps/"]}'
    -e private_registry=true ;
```

```shellsession
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e '{"package_paths": ["~/rs-workflow-env/apps/"]}'
    -e private_registry=true ;
```

!!! warning "Disclaimer: **After** Jupyterhub installation (rs-workflow-env)"
    Because Dask is configured to use JupyterHub authentication, you need to generated a token from JupyterHub and configure rs-server-staging with this token, so it can uses the Dask cluster.
    See **_"Prerequisite"_** in the [how-to/Dask Gateway](./how-to/Dask-gateway.md).

!!! warning "Disclaimer: **After** Prefect-Worker installation (rs-workflow-env)"
    See the [how-to/Prefect-Worker](./how-to/Prefect%20Worker.md) after deploying rs-workflow-env.

```shellsession
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e '{"package_paths": ["~/rs-server-deployment/apps/"]}' ;
    -e private_registry=true ;
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
