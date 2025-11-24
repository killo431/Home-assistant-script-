# Start from Home Assistant base image, using ARG for flexibility
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Define build arguments with defaults when appropriate
ARG BUILD_ARCH
ARG YQ_VERSION=4.42.1
ARG COSIGN_VERSION=2.1.1

# Install required packages and download arch-specific binaries
RUN set -x \
    && apk add --no-cache \
        git \
        docker \
        docker-cli-buildx \
        coreutils \
        wget \
    \
    && case "$BUILD_ARCH" in \
        "aarch64") \
            wget -q -O /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_arm64"; \
            wget -q -O /usr/bin/cosign "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-arm64"; \
            ;; \
        "amd64") \
            wget -q -O /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"; \
            wget -q -O /usr/bin/cosign "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64"; \
            ;; \
        *) \
            echo "Unsupported BUILD_ARCH: $BUILD_ARCH"; \
            exit 1; \
            ;; \
    esac \
    && git config --global --add safe.directory "*" \
    && chmod +x /usr/bin/yq \
    && chmod +x /usr/bin/cosign

# Copy builder.sh to image
COPY builder.sh /usr/bin/

WORKDIR /data
ENTRYPOINT ["/usr/bin/builder.sh"]
