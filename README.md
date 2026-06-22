# A Custom Caddy Docker Image with Essential Plugins

[![Docker Pulls](https://img.shields.io/docker/pulls/morsalin1342/caddy.svg?style=for-the-badge&logo=docker)](https://hub.docker.com/r/morsalin1342/caddy)
[![GitHub Stars](https://img.shields.io/github/stars/morsalin1342/caddy-docker?style=for-the-badge&logo=github)](https://github.com/morsalin1342/caddy-docker)
[![License](https://img.shields.io/github/license/morsalin1342/caddy-docker?style=for-the-badge)](https://github.com/morsalin1342/caddy-docker/blob/master/LICENSE)

This repository contains the build instructions for a customized [Caddy](https://caddyserver.com/) Docker image — a high-performance **reverse proxy** and **web server** with **automatic HTTPS** via Let's Encrypt. It includes the standard Caddy features plus a selection of commonly used plugins for DNS validation, caching, and more.

The image is automatically built and published to [Docker Hub](https://hub.docker.com/r/morsalin1342/caddy) via GitHub Actions.

## ✨ Why This Image?

| Feature | Official `caddy` | This Image |
|---------|-----------------|------------|
| **Brotli compression** | ❌ | ✅ |
| **Mercure hub** | ❌ | ✅ (real-time SSE) |
| **HTTP caching** | ❌ | ✅ Souin (Redis, Otter, SimpleFS) |
| **DNS challenge** | Requires custom build | ✅ 6 providers built-in |
| **Production ready** | Needs custom build | ✅ Ready to deploy |

## Quick Start

To get started, you need a `Caddyfile` for your configuration.

```sh
docker run -d --name caddy \
    -p 80:80 \
    -p 443:443 \
    -p 443:443/udp \
    -v /path/to/your/Caddyfile:/etc/caddy/Caddyfile:ro \
    -v caddy_data:/data \
    -v caddy_config:/config \
    morsalin1342/caddy:latest
```

### Persistent Data

This command uses Docker named volumes to persist important data:

*   **`caddy_data`**: Stores TLS certificates and other persistent data. Caddy will create this automatically.
*   **`caddy_config`**: Stores any JSON config changes made via the admin API.

## Configuration

Your primary method of configuration is by providing a `Caddyfile`. Mount your local `Caddyfile` to `/etc/caddy/Caddyfile` inside the container as shown in the command above.

For more advanced use cases, you can use the [Caddy Admin API](https://caddyserver.com/docs/api).

## Versioning

This image is tagged with two schemes:

*   `morsalin1342/caddy:latest`: Always points to the most recently built image from the `master` branch.
*   `morsalin1342/caddy:<version>`: (e.g., `morsalin1342/caddy:2.11.4`) A specific version tag corresponding to the version of Caddy used in the build.

It is recommended to use a specific version tag in production environments for stability.

## Included Plugins

This image extends the official Caddy image with the following plugins:

*   **Brotli Compression**: `github.com/dunglas/caddy-cbrotli`
*   **Mercure Hub**: `github.com/dunglas/mercure/caddy`
*   **Vulcain Gateway**: `github.com/dunglas/vulcain/caddy`
*   **HTTP Caching (Souin)**: `github.com/darkweak/souin/plugins/caddy`
    *   Storage backends:
        *   `github.com/darkweak/storages/go-redis/caddy` (Redis)
        *   `github.com/darkweak/storages/otter/caddy` (in-memory)
        *   `github.com/darkweak/storages/simplefs/caddy` (file-based)
*   **DNS Providers for ACME TLS**:
    *   `github.com/caddy-dns/vultr`
    *   `github.com/caddy-dns/azure`
    *   `github.com/caddy-dns/googleclouddns`
    *   `github.com/caddy-dns/digitalocean`
    *   `github.com/caddy-dns/cloudflare`
    *   `github.com/caddy-dns/route53`

## ❓ FAQ

**Q: How do I add more plugins?**
A: Fork this repository and add your desired plugins to the `xcaddy build` command in the `Dockerfile`, then rebuild. Caddy plugins are Go modules compiled directly into the binary.

**Q: How do I use DNS challenge for wildcard certificates?**
A: All six DNS providers (Cloudflare, Route53, DigitalOcean, Vultr, Azure, Google Cloud DNS) are pre-compiled. Set the appropriate environment variables for your provider's API credentials and configure the `tls` directive in your `Caddyfile`.

**Q: How does caching work with this image?**
A: The Souin cache handler is pre-installed with three storage backends: `simplefs` (file-based, zero config), `go-redis` (distributed), and `otter` (in-memory). Configure caching in your `Caddyfile` via the `cache` directive.

**Q: Can I use this image with FrankenPHP?**
A: This is a standalone Caddy image. For a pre-configured Caddy+PHP setup, use the [morsalin1342/frankenphp](https://hub.docker.com/r/morsalin1342/frankenphp) image instead, which bundles this same Caddy plugin stack with PHP.

---

## Feedback and Issues

If you have suggestions or find a bug, please [open an issue](https://github.com/morsalin1342/caddy-docker/issues) on the GitHub repository.

---

⭐ **If this project helps you, consider giving it a star!**
