# Node maintenance without SSH

This guide shows how to open a root shell on a Kubernetes worker node without SSH using [`kubectl-node-shell`](https://github.com/kvaps/kubectl-node-shell).

> **Note:** This requires a running `kubelet` on the target node and cluster-admin / privileged pod permissions. If a node is completely unreachable or `kubelet` is down, recover or replace the node via the cloud provider (OVHcloud console/support).

## 1. Install `kubectl-node-shell`

Install the plugin on your machine (via [Krew](https://krew.sigs.k8s.io/) or direct download):

```bash
kubectl krew install node-shell
```

Or install the script directly:

```bash
curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
chmod +x ./kubectl-node_shell
sudo mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell
```

## 2. Open a root shell on a node

1. List the nodes to find the target `<node-name>`:

```bash
kubectl get nodes
```

2. Start an interactive root shell on the node:

```bash
kubectl node-shell <node-name>
```

*(When you exit the shell, the temporary `nsenter-*` pod is automatically deleted.)*

## 3. Common maintenance tasks

Once connected to the node shell, you are `root` on the host filesystem:

### Check system logs and debug/repair `kubelet`

```bash
# Consult system logs
tail -n 200 /var/log/syslog

# Debug and restart kubelet
systemctl status kubelet
journalctl -u kubelet -n 200 --no-pager
systemctl restart kubelet
```

> **If `kubelet` is completely down/crashed:** `kubectl node-shell` cannot schedule a pod on an unresponsive node. For OVHcloud Managed Kubernetes nodes, recover or replace the node via the OVHcloud console/support (or use the cloud provider's rescue/serial console on self-managed nodes).

### Manage containers (`ctr`)

Kubernetes nodes run `containerd` under the `k8s.io` namespace and include the `ctr` CLI by default:

```bash
ctr -n k8s.io containers ls
ctr -n k8s.io images ls
```

### Kill a stuck process

```bash
ps -ef | grep <process-name>
kill -TERM <pid>
# If it does not stop:
kill -KILL <pid>
```

### Edit local configuration (network, mounts, permissions)

```bash
# Network (/etc/netplan)
cp /etc/netplan/50-cloud-init.yaml /root/50-cloud-init.yaml.bak
vi /etc/netplan/50-cloud-init.yaml

# Mounts (/etc/fstab)
cp /etc/fstab /root/fstab.bak
vi /etc/fstab

# File permissions / ownership
chmod 640 /path/to/file
chown root:root /path/to/file
```

### Copy a file from your PC to the node

Run this from your **local terminal** (outside the node shell):

```bash
kubectl node-shell <node-name> -- sh -c 'cat > /tmp/myfile.txt' < ./myfile.txt
```

### Install, update, or remove a package / application

```bash
# OS packages (apt)
apt-get update
apt-get install <package-name>
apt-get remove <package-name>
```

For Kubernetes applications deployed on the cluster (e.g., for a CVE workaround), update the Helm/deployment configuration or follow [Remove applications](Remove%20applications.md).
