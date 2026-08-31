FROM caddy:2.11.4-builder AS builder

RUN apk add --no-cache build-base brotli-dev

RUN CGO_ENABLED=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags='-w -s' -tags=nobadger,nomysql,nopgx" \
    xcaddy build \
    --with github.com/corazawaf/coraza-caddy/v2 \
    --with pkg.jsn.cam/caddy-defender \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/dunglas/caddy-cbrotli \
    --with github.com/caddy-dns/vultr \
    --with github.com/caddy-dns/azure \
    --with github.com/caddy-dns/googleclouddns \
    --with github.com/caddy-dns/digitalocean \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/route53 \
    --with github.com/darkweak/souin/plugins/caddy \
    --with github.com/darkweak/storages/go-redis/caddy \
    --with github.com/darkweak/storages/otter/caddy \
    --with github.com/darkweak/storages/simplefs/caddy

FROM caddy:2.11.4

LABEL org.opencontainers.image.title="caddy" \
      org.opencontainers.image.description="Caddy with Coraza WAF, rate limiting, IP blocking, Brotli, Souin cache and 6 DNS providers" \
      org.opencontainers.image.source="https://github.com/morsalin1342/caddy-docker" \
      org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache brotli-libs
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
