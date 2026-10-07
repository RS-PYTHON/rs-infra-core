# Node maintenance without SSH

## Scope and status

This procedure provides an on-demand root shell on a reachable Linux worker through
the Kubernetes API, using `kubectl node-shell` to create a temporary privileged
pod and enter the host namespaces. Use `nerdctl` for Docker-style containerd
commands and `crictl` for CRI diagnostics. No SSH daemon, port or key is required.
Repeat the procedure for each node. The [manual pod template](node-maintenance/pod.yaml)
remains an alternative when explicit pod controls are required; it is outside
the application deployment tree and is never installed by the playbooks.

Status: prepared for review; cluster tests, Confluence publication and ADS Security
validation are pending. None of the cluster commands below were executed during
implementation. Run acceptance tests on a disposable non-production worker first.

The repository provisions OVHcloud Managed Kubernetes (`roles/terraform/cluster/tasks/cluster.tf`).
Worker operating systems and kubelet are provider managed; changes can be lost on
replacement or conflict with provider maintenance. Confirm provider support for
the intended workaround. Provider-managed control-plane hosts are not accessible
through this procedure. Therefore the literal requirement to reach *any* node,
including one whose kubelet is dead, needs a provider recovery path as well.

## Access and security prerequisites

- Use a named operator identity and the [remote kubectl procedure](Remote%20kubectl.md),
  through the existing approved API access path. Terraform restricts the API to
  the bastion IP; workstation examples assume that connectivity already exists.
- Record the incident/change reference, context, node, operator, start time,
  planned actions and rollback. Keep before/after evidence in the incident record.
- Use an existing, security-approved maintenance namespace which permits privileged
  containers, host namespaces and a writable hostPath. Pod Security Admission,
  admission webhooks and runtime security may reject this pod even when RBAC allows it.
  Arrange a scoped exception through the normal security process; do not disable
  cluster-wide protections or deploy in a workload namespace to bypass policy.
- Arrange time-limited access to `get/list/watch/create/delete` pods,
  `create` pods/attach and pods/exec, and
  `get` pods/log in that namespace, and `get` nodes at cluster scope. Waiting for
  readiness also requires `watch` pods. Cordon/drain needs additional node and
  eviction permissions when applicable. Do not give ordinary workload users this
  access. Creating these pods effectively grants host root access and can expose
  cluster credentials. Unlike the manual template, upstream node-shell does not
  explicitly disable service account token mounting; validate the namespace's
  service account configuration with ADS Security.
- Use a scanned, approved image pinned by digest and compatible with the target
  architecture. For normal node-shell it must contain `nsenter` (util-linux)
  and run as UID 0. For X-mode it also needs `/bin/sh`, `tar` and `nerdctl`.
  The manual template needs `/bin/sh`, `sleep`, `chroot`, `nsenter` and `tar`.
  Editors, `timeout`, `/bin/sh` and other host tools below must exist on the node.
- Kubernetes audit logs record API activity, not a complete interactive shell
  transcript. Use the approved session-recording mechanism and protect records
  that may contain sensitive data. ADS Security must validate identity lifecycle,
  namespace restrictions, image, admission exceptions, recording and cleanup.

## Start a session

Install the reviewed node-shell plugin on the **operator workstation**, using
the approved software distribution process. Upstream provides installation via
Krew (`kubectl krew install node-shell`); record the installed version with
`kubectl node-shell --version` and approve/pin that version before operational use.
Do not download and execute an unreviewed script from a moving branch.
The options below were checked against upstream node-shell 1.11.0; revalidate
them against the approved installed version. Installing the plugin does not
install a daemon on nodes, but opening a session creates a cluster pod.

The following commands create cluster resources and are for an authorized
maintenance window only. Specify the context explicitly on every command.

```bash
CTX='REPLACE_NON_PRODUCTION_CONTEXT'
NS='REPLACE_APPROVED_MAINTENANCE_NAMESPACE'
NODE='REPLACE_NODE_NAME'
IMAGE='REPLACE_APPROVED_IMAGE_AT_SHA256_DIGEST'
# Use a unique Kubernetes-label-safe incident/session identifier.
SESSION='REPLACE_SESSION_ID'
kubectl --context="$CTX" get node "$NODE" -o wide
kubectl --context="$CTX" auth can-i create pods -n "$NS"
kubectl --context="$CTX" auth can-i create pods/exec -n "$NS"
kubectl --context="$CTX" auth can-i create pods/attach -n "$NS"
kubectl --context="$CTX" auth can-i delete pods -n "$NS"
```

