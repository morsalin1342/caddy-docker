FROM caddy:2.11.2-builder AS builder

RUN apk add --no-cache build-base brotli-dev

RUN CGO_ENABLED=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags='-w -s' -tags=nobadger,nomysql,nopgx" \
    xcaddy build \
    --with github.com/dunglas/caddy-cbrotli \
    --with github.com/dunglas/mercure/caddy \
    --with github.com/dunglas/vulcain/caddy \
    --with github.com/caddy-dns/vultr \
    --with github.com/caddy-dns/azure \
    --with github.com/caddy-dns/googleclouddns \
    --with github.com/caddy-dns/digitalocean \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/route53 \
    --with github.com/caddyserver/cache-handler \
    --with github.com/darkweak/storages/go-redis/caddy@v0.0.19 \
    --with github.com/darkweak/storages/otter/caddy@v0.0.19 \
    --with github.com/darkweak/storages/simplefs/caddy@v0.0.19

FROM caddy:2.11.2

RUN apk add --no-cache brotli-libs
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
