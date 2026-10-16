# rs-infra-core

Kubernetes infrastructure of [RS-Python](https://github.com/RS-PYTHON/rs-documentation): creation of the cluster on
the cloud provider and deployment of its core components (networking, certificates, identity and access management,
databases, backups), on top of which all the other components of RS-Python are deployed.

## Overview

This repository provides:

- the [Terraform](https://developer.hashicorp.com/terraform) code that creates the cloud resources: private network,
  bastion, managed Kubernetes cluster with its node pools, S3 buckets, shared file systems
  ([roles/terraform](roles/terraform)),
- the [Ansible](https://docs.ansible.com/) playbooks that create the cluster (`cluster.yaml`), start and stop it
  (`start-stop.yaml`), generate the inventory (`generate_inventory.yaml`) and deploy or remove the applications of
  any RS-Python repository (`apps.yaml`, `remove_apps.yaml`),
- a sample inventory ([inventory/sample](inventory/sample)) with all the parameters of a platform,
- the core applications ([apps](apps)): [Envoy Gateway](https://gateway.envoyproxy.io/),
  [cert-manager](https://cert-manager.io/), [Keycloak](https://www.keycloak.org/),
  [CloudNativePG](https://cloudnative-pg.io/), [Velero](https://velero.io/), CSI drivers...

![Infrastructure overview](docs/images/infrastructure.svg)

## Getting started

Follow the [infrastructure installation](docs/installation.md) guide, then the
[deployment of RS-Python](https://github.com/RS-PYTHON/rs-documentation/blob/develop/docs/administration/deploy.md).

## Documentation

- [Infrastructure installation](docs/installation.md)
- [How-to guides](docs/installation.md#operations): cluster management, credentials, remote kubectl, backups and
  restorations...
- [Update the infrastructure](https://github.com/RS-PYTHON/rs-documentation/blob/develop/docs/administration/update-infrastructure.md)
- [RS-Python documentation](https://github.com/RS-PYTHON/rs-documentation)

## Related repositories

- [rs-infra-monitoring](https://github.com/RS-PYTHON/rs-infra-monitoring): monitoring stack, deployed with the
  playbooks of this repository.
- [rs-workflow-env](https://github.com/RS-PYTHON/rs-workflow-env): virtual environment (JupyterHub, Prefect, Dask
  Gateway).
- [rs-server-deployment](https://github.com/RS-PYTHON/rs-server-deployment): deployment of the RS-Python services.
- [rs-workflow-deployment](https://github.com/RS-PYTHON/rs-workflow-deployment): deployment of the Prefect flows.

## Contributing

See the [contribution guidelines](https://github.com/RS-PYTHON/rs-documentation/blob/develop/docs/developers/contributing.md).
Report bugs in the [issue tracker](https://github.com/RS-PYTHON/rs-infra-core/issues). In case of sensitive bugs like
security vulnerabilities, please contact <ops_coprs@airbus.com> directly instead of using the issue tracker.

## Licensing

The code in this project is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

---

![](https://raw.githubusercontent.com/RS-PYTHON/.github/refs/heads/main/profile/banner_logo.jpg)

This project is funded by the EU and ESA.
