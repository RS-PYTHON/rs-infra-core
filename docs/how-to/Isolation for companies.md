# Isolation for companies

To be able to isolate between companies, we will create a namespace per company and leverage natives features from Kubernetes such as `NetworkPolicy` (<https://kubernetes.io/docs/concepts/services-networking/network-policies/>), `LimitRange` (<https://kubernetes.io/docs/concepts/policy/limit-range/>) and and `ResourceQuota` (<https://kubernetes.io/docs/concepts/policy/resource-quotas/>).

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
labels:
- includeSelectors: true
  pairs:
    app.kubernetes.io/instance: '{{ app_name }}'

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

## Create the Resource Quota and the Limit Range for the playground namespace

Create a new folder `~/rs-infra-core/apps/00-policies-playground` and add the files described in the next steps.

### limitrange.yaml

```YAML
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-cpu
spec:
  limits:
  - max:
      memory: 60Gi
      cpu: "16"
    default:
      memory: 128Mi
      cpu: 100m
    type: Container
```

### resourcequota.yaml

```YAML
apiVersion: v1
kind: ResourceQuota
metadata:
  name: mem-cpu
spec:
  hard:
    limits.cpu: "48"
    limits.memory: 100Gi
```

### kustomization.yaml

Add the file `~/rs-infra-core/apps/00-policies-playground/kustomization.yaml` with the following content :

```YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: playground-ns

labels:
- includeSelectors: true
  pairs:
    app.kubernetes.io/instance: '{{ app_name }}'

resources:
- resourcequota.yaml
- limitrange.yaml
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
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-nginx-dask
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: dask-gateway
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8000
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

### Duplicate the workpools prefect3-worker-integrated, prefect3-worker-sandbox, prefect3-worker-monitoring

#### Deplicate the folders

Duplicate `~/rs-workflow-env/apps/prefect3-worker-integrated` to `~/rs-workflow-env/apps/prefect3-worker-integrated-playground`.
Duplicate `~/rs-workflow-env/apps/prefect3-worker-sandbox` to `~/rs-workflow-env/apps/prefect3-worker-sandbox-playground`.
Duplicate `~/rs-workflow-env/apps/prefect3-worker-monitoring` to `~/rs-workflow-env/apps/prefect3-worker-monitoring-playground`.

#### Replace the name

Edit the values of the prefect server by changing `prefect3server.ops` to `prefect3server.playground` in the file `~/rs-workflow-env/apps/prefect3-worker-integrated-playground/values.yaml`. For e.g. with sed :

```Bash
sed 's#prefect3server.ops#prefect3server.playground#g' -i ~/rs-workflow-env/apps/prefect3-worker-integrated-playground/values.yaml
```

And changing `prefect3worker.integrated` to `prefect3worker.integratedplayground`. For e.g. with sed :

```Bash
sed 's#prefect3worker.integrated#prefect3worker.integratedplayground#g' -i ~/rs-workflow-env/apps/prefect3-worker-integrated-playground/values.yaml
```

***Repeat for every new workpools.***

#### Replace the namespace

Change the namespace in the file `~/rs-workflow-env/apps/prefect3-worker-integrated-playground/kustomization.yaml`. For e.g. with sed :

```Bash
sed 's#prefect3worker.integrated.namespace#prefect3worker.integratedplayground.namespace#g' -i ~/rs-workflow-env/apps/prefect3-worker-integrated-playground/kustomization.yaml
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
sed 's#prefect3worker.integrated.name#prefect3worker.integratedplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#prefect3worker.sandbox.name#prefect3worker.sandboxplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
sed 's#prefect3worker.monitoring.name#prefect3worker.monitoringplayground.name#g' -i ~/rs-workflow-env/apps/jupyterhub-playground/values.yaml
```

## Dask-gateway isolation

### Duplicate the app dask-gateway

#### Deplicate the folder

Duplicate `~/rs-workflow-env/apps/dask-gateway` to `~/rs-workflow-env/apps/dask-gateway-playground`.

#### Shared volume (ReadWriteMany)

We need to create a big shared volume in the namespace that will be shared between the dask scheduler and workers. It is required by some processors.

Create the new manifest `~/rs-workflow-env/apps/dask-gateway-playground/sharedvolume.yaml` with the following content :

 ```YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rspython-ops_ads_01
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 3Ti
  storageClassName: csi-manila-nfs
 ```

### Update the values

#### Replace `jupyterhub.ops` by `jupyterhub.playground`

Replace `jupyterhub.ops` by `jupyterhub.playground` in the following files :
- `~/rs-workflow-env/apps/dask-gateway-playground/values.yaml`

For e.g. with sed :

```Bash
sed 's#jupyterhub.ops#jupyterhub.playground#g' -i ~/rs-workflow-env/apps/dask-gateway-playground/values.yaml
```

#### Replace the namespace

TODO in kustomize and in values.yaml

```YAML
gateway:
  auth:
    type: jupyterhub
    jupyterhub:
      apiToken: {{ jupyterhub.playground.services.daskgateway.apitoken }}
      apiUrl: {{ jupyterhub.playground.services.daskgateway.apiurl }}
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: "node-role.kubernetes.io/rs_env"
              operator: Exists
  tolerations:
    - key: role
      value: rs_env
      effect: NoSchedule
  extraConfig:
    clusteroptions: |
        from dask_gateway_server.options import Options, Integer, Float, String, Mapping

        def option_handler(options):
            return {
                "worker_cores": options.worker_cores,
                "worker_memory": "%fG" % options.worker_memory,
                "scheduler_core_limit": options.scheduler_core_limit,
                "scheduler_memory_limit": "%fG" % options.scheduler_memory_limit,
                "image": options.image,
                "cluster_max_cores": options.cluster_max_cores,
                "cluster_max_memory": options.cluster_max_memory,
                "cluster_max_workers": options.cluster_max_workers,
                "cluster_name": options.cluster_name,
                "scheduler_extra_container_config": options.scheduler_extra_container_config,
                "scheduler_extra_pod_annotations": options.scheduler_extra_pod_annotations,
                "scheduler_extra_pod_config": options.scheduler_extra_pod_config,
                "scheduler_extra_pod_labels": options.scheduler_extra_pod_labels,
                "environment": options.environment,
                "worker_extra_pod_config": options.worker_extra_pod_config,
                "worker_extra_container_config": options.worker_extra_container_config,
            }

        c.Backend.cluster_options = Options(
            Float("worker_cores", 1, min=1, max=8, label="Worker Cores"),
            Float("worker_memory", 4, min=1, max=64, label="Worker Memory (GiB)"),
            Float("scheduler_core_limit", 1, min=1, max=2, label="Scheduler Max Cores"),
            Float("scheduler_memory_limit", 2, min=1, max=64, label="Scheduler Max Memory (GiB)"),
            String("image", default="ghcr.io/rs-python/rs-infra-core-dask-gateway:latest", label="Image"),
            Float("cluster_max_cores", 4, min=1, max=80, label="Cluster max cores"),
            Float("cluster_max_memory", default=17179869184, min=1073741824, max=343597383680, label="Cluster max memory"),
            Integer("cluster_max_workers", 5, min=1, max=20, label="Cluster max workers"),
            String("cluster_name", default="MyDaskCluster", label="Cluster Name"),
            Mapping("scheduler_extra_container_config", default={"readinessProbe":{"failureThreshold":3,"httpGet":{"path":"/api/health","port":8788,"scheme":"HTTP"},"periodSeconds":5,"successThreshold":1,"timeoutSeconds":15}, "imagePullPolicy": "Always"}, label="scheduler_extra_container_config"),
            Mapping("scheduler_extra_pod_annotations", default={"usage":"unknown","access":"internal"}, label="Scheduler_extra_pod_annotations"),
            Mapping("scheduler_extra_pod_config", default={"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"node-role.kubernetes.io/access_csc","operator":"Exists"}]}]}}},"tolerations":[{"key":"role","operator":"Equal","value":"access_csc","effect":"NoSchedule"}]}, label="Scheduler_extra_pod_config"),
            Mapping("scheduler_extra_pod_labels", default={"user":"unknown","team":"unknown","cluster_name":"MyDaskCluster"}, label="Scheduler_extra_pod_labels"),
            Mapping("environment", default={"S3_ENDPOINT":"{{ s3.endpoint }}","S3_REGION":"{{ s3.region }}","TEMPO_ENDPOINT":"http://alloy.monitoring.svc.cluster.local:4317", "OTEL_PYTHON_REQUESTS_TRACE_HEADERS":"0", "OTEL_PYTHON_REQUESTS_TRACE_BODY":"0"}, label="Environment variables"),
            Mapping("worker_extra_pod_config", default={"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"node-role.kubernetes.io/access_csc","operator":"Exists"}]}]}}},"tolerations":[{"key":"role","operator":"Equal","value":"access_csc","effect":"NoSchedule"}]}, label="Worker_extra_pod_config"),
            Mapping("worker_extra_container_config", default={"envFrom":[{"secretRef":{"name": "obs"}}]}, label="Worker_extra_container_config"),
            handler=option_handler,
        )

  backend:
    namespace: playground
    scheduler:
      extraPodConfig:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                  - key: "node-role.kubernetes.io/rs_env"
                    operator: Exists
        tolerations:
          - key: role
            value: rs_env
            effect: NoSchedule
    worker:
      extraPodConfig:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                  - key: "node-role.kubernetes.io/rs_env"
                    operator: Exists
        tolerations:
          - key: role
            value: rs_env
            effect: NoSchedule

controller:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: "node-role.kubernetes.io/rs_env"
              operator: Exists
  tolerations:
    - key: role
      value: rs_env
      effect: NoSchedule

traefik:
  service:
    type: ClusterIP
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: "node-role.kubernetes.io/rs_env"
              operator: Exists
  tolerations:
    - key: role
      value: rs_env
      effect: NoSchedule
```

## Deploy the apps

Deploy the new apps like any other apps:
- `~/rs-infra-core/apps/00-namespaces`
- `~/rs-infra-core/apps/00-secret-private-registry`
- `~/rs-infra-core/apps/00-networkpolicies-processing`
- `~/rs-infra-core/apps/00-networkpolicies-playground`
- `~/rs-infra-core/apps/00-policies-playground`
- `~/rs-workflow-env/apps/01-prefect3-db-playground`
- `~/rs-workflow-env/apps/prefect3-server-playground`
- `~/rs-workflow-env/apps/prefect3-worker-monitoring-playground`
- `~/rs-workflow-env/apps/prefect3-worker-sandbox-playground`
- `~/rs-workflow-env/apps/prefect3-worker-integrated-playground`
- `~/rs-workflow-env/apps/jupyterhub-playground`
- `~/rs-workflow-env/apps/dask-gateway-playground`