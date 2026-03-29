# A Custom Caddy Docker Image with Essential Plugins

[![Docker Pulls](https://img.shields.io/docker/pulls/morsalin1342/caddy.svg)](https://hub.docker.com/r/morsalin1342/caddy)

This repository contains the build instructions for a customized [Caddy](https://caddyserver.com/) Docker image. It includes the standard Caddy features plus a selection of commonly used plugins for DNS validation, caching, and more.

The image is automatically built and published to [Docker Hub](https://hub.docker.com/r/morsalin1342/caddy) via GitHub Actions.

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
*   `morsalin1342/caddy:<version>`: (e.g., `morsalin1342/caddy:2.11.2`) A specific version tag corresponding to the version of Caddy used in the build.

It is recommended to use a specific version tag in production environments for stability.

## Included Plugins

This image extends the official Caddy image with the following plugins:

*   **Brotli Compression**: `github.com/dunglas/caddy-cbrotli`
*   **Mercure Hub**: `github.com/dunglas/mercure/caddy`
*   **Vulcain Gateway**: `github.com/dunglas/vulcain/caddy`
*   **Response Caching**: `github.com/caddyserver/cache-handler`
*   **Storage Handlers**:
    *   `github.com/darkweak/storages/go-redis/caddy`
    *   `github.com/darkweak/storages/otter/caddy`
    *   `github.com/darkweak/storages/simplefs/caddy`
*   **DNS Providers for ACME TLS**:
    *   `github.com/caddy-dns/vultr`
    *   `github.com/caddy-dns/azure`
    *   `github.com/caddy-dns/googleclouddns`
    *   `github.com/caddy-dns/digitalocean`
    *   `github.com/caddy-dns/cloudflare`
    *   `github.com/caddy-dns/route53`

## Feedback and Issues

If you have suggestions or find a bug, please [open an issue](https://github.com/morsalin1342/caddy-docker/issues) on the GitHub repository.
