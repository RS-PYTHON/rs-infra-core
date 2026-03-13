# Isolation for companies

To be able to isolate between companies, we will create a namespace per company and leverage the `NetworkPolicy.networking.k8s.io` from Kubernetes.

## Create the Network Policies for the processing namespace

Create a new folder `~/rs-infra-core/apps/00-networkpolicies-processing` and add the files described in the next steps.

*Note:* The app's must be named like `[0-9]{2}-networkpol*`. Example : [https://regex101.com/r/wEo0NM/1](https://regex101.com/r/wEo0NM/1)


### networkpolicy-block.yaml

Add the file `~/rs-infra-core/apps/00-networkpolicies-processing/networkpolicy-block.yaml` with the following content :

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: 
    matchLabels:
      app.kubernetes.io/name: prefect-copernicus-server
  policyTypes:
  - Ingress
```

It is the default "block all" policy for ingress traffic for prefect server pod.

### networkpolicy-ingress.yaml

Add the file `~/rs-infra-core/apps/00-networkpolicies-processing/networkpolicy-ingress.yaml` with the following content :

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-nginx-prefect
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prefect-copernicus-server
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
```

### networkpolicy-intra.yaml

Add the file `~/rs-infra-core/apps/00-networkpolicies-processing/networkpolicy-intra.yaml` with the following content :

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
spec:
  podSelector: 
    matchLabels:
      app.kubernetes.io/name: prefect-copernicus-server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}
```
It is the policy to allow all ingress traffic within the same namespace.

### kustomization.yaml

Last but not least, add the file `~/rs-infra-core/apps/00-networkpolicies-processing/kustomization.yaml` with the following content :

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: processing

resources:
- networkpolicy-block.yaml
- networkpolicy-ingress.yaml
- networkpolicy-intra.yaml
```

*Note:* For the **networkpolicies** app, we **MUST NOT** include the usual label part in the file `kustomization.yaml` because Kustomize wrongly adds it to the pod selector in addition to the metadata part. The ruling then becomes invalid and the ingress/egress is never allowed for anything.

## Create a namespace for the company

Add the new namespace for the company in `~/rs-infra-core/apps/00-namespaces`. For e.g. if the new namespace is `playground-ns` :

```YAML
apiVersion: v1
kind: Namespace
metadata:
  name: playground-ns
```

Do not forget to update the file `kustomization.yaml` to include the new file.

## Create the private registry secret for the playground namespace

Add the new namespace for the company in `~/rs-infra-core/apps/00-secret-private-registry/secrets.yaml`. For e.g. if the new namespace is `playground-ns` :

```YAML
---
apiVersion: v1
kind: Secret
metadata:
  name: harbor-pull-secret
  labels:
    app.kubernetes.io/instance: '{{ app_name }}'
  namespace: playground-ns
type: kubernetes.io/dockerconfigjson
stringData:
  .dockerconfigjson: >
    {
      "auths": {
        "{{ registry.harbor_url | default('harbor.example.com') }}": {
          "username": "{{ registry.harbor_user | default('default-user') }}",
          "password": "{{ registry.harbor_pass | default('default-pass') }}",
          "auth": "{{ (registry.harbor_user | default('default-user') + ':' + registry.harbor_pass | default('default-pass')) | b64encode }}"
        }
      }
    }
```

## Create the Network Policies for the playground namespace

Create a new folder `~/rs-infra-core/apps/00-networkpolicies-playground` and add the files described in the next steps.

*Note:* The app's must be named like `[0-9]{2}-networkpol*`. Example : [https://regex101.com/r/wEo0NM/1](https://regex101.com/r/wEo0NM/1)


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

*Note:* For the **networkpolicies** app, we **MUST NOT** include the usual label part in the file `kustomization.yaml` because Kustomize wrongly adds it to the pod selector in addition to the metadata part. The ruling then becomes invalid and the ingress/egress is never allowed for anything.

## Prefect isolation

### Update the inventory

Edit the inventory file (~/rs-infra-core/inventory/mycluster/host_vars/setup/apps.yml) to add the new prefect server instance. In this example it's under `prefect3server.playground`.

From :

```YAML
prefect3server:
  ops:
    name: prefect-copernicus
    namespace: processing
    subDomain: processing
    allowedRoles: "role:RS-JUPYTER-USER"
    database:
      host: postgresql-cluster-rw.database.svc.cluster.local
      # Database name must be only composed of lowercase alphanumerics characters
      name: prefectcopernicus
      username: prefect
      password: "{{ lookup('password', '/dev/null length=30 chars=ascii_letters') }}"
```

To :

```YAML
prefect3server:
  ops:
    name: prefect-copernicus
    namespace: processing
    subDomain: processing
    allowedRoles: "role:RS-JUPYTER-USER"
    database:
      host: postgresql-cluster-rw.database.svc.cluster.local
      # Database name must be only composed of lowercase alphanumerics characters
      name: prefectcopernicus
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
      # Database name must be only composed of lowercase alphanumerics characters
      name: prefectplayground
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

Edit the inventory file (~/rs-infra-core/inventory/mycluster/host_vars/setup/apps.yml) to add the new jupyterhub instance. In this example it's under `jupyterhub.playground`.

From :

```YAML
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

### Update the jupyterhub client in Keycloak

Add a new `Valid redirect URIs` :

- Go to `Clients`
- Select `jupyterhub`
- Scroll down on the `Settings` tab to reach `Valid redirect URIs`
- Add the new jupyterhub public url, in our e.g. `https://playground.example.com/jupyter/*`

*Note:* the subdomain playground is set at `jupyterhub.playground.subDomain`

### Duplicate the app jupyterhub

#### Deplicate the folder

Duplicate `~/rs-workflow-env/apps/jupyterhub` to `~/rs-workflow-env/apps/jupyterhub-playground`.

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

#### Replace the prefect server and worker variables

For e.g. with sed :

```Bash
sed 's#prefect3server.ops#prefect3server.playground#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#prefect3worker.eopf.name#prefect3worker.eopfplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#prefect3worker.general.name#prefect3worker.generalplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#prefect3worker.staging.name#prefect3worker.stagingplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
```

## Deploy the apps

Deploy the new apps like any other apps:
- `~/rs-infra-core/apps/00-namespaces`
- `~/rs-infra-core/apps/00-secret-private-registry`
- `~/rs-infra-core/apps/00-networkpolicies-processing`
- `~/rs-infra-core/apps/00-networkpolicies-playground`
- `~/rs-workflow-env/apps/01-prefect3-db-playground`
- `~/rs-workflow-env/apps/prefect3-server-playground`
- `~/rs-workflow-env/apps/prefect3-worker-staging-playground`
- `~/rs-workflow-env/apps/prefect3-worker-general-playground`
- `~/rs-workflow-env/apps/prefect3-worker-eopf-playground`
- `~/rs-workflow-env/apps/jupyterhub-playground`
