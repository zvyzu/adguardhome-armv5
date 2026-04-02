# AdGuardHome ARMv5 Container (MikroTik hEX / Legacy Routers)

**AdGuardHome container image for ARMv5 devices**, designed specifically for legacy routers such as:

✅ MikroTik hEX (EN7562CT CPU)

✅ Other ARMv5-only container environments

Official AdGuardHome images do **not support ARMv5**, which prevents them from running on certain MikroTik devices.
This repository solves that limitation by providing a working, lightweight container build.

---

## ✨ Features

- ARMv5 compatible container image
- Based on official AdGuardHome release binaries
- Minimal and lightweight runtime image (Include only necessary runtime dependencies and the AdGuardHome binary)

---

## 📦 Container Image

The prebuilt image is available on **GitHub Container Registry (GHCR)** and **Docker Hub**:

Set your MikroTik container registry to:

```
https://ghcr.io
```

Then pull the image from:

```
zvyzu/adguardhome-armv5:latest
```

or

```
https://registry-1.docker.io
```

Then pull the image from:

```
vyzu/adguardhome-armv5:latest
```

---

## 🌐 Default Web Interface

After starting the container, the AdGuardHome setup interface will be available at:

```
http://<container-ip>:3000
```

Follow the setup wizard to complete the configuration.

---

## 🔌 Exposed Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 53   | TCP/UDP  | DNS |
| 67/68| UDP      | DHCP |
| 80   | TCP      | HTTP |
| 443  | TCP      | HTTPS |
| 853  | TCP/UDP  | DNS-over-TLS |
| 784  | UDP      | DNS-over-QUIC |
| 8853 | UDP      | DNS-over-QUIC (Alt) |
| 5443 | TCP/UDP  | DNSCrypt |
| 3000 | TCP      | Initial Setup UI |

---

## 📚 Upstream Project & Credits

This repository packages the official **AdGuardHome** software.

AdGuardHome is developed by:

AdGuard Team  
https://github.com/AdguardTeam/AdGuardHome  

License:  
https://github.com/AdguardTeam/AdGuardHome/blob/master/LICENSE.txt  

All credit for the DNS server itself belongs to the AdGuard developers.

---

## ⚠️ Disclaimer

This project only provides container packaging for ARMv5 environments.

It is:

- Not affiliated with AdGuard
- Not an official AdGuard build
- Provided without warranty

---
