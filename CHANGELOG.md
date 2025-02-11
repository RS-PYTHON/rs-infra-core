# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> Content of release :
>
>- **Added** for new features.
>- **Changed** for changes in existing functionality.
>- **Deprecated** for soon-to-be removed features.
>- **Removed** for now removed features.
>- **Fixed** for any bug fixes.
>- **Security** in case of vulnerabilities.

## [0.2a10] - 2025-02-12

### Added
- RSPY-570 : Integrate DPR empty processor

### Changed

- rs-server : bumped the versions to 0.2.0-a10
- RSPY-596 : Update to stac-browser 3.3
- RSPY-577 : Update cluster deployment to OVH
- RSPY-580 : Changed cluster start and stop to be compatible with OVH

### Deprecated

- Prefect 2 is deprecated and is *partially* replaced with Prefect 3 and will be *fully* replaced with Prefect 3 in version `0.2a11`

|                        | Release 0.2a10 (current version)             | Release 0.2a11 (next version)               |
|------------------------|----------------------------------------------|---------------------------------------------|
| Prefect 2 internal svc | prefect-server.processing.svc.cluster.local  | X                                           |
| Prefect 2 public svc   | processing.example.com                       | X                                           |
| Prefect 3 internal svc | prefect3-server.processing.svc.cluster.local | prefect-server.processing.svc.cluster.local |
| Prefect 3 public svc   | prefect3.example.com                         | processing.example.com                      |

### Fixed

- RSPY-591 : Wazuh agents are not connected

## [0.2a9] - 2025-01-15

:sparkler: Happy new year !

### Changed

- Documentation for dask-gateway
- rs-server : bumped the versions to 0.2.0-a9

### Fixed

- RSPY-548 : No OpenTelemetry support in dask cluster
- RSPY-558 : Affinity and Toleration not set on rs-server-cadip, rs-server-adgs
- Grafana : generic oAuth, several users with the same email were not allowed

## [0.2a8] - 2024-12-13

### Added

- rs-server-staging : switch OGC API persistence to PostgreSQL, added `catalogBucket`
- rs-server-station-credentials : added adgs2 station
- dask-gateway : added `imagePullPolicy` and `cluster_name` parameter
- Prefect 3 server and worker

### Changed

- dask-gateway
  - removed `rs-server-common`
  - added `git`
  - updated `rs-server-staging`
- rs-server : bumped the versions to 0.2.0-a8
- `cluster.tfvars` updated
- docker base image from `quay.io` or `docker.io` migrated on `ghcr.io` (avoid pull limitations in CI)

### Deprecated

- Prefect 2 server and worker (will be removed in Q1 2025)

## [0.2a7] - 2024-11-22

### Added

- Dask-gateway : new server parameter `scheduler_extra_container_config`
- RSPY-360 : Add taint on nodes
- RSPY-479 : OVH : start a single isolated node
- RSPY-480 : OVH : deploy IAM for publication service

### Changed

- rs-server-staging : pre-requirement about the JupyterHub token updated (docs and conf)

### Fixed

- RSPY-503 : STAC Browser AUXIP deployment missing
- apikeymanager: set use_authlib_oauth to `true`
- RSPY-509 : Unable to retrieve traces older than 24 hours
- Tempo : missing backend configuration for S3
- RSPY-531 : [RS-STAGING] Bucket name not modifiable on current configuration

## [0.2a6] - 2024-11-07

### Added

- (Partial) RSPY-425 : CI/CD chain to build a Dask base image that embeds rs-client library
- RSPY-361 : Add egress to a set of nodes

### Changed

- Refactor terraform node labeling
- Update rs-server version and conf

### Fixed

- jupyterhub secret name

## [0.2a5] - 2024-10-14

### Added

- RSPY-230 : Deploy STAC browser
- rs-server : added application rs-server-station-credentials

### Changed

- Bump helm chart version for rs-server
- rs-server : updated several charts

### Fixed

- JupyterHub : Value of `RSPY_UAC_CHECK_URL`

## [0.2a4] - 2024-09-25

### Added

- RSPY-346 : OAuth2 with PKCE authorisation within JupyterHub

### Changed

- Bump helm chart version for rs-server
- Ingress path for rs-server-catalog and rs-server-staging

### Fixed

