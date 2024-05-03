# Create a docker registry secret in Kubernetes

You might need to create a docker registry secret to retrieve private container image from the GitHub Container Registry : ghcr.io

## Create a Personal Access Tokens (classic)

Check the official GitHub documentation : <https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic>

And create a PAT with at least `read:packages` scope.

## Create a docker registry secret in Kubernetes

Check the official Kubernetes documentation : <https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_secret_docker-registry/>

And create a Kubernetes secret with the GitHub token obtained in the previous step :

```bash
kubectl -n processing create secret docker-registry ghcr-k8s --docker-server=ghcr.io --docker-username=<USERNAME> --docker-password=<TOKEN_FROM_PREVIOUS_STEP>
```
