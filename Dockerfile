# Build stage: clone repo and build binaries
FROM golang:1.23 AS builder

WORKDIR /src

RUN git clone https://tangled.sh/@tangled.sh/core

WORKDIR /src/core

RUN export CGO_ENABLED=1 && \
    go build -o knot ./cmd/knotserver && \
    go build -o keyfetch ./cmd/keyfetch && \
    go build -o repoguard ./cmd/repoguard

# Runtime stage: setup system using a newer debian base image for updated glibc
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y ca-certificates openssh-client openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Copy binaries
COPY --from=builder /src/core/knot /usr/local/bin/knotserver
COPY --from=builder /src/core/keyfetch /keyfetch
COPY --from=builder /src/core/repoguard /repoguard

# Set permissions for keyfetch
RUN chown root:root /keyfetch && chmod 755 /keyfetch

# Configure SSH authorized keys command
RUN mkdir -p /etc/ssh/sshd_config.d && \
    printf "Match User git\n  AuthorizedKeysCommand /keyfetch\n  AuthorizedKeysCommandUser nobody" \
    > /etc/ssh/sshd_config.d/authorized_keys_command.conf

# Create git user and deploy repoguard
RUN useradd -m -d /knot/git -s /bin/bash git && \
    cp /repoguard /knot/git/ && chown git:git /knot/git/repoguard

# Expose necessary ports
EXPOSE 5555 5444

# Set command to start the knot server
CMD ["/usr/local/bin/knotserver"]