- RSPY-381 : [Deployment] Error during cluster creation
- RSPY-382 : [Deployment] Prometheus datasource not created
- RSPY-385 : CloudNative PG Deployment failed due to syntax issue on limit/request
- RSPY-386 : Grafana-Tempo deployment values don't match with apps.yaml
- RSPY-387 : Missing credential secret creation for Github Repository
- RSPY-388 : [Velero] First Deployment failed due to missing CRD
- RSPY-399 : [Infra] Impossible to create PV (quota reached)

## [0.2a3] - 2024-09-05

### Added

- RSPY-166 : Use Keycloak to login into Wazuh
- RSPY-264 : [Monitoring] Create Grafana datasources for PostgreSQL databases
- RSPY-266 : [Monitoring] Create JupyterHub ServiceMonitor
- RSPY-293 : Use Keycloak to login into Neuvector
- RSPY-312 : Configure Prefect Server logging
- RSPY-318 : Backup and restore Keycloak data
- RSPY-335 : Deploy dask gateway server

### Fixed

- RSPY-351 : Variabilize the bucket name

## [0.2a2] - 2024-07-17

### Added

- RSPY-317 : Deploy VELERO component on the cluster
- rs-server
  - mockup-station-lta : helm chart added
  - rs-server-catalog : parameter `app.uacHomeUrl` added
- CloudNativePG : restore procedure added

## [0.2a1] - 2024-06-26

### Added

- RSPY-210 : Deploy Grafana Tempo on K8S cluster
- RSPY-223 : Provide an Ansible playbook to deploy RS-Server
- Jupyter : View hidden files, Dask labextension

### Fixed

- RSPY-254 : [Safety] Errors displayed on Wazuh UI


## [0.1a10] - 2024-06-05

### Added

- RSPY-253 : Deploy RS-Client libraries into JupiterLab instances

### Fixed

- RSPY-241 : [Deployment] JupiterHub UI not reachable after deployment
- RSPY-267 : [Security] No severity score on huge amount of CVE
- RSPY-252 : [Deployment] Namespace issue during installation of Neuvector crds
- RSPY-261 : [Monitoring] No prometheus value retrieved for neuvector
- RSPY-245 : [Deployment] Missing namespaces in kustomization.yaml
- RSPY-258 : [Deployment] Grafana in CrashLoop when no plugin
- RSPY-260 : [monitoring] Monitoring certificate secret name not match with deployment for grafana and prometheus
- RSPY-259 : [Deployment] Missing secret for Loki
- RSPY-263 : [Monitoring] Prometheus GrafanaDatasource not created during prometheus deployment

## [0.1a9] - 2024-05-15

### Added

- RSPY-130 : Deploy Grafana on K8S cluster
- RSPY-133 : Deploy Prefect Workers on K8S cluster

### Fixed

- RSPY-181 : Deployment: label not well set by deployment script
- RSPY-196 : Platform deployment: error keycloak realm import
- RSPY-220 : Kubectl commands with kubectl OIDC not working
- RSPY-239 : [Deployment] No JupiterHub image reachable from Validation platform
- RSPY-240 : [Deployment] No Secret Create during Wazuh Agent deployment

## [0.1a8] - 2024-04-30

### Added

- RSPY-99 : Deploy JupyterHub on K8S cluster
- RSPY-128 : Deploy promtail and Grafana Loki on K8S cluster

### Fixed

- RSPY-170 : Platform deployment and start-stop playbook failed due to missing credential
- RSPY-176 : Platform deployment: first application deployment execution failed for the step cluster-issuer
- RSPY-177 : Platform Deployment: Failed to deployed application due to missing parameter in group_vars
- RSPY-179 : Platform deployment: no cinder controller for PVC
- RSPY-180 : Platform deployment: kubelet errors with cpu manager
- RSPY-182 : Wazuh agent is being reinstalled when cluster is restarted
- RSPY-183 : Prometheus is not accessible from the ingress

## [0.1a7] - 2024-04-05

### Added

- RSPY-129 : Deploy prometheus and node_exporter on K8S cluster
- RSPY-121 : Setup Ingress Controller
- RSPY-81 : Deploy keycloak on K8S cluster
- RSPY-68 : Configure OpenID Connect on K8S cluster
- RSPY-49 : Deploy Prefect Server on K8S cluster
- RSPY-29 : Deploy Kubernetes

### Changed

- RSPY-171 : [URGENT] Replace Miniconda by Miniforge

### Fixed

- RSPY-125 : Cluster configuration folder is hard-coded

## [0.1a3] - 2024-01-16

### Added

- RSPY-23 : Prepare cluster settings (node sizing)
- RSPY-24 : Deploy cluster nodes
- RSPY-42 : Write "nodes start/stop" procedure
