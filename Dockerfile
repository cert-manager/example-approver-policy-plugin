# Build the approver-policy binary
FROM docker.io/library/golang:1.26@sha256:313faae491b410a35402c05d35e7518ae99103d957308e940e1ae2cfa0aac29b as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source files
COPY main.go main.go

# Build
RUN go build -o cert-manager-example-approver-policy-plugin main.go

FROM gcr.io/distroless/base@sha256:c83f022002fc917a92501a8c30c605efdad3010157ba2c8998a2cbf213299201
LABEL description="example cert-manager approver-policy plugin"

WORKDIR /
USER 1001
COPY --from=builder /workspace/cert-manager-example-approver-policy-plugin /usr/bin/cert-manager-approver-policy

ENTRYPOINT ["/usr/bin/cert-manager-approver-policy"]
