# STAGE 1: Builder
# Downloads and extracts the AdGuardHome binary for ARMv5
FROM debian:stable AS builder

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp/build

# Install build dependencies and runtime assets to copy into scratch
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        tar \
        tzdata \
        libcap2 \
        libcap2-bin && \
    rm -rf /var/lib/apt/lists/*

# Download and extract the latest AdGuardHome release
RUN set -eux; \
    AGH_VERSION=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | jq -r .tag_name | sed 's/v//'); \
    echo "Downloading AdGuardHome v${AGH_VERSION}..."; \
    curl -fSL "https://github.com/AdguardTeam/AdGuardHome/releases/download/v${AGH_VERSION}/AdGuardHome_linux_armv5.tar.gz" -o agh.tar.gz; \
    tar -xzf agh.tar.gz;

# STAGE 2: Final Runtime
FROM busybox:stable-glibc

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

COPY --from=builder /usr/lib/arm-linux-gnueabi/libcap.so* /usr/lib/
COPY --from=builder /sbin/setcap /sbin/setcap

RUN --mount=type=bind,from=builder,source=/tmp/build/AdGuardHome/AdGuardHome,target=/tmp/AdGuardHome \
    mkdir -p /opt/adguardhome/conf /opt/adguardhome/work && \
    cp /tmp/AdGuardHome /opt/adguardhome/AdGuardHome && \
    addgroup -g 10001 adguardhome && \
    adduser -D -H -u 10001 -G adguardhome adguardhome && \
    chown -R 10001:10001 /opt/adguardhome && \
    chmod 0755 /opt/adguardhome/AdGuardHome && \
    setcap 'cap_net_bind_service=+eip' /opt/adguardhome/AdGuardHome

ENV TZ=UTC

# Expose Ports
# DNS (53), DHCP (67/68), HTTP/S (80/443), DoT/DoQ (853), DoQ-Alt (784/8853), DNSCrypt (5443), Setup (3000)
EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 853/tcp 853/udp 784/udp 8853/udp 5443/tcp 5443/udp 3000/tcp

# Start AdGuardHome
WORKDIR /opt/adguardhome/work

ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]

CMD [ \
    "--no-check-update", \
    "--config", "/opt/adguardhome/conf/AdGuardHome.yaml", \
    "--work-dir", "/opt/adguardhome/work" \
]
