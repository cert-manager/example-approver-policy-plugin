# Build the approver-policy binary
FROM docker.io/library/golang:1.26@sha256:87a41d2539e5671777734e91f467499ed5eafb1fb1f77221dff2744db7a51775 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source files
COPY main.go main.go

# Build
RUN go build -o cert-manager-example-approver-policy-plugin main.go

FROM gcr.io/distroless/base@sha256:f2df8702d4dcc45ce76df6cbc14ad1975fcf88a04bd0e8947b6194264f9ab75e
LABEL description="example cert-manager approver-policy plugin"

WORKDIR /
USER 1001
COPY --from=builder /workspace/cert-manager-example-approver-policy-plugin /usr/bin/cert-manager-approver-policy

ENTRYPOINT ["/usr/bin/cert-manager-approver-policy"]