Resolve any failed authorization check before proceeding. Open the host shell:

```bash
KUBECTL_NODE_SHELL_LABELS="maintenance-session=$SESSION" \
  kubectl node-shell --context "$CTX" -n "$NS" "$NODE" --image "$IMAGE" -- \
  timeout 3600 /bin/sh -l
```

Put `--context` and namespace after `node-shell` so the plugin receives them.
Normal mode enters the host namespaces directly; do not run another chroot.
Check `id -u` returns `0`, then check `hostname` and `cat /etc/os-release` against
the selected node. The command runs the **host's** `timeout` and shell; tools
installed only in the helper image are not automatically available here.

The plugin prints its generated `nsenter-*` pod name. In a second operator
terminal, set the same CTX/NS/SESSION variables, identify that pod and record it:

```bash
kubectl --context="$CTX" -n "$NS" get pods -l "maintenance-session=$SESSION" -o wide
POD='REPLACE_GENERATED_POD_NAME'
kubectl --context="$CTX" -n "$NS" get pod "$POD" -o yaml
```

The plugin attaches to the session and attempts pod deletion when it exits.
Verify cleanup even after normal exit. `timeout` limits this host command to an
hour; upstream node-shell does not set a pod `activeDeadlineSeconds`, an incident
annotation or token-automount controls. A lost client or interrupted cleanup can
leave a pod object. If security requires those explicit controls, use the manual
template below. `KUBECTL_NODE_SHELL_POD_RUNNING_TIMEOUT` limits startup waiting,
not the session lifetime. For a private registry, configure the approved secret
with `KUBECTL_NODE_SHELL_IMAGE_PULL_SECRET_NAME` before invoking the plugin.

### Alternative: explicit maintenance pod

Choose this instead of node-shell when a reviewed manifest, pod deadline and
token-automount controls are required. It uses its own named pod/container:

```bash
POD='REPLACE_UNIQUE_SESSION_NAME'
cp docs/how-to/node-maintenance/pod.yaml /tmp/node-maintenance.yaml
```

Edit the local copy: replace namespace, node, session name, incident reference
and image. Use the same values as above. Review the exact manifest and confirm
no `REPLACE_` markers remain. A new unique pod name prevents accidental reuse of
another operator's session. A failed authorization check must be resolved before proceeding.

```bash
kubectl --context="$CTX" create -f /tmp/node-maintenance.yaml
kubectl --context="$CTX" -n "$NS" wait --for=condition=Ready "pod/$POD" --timeout=120s
kubectl --context="$CTX" -n "$NS" exec -it "$POD" -c maintenance -- chroot /host /bin/sh
```

Inside the host shell, `id -u` must return `0`. `/` is now the node filesystem;
processes and networking are shared with the node. Without chroot, use `/host`
for node files. `chroot` alone does not enter the host mount namespace. For
systemd, mount operations or tools that need all host namespaces, open a separate
shell from the operator terminal:

```bash
kubectl --context="$CTX" -n "$NS" exec -it "$POD" -c maintenance -- \
  nsenter --target 1 --mount --uts --ipc --net --pid --root --wd -- /bin/sh
```

This uses the host PID 1 root and namespaces. Check `id`, `hostname` and
`cat /etc/os-release` against the selected node before modifying anything.
The pod has a one-hour deadline and does not restart. This ends the session,
but does not delete the pod object or restore host changes. Cleanup is mandatory.
Do not use this session for package operations that exceed its deadline.

## Maintenance actions

Commands below run in the **host shell** unless marked as operator-terminal commands.
Before disruptive work, assess replicas, volumes, capacity and disruption budgets.
Cordon/drain the selected node in an approved window where appropriate; do not
force eviction or discard local data merely to make drain succeed. Record whether
the node was already cordoned, so cleanup does not undo another maintenance action.

### System logs and kubelet diagnostics

