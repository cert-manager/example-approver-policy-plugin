# example-approver-policy-plugin

This repo contains an example [cert-manager/approver-policy plugin](https://cert-manager.io/docs/projects/approver-policy/#plugins).


> :warning:  This is plugin is not meant to be actually used and does not contain a best practices production ready code.

## Implementing a custom approver plugin

[cert-manager/approver-policy](https://cert-manager.io/docs/projects/approver-policy/) can be extended via a plugin mechanism where a custom plugin can be written with custom logic for evaluating `CertificateRequest`s and `CertificateRequestPolicy`s. This can then be registered with the core cert-manager/approver-policy (in Go code) and a single image can be built that will have both the core approver and the custom plugin.

To get started with writing an approver plugin you can clone this repo and change the logic in the  methods of the example plugin to do what you want it to do, add tests and the desired packaging mechanism.

The general flow when writing an example plugin (that this sample implementation follows):

- implement the [`cert-manager/approver-policy.Interface`](https://github.com/cert-manager/approver-policy/blob/v0.6.3/pkg/approver/approver.go#L27-L53). This should contain all the logic of the new plugin for evaluating `CertificateRequest`s and `CertificateRequestPolicy`s.

- ensure that the implementation of `approver-policy.Interface` is registered with [the global approver registry shared with core approver](https://github.com/cert-manager/approver-policy/blob/v0.6.3/pkg/registry/registry.go#L28)

- build a single Go binary that contains the custom plugin(s) that you wish to use as well as the upstream approver-policy. The entrypoint should be [root command of approver-policy](https://github.com/cert-manager/approver-policy/blob/v0.6.3/cmd/main.go#L24)

- package the whole project using your favourite packaging mechanism. This repo contains an example Dockerfile and an example Helm chart that includes the core cert-manager/approver-policy's Helm chart.

## example plugin

This repo contains an example plugin `example-approver-policy-plugin` that allows to specify a weekday when `CertificateRequest`s can be approved.

See an example `CertificateRequestPolicy` that allows issuance only on Tuesdays in ./deploy/examples/tuesday.yaml:

```yaml
apiVersion: policy.cert-manager.io/v1alpha1
kind: CertificateRequestPolicy
metadata:
  name: tuesday
spec:
  allowed:
    ... # Be aware that using a plugin does not disable the core approver- a CertificateRequest still has to match the allowed block here even if a plugin is specified
  selector:
   ...
  plugins:
    example-approver-policy-plugin:
      values:
        day: "2" # Tuesday (0 - Sunday, 1 - Monday etc)
```