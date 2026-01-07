# Isolation for companies

To be able to isolate between companies, we will create a namespace per company and leverage the `NetworkPolicy.networking.k8s.io` from Kubernetes.

## Create a namespace for the company

Add the new namespace for the company in `~/rs-infra-core/apps/00-namespaces`. For e.g. if the new namespace is `playground-ns` :

```YAML
apiVersion: v1
kind: Namespace
metadata:
  name: playground-ns
```

Do not forget to update the file `kustomization.yaml` to include the new file.

## Create the Network Policies

Create a new folder `~/rs-infra-core/apps/00-networkpolicies-playground` and add the files described in the next steps.

### networkpolicy-block.yaml

Add the file `~/rs-infra-core/apps/00-networkpolicies-playground/networkpolicy-block.yaml` with the following content :

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

It is the default "block all" policy for ingress traffic.

### networkpolicy-acme.yaml

Add the file `~/rs-infra-core/apps/00-networkpolicies-playground/networkpolicy-acme.yaml` with the following content :

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-to-http01-solver
spec:
  podSelector:
    matchLabels:
      acme.cert-manager.io/http01-solver: "true"
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8089
```

It is the policy to allow the acme HTTP resolver for Let's Encrypt certificates.

### networkpolicy-ingress.yaml

Add the file `~/rs-infra-core/apps/00-networkpolicies-playground/networkpolicy-ingress.yaml` with the following content :

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-nginx-prefect
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prefect-server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 4200
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-nginx-jupyter
spec:
  podSelector:
    matchLabels:
      app: jupyterhub
      component: hub
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 80
```

It is the policy to allow traffic from the nginx ingress-controller to the prefect and jupyter services.

### networkpolicy-intra.yaml

Add the file `~/rs-infra-core/apps/00-networkpolicies-playground/networkpolicy-intra.yaml` with the following content :

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}
```
It is the policy to allow all ingress traffic within the same namespace.

### kustomization.yaml

Last but not least, add the file `~/rs-infra-core/apps/00-networkpolicies-playground/kustomization.yaml` with the following content :

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: playground-ns

resources:
- networkpolicy-block.yaml
- networkpolicy-acme.yaml
- networkpolicy-ingress.yaml
- networkpolicy-intra.yaml
- networkpolicy-jupyter.yaml
```

## Prefect isolation

### Update the inventory

Edit the inventory file (~/rs-infra-core/inventory/mycluster/host_vars/setup/apps.yml) to add the new prefect server instance. In this example it's under `prefect3server.playground`.

From :

```YAML
prefect3server:
  ops:
    name: prefect
    namespace: processing
    subDomain: processing
    allowedRoles: "role:RS-JUPYTER-USER"
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
    namespace: processing
    subDomain: processing
    allowedRoles: "role:RS-JUPYTER-USER"
    database:
      host: postgresql-cluster-rw.database.svc.cluster.local
      username: prefect
      password: "{{ lookup('password', '/dev/null length=30 chars=ascii_letters') }}"
  # New prefect instance below
  playground:
    name: prefect-playground
    namespace: processing
    subDomain: processing.playground
    allowedRoles: "role:toto,role:titi"
    database:
      host: postgresql-cluster-rw.database.svc.cluster.local
      username: prefect-playground
      password: "{{ lookup('password', '/dev/null length=30 chars=ascii_letters') }}"
```

### Duplicate the database 01-prefect3-db

#### Deplicate the folder

Duplicate `~/rs-workflow-env/apps/01-prefect3-db` to `~/rs-workflow-env/apps/01-prefect3-db-playground`.

#### Replace the name

Edit the values by changing `prefect3server.ops` to `prefect3server.playground` in the file `~/rs-workflow-env/apps/01-prefect3-db-playground/database.yaml`. For e.g. with sed :

```Bash
sed 's#prefect3server.ops#prefect3server.playground#g' -i ~/rs-workflow-env/apps/01-prefect3-db-playground/database.yaml
```

### Duplicate the apps prefect3-server

#### Deplicate the folder

Duplicate `~/rs-workflow-env/apps/prefect3-server` to `~/rs-workflow-env/apps/prefect3-server-playground`.

#### Replace the name

Edit the values by changing `prefect3server.ops` to `prefect3server.playground` in the file `~/rs-workflow-env/apps/prefect3-server-playground/values.yaml`. For e.g. with sed :

```Bash
sed 's#prefect3server.ops#prefect3server.playground#g' -i ~/rs-workflow-env/apps/prefect3-server-playground/values.yaml
```

#### Replace the namespace

Change the namespace in the file `~/rs-workflow-env/apps/prefect3-server-playground/kustomization.yaml`. For e.g. with sed :

```Bash
sed 's#prefect3server.ops.namespace#prefect3server.playground.namespace#g' -i ~/rs-workflow-env/apps/prefect3-server-playground/kustomization.yaml
```

### Duplicate the workpools prefect3-worker-eopf, prefect3-worker-general, prefect3-worker-staging

#### Deplicate the folders

Duplicate `~/rs-workflow-env/apps/prefect3-worker-eopf` to `~/rs-workflow-env/apps/prefect3-worker-eopf-playground`.
Duplicate `~/rs-workflow-env/apps/prefect3-worker-general` to `~/rs-workflow-env/apps/prefect3-worker-general-playground`.
Duplicate `~/rs-workflow-env/apps/prefect3-worker-staging` to `~/rs-workflow-env/apps/prefect3-worker-staging-playground`.

#### Replace the name

Edit the values of the prefect server by changing `prefect3server.ops` to `prefect3server.playground` in the file `~/rs-workflow-env/apps/prefect3-worker-eopf-playground/values.yaml`. For e.g. with sed :

```Bash
sed 's#prefect3server.ops#prefect3server.playground#g' -i ~/rs-workflow-env/apps/prefect3-worker-eopf-playground/values.yaml
```

And changing `prefect3worker.eopf` to `prefect3worker.eopfplayground`. For e.g. with sed :

```Bash
sed 's#prefect3worker.eopf#prefect3worker.eopfplayground#g' -i ~/rs-workflow-env/apps/prefect3-worker-eopf-playground/values.yaml
```

***Repeat for every new workpools.***

#### Replace the namespace

Change the namespace in the file `~/rs-workflow-env/apps/prefect3-worker-eopf-playground/kustomization.yaml`. For e.g. with sed :

```Bash
sed 's#prefect3worker.eopf.namespace#prefect3worker.eopfplayground.namespace#g' -i ~/rs-workflow-env/apps/prefect3-worker-eopf-playground/kustomization.yaml
```

***Repeat for every new workpools.***

## Jupyter isolation

### Update the inventory

Edit the inventory file (~/rs-infra-core/inventory/mycluster/host_vars/setup/apps.yml) to add the new clientid and jupyterhub instance. In this example it's under `jupyterhub_oidc_client_secret` and `jupyterhub.playground`.

From :

```YAML
[...]
jupyterhub_oidc_client_secret: "{{ lookup('password', '/dev/null length=60 chars=ascii_letters') }}"
[...]
jupyterhub:
  ops:
    name: jupyterhub
    namespace: processing
    subDomain: processing
    allowedGroups: |
      - RS-JUPYTER-USER

    adminGroups: |
      - RS-ADMIN

    jupyterhub_crypt_key: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
    services:
      daskgateway:
        apitoken: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
        apiurl: http://hub.processing.svc.cluster.local:8081/api
      metrics:
        apitoken: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
      # -- OpenTelemetry
      otel:
        # -- Trace request headers with OpenTelemetry ?
        trace_headers: false
        # -- Trace request bodies and response contents with OpenTelemetry ?
        trace_body: false
```

To :

```YAML
[...]
jupyterhub_oidc_client_secret: "{{ lookup('password', '/dev/null length=60 chars=ascii_letters') }}"
jupyterhubplayground_oidc_client_secret: "{{ lookup('password', '/dev/null length=60 chars=ascii_letters') }}"
[...]
jupyterhub:
  ops:
    name: jupyterhub
    namespace: processing
    subDomain: processing
    allowedGroups: |
      - RS-JUPYTER-USER

    adminGroups: |
      - RS-ADMIN

    jupyterhub_crypt_key: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
    services:
      daskgateway:
        apitoken: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
        apiurl: http://hub.processing.svc.cluster.local:8081/api
      metrics:
        apitoken: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
      # -- OpenTelemetry
      otel:
        # -- Trace request headers with OpenTelemetry ?
        trace_headers: false
        # -- Trace request bodies and response contents with OpenTelemetry ?
        trace_body: false
  playground:
    name: jupyterhub
    namespace: playground
    subDomain: playground
    allowedGroups: |
      - RS-JUPYTER-USER

    adminGroups: |
      - RS-ADMIN

    jupyterhub_crypt_key: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
    services:
      daskgateway:
        apitoken: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
        apiurl: http://hub.playground.svc.cluster.local:8081/api
      metrics:
        apitoken: "{{ lookup('password', '/dev/null', length=64, chars=['ascii_letters']) }}"
      # -- OpenTelemetry
      otel:
        # -- Trace request headers with OpenTelemetry ?
        trace_headers: false
        # -- Trace request bodies and response contents with OpenTelemetry ?
        trace_body: false
```