```bash
tail -n 200 /var/log/syslog
journalctl --no-pager -n 200
journalctl -u kubelet --no-pager -n 200
systemctl status kubelet --no-pager
df -h
df -i
```

Some images use journald without `/var/log/syslog`; record that difference and
collect the journal instead. Preserve relevant logs before changing the system.
For kubelet configuration, inspect `systemctl cat kubelet` and back up the actual
configuration path referenced there before editing. For an approved repair on
a reachable node, use the namespace-entered shell, then `systemctl restart kubelet`
and inspect `journalctl -u kubelet`. Restart can interrupt exec and pod management;
verify node readiness from the operator terminal afterward. If kubelet cannot
start new pods or service exec, use the recovery path below.

### Kill a process blocking pod removal

Identify the workload, owner and PID with `ps -ef` and the container runtime.
Confirm the process belongs to the affected workload, rather than kubelet,
the runtime or a provider agent. Prefer graceful workload termination first.

```bash
ps -o pid,ppid,user,args -p REPLACE_PID
kill -TERM REPLACE_PID
```

Re-check that exact PID and command before escalating to `kill -KILL REPLACE_PID`.
Killing a process does not resolve a finalizer or storage detach issue; inspect
pod events and finalizers separately. Never remove finalizers without understanding
their cleanup obligations.

### Container runtime commands

In the normal node-shell host session, if the approved `nerdctl` binary is already
available on the host:

```bash
nerdctl --namespace k8s.io ps -a
nerdctl --namespace k8s.io images
```

`k8s.io` is a containerd namespace, shared by all Kubernetes namespaces. Confirm
the containerd socket from host configuration; use `--address` if it differs
from the CLI default. Do not assume nerdctl is installed on OVHcloud workers.
If it is absent, use the already available `crictl`, or open a separate **X-mode**
session from the operator terminal with nerdctl included in the approved image:

```bash
KUBECTL_NODE_SHELL_LABELS="maintenance-session=$SESSION" \
  kubectl node-shell --context "$CTX" -n "$NS" -x "$NODE" --image "$IMAGE" -- /bin/sh
# Inside X-mode, after confirming the host socket path:
nerdctl --address /host/run/containerd/containerd.sock --namespace k8s.io ps -a
```

X-mode needs `jq` on the workstation. It keeps the helper filesystem and mounts
the node at `/host`; host configuration paths must therefore be prefixed with
`/host`. This example assumes the confirmed node socket is
`/run/containerd/containerd.sock`. No additional containerd daemon is needed.
Record the separate generated pod name and verify its deletion afterward.
X-mode has no built-in one-hour deadline; exit promptly, or use the manual
template when a pod-level deadline is required.

For CRI diagnostics, use the following in the **host shell**:

```bash
crictl info
crictl ps -a
```

Use the node's `/etc/crictl.yaml` or the endpoint from its kubelet configuration.
If it is missing, pass the confirmed socket using `crictl --runtime-endpoint ...`.
For nodes actually using Docker, `docker ps` is the equivalent diagnostic check.
Do not install Docker on a containerd node. Runtime stop/remove commands require
the same workload assessment as process termination. Avoid `nerdctl run`, Compose
or blanket prune operations on a Kubernetes worker: application changes belong
in deployment/Helm configuration, and controllers can recreate stopped containers.

### Network, mounts and permissions

Ubuntu/netplan example (choose the real file; do not create a competing configuration):

```bash
cp -a /etc/netplan /root/netplan.before-maintenance
vi /etc/netplan/REPLACE_EXISTING_FILE.yaml
netplan generate
```

`netplan generate` validates/generates configuration without applying it. Only
apply network changes with a confirmed provider recovery route and rollback plan:
connectivity loss also removes this maintenance access. `netplan try` can provide
a timed rollback, but must first be validated on this host and session type.
Restore the saved files if validation fails. If the node does not use netplan,
identify its actual network manager and record TC-001 applicability before editing.

```bash
cp -a /etc/fstab /root/fstab.before-maintenance
vi /etc/fstab
findmnt --verify --verbose
```

