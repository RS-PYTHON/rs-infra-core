# Remove a deployed application

The `remove_apps.yaml` playbook removes the Kubernetes resources of one application, or of all the applications, of
a package (the `apps/` folder of a repository, see
[Deploy RS-Python](https://github.com/RS-PYTHON/rs-documentation/blob/develop/docs/administration/deploy.md)).
It is the reverse of the `apps.yaml` playbook and uses the same inventory.

On the bastion, from the `rs-infra-core` directory:

```shell
# Activate the environment that contains Ansible
conda activate rspy

# Name of the application to remove, without its "NN-" prefix:
# e.g. "cluster-issuer" to remove "02-cluster-issuer", "jupyterhub" to remove "jupyterhub"
APP=jupyterhub
# Package that contains the application, e.g. ~/rs-infra-core/apps/, ~/rs-infra-monitoring/apps/,
# ~/rs-workflow-env/apps/, ~/rs-server-deployment/apps/ or ~/rs-workflow-deployment/apps/
PACKAGE=~/rs-workflow-env/apps/

ansible-playbook remove_apps.yaml \
  -i inventory/mycluster/hosts.yaml \
  -e '{"package_paths": ["'${PACKAGE}'"], "app": "'${APP}'"}'
```

Without the `app` variable, all the applications of the package are removed.

> **Note:** the persistent volumes and the databases of the removed application may be kept, depending on their
> reclaim policy. Remove them explicitly if you don't need them anymore.
