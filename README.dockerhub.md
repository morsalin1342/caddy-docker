# Caddy — Custom Web Server with Essential Plugins

**Maintained by [morsalin1342](https://hub.docker.com/u/morsalin1342)** · [GitHub](https://github.com/morsalin1342/caddy-docker)

A custom Caddy build with the OWASP Coraza WAF, rate limiting, AI-crawler blocking, Brotli compression, HTTP caching, and 6 DNS challenge providers for automatic HTTPS.

## Quick Start

```bash
docker run -d --name caddy \
    -p 80:80 -p 443:443 -p 443:443/udp \
    -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile:ro \
    -v caddy_data:/data \
    morsalin1342/caddy:latest
```

## Example Caddyfile

```caddy
{
    order coraza_waf first
}

example.com {
    encode zstd gzip
    cache
    coraza_waf {
        load_owasp_crs
        directives `
            Include @coraza.conf-recommended
            Include @crs-setup.conf.example
            Include @owasp_crs/*.conf
            SecRuleEngine DetectionOnly
        `
    }
    reverse_proxy localhost:8080
}
```

`load_owasp_crs` is required for the `@` include paths to resolve. Start in
`DetectionOnly`, tune out false positives, then switch to `On`.

## Included Plugins

| Category | Plugins |
|----------|---------|
| Security | Coraza WAF (SecLang/ModSecurity compatible, OWASP CRS compiled in) |
| Rate limiting | Sliding-window, multi-zone, keyed on any request placeholder |
| Bot / IP blocking | Defender — embedded AI-crawler and cloud-provider IP ranges |
| Compression | cbrotli (Brotli) |
| Caching | Souin with Redis, Otter, and SimpleFS backends |
| DNS/ACME | Cloudflare, Route53, DigitalOcean, Vultr, Azure, Google Cloud DNS |

## Tags

`latest`, `2.11.4` — version-tagged for production stability.

---

### 🔗 Related Images & Tools

| Image / Tool | Description |
|--------------|-------------|
| [morsalin1342/frankenphp](https://hub.docker.com/r/morsalin1342/frankenphp) | Caddy + PHP app server |
| [morsalin1342/php](https://hub.docker.com/r/morsalin1342/php) | PHP-FPM & CLI |
| [easydigital/caddy](https://hub.docker.com/r/easydigital/caddy) | Enterprise org mirror |
| [caddy-souin-cache-manager](https://github.com/morsalin1342/caddy-souin-cache-manager) | WordPress plugin to manage Souin cache from WP Admin |