Review verification output before any mount or reboot. Perform actual mount
operations in the namespace-entered shell. Restore the saved fstab on failure;
do not run a blanket `mount -a` during validation. For a permission workaround,
record `stat` output first, change only the named path using `chmod`/`chown`,
and document exact original values for rollback.

### Copy a file from the operator PC

For node-shell, stream the local file through a short-lived host command from
the **operator terminal** (each invocation creates and cleans up its own pod):

```bash
sha256sum ./diagnostic.txt
KUBECTL_NODE_SHELL_LABELS="maintenance-session=$SESSION" \
  kubectl node-shell --context "$CTX" -n "$NS" "$NODE" --image "$IMAGE" -- \
  /bin/sh -c 'umask 077; mkdir -p /var/tmp/node-maintenance; cat > /var/tmp/node-maintenance/diagnostic.txt' \
  < ./diagnostic.txt
kubectl node-shell --context "$CTX" -n "$NS" "$NODE" --image "$IMAGE" -- \
  sha256sum /var/tmp/node-maintenance/diagnostic.txt
```

Match the checksums and remove the test file from the host afterward. Do not
overwrite a pre-existing file. Normal node-shell does not mount `/host`, so the
manual-template `kubectl cp` commands below do not apply to that mode.

For the **manual template only**, use the following:

From a second **operator terminal** with the same CTX/NS/POD variables:

```bash
kubectl --context="$CTX" -n "$NS" exec "$POD" -c maintenance -- \
  mkdir -p /host/var/tmp/node-maintenance
kubectl --context="$CTX" -n "$NS" cp ./diagnostic.txt \
  "$POD:/host/var/tmp/node-maintenance/diagnostic.txt" -c maintenance
sha256sum ./diagnostic.txt
kubectl --context="$CTX" -n "$NS" exec "$POD" -c maintenance -- \
  chroot /host sha256sum /var/tmp/node-maintenance/diagnostic.txt
```

`kubectl cp` needs `tar` in the container. Match checksums, set the intended
owner/mode in the host shell and remove the test file after validation. To retrieve
a log, reverse the source and destination in `kubectl cp`. Protect sensitive files.

### Install, update or uninstall an application

For an OS package, run the host's package manager in the namespace-entered shell,
using approved repositories. Debian/Ubuntu examples:

```bash
dpkg-query -W REPLACE_PACKAGE
apt-get --simulate install REPLACE_PACKAGE=REPLACE_APPROVED_VERSION
apt-get install REPLACE_PACKAGE=REPLACE_APPROVED_VERSION
# Uninstall only the package approved for removal:
apt-get --simulate remove REPLACE_PACKAGE
apt-get remove REPLACE_PACKAGE
```

Check repository metadata freshness, dependency changes and availability of the
previous package version before execution. Avoid broad upgrades, autoremove or
removing kubelet/runtime/provider packages. Record versions before/after and the
reinstallation/downgrade plan. Direct OS fixes are temporary on managed workers;
request the permanent fix through provider maintenance or the supported node image.

For a Kubernetes application/CVE, update its image/version or remove it in the
owning deployment/Helm configuration on a dedicated branch. Follow the normal
release procedure and [application removal procedure](Remove%20applications.md).
Deleting a local container is temporary: its controller recreates it.

## Unreachable node or crashed kubelet

Node-shell, the manual template and `kubectl debug node --profile=sysadmin` need a functioning
kubelet/runtime and API-to-node connectivity. A Running maintenance pod is not
a reliable recovery channel if kubelet dies, because exec also depends on kubelet.
Do not stop kubelet to test recovery through this channel.

For this repository's OVHcloud managed workers, collect node identity, providerID,
events, last available logs, incident time and impact. Escalate to OVHcloud support
for diagnosis/recovery or an approved node replacement through the managed service.
Review disruption budgets and local-volume/data loss before replacement. Do not
assume a root console is available or alter underlying managed instances through
OpenStack directly. Provider-managed control-plane incidents also go to OVHcloud.

For a separately operated self-managed cluster, a previously tested provider
serial/VNC console or rescue mechanism with secured root credentials can provide
the independent recovery channel. Validate that path before relying on it.
The story's dead-kubelet repair requirement remains unaccepted until the appropriate
provider recovery route has been demonstrated.

## End the session

