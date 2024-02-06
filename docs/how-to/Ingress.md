# Ingress

an Ingress is an API object that manages external access to the services in a cluster, typically HTTP.

Ingress may provide load balancing, SSL termination and name-based virtual hosting.

[Learn more about Ingress on the main Kubernetes documentation site](https://kubernetes.io/docs/concepts/services-networking/ingress/).

## NGINX Ingress Controller

ingress-nginx is an Ingress controller for Kubernetes using [NGINX](https://www.nginx.org/) as a reverse proxy and load
balancer.

## cert-manager

cert-manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.

cert-manager also ensures certificates remain valid and up to date, attempting to renew certificates at an appropriate time before expiry to reduce the risk of outages and remove toil.

Documentation for cert-manager can be found at [cert-manager.io](https://cert-manager.io/docs/).

For the common use-case of automatically issuing TLS certificates for Ingress resources, see the [cert-manager nginx-ingress quick start guide](https://cert-manager.io/docs/tutorials/acme/nginx-ingress/).

For a more comprehensive guide to issuing your first certificate, see our [getting started guide](https://cert-manager.io/docs/getting-started/).

## Ingress + SSL

Thanks to the NGINX ingress controller and the cert-manager components, when installed and properly configured, it's easy to deploy in ingress with SSL with just one Kubernetes resource file.

The example below shows how to deploy an ingress that will automatically provides the SSL certificate and updates it before it expires:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  name: demo
spec:
  ingressClassName: nginx
  rules:
  - host: demo.example.com
    http:
      paths:
      - backend:
          service:
            name: demo
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - demo.example.com
    secretName: demo-example-com-secret
```

(Replace the value of "demo.example.com" and "demo-example-com-secret")
