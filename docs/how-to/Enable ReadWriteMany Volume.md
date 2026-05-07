# Enable ReadWriteMany volume

## Preambule

A ReadWriteMany volume, often written `rwx` is volume that can be mounted as read-wirte by many nodes. For more information, [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes).

OVH Cloud Provider enabled this feature in April 2026. The following How-to is based on the documentation provided by OVH here : [https://help.ovhcloud.com/csm/en-public-cloud-storage-file-storage-service-getting-started?id=kb_article_view&sysparm_article=KB0072892](https://help.ovhcloud.com/csm/en-public-cloud-storage-file-storage-service-getting-started?id=kb_article_view&sysparm_article=KB0072892).

Several methods are available for enabling this, but we have chosen ‘Via Manila CSI in a Kubernetes environment’, as this is the one that best meets our needs: a Kubernetes volume that can be created dynamically without manual intervention from an administrator.

It has been automated in pull request [RS-PYTHON/rs-infra-core#312](https://github.com/RS-PYTHON/rs-infra-core/pull/312) and [RS-PYTHON/rs-workflow-env#92](https://github.com/RS-PYTHON/rs-workflow-env/pull/92) when you install Kubernetes cluster from scratch.

However, you can enabled it if you already run a kubernetes cluster and don't want to redeploy everything.

## Instructions

### Installation OpenStack CLI

Install the Manila client to manage File Storage shares on the bastion:

```Bash
conda run -n rspy conda install -y -c conda-forge python-manilaclient python-openstackclient
```

### Preparing OpenStack resources for Manila CSI

#### Create a dedicated OpenStack user for Manila

You need a separate OpenStack user to manage Manila resources. This user can be created:

* Through the OVHcloud Control Panel (Public Cloud > Settings > Users & Roles)
* Or via the OVHcloud CLI

The roles needed are :

* share operator 
* network operator

The first to be able to ‘share’ the target network and ‘network operator’ to be able to display the desired network.

#### Collect OpenStack project and user details

Download your project’s openrc file from the OVHcloud Control Panel, matching the same region as your Kubernetes cluster, and note the following credentials:

* os-userName (value of OS_USERNAME)
* os-password
* os-domainName (=default)
* os-projectDomainID (=default)
* os-projectName (value of OS_TENANT_NAME)

#### Configure the OpenStack shared network

Manila requires a share network because the driver is configured with DHSS=true (driver_handles_share_servers).

This resource is managed by the owner of the OpenStack project.

Note: the following command are in GRA11, adapt to your region.

```Bash
# List private networks attached to your MKS cluster
openstack --os-region-name GRA11 network list

# Retrieve the network ID
openstack --os-region-name GRA11 network show -c id -f value <PRIVATE_NETWORK_NAME>

# Retrieve the subnet ID linked to this network
openstack --os-region-name GRA11 subnet show -c id -f value <PRIVATE_SUBNET_NAME>

# Create the Manila share network
openstack --os-region-name GRA11 share network create \
  --name mks-manila-csi-ops \
  --neutron-net-id <PRIVATE_NETWORK_ID> \
  --neutron-subnet-id <PRIVATE_SUBNET_ID>
```

Example output :

```Bash
+-----------------------------------+----------------------------------------------------------+
| Field                             | Value                                                    |
+-----------------------------------+----------------------------------------------------------+
| created_at                        | 2025-10-04T14:12:25.111776                               |
| description                       | None                                                     |
| id                                | 07363bc7-be2a-4a7d-b675-09844b344b3b                     |
| name                              | mks-manila-csi-ops                                       |
| network_allocation_update_support | True                                                     |
| project_id                        | <PROJECT_ID>                                             |
| security_service_update_support   | True                                                     |
| share_network_subnets             |                                                          |
|                                   | id = 90cf66fc-23eb-4dce-80a3-bf8fa3a912c3                |
|                                   | availability_zone = None                                 |
|                                   | created_at = 2025-10-04T14:12:25.126327                  |
|                                   | updated_at = None                                        |
|                                   | segmentation_id = None                                   |
|                                   | neutron_net_id = <PRIVATE_NETWORK_NAME>                  |
|                                   | neutron_subnet_id = <PRIVATE_SUBNET_NAME>                |
|                                   | ip_version = None                                        |
|                                   | cidr = None                                              |
|                                   | network_type = None                                      |
|                                   | mtu = None                                               |
|                                   | gateway = None                                           |
| status                            | active                                                   |
| updated_at                        | None                                                     |
+-----------------------------------+----------------------------------------------------------+
```

### Update the inventory

Option 1 (recommended) : Put this directly in your generated inventory file (`inventory/mycluster/group_vars/all/generated_inventory_vars.yaml`) :

```YAML
sharenetwork:
  manila_username: "<manila_username>"
  manila_password: "<manila_password>"
  sharenetwork_id: "<sharenetwork_id>"
  osprojectname: "<osprojectname>"
```

And replace with the correct values.

Option 2 : or create a new file in `{{ inventory_dir }}/host_vars/setup/sharenetwork.yaml` with the same content.

And regenerate the inventory file. **Be careful**, the auto generated values will be replaced with new ones, and this will severly mess up your inventory with wrong password everywhere.

### Deploy the apps

#### 00-storage-class

To deploy the new storage class (`sc-manila-nfs.yaml`).

```Bash
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e app="storage-class"
    -e private_registry=true ;
```

#### 01-csi-driver-nfs

```Bash
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e app="csi-driver-nfs"
    -e private_registry=true ;
```

#### 01-openstack-manila-csi

```Bash
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml \
    -e app="openstack-manila-csi"
    -e private_registry=true ;
```

### Create a shared volume

Take as example this file [RS-PYTHON/rs-workflow-env/apps/dask-gateway/sharedvolume.yaml](https://github.com/RS-PYTHON/rs-workflow-env/blob/feat-rspy994/create-rwx-volume/apps/dask-gateway/sharedvolume.yaml).
