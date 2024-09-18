# Create a docker registry secret in Kubernetes

You might need to create a docker registry secret to retrieve private container image from the GitHub Container Registry : ghcr.io

## Create a Personal Access Tokens (classic)

Check the official GitHub documentation : <https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic>

And create a PAT with at least `read:packages` scope.

## Replace values in your inventory file

Replace the value in your inventory file : [inventory/mycluster/host_vars/setup/apps.yml](../../inventory/sample/host_vars/setup/apps.yml)

Into the following block :

```YAML
# You might need to create a docker registry secret
# to retrieve private container image from the
# GitHub Container Registry : ghcr.io
# Refer to the doc in /docs/how-to/GitHub Container Registry.md
github:
  registrySecret:
    name: ghcr-k8s
    registry: ghcr.io
    username: YOUR_GITHUB_USERNAME
    password: YOUR_GITHUB_TOKEN
```
