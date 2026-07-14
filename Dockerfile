# Build the approver-policy binary
FROM docker.io/library/golang:1.26.5@sha256:983a0823d3dab83604654972fe6bbda13142a7c57f987804fbdddb9d47dad9ec as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source files
COPY main.go main.go

# Build
RUN go build -o cert-manager-example-approver-policy-plugin main.go

FROM gcr.io/distroless/base@sha256:7c4468db5fea18a1630860619be640c4c0ad158c0d63f12951b96b7d0f5ddd62
LABEL description="example cert-manager approver-policy plugin"

WORKDIR /
USER 1001
COPY --from=builder /workspace/cert-manager-example-approver-policy-plugin /usr/bin/cert-manager-approver-policy

ENTRYPOINT ["/usr/bin/cert-manager-approver-policy"]
