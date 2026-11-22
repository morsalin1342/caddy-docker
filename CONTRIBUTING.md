# Contributing

Thanks for your interest in improving this Caddy Docker image!

## How to Contribute

### Request a New Plugin
1. Open an issue with the title `Plugin request: <name>`
2. Provide the Go module path (e.g., `github.com/org/repo`)
3. Explain the use case — why should it be included for everyone?

### Report a Bug
1. Open an issue with details: image tag, error message, steps to reproduce
2. If the bug is about a plugin not working, include your `Caddyfile` config (redact secrets)

### Submit a Pull Request
1. Fork the repo and create a feature branch
2. Add your plugin to the `xcaddy build` command in the `Dockerfile`
3. Test locally:
   ```bash
   docker build -t test-caddy .
   docker run --rm test-caddy version
   ```
4. Open a PR against `master` with a clear description

## Project Structure

```
.
├── Dockerfile                 # Multi-stage Caddy build
├── scripts/check-upstream.sh  # Compares the pinned versions with upstream
├── .github/workflows/         # CI/CD pipeline
├── README.md                  # GitHub README
├── README.dockerhub.md        # Personal Docker Hub description
└── README.dockerhub-org.md    # Org Docker Hub description
```

## Version Upgrades

To upgrade the Caddy version:
1. Update the version and the digest in both `FROM` lines in the `Dockerfile`
   (`docker buildx imagetools inspect caddy:<version>` prints the digest)
2. Test the build locally
3. The CI pipeline will auto-detect the new version for tagging

## Keeping the pins current

`scripts/check-upstream.sh` compares every version pinned in the `Dockerfile` with
the latest upstream release: Caddy (GitHub releases), each `--with` plugin and the
`golang.org/x/net` replacement (the Go module proxy). It exits non-zero and lists
what is behind. The `Upstream check` workflow runs it every Monday and can be run
by hand; it changes nothing, so moving a pin is still a commit of its own. Run it
locally with `bash scripts/check-upstream.sh` (set `GITHUB_TOKEN` to avoid the
GitHub API's anonymous rate limit). Dependabot moves the workflow actions and the
base image digests.
