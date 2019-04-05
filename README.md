# k8s-pac-demo

This repo contains demo materials for Kubernetes Policy-as-Code usinfg OPA (Open Policy Agent):

- [OPA Webhook](./opa)
    The OPA Webhook is a Kubernetes Validating webhook released as part of the Open Policy Agent project. The webhook is written in `go` and the policies are written in `Rego`

## Demo Setup

The demo in this repo requires a running Kubernetes cluster (1.9+) with the appropriate API Server flags enabling Dynamic Admission Controllers (Validating/Mutating Webhooks). You can utilize the included KIND (Kubernetes-in-Docker) configs and deploy script to generate a compatible cluster provided you have a running Docker install available.

[KIND Deploy](./kind)

## Links

- https://www.openpolicyagent.org/
- https://www.slideshare.net/TorinSandall/rego-deep-dive
- https://kind.sigs.k8s.io/