Exit all host shells. Restore temporary configuration and remove test packages/files;
retain intentional fixes with their incident reference and permanent remediation plan.
From the **operator terminal**:

For node-shell, first allow its exit cleanup to finish, then look up the exact
recorded pod name. If it remains, delete it using the command below. For the
manual template, delete it explicitly. Repeat for every X-mode/session pod;
do not delete another operator's pods.

```bash
kubectl --context="$CTX" -n "$NS" delete pod "$POD" --wait=true --timeout=120s
kubectl --context="$CTX" -n "$NS" get pod "$POD"
kubectl --context="$CTX" get node "$NODE" -o wide
```

The pod lookup must return NotFound. If deletion times out, investigate node health
and confirm actual container termination; force-deleting the API object alone
does not prove the host process stopped. Uncordon only if this incident cordoned
the node and the node/workloads pass recovery checks. Revoke temporary access and
exceptions, record end time, attach evidence and confirm the host configuration.

## TC-001 and completion record

Use a disposable non-production worker and a harmless process owned by root or
another test account, never a production process. Configuration tests should make
a reversible comment-only change, validate it, and restore the original file.
Choose an approved harmless package that was initially absent, install it and remove
it. Network activation, mount changes and kubelet restart need separate disruption
testing with the provider recovery route available.

| Check | Expected evidence | Result |
| --- | --- | --- |
| Root access on each worker pool, including tainted/cordoned test workers | Selected node identity, UID 0, session manifest | Not run |
| Read `/var/log/syslog` | Output, or documented journald equivalent if absent | Not run |
| Kill process not owned by operator | Owner/PID before, process absent after TERM | Not run |
| Elevated nerdctl and crictl commands | Host runtime info/list output; nerdctl uses k8s.io and confirmed host socket | Not run |
| Edit `/etc/netplan` | Backup, reversible diff, validation, original restored | Not run |
| Edit `/etc/fstab` | Backup, reversible diff, findmnt verification, restored | Not run |
| Copy PC file to node | Matching source/host SHA-256, test file removed | Not run |
| Install/uninstall OS application | Package absent before, installed version, absent after | Not run |
| Repair kubelet failure | Provider recovery evidence and Ready node afterward | Not run |
| Access denied for ordinary user | Creation/exec denied with unprivileged identity | Not run |
| Node-shell timeout and cleanup | Host command ends; generated pods deleted, including interrupted-client cleanup; access revoked | Not run |
| Manual template expiry and cleanup | Deadline terminates container; pod deleted | Not run |

Record node-shell/nerdctl versions, cluster/server/client versions, node OS/runtime, approved image digest,
operator, date, incident, commands, outputs, rollback and reviewer for each run.
Do not mark tests passed based on local manifest inspection.

| Definition of Done item | Status |
| --- | --- |
| Node-shell/nerdctl procedure and alternative maintenance template | Implemented locally |
| TC-001 and recovery tests passed | Pending non-production execution |
| Procedure published on Confluence | Pending; publish this reviewed document and evidence |
| ADS Security validation | Pending; record approver, date and review reference |
| Dedicated branch derived from development branch | `feat/node-maintenance-without-ssh`, from `develop` (repository has no `dev` ref) |
| Code pushed on dedicated branch | Pending; no push performed |

## References

- [Node-shell usage and installation](https://github.com/kvaps/kubectl-node-shell)
- [Node-shell implementation: namespace entry, attach and cleanup](https://github.com/kvaps/kubectl-node-shell/blob/master/kubectl-node_shell)
- [Nerdctl Kubernetes debugging and containerd namespaces](https://github.com/containerd/nerdctl#debugging-kubernetes)
- [Kubernetes node debugging and its unavailable-node limitation](https://kubernetes.io/docs/tasks/debug/debug-cluster/kubectl-node-debug/)
- [OVHcloud managed Kubernetes architecture](https://docs.ovhcloud.com/en/guides/public-cloud/containers-orchestration/managed-kubernetes/understanding-mks-architecture)
- [OVHcloud managed Kubernetes known limits](https://github.com/ovh/docs/blob/develop/pages/public_cloud/containers_orchestration/managed_kubernetes/known-limits/guide.en-sg.md)
