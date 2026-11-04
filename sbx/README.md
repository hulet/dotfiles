# sbx kits

Composable [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kits
(schema v2 mixins) for Claude Code sandboxes. Every sandbox gets `base`; add
the others it needs.

## Kit catalog

- **`base`** — Node.js 24, sandbox-private `node_modules` / `.venv` /
  `.svelte-kit` with lockfile installs, the superpowers plugin, the Claude Code
  settings file, and the general package and registry hosts. In every sandbox.
- **`scanners`** — gitleaks, hadolint, trivy, semgrep. Needed when any of them
  is `command not found`, e.g. in a project's `npm run scan`.
- **`cloud-clis`** — gcloud, gsutil, bq and AWS CLI v2. Needed when any of
  those commands is `command not found`.
- **`postgres-client`** — `pg_dump`, `pg_restore` and `psql` for one
  PostgreSQL major version (`--kit-arg postgres-client.version=<major>`,
  default 18). Needed when any of them is `command not found`.

`base` carries a copy of this catalog in its agent instructions (a snapshot
from when the sandbox was created) and points agents here for the current
list.

## Using the kits

Each kit is referenced by URL; the repo is public, so no credentials are
needed:

```
git+https://github.com/hulet/dotfiles.git#ref=main&dir=sbx/kits/<name>
```

One-time setup on each machine: sbx accepts kits only from Docker Hub until
other sources are allowed, so allow this repo (the command replaces the whole
list):

```sh
sbx settings set kit.allowedSources '["docker.io/","github.com/hulet/dotfiles"]'
```

From a project directory, on the host:

```sh
K='git+https://github.com/hulet/dotfiles.git#ref=main&dir=sbx/kits'
sbx run claude . --kit "$K/base" --kit "$K/scanners" \
  -- --settings /home/agent/sbx-claude-settings.json
```

Or use `sbxc` from dotfiles, which always adds `base`:

```sh
sbxc scanners postgres-client   # create, or re-attach if it exists
sbxc                            # re-attach
```

- Pass `-- --settings /home/agent/sbx-claude-settings.json` on every
  `sbx run`, re-attaches included; it is a Claude Code argument sbx does not
  remember. `sbxc` does this for you.
- Kits are fixed when a sandbox is created. To change them: commit and push
  work in progress, `sbx rm <sandbox>`, and create it again.
- On a new sandbox, exit and re-attach once: plugins installed during startup
  load only in the next Claude Code session.
- The first start of a sandbox runs `npm ci` / `uv sync --frozen` for
  projects with those lockfiles; the first session waits for it (up to 10
  minutes) if it is still running.
- `ref=main` means a new sandbox gets whatever is on `main`. Push kit changes
  before creating sandboxes that need them.
- Regional AWS endpoints are not covered by `cloud-clis`' `*.amazonaws.com`
  (sbx enforces single-label wildcards only). Sign in with
  `aws configure sso --use-device-code` / `aws sso login --use-device-code`,
  and for your region R allow `oidc.R.amazonaws.com`,
  `portal.sso.R.amazonaws.com`, `sts.R.amazonaws.com` and each service's
  endpoint (e.g. `s3.R.amazonaws.com`) with `sbx policy allow network <host>`.

## Adding a kit

1. Create `sbx/kits/<name>/spec.yaml` (`schemaVersion: '2'`, `kind: mixin`,
   `name: <name>`, `displayName`, `description`, `agentInstructions`). Keep
   the tool's network hosts in its own kit unless every project may reach
   them (then they belong in `base`).
2. Add a catalog line in this file **and** in `base`'s `agentInstructions`
   (`### Kit catalog`), in the `- **\`name\`** — ...` form.
3. Run `sbx/tests/run.sh`.
4. Try it in a throwaway sandbox (below), then push to `main`.

`sbxc` needs no change: it maps any kit name to its directory here.

## Trying a change before it reaches main

The URLs read `main`, so test a changed kit by local path in a throwaway
sandbox, from a scratch directory:

```sh
mkdir -p /tmp/kit-try && cd /tmp/kit-try
sbx run claude . --kit ~/git/dotfiles/sbx/kits/base --kit ~/git/dotfiles/sbx/kits/<name> \
  -- --settings /home/agent/sbx-claude-settings.json
```

Remove it afterwards with `sbx rm` (its name is printed by `sbx ls`).

## Updating a pinned tool

Every binary downloaded from a URL is pinned to a version and to a SHA256 per
architecture embedded in its install step, checked with `sha256sum -c` before
anything is unpacked. Checksums are never fetched at install time from the
same release as the binary: whoever controls a release controls its checksum
file, and in 2026 Trivy's release tags were re-pointed to a malicious build.
apt (signed indexes) and PyPI via uv (immutable release files) need only a
version pin.

To update one:

1. **Pick the version.** Prefer a release at least 7 days old: supply-chain
   compromises are usually caught within days. Read the release notes for
   breaking changes and security advisories.
2. **Get the expected hashes** for that exact version, for both
   `linux/amd64` and `linux/arm64`, from the vendor's published source:
   Trivy's `trivy_<version>_checksums.txt`; gitleaks'
   `gitleaks_<version>_checksums.txt`; hadolint's `checksums.sha256`; Node's
   `SHASUMS256.txt`. For gcloud, use the SHA256 on Google's versioned-archives
   page; Google lists only the current release, so for an older version hash
   the download yourself. For the AWS CLI, hash the zip after its signature
   check (step 3).
3. **Cross-check through a second channel**; if anything disagrees, stop and
   report it — do not update:
   - Trivy: `cosign verify-blob <asset> --bundle <asset>.sigstore.json --certificate-identity-regexp 'https://github.com/aquasecurity/trivy/.github/workflows/.+' --certificate-oidc-issuer https://token.actions.githubusercontent.com`
   - Node: `gpg --verify SHASUMS256.txt.asc` with the keys from
     https://github.com/nodejs/release-keys imported.
   - AWS CLI: `gpg --verify <zip>.sig <zip>` against the AWS CLI Team key
     (fingerprint `FB5D B77F D5C1 18B8 0511 ADA8 A631 0ACC 4672 475C`, from
     AWS's install documentation).
   - hadolint: compare with `docker run --rm --entrypoint sha256sum hadolint/hadolint:v<version>-debian /bin/hadolint`
     (that image's architecture).
   - gitleaks: compare the release's GitHub asset digests with its
     checksums file.
   - gcloud: no second channel; compare the page's SHA256 with your
     download's.
4. **Edit the kit:** in the one install step, change `version=` and both
   `sum=` values together. Nothing else.
5. **Test:** run `sbx/tests/run.sh`; then create a throwaway sandbox with
   the changed kit by local path (above) and check that the install step
   passed, `<tool> --version` reports the new version, and the tool's normal
   command works.
6. **Commit** one tool per commit; the message records the old and new
   version, where the hashes came from and how they were cross-checked.

## Conventions

- Comments explain only what the code cannot: why a step or host exists, and
  how to remove each workaround. Workarounds are labelled `WORKAROUND` with
  an issue link and a removal checklist.
- Allowlist hosts are grouped under a note naming what uses them.
- One install step per tool, each with a precise `description`.
- In-sandbox names use the `sbx-` prefix (`~/.local/lib/sbx-*`,
  `/opt/sbx-<kit>/`).
- Run `sbx/tests/run.sh` before every push that touches `sbx/kits/` or
  `sbx/sbxc.zsh`.
