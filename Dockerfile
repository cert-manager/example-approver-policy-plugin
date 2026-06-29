# Build the approver-policy binary
FROM docker.io/library/golang:1.26.4@sha256:f96cc555eb8db430159a3aa6797cd5bae561945b7b0fe7d0e284c63a3b291609 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source files
COPY main.go main.go

# Build
RUN go build -o cert-manager-example-approver-policy-plugin main.go

FROM gcr.io/distroless/base@sha256:57c1e4c72feb5925c4763ae4f6bd2013ad3854f57eff5b60dd9acb1ce0abc66e
LABEL description="example cert-manager approver-policy plugin"

WORKDIR /
USER 1001
COPY --from=builder /workspace/cert-manager-example-approver-policy-plugin /usr/bin/cert-manager-approver-policy

ENTRYPOINT ["/usr/bin/cert-manager-approver-policy"]