### Update the realm

Execute the following commands :

```Bash
export TEMPLATE_JUPYTER="jupyterhub"
export NEW_JUPYTER="jupyterplayground"

yq -i '
.spec.realm.clients += (
  .spec.realm.clients[]
  | select(.clientId == env(TEMPLATE_JUPYTER))
  | .clientId = env(NEW_JUPYTER)
  | .name = env(NEW_JUPYTER)
  | .adminUrl = "https://{{ " + env(TEMPLATE_JUPYTER) + ".playground.subDomain }}.{{ " + env(platform_domain_name) + " }}/jupyter"
  | .rootUrl = "https://{{ " + env(TEMPLATE_JUPYTER) + ".playground.subDomain }}.{{ " + env(platform_domain_name) + " }}/jupyter"
  | .secret = "{{ " + env(NEW_JUPYTER) + "_oidc_client_secret }}"
  | .redirectUris = ["https://{{ " + env(TEMPLATE_JUPYTER) + ".playground.subDomain }}.{{ " + env(platform_domain_name) + " }}/jupyter/*"]
  | .webOrigins = ["https://{{ " + env(TEMPLATE_JUPYTER) + ".playground.subDomain }}.{{ " + env(platform_domain_name) + " }}/jupyter"]
)
| .spec.realm.users += (
  .spec.realm.users[]
  | select(.serviceAccountClientId == env(TEMPLATE_JUPYTER))
  | .username = "service-account-" + env(NEW_JUPYTER)
  | .serviceAccountClientId = env(NEW_JUPYTER)
  | .clientRoles = (.clientRoles + { (env(NEW_JUPYTER)): .clientRoles[env(TEMPLATE_JUPYTER)] })
  | del(.clientRoles[env(TEMPLATE_JUPYTER)])
)
| .spec.realm.roles.client[env(NEW_JUPYTER)] = (
  .spec.realm.roles.client[env(TEMPLATE_JUPYTER)]
  | map(select(.name == "uma_protection") | del(.containerId))
)
' ~/rs-infra-core/apps/05-keycloak/keycloakrealmimport.yaml
```

### Duplicate the app jupyterhub

#### Deplicate the folder

Duplicate `~/rs-workflow-env/apps/jupyterhub` to `~/rs-workflow-env/apps/jupyterhub-playground`.

#### Replace the client id and secret

Edit the values in the file `~/rs-workflow-env/apps/jupyterhub-playground/values.yaml`:

- changing `hub.config.GenericOAuthenticator.client_id` value from `jupyterhub` to `jupyterhubplayground`
- changing `client_secret` value from `jupyterhub_oidc_client_secret` to `jupyterhubplayground_oidc_client_secret`

For e.g. with sed :

```Bash
sed 's#client_id: jupyterhub#client_id: jupyterhubplayground#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#jupyterhub_oidc_client_secret#jupyterhubplayground_oidc_client_secret#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
```

### Update the values

#### Replace `jupyterhub.ops` by `jupyterhub.playground`

Replace `jupyterhub.ops` by `jupyterhub.playground` in the following files :
- `~/rs-workflow-env/apps/jupyterhub-playground/values.yaml`
- `~/rs-workflow-env/apps/jupyterhub-playground/kustomization.yaml`
- `~/rs-workflow-env/apps/jupyterhub-playground/secret.yaml`

For e.g. with sed :

```Bash
sed 's#jupyterhub.ops#jupyterhub.playground#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#jupyterhub.ops#jupyterhub.playground#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/kustomization.yaml
sed 's#jupyterhub.ops#jupyterhub.playground#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/secret.yaml
```

#### Replace the prefect worker variables

For e.g. with sed :

```Bash
sed 's#prefect3worker.eopf.name#prefect3worker.eopfplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#prefect3worker.general.name#prefect3worker.generalplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#prefect3worker.staging.name#prefect3worker.stagingplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
```

## Deploy the apps

Deploy the new apps like any other apps:
- `~/rs-infra-core/apps/00-namespaces`
- `~/rs-infra-core/apps/00-networkpolicies-playground`
- `~/rs-workflow-env/apps/01-prefect3-db-playground`
- `~/rs-workflow-env/apps/prefect3-server-playground`
- `~/rs-workflow-env/apps/prefect3-worker-staging-playground`
- `~/rs-workflow-env/apps/prefect3-worker-general-playground`
- `~/rs-workflow-env/apps/prefect3-worker-eopf-playground`
- `~/rs-workflow-env/apps/jupyterhub-playground`
