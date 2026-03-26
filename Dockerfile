# STAGE 1: Builder
# Downloads and extracts the AdGuardHome binary for ARMv5
FROM arm32v5/debian:bookworm AS builder

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp/build

# Install build dependencies and runtime components we need to extract
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        tar \
        tzdata \
        libcap2 \
        && rm -rf /var/lib/apt/lists/*

# Download and extract the latest AdGuardHome release
RUN set -eux; \
    AGH_VERSION=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | jq -r .tag_name | sed 's/v//'); \
    echo "Downloading AdGuardHome v${AGH_VERSION}..."; \
    curl -fSL "https://github.com/AdguardTeam/AdGuardHome/releases/download/v${AGH_VERSION}/AdGuardHome_linux_armv5.tar.gz" -o agh.tar.gz; \
    tar -xzf agh.tar.gz; \
    rm agh.tar.gz

# Extract list of shared libraries needed by AdGuardHome
RUN ldd /tmp/build/AdGuardHome/AdGuardHome | grep -o '/lib[^ ]*' | sort -u > /tmp/needed-libs.txt

# STAGE 2: Final Runtime - Minimal Scratch Image
FROM scratch

# Metadata
LABEL maintainer="vyzu"

# Set timezone
ENV TZ=UTC LANG=en_US.UTF-8

# Create directory structure
WORKDIR /opt/adguardhome

# Copy AdGuardHome binary
COPY --from=builder /tmp/build/AdGuardHome/AdGuardHome /opt/adguardhome/AdGuardHome

# Copy required shared libraries
COPY --from=builder /tmp/needed-libs.txt /tmp/needed-libs.txt
RUN xargs -a /tmp/needed-libs.txt copy-libs 2>/dev/null || \
    for lib in $(cat /tmp/needed-libs.txt); do \
        mkdir -p $(dirname /lib${lib#/lib}); \
        cp -L $lib /lib${lib#/lib} 2>/dev/null || true; \
    done

# Remove temp file
RUN rm -f /tmp/needed-libs.txt

# Copy CA certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/share/ca-certificates/ /usr/share/ca-certificates/

# Copy timezone data
COPY --from=builder /usr/share/zoneinfo/ /usr/share/zoneinfo/
COPY --from=builder /etc/localtime /etc/localtime

# Copy libcap library
COPY --from=builder /lib/arm-linux-gnueabi/libcap.so.2 /lib/arm-linux-gnueabi/libcap.so.2
COPY --from=builder /lib/arm-linux-gnueabi/libcap.a /lib/arm-linux-gnueabi/libcap.a

# Setup directories and permissions
RUN mkdir -p work conf && \
    chmod +x /opt/adguardhome/AdGuardHome

# Expose Ports
# DNS (53), DHCP (67/68), HTTP/S (80/443), DoT/DoQ (853), DoQ-Alt (784/8853), DNSCrypt (5443), Setup (3000)
EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 853/tcp 853/udp 784/udp 8853/udp 5443/tcp 5443/udp 3000/tcp

# Start AdGuardHome
CMD ["/opt/adguardhome/AdGuardHome", \
     "--work-dir", "/opt/adguardhome/work", \
     "--config", "/opt/adguardhome/conf/AdGuardHome.yaml"]
