# Build the approver-policy binary
FROM docker.io/library/golang:1.27.1@sha256:3680233e3204827fbdc66088528ae6d4b3d034f51d03a99d454f6de034888244 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source files
COPY main.go main.go

# Build
RUN go build -o cert-manager-example-approver-policy-plugin main.go

FROM gcr.io/distroless/base@sha256:0ebad3510af52aefe45045cc01b07564570be4feecf8d9f93d3a05d1b5f2f93b
LABEL description="example cert-manager approver-policy plugin"

WORKDIR /
USER 1001
COPY --from=builder /workspace/cert-manager-example-approver-policy-plugin /usr/bin/cert-manager-approver-policy

ENTRYPOINT ["/usr/bin/cert-manager-approver-policy"]
