# Build the approver-policy binary
FROM docker.io/library/golang:1.25@sha256:cc737435e2742bd6da3b7d575623968683609a3d2e0695f9d85bee84071c08e6 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source files
COPY main.go main.go

# Build
RUN go build -o cert-manager-example-approver-policy-plugin main.go

FROM gcr.io/distroless/base@sha256:347a41e7f263ea7f7aba1735e5e5b1439d9e41a9f09179229f8c13ea98ae94cf
LABEL description="example cert-manager approver-policy plugin"

WORKDIR /
USER 1001
COPY --from=builder /workspace/cert-manager-example-approver-policy-plugin /usr/bin/cert-manager-approver-policy

ENTRYPOINT ["/usr/bin/cert-manager-approver-policy"]
