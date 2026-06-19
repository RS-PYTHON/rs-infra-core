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

## [1.0a11] - 2026-06-19

### Added

- [PR#328](https://github.com/RS-PYTHON/rs-infra-core/pull/328) : feat: remove specific apps for OVH on the CI deployment
- [PR#329](https://github.com/RS-PYTHON/rs-infra-core/pull/329) : feat: add new level for the cleanup script

### Changed

- [PR#320](https://github.com/RS-PYTHON/rs-infra-core/pull/320) : Update to oauth2-proxy 10.6.0 / 7.15.2
- [RSPY-1025](https://github.com/RS-PYTHON/rs-infra-core/pull/311) : Update SVG diagram to new S1-ARD processor version

### Fixed

- [PR#323](https://github.com/RS-PYTHON/rs-infra-core/pull/323) : fix: oauth2-proxy affinity
- [PR#324](https://github.com/RS-PYTHON/rs-infra-core/pull/324) : fix: Update keycloakrealmimport.yaml
- [PR#325](https://github.com/RS-PYTHON/rs-infra-core/pull/325) : docs: update kustomization part with networpolicies and labels
- [PR#326](https://github.com/RS-PYTHON/rs-infra-core/pull/326) : docs: update share network command
- [PR#327](https://github.com/RS-PYTHON/rs-infra-core/pull/327) : fix: cluster start on monday morning on OVH

## [1.0a10] - 2026-06-03

### Added

- [RSPY-994](https://github.com/RS-PYTHON/rs-infra-core/pull/312) : feat: add rwx volume (part 1)

### Changed

- [PR#317](https://github.com/RS-PYTHON/rs-infra-core/pull/317) : Update workpool names
- [PR#319](https://github.com/RS-PYTHON/rs-infra-core/pull/319) : Update to seaweedfs 4.29
- [PR#318](https://github.com/RS-PYTHON/rs-infra-core/pull/318) : Add version and binary only in CI

## [1.0a9] - 2026-04-27

### Added

- [RSPY-995](https://github.com/RS-PYTHON/rs-infra-core/pull/313) : Run check-code-quality CI
- [RSPY-1046](https://github.com/RS-PYTHON/rs-infra-core/pull/314) : Add Sentinel-1D

### Changed

- [RSPY-688](https://github.com/RS-PYTHON/rs-infra-core/pull/310) : Upgrade keycloak to 26.5.7

## [1.0a8] - 2026-03-30

### Added

- [RSPY-867](https://github.com/RS-PYTHON/rs-infra-core/pull/304) : Restore pgstac database
- [RSPY-900](https://github.com/RS-PYTHON/rs-infra-core/pull/288) : Decouple and update Dask versions
- [RSPY-691](https://github.com/RS-PYTHON/rs-infra-core/pull/307) : Remove security from infra repo

### Changed

- [PR#284](https://github.com/RS-PYTHON/rs-infra-core/pull/184) : Update to velero 1.17.2
- [PR#284](https://github.com/RS-PYTHON/rs-infra-core/pull/301) : Update to Python 3.13.12 / Prefect 3.6.20
- [RSPY-691](https://github.com/RS-PYTHON/rs-infra-core/pull/306) : Allow configure-ca script to be called several times
- [PR#284](https://github.com/RS-PYTHON/rs-infra-core/pull/305) : Add parameter for max node with dask_worker and access_csc

### Fixed

- [PR#303](https://github.com/RS-PYTHON/rs-infra-core/pull/303) : Add secret for the private registry in the isolated namespace

### Removed

- [PR#307](https://github.com/RS-PYTHON/rs-infra-core/pull/307) : Feat/remove security from infra repo

## [1.0a7] - 2026-03-02

### Added

- [RSPY-915](https://github.com/RS-PYTHON/rs-infra-core/pull/258) : cloudnative
- [PR#284](https://github.com/RS-PYTHON/rs-infra-core/pull/284) : creation database for s3quotamonitoring
- [PR#286](https://github.com/RS-PYTHON/rs-infra-core/pull/286) : Configuration for min prefect_flow node and max nod scheduler node

### Changed

- [PR#281](https://github.com/RS-PYTHON/rs-infra-core/pull/281) : Split NOTICE.md per infra repository
- [PR#279](https://github.com/RS-PYTHON/rs-infra-core/pull/279) : Update to ingress-nginx 1.14.3
- [PR#283](https://github.com/RS-PYTHON/rs-infra-core/pull/283) : Add robustness in ansible rescue step
- [PR#282](https://github.com/RS-PYTHON/rs-infra-core/pull/282) : Update to SeaweedFS 4.12
- [PR#291](https://github.com/RS-PYTHON/rs-infra-core/pull/291) : Update to seaweedfs 4.13
- [PR#287](https://github.com/RS-PYTHON/rs-infra-core/pull/287) : rs-server-osam
- [PR#290](https://github.com/RS-PYTHON/rs-infra-core/pull/290) : Update to oauth2-proxy 10.1.4 / 7.14.2
- [PR#292](https://github.com/RS-PYTHON/rs-infra-core/pull/292) : Use OCI Registry for cert-manager
- [PR#295](https://github.com/RS-PYTHON/rs-infra-core/pull/295) : Lower the length of hashed passwords to 24 characters
- [PR#294](https://github.com/RS-PYTHON/rs-infra-core/pull/294) : Update to cert-manager 1.19.4
- [PR#297](https://github.com/RS-PYTHON/rs-infra-core/pull/297) : CI: Trigger downstream deployments
- [PR#293](https://github.com/RS-PYTHON/rs-infra-core/pull/293) : feat: add cluster roles / bindings for k8s diagnostics
- [RSPY-876](https://github.com/RS-PYTHON/rs-infra-core/pull/300) : Move JupyterHub image to rs-workflow-env


## [1.0a6] - 2026-02-02

### Added

- [PR#259](https://github.com/RS-PYTHON/rs-infra-core/pull/259) : keycloak-limit-attributes
- [PR#260](https://github.com/RS-PYTHON/rs-infra-core/pull/260) : Companies isolation

### Changed

- [PR#262](https://github.com/RS-PYTHON/rs-infra-core/pull/262) : Replace minio by seaweedfs
- [PR#275](https://github.com/RS-PYTHON/rs-infra-core/pull/275) : Update to oauth2-proxy helm chart 10.1.2
- [PR#276](https://github.com/RS-PYTHON/rs-infra-core/pull/276) : Update to terraform-provider-random 3.8.1
- [PR#163](https://github.com/RS-PYTHON/rs-infra-core/pull/163) : Decoupled Dask architecture
- [PR#270](https://github.com/RS-PYTHON/rs-infra-core/pull/270) : Update Copyright 2026
- [PR#269](https://github.com/RS-PYTHON/rs-infra-core/pull/269) : Update to ingress-nginx 1.14.1
- [PR#271](https://github.com/RS-PYTHON/rs-infra-core/pull/271) : Update to Python 3.13.11/Jupyter 5.4.3/Prefect 3.6.12
- [PR#277](https://github.com/RS-PYTHON/rs-infra-core/pull/277) : Update to cert-manager 1.19.3
- [PR#267](https://github.com/RS-PYTHON/rs-infra-core/pull/267) : Moved station configuration to rs-server-deployment

### Fixed

- [PR#263](https://github.com/RS-PYTHON/rs-infra-core/pull/263) : Fix Grafana deployment with private repository

## [1.0a5] - 2025-12-23

### Added

- [PR#236](https://github.com/RS-PYTHON/rs-infra-core/pull/236) : Add explicit confirmation before removing applications
- [PR#246](https://github.com/RS-PYTHON/rs-infra-core/pull/246) : Allow to define APPS_DIR outside of github action scripts

### Changed

- [RSPY-648](https://github.com/RS-PYTHON/rs-infra-core/pull/235) : Upgrade to python 3.13
- [RSPY-625](https://github.com/RS-PYTHON/rs-infra-core/pull/247) : Update to prefect 3.6.5
- [RSPY-801](https://github.com/RS-PYTHON/rs-infra-core/pull/201) : Update to oauth2-proxy 9.0.1 / 7.13.0
- [RSPY-856](https://github.com/RS-PYTHON/rs-infra-core/pull/182) : Update to cert-manager 1.19.1
- [RSPY-856](https://github.com/RS-PYTHON/rs-infra-core/pull/252) : Update to cert-manager 1.19.2
- [PR#233](https://github.com/RS-PYTHON/rs-infra-core/pull/233) : Retry pulling helm chart in case of http 50x error
- [PR#234](https://github.com/RS-PYTHON/rs-infra-core/pull/234) : Retry pulling helm chart in case of timeouts
- [PR#237](https://github.com/RS-PYTHON/rs-infra-core/pull/237) : Copied changes from install_app to remove_app
- [PR#239](https://github.com/RS-PYTHON/rs-infra-core/pull/239) : Improve k8s diagnostics script
- [PR#240](https://github.com/RS-PYTHON/rs-infra-core/pull/240) : Improve CICD robustness
- [PR#241](https://github.com/RS-PYTHON/rs-infra-core/pull/241) : Log more info in K8S diagnostics
- [PR#244](https://github.com/RS-PYTHON/rs-infra-core/pull/244) : Improve k8s diagnostics script
- [PR#248](https://github.com/RS-PYTHON/rs-infra-core/pull/248) : Log yq version
- [PR#249](https://github.com/RS-PYTHON/rs-infra-core/pull/249) : Log last 50 lines of logs to get more stack traces
- [PR#251](https://github.com/RS-PYTHON/rs-infra-core/pull/251) : Increase log retrieval from 50 to 100 lines
- [PR#254](https://github.com/RS-PYTHON/rs-infra-core/pull/254) : Minor cleanup/improvements
- [PR#255](https://github.com/RS-PYTHON/rs-infra-core/pull/255) : Always print kubernetes diagnostics

### Fixed

- [PR#238](https://github.com/RS-PYTHON/rs-infra-core/pull/238) : Fixes for install_app and remove_app
- [PR#242](https://github.com/RS-PYTHON/rs-infra-core/pull/242) : Revert to kubernetes-client 1.33.0 to avoid kustomize 5.8.0
- [PR#243](https://github.com/RS-PYTHON/rs-infra-core/pull/243) : Really remove Kustomize 5.8.0
- [PR#250](https://github.com/RS-PYTHON/rs-infra-core/pull/250) : Remove cache, does not work
- [PR#256](https://github.com/RS-PYTHON/rs-infra-core/pull/256) : Fix copyrights

## [1.0a4] - 2025-11-19

### Added

- [PR#217](https://github.com/RS-PYTHON/rs-infra-core/pull/217) : Add minikube failure diagnostics script

### Changed

- [PR#218](https://github.com/RS-PYTHON/rs-infra-core/pull/218) : CICD: Lower the replica count of Prefect workers to 1
- [PR#219](https://github.com/RS-PYTHON/rs-infra-core/pull/219) : CICD: Lower the resources allocated to staging dask cluster
- [PR#220](https://github.com/RS-PYTHON/rs-infra-core/pull/220) : Cache Miniforge and Conda env to speedup cicd
- [PR#224](https://github.com/RS-PYTHON/rs-infra-core/pull/224) : Add aggressive cleanup script to free Github runner disk space
- [PR#225](https://github.com/RS-PYTHON/rs-infra-core/pull/225) : Fix catalog database username
- [PR#226](https://github.com/RS-PYTHON/rs-infra-core/pull/226) : Lower the keycloak-operator CPU and memory requests
- [PR#227](https://github.com/RS-PYTHON/rs-infra-core/pull/227) : Allow to configure wait timeouts
- [PR#228](https://github.com/RS-PYTHON/rs-infra-core/pull/228) : Remove '*' for allowed special characters in random passwords
- [PR#229](https://github.com/RS-PYTHON/rs-infra-core/pull/229) : Logs of previous pod if needed
- [PR#231](https://github.com/RS-PYTHON/rs-infra-core/pull/231) : fix: force helm version
- [PR#232](https://github.com/RS-PYTHON/rs-infra-core/pull/232) : Fix bcrypt version < 5.0.0
- [RSPY-795](https://github.com/RS-PYTHON/rs-infra-core/pull/215) : Isolate jupyterhub

## [1.0a3] - 2025-10-23

### Added

- [PR#203](https://github.com/RS-PYTHON/rs-infra-core/pull/203) : Add remove application playbook and doc

### Changed

- [PR#205](https://github.com/RS-PYTHON/rs-infra-core/pull/205) : Update layer-cleanup.sh
- [PR#207](https://github.com/RS-PYTHON/rs-infra-core/pull/207) : feat: update inventory for cnpgstac
- [PR#206](https://github.com/RS-PYTHON/rs-infra-core/pull/206) : update template for R3-64 on dask-worker-on-demand-rspython-ops
- [RSPY-816](https://github.com/RS-PYTHON/rs-infra-core/pull/208) : Externalize inventory configuration script and improve CI/CD
- [PR#210](https://github.com/RS-PYTHON/rs-infra-core/pull/210) : Increase timeout from 120s to 180s in CI/CD
- [PR#211](https://github.com/RS-PYTHON/rs-infra-core/pull/211) : Externalize install-requirements.sh
- [PR#212](https://github.com/RS-PYTHON/rs-infra-core/pull/212) : Fix docker image tags
- [RSPY-795](https://github.com/RS-PYTHON/rs-infra-core/pull/213) : Multiple-prefect-instances

## [1.0a2] - 2025-09-30

### Added

- [PR#183](https://github.com/RS-PYTHON/rs-infra-core/pull/183) : Update CloudNativePG
- [PR#173](https://github.com/RS-PYTHON/rs-infra-core/pull/173) : Update OAuth2 Proxy (bye bye bitnami)
- [PR#195](https://github.com/RS-PYTHON/rs-infra-core/pull/195) : Add S1 ARD processor

### Changed

- [PR#196](https://github.com/RS-PYTHON/rs-infra-core/pull/196) : Allow latest version of Ansible
- Update inventory for prip stations

### Fixed

- [PR#193](https://github.com/RS-PYTHON/rs-infra-core/pull/193) : Add missing depedencies

## [1.0a1] - 2025-08-29

### Added

- [RSPY-737](https://github.com/RS-PYTHON/rs-infra-core/pull/162) : Make s3l0 processing work
- [RSPY-728](https://github.com/RS-PYTHON/rs-infra-core/pull/165) : Update oauth2 proxy
- [RSPY-735](https://github.com/RS-PYTHON/rs-infra-core/pull/169) : Add rs_performance_indicator and add new general prefect workpool
- [RSPY-766](https://github.com/RS-PYTHON/rs-infra-core/pull/174) : Add plotting python libraries in jupyter docker image
- [PR#175](https://github.com/RS-PYTHON/rs-infra-core/pull/175) : Add more Python libraries to open and plot zarr files
- [PR#177](https://github.com/RS-PYTHON/rs-infra-core/pull/177) : Install nbconvert in Jupyter image to convert notebooks to PDF files
- [RSPY-737](https://github.com/RS-PYTHON/rs-infra-core/pull/176) : Update to S3L0 1.2.1
- [PR#178](https://github.com/RS-PYTHON/rs-infra-core/pull/178) : Test real deployment in ci/cd
- [PR#187](https://github.com/RS-PYTHON/rs-infra-core/pull/187) : Improve deployment tests
- [RSPY-729](https://github.com/RS-PYTHON/rs-infra-core/pull/170) : Use OVH private docker registry

### Changed

- [RSPY-667](https://github.com/RS-PYTHON/rs-infra-core/pull/172) : Define rs_server.full_domain variable
- [PR#186](https://github.com/RS-PYTHON/rs-infra-core/pull/186) : Remove storage-class label, version is managed by OVH

### Fixed

- [PR#166](https://github.com/RS-PYTHON/rs-infra-core/pull/166) : Fix ds-anotify
- [PR#167](https://github.com/RS-PYTHON/rs-infra-core/pull/167) : Add gitlab token for private repo
- [PR#168](https://github.com/RS-PYTHON/rs-infra-core/pull/168) : Add missing node affinity and toleration
- [PR#171](https://github.com/RS-PYTHON/rs-infra-core/pull/171) : Fix template name for node dask_scheduler
- [PR#180](https://github.com/RS-PYTHON/rs-infra-core/pull/180) : Updated nodepoool in start/stop playbook

## [0.2] - 2025-08-04

### Added

- [PR#160](https://github.com/RS-PYTHON/rs-infra-core/pull/160) : add port in sample for grafana smtp configuration
- [PR#161](https://github.com/RS-PYTHON/rs-infra-core/pull/161) : feat: update inventory for loki

### Fixed

- [PR#139](https://github.com/RS-PYTHON/rs-infra-core/pull/139) : Remove Kubernetes deployment code
- [PR#142](https://github.com/RS-PYTHON/rs-infra-core/pull/142) : kustomize edit fix --vars on all apps
- [PR#157](https://github.com/RS-PYTHON/rs-infra-core/pull/157) : Remove collections directory
- [PR#158](https://github.com/RS-PYTHON/rs-infra-core/pull/158) : Restore kube_oidc configuration removed accidentally with kubespray
- [PR#159](https://github.com/RS-PYTHON/rs-infra-core/pull/159) : Fix SARIF upload category

## [0.2a15] - 2025-07-04

### Added

- [PR#148](https://github.com/RS-PYTHON/rs-infra-core/pull/148) : Install jq in jupyter
- [RSPY-659](https://github.com/RS-PYTHON/rs-infra-core/pull/151) : Create dask staging cluster automatically
- [RSPY-609](https://github.com/RS-PYTHON/rs-infra-core/pull/154) : Test latest L0 processor

### Changed

- [PR#149](https://github.com/RS-PYTHON/rs-infra-core/pull/149) : Optimisation on security scan on CI
- [RSPY-697](https://github.com/RS-PYTHON/rs-infra-core/pull/146) : Update nodepools
- [PR#152](https://github.com/RS-PYTHON/rs-infra-core/pull/152) : Optimisation on docker build CI

### Fixed

- [PR#150](https://github.com/RS-PYTHON/rs-infra-core/pull/150) : Fix typo in doc
- [PR#153](https://github.com/RS-PYTHON/rs-infra-core/pull/153) : Fix indentation in doc

## [0.2a14] - 2025-06-10

### Added

- [PR#136](https://github.com/RS-PYTHON/rs-infra-core/pull/136) : Add operational and dask-gateway rolebinding
- [RSPY-672](https://github.com/RS-PYTHON/rs-infra-core/pull/135) : Split dpr processing flow
- [PR#145](https://github.com/RS-PYTHON/rs-infra-core/pull/145) : Add Keycloak SMTP configuration
- [RSPY-601-603](https://github.com/RS-PYTHON/rs-infra-core/pull/147) : Add osam service

### Changed

- [PR#141](https://github.com/RS-PYTHON/rs-infra-core/pull/141) : Enable CI/CD
- [PR#144](https://github.com/RS-PYTHON/rs-infra-core/pull/144) : Update Python and conda

### Fixed

- [PR#138](https://github.com/RS-PYTHON/rs-infra-core/pull/138) : Fix pre-commit violations
- [PR#140](https://github.com/RS-PYTHON/rs-infra-core/pull/140) : Fix links and typos
- [PR#143](https://github.com/RS-PYTHON/rs-infra-core/pull/143) : Fix doc

## [0.2a13] - 2025-05-15

### Added

- [PR#129](https://github.com/RS-PYTHON/rs-infra-core/pull/129) :  Trace requests headers and body with opentelemetry
- [RSPY-652/653/654](https://github.com/RS-PYTHON/rs-infra-core/pull/132) : Add rs-dpr-service

### Changed

- [RSPY-664](https://github.com/RS-PYTHON/rs-infra-core/pull/125) : use smaller nodes for staging
- [RSPY-594](https://github.com/RS-PYTHON/rs-infra-core/pull/127) : Use latest rs-server wheels when building the dask-staging image
- [RSPY-594](https://github.com/RS-PYTHON/rs-infra-core/pull/130) : Build jupyter with latest rs-client-libraries wheel
- [PR#131](https://github.com/RS-PYTHON/rs-infra-core/pull/131) : Remove old phase1 files
- [PR#133](https://github.com/RS-PYTHON/rs-infra-core/pull/133) : Use custom pygeo projects

### Fixed

- [PR#124](https://github.com/RS-PYTHON/rs-infra-core/pull/124) : remove old ogc validation env var

## [0.2a12] - 2025-04-14

### Added

- RSPY-236: Upgrade to Ubuntu 24.04.2
- RSPY-644: [S3L0 demo] Use OpenTelemetry
- New docker image `ghcr.io/rs-python/rs-infra-core-mockup`

### Changed

- Bump rs-server-staging version to `0.2a12`
- RSPY-631: Update to latest stable version of Prefect 3 (3.2.13) and drop Prefect 2
- Bump ingress-nginx to fix CVE-2025-1974

### Fixed

- Documentation outdated : bumped cots version
- Typos in installation documentation
- Typos in installation scripts
- Changed executable to `/bin/bash` for several steps in ansible
- Removed several special chars in the auto generated passwords that breaks YAML when it's the first caracter in the string

## [0.2a11] - 2025-03-12

:rotating_light: **Breaking changes**

- Many apps have been moved from `rs-infra-core` to `rs-infra-security`, `rs-infra-monitoring`, `rs-server-deployment` and `rs-workflow-env`
- Starting from this version (0.2a11), RS cannot be installed on Orange and shall be installed on OVH.

### Added

- RSPY-581 : OVH: deployment of rs-infra-core
- RSPY-583 : OVH: deployment of rs-infra-monitoring
- RSPY-584 : OVH: deployment of rs-infra-security
- RSPY-585 : OVH: deployment of rs-workflow-env (rs-workflow-env-deployment repository )
- RSPY-586 : OVH: deployment of rs-server (rs-server-deployment repository)
- RSPY-602 : Update stac-fastapi / stac-fastapi-pgstac / pgstac to 5.0.x / 4.0.x / 0.9.x
- RSPY-607 : Update S1L0 processing Prefect flow with real S1L0Processor 0.9.0
- New apps `ds-fanotify` to increase fanotify limit on the node (the limit was quickly reached on the OVH node)

### Changed

- Many apps have been moved from `rs-infra-core` to `rs-infra-security`, `rs-infra-monitoring`, `rs-server-deployment` and `rs-workflow-env`
- Updated keycloak realm to Remove old references to phase1
- Updated to storage classes for OVH
- Ingress nginx
  - svc is now `LoadBalancer` (instead of `NodePort`) (needed for OVH)
  - Has its own namespace `ingress-nginx` (instead of `kube-system`)

### Deprecated

- Prefect 2 is completely deprecated and is replaced with Prefect 3
- Removed old ClusterRoleBinding from phase1

### Fixed

- RSPY-416 : [Security] Cannot connect to Wazuh GUI with SSO
- Missing namespaces : ingress-nginx and dask-gateway
- Remove `NoSchedule` and `PreferNoSchedule` on infra and processing nodepool

## [0.2a10] - 2025-02-18

:rotating_light: The repository has been renamed from `rs-infrastructure` to `rs-infra-core`.

### Added

- RSPY-570 : Integrate DPR empty processor

### Changed

- rs-server : bumped the versions to 0.2.0-a10
- RSPY-596 : Update to stac-browser 3.3
- RSPY-577 : Update cluster deployment to OVH
- RSPY-580 : Changed cluster start and stop to be compatible with OVH
- CI/CI : Updated for the rename of the repository

### Deprecated

- Prefect 2 is deprecated and is *partially* replaced with Prefect 3 and will be *fully* replaced with Prefect 3 in version `0.2a11`

|                        | Release 0.2a10 (current version)             | Release 0.2a11 (next version)               |
|------------------------|----------------------------------------------|---------------------------------------------|
| Prefect 2 internal svc | prefect-server.processing.svc.cluster.local  | X                                           |
| Prefect 2 public svc   | processing.example.com                       | X                                           |
| Prefect 3 internal svc | prefect3-server.processing.svc.cluster.local | prefect-server.processing.svc.cluster.local |
| Prefect 3 public svc   | prefect3.example.com                         | processing.example.com                      |

- Some folders and applications will be moved into other repositories to separate what is strictly related to the infrastructure, rs-server and applications needed for rs-srver

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
