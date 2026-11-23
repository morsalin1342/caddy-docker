FROM caddy:2.11.9-builder@sha256:cda07fe9d82728c7ac44d844306d435e98131423dc7b114f05a8a8ecfff94707 AS builder

RUN apk add --no-cache build-base brotli-dev

# golang.org/x/net is raised to v0.63.0, the latest release, the version FrankenPHP
# 1.14.0 requires. v0.62.0 fixed CVE-2026-78661 (x/net/html denial of service).
# Without the --replace line at the end of the list below, Caddy 2.11.9 and these
# plugins would resolve it to v0.60.0.
RUN CGO_ENABLED=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags='-w -s' -tags=nobadger,nomysql,nopgx" \
    xcaddy build \
    --with github.com/corazawaf/coraza-caddy/v2@v2.6.2 \
    --with pkg.jsn.cam/caddy-defender@v0.10.2 \
    --with github.com/mholt/caddy-ratelimit@v0.1.0 \
    --with github.com/dunglas/caddy-cbrotli@v1.0.1 \
    --with github.com/caddy-dns/vultr@v0.0.0-20250723121531-55bf3e9768be \
    --with github.com/caddy-dns/azure@v0.6.0 \
    --with github.com/caddy-dns/googleclouddns@v1.1.0 \
    --with github.com/caddy-dns/digitalocean@v0.0.0-20250606074528-04bde2867106 \
    --with github.com/caddy-dns/cloudflare@v0.2.4 \
    --with github.com/caddy-dns/route53@v1.6.3 \
    --with github.com/darkweak/souin/plugins/caddy@v1.7.10 \
    --with github.com/darkweak/storages/go-redis/caddy@v0.0.23 \
    --with github.com/darkweak/storages/otter/caddy@v0.0.23 \
    --with github.com/darkweak/storages/simplefs/caddy@v0.0.23 \
    --replace golang.org/x/net=golang.org/x/net@v0.63.0

FROM caddy:2.11.9@sha256:4851e54a46b206517c574821bb5cc67f170d2156041e9fbc4c9193b45e84a75b

# licenses is empty on purpose. The repository's own files are MIT, but the image
# combines software under many licences (the README's Licence section names the main
# ones; the SBOM each build keeps lists every package), and no single SPDX expression
# has been derived for all of it. The empty value also overrides the base image's own
# label, Apache-2.0, which is Caddy's licence and not the whole image's.
LABEL org.opencontainers.image.title="caddy" \
      org.opencontainers.image.description="Caddy with Coraza WAF, rate limiting, IP blocking, Brotli, Souin cache and 6 DNS providers" \
      org.opencontainers.image.source="https://github.com/morsalin1342/caddy-docker" \
      org.opencontainers.image.licenses=""

# Alpine security updates for everything the base image ships (brotli-libs
# CVE-2026-111497, zlib CVE-2026-85091, musl, curl), then the runtime packages.
RUN apk upgrade --no-cache \
    && apk add --no-cache acl brotli-libs gosu
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
