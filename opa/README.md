# OPA Validating Webhook for Kubernetes

This is a guide for deploying the Open Policy Agent Validating Webhook for Kubernetes

## Policies

- [Liveness Probe](./policy/policy-liveness-probe-check.rego)
- [Readiness Probe](./policy/policy-readiness-probe-check.rego)
- [Privileged Pod Security Context](./policy/policy-privileged-pod-check.rego)

## Prereqs

Kubernetes 1.9.0 or above with the admissionregistration.k8s.io/v1beta1 API enabled. Verify that by the following command:

```
$ kubectl api-versions | grep admissionregistration.k8s.io/v1beta1
```

The result should be:

```
admissionregistration.k8s.io/v1beta1
```

In addition, the `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook` admission controllers should be added and listed in the correct order in the admission-control flag of kube-apiserver.

## Deploy Webhook

Run the install script with the `install` option

```
$ cd ./deploy/scripts
$ ./opa-webhook-install.sh install
```

## Cleanup Webhook

Run the install script with the `delete` option

```
$ cd ./deploy/scripts
$ ./opa-webhook-install.sh delete
```

## Testing

The install script creates the `test-opa` namespace and labels is with `k8s.t-mobile.com/opa=enabled` for testing purposes.

- Deploy test deployment to Kubernetes cluster

  ```
  $ kubectl apply -f ./testing/test-deploy1.yaml -n test2
  ```

  NOTE: The webhook should deny this workload

  
### Test Samples Available

| File                                  | Test Type                                      | Expected Result   |
|---                                    |---                                             |---                |
| ./testing/test-deploy1.yaml           | Deployment, No Probes, Not Privileged          | FAIL              |
| ./testing/test-deploy2.yaml           | Deployment, Has Probes, Not Privileged         | PASS              |
| ./testing/test-deploy3.yaml           | Deployment, Has Probes, Privileged             | FAIL              |

NOTE: There's a raw JSON file for each associated YAML manifest


## Troubleshooting

### Verify ConfigMap Status

OPA writes an annotation to each policy configMap to notate the status of the policy (whether it's valid and has been accepted by OPA)

```
$ kubectl get cm -n opa policy-liveness-probe-check -o jsonpath="{.metadata.annotations.openpolicyagent\.org/policy-status}{\"\n\"}"
```

### Proxy for direct API access (maybe setup ingress too for external calls)

You can initiate a proxy to the OPA pod to submit JSON objects to the OPA API dircetly. You can also expose this via ingress if you need to access the API externally

```
$ kubectl port-forward -n opa opa-6f84468f7f-bc9l2 8181 
```

Once the proxy connection is live, you can query the webhook directly

```
$ curl -v http://localhost:8181/ -d @test1.json -H "Content-Type: application/json"
```

### Rego Playground

The OPA Project has an interactive [Playground](https://play.openpolicyagent.org/) for Rego on its site for building out policies with immediate feedback

## Links

- [Github Repo](https://github.com/open-policy-agent/opa)

- [Docs for webhook](https://www.openpolicyagent.org/docs/kubernetes-admission-control.html)

- [Docs for Rego](https://www.openpolicyagent.org/docs/language-reference.html)

- [Rego Deep Div Presentation](https://www.slideshare.net/TorinSandall/rego-deep-dive)