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
