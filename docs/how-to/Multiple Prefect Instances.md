# Multiple Prefect Instances

## Update the inventory

Edit the inventory file (rs-infra-core/inventory/mycluster/host_vars/setup/apps.yml)

From :

```YAML
prefect3server:
  ops:
    name: prefect
    subDomain: processing
    allowedRoles: "role:toto,role:titi"
    database:
      host: postgresql-cluster-rw.database.svc.cluster.local
      username: prefect
      password: "{{ lookup('password', '/dev/null length=30 chars=ascii_letters') }}"
```

To :
```YAML
prefect3server:
  ops:
    name: prefect
    subDomain: processing
    allowedRoles: "role:RS-JUPYTER-USER"
    database:
      host: postgresql-cluster-rw.database.svc.cluster.local
      username: prefect
      password: "{{ lookup('password', '/dev/null length=30 chars=ascii_letters') }}"
  # New prefect instance below
  playground:
    name: prefect-playground
    subDomain: prefect-playground
    allowedRoles: "role:toto,role:titi"
    database:
      host: postgresql-cluster-rw.database.svc.cluster.local
      username: prefect-playground
      password: "{{ lookup('password', '/dev/null length=30 chars=ascii_letters') }}"
```

## Duplicate the database 01-prefect3-db

### Deplicate the folder

Duplicate `rs-workflow-env/apps/01-prefect3-db` to `rs-workflow-env/apps/01-prefect3-db-playground`.

### Replace the name

Edit the values (rs-workflow-env/apps/01-prefect3-db-playground/database.yaml) by changing `prefect3server.ops` to `prefect3server.playground`. For e.g. with sed :

```Bash
sed 's#prefect3server.ops#prefect3server.playground#g' -i rs-workflow-env/apps/01-prefect3-db-playground/database.yaml
```

## Duplicate the apps prefect3-server

### Deplicate the folder

Duplicate `rs-workflow-env/apps/prefect3-server` to `rs-workflow-env/apps/prefect3-server-playground`.

### Replace the name

Edit the values (rs-workflow-env/apps/prefect3-server-playground/values.yaml) by changing `prefect3server.ops` to `prefect3server.playground`. For e.g. with sed :

```Bash
sed 's#prefect3server.ops#prefect3server.playground#g' -i rs-workflow-env/apps/prefect3-server-playground/values.yaml
```

## Duplicate the workpools prefect3-worker-eopf, prefect3-worker-general, prefect3-worker-staging

### Deplicate the folders

Duplicate `rs-workflow-env/apps/prefect3-worker-eopf` to `prefect3-worker-eopf-playground`.  
Duplicate `rs-workflow-env/apps/prefect3-worker-general` to `prefect3-worker-general-playground`.  
Duplicate `rs-workflow-env/apps/prefect3-worker-staging` to `prefect3-worker-staging-playground`.

### Replace the name

Edit the values (prefect3-worker-eopf-playground/values.yaml) by changing `prefect3server.ops` to `prefect3server.playground`. For e.g. with sed :

```Bash
sed 's#prefect3server.ops#prefect3server.playground#g' -i rs-workflow-env/apps/prefect3-worker-eopf-playground/values.yaml
```

## Deploy the apps

Deploy the new apps like any other apps:
- rs-workflow-env/apps/01-prefect3-db-playground
- rs-workflow-env/apps/prefect3-server-playground
- rs-workflow-env/apps/prefect3-worker-staging-playground
- rs-workflow-env/apps/prefect3-worker-general-playground
- rs-workflow-env/apps/prefect3-worker-eopf-playground
