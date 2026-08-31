# Caddy — Enterprise Web Server

**Published by [easydigital](https://hub.docker.com/u/easydigital)** · [GitHub](https://github.com/morsalin1342/caddy-docker)

Enterprise Caddy build with production-ready plugins. Same image as `morsalin1342/caddy` — published here for organizational deployments.

## Production Deployment

```yaml
# production.yml
services:
  caddy:
    image: easydigital/caddy:2.11.4
    restart: always
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    environment:
      CLOUDFLARE_API_TOKEN: ${CF_TOKEN}

volumes:
  caddy_data:
  caddy_config:
```

## DNS Challenge Example

```caddy
*.example.com {
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
    reverse_proxy localhost:8080
}
```

## Tags

`latest`, `2.11.4` — pin to a specific version for production.

---

### 🔗 Related Images & Tools

| Image / Tool | Description |
|--------------|-------------|
| [easydigital/frankenphp](https://hub.docker.com/r/easydigital/frankenphp) | Caddy + PHP app server in one container (org) |
| [easydigital/php](https://hub.docker.com/r/easydigital/php) | Traditional PHP-FPM & CLI images (org) |
| [easydigital/nginx](https://hub.docker.com/r/easydigital/nginx) | nginx with ModSecurity 3, Brotli, zstd & GeoIP2 (org) |
| [morsalin1342/caddy](https://hub.docker.com/r/morsalin1342/caddy) | Personal account mirror |
| [caddy-souin-cache-manager](https://github.com/morsalin1342/caddy-souin-cache-manager) | Manage this image's Souin cache from WP Admin |
