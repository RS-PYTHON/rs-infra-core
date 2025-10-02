# Remove a deployed application

```shellsession
# Conf
DEPLOY_DIR=/home/ubuntu/Deployment/rs-python
RSCONFIG_DIR=${DEPLOY_DIR}/rs-config
RSINFRA_DIR=${DEPLOY_DIR}/rs-config/rs-infra-core

cd ${RSINFRA_DIR}

# Activate virtualenv (necessary to run ansible-playbooks):
conda activate rspy

# Standard undeployment:
# Example 1: to undeploy "02-cluster-issuer", just input "cluster-issuer" (omit the number)
# Example 2: to undeploy "keycloak", input "keycloak"
APP=
# Choose apps dir : apps / apps-env / apps-monitoring / apps-rs-server / apps-workflow
APPS_DIR=
ansible-playbook remove_apps.yaml \
  -i inventory/mycluster/hosts.yaml \
  -e '{"package_paths": ["'${RSCONFIG_DIR}/${APPS_DIR}'"], "app": "'${APP}'"}'
```
