FROM alpine:3.21 AS fetcher

ARG K3S_VERSION
ARG TARGETARCH=amd64

RUN apk add --no-cache curl ca-certificates && \
    K3S_URL_VERSION="$(echo "${K3S_VERSION}" | sed 's/+/%2B/g')" && \
    curl -fsSL \
      "https://github.com/k3s-io/k3s/releases/download/${K3S_URL_VERSION}/k3s" \
      -o /usr/local/bin/k3s && \
    chmod 755 /usr/local/bin/k3s

FROM alpine:3.21

ARG K3S_VERSION
LABEL org.opencontainers.image.title="k3s" \
      org.opencontainers.image.description="Minimal k3s amd64 image on Alpine" \
      org.opencontainers.image.version="${K3S_VERSION}" \
      org.opencontainers.image.source="https://github.com/k3s-io/k3s" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN apk add --no-cache \
      ca-certificates \
      iptables \
      ip6tables \
      libseccomp \
      nfs-utils \
      socat \
      conntrack-tools \
      coreutils \
      util-linux-misc && \
    rm -rf /var/cache/apk/*

COPY --from=fetcher /usr/local/bin/k3s /usr/local/bin/k3s

VOLUME ["/var/lib/rancher/k3s"]

ENTRYPOINT ["/usr/local/bin/k3s"]
CMD ["--help"]
