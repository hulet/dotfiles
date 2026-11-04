# sbx kits in dotfiles: design

Date: 2026-11-03
Status: approved for planning

## Goal

Replace the three separate Docker Sandboxes (sbx) kits —
`spellcheck-app/sbx/shared`, `ward-manager/sbx/ward-manager-dev` and
`dotfiles/kits/sbx-defaults` — with four composable v2 mixin kits in
`dotfiles/kits/`, referenced over `git+https` when every sandbox is recreated.
The base kit is meant for many apps; ward-manager and spellcheck-app are the
first two consumers, not the design target.

## Decisions

| Topic | Decision |
|---|---|
| Kit layout | Four separate mixins, combined with repeated `--kit` |
| Format | Kit schema v2 (`schemaVersion: '2'`, `kind: mixin`). v3, `sbxenv.yaml` and `sbx kit add` are out of scope |
| Reference | `git+https://github.com/hulet/dotfiles.git#ref=main&dir=kits/<name>` (repo is public) |
| Ref | `main` everywhere; push dotfiles before creating sandboxes that need a change |
| Launch | Full commands in each project README, plus `sbxc` in `dotfiles/zshrc` |
| Sandbox names | None passed; sbx's default `<agent>-<workdir>` |
| Network split | `base` allows every general host any project may reach; tool kits add only vendor-specific hosts |
| Agent notes | Each kit carries its own `agentInstructions` (tool kits are therefore creation-only, not `sbx kit add`-compatible; notes can move into `base` later if needed) |
| Cloudflare plugin | Dropped, with its `extraKnownMarketplaces` entry |
| Dependency directories | Sandbox-private, so host and sandbox installs never clash |

## Layout

```
dotfiles/kits/
  README.md
  base/
    spec.yaml
    files/home/sbx-claude-settings.json
    files/home/.local/lib/sbx-workspace-mounts.sh
    files/home/.local/lib/sbx-deps-install.sh
  scanners/spec.yaml
  cloud-clis/spec.yaml
  postgres-client/spec.yaml
```

Each kit's `name` equals its directory name. In-sandbox names use a neutral
`sbx-` prefix: scripts in `~/.local/lib/sbx-*`, log prefixes `sbx-<script>:`,
tool trees under `/opt/sbx-<kit>/`.

## Conventions

- Comments explain only what the code cannot: why a step or host exists, and
  how to remove each workaround. No restated code, no history.
- Allowlist hosts are grouped under a short note naming their consumer.
- Workarounds are labelled `WORKAROUND`, link their issue, and state a removal
  condition and checklist. No "last checked" dates.
- One install step per tool, each with a precise `description`.
- Every binary downloaded from a release URL is pinned to a version **and** to
  an expected SHA256 per architecture, embedded in the spec. The install step
  checks the download with `sha256sum -c` and stops on a mismatch before
  unpacking or running anything; only then does it assert the reported
  version. Checksums are never fetched at install time from the same release
  as the binary — whoever controls a release controls its checksum file (the
  2026 Trivy compromise re-pointed release tags to a malicious build).
  Sources with their own signature checking need no embedded hash: apt
  (signed archives) and PyPI via `uv` (immutable release files).
- Each pinned install step carries a one-line comment pointing to
  `kits/README.md` → "Updating a pinned tool".
- `kits/README.md` holds the overview: the authoritative kit catalog (see
  "Kit catalog" under base), the URL format, example combinations, how to add
  a kit (including "add a catalog line to `base`"), how to update a pinned
  tool (below), these conventions, and a
  first-run note: on a new sandbox, exit and re-attach once so the plugins
  installed during startup load (a fresh plugin install only takes effect in
  the next Claude Code session).

### Updating a pinned tool

`kits/README.md` carries this procedure, written for a future agent or human:

1. **Pick the version.** Prefer a release at least 7 days old: supply-chain
   compromises are usually caught and pulled within days. Read the release
   notes for breaking changes and any security advisory.
2. **Get the expected hashes from the vendor's published checksums** for that
   exact version, for both `linux/amd64` and `linux/arm64` (e.g. Trivy's
   `trivy_<version>_checksums.txt`, gitleaks' `gitleaks_<version>_checksums.txt`,
   hadolint's per-asset `.sha256`, Google's published SHA256 for the gcloud
   tarball).
3. **Cross-check through a second channel** where one exists — verify the
   release's signature (e.g. `cosign verify-blob` for Trivy, the AWS CLI's PGP
   signature against AWS's published key), or compare with the hash in the
   Homebrew formula or another independent source. If the two disagree, stop
   and report it; do not update.
4. **Edit the kit:** change the version and both hashes together in the same
   install step, and the version assertion. Nothing else.
5. **Test** in a new sandbox (a new name, since kits are fixed at creation):
   the install step passes, `<tool> --version` reports the new version, and
   the tool's normal command works (e.g. `npm run scan` in a project that
   uses it).
6. **Commit** one tool per commit, with the old and new version, where the
   hashes came from and how they were cross-checked in the message.

For AWS CLI v2, which publishes a PGP signature but no checksum file: verify
the zip's signature against AWS's published public key once, then embed the
zip's SHA256 like the others.

## Kit: base

Used by every sandbox.

**`setup.install`:** set the system timezone to America/Los_Angeles (the image
defaults to UTC; sbx injects a fixed-offset `TZ` with no DST rule).

**`setup.startup`**, in order:

1. `sbx-workspace-mounts.sh` (root): bind-mount sandbox-local directories over
   the workspace's dependency and scratch directories, so neither side's
   platform-specific build overwrites the other's.
2. `sbx-deps-install.sh` (agent user): install dependencies into those private
   directories from a lockfile.
3. `claude plugin marketplace add anthropics/claude-plugins-official`, then
   `claude plugin install superpowers@claude-plugins-official`.

**`sbx-workspace-mounts.sh`** generalizes today's scratch-mounts script. It
holds a detector table — "project has X" → "make Y sandbox-private":

| Detected | Private directory |
|---|---|
| `package.json` | `node_modules` |
| `pyproject.toml` or `requirements*.txt` | `.venv` |
| `svelte.config.{js,ts,mjs}` | `.svelte-kit` |

The former `vite` → `node_modules/.vite-temp` detector is dropped (covered by
the private `node_modules`). Adding an ecosystem (Rust `target/`, Ruby
`vendor/bundle`) is one table row. Arguments after the workspace, or
`SCRATCH_MOUNT_DIRS` (renamed from `SBX_SCRATCH_DIRS`; sbx reserves `SBX_`),
override detection. It is idempotent, never creates a missing parent, and
covers the workspace root only, not git worktrees under it. Workspace comes
from `$1`, falling back to `$WORKSPACE_DIR` (sudo strips the variable).

**`sbx-deps-install.sh`** installs only when the command is unambiguous from a
lockfile, and only when that lockfile's hash differs from a stamp kept inside
the private directory:

| Lockfile | Command |
|---|---|
| `package-lock.json` | `npm ci` |
| `uv.lock` | `uv sync --frozen` |

Anything else (pip-installed projects, yarn, pnpm) gets an empty private
directory that the project's CLAUDE.md explains how to fill. Failures warn and
do not block the sandbox. Re-running is near-instant when nothing changed.
Startup commands run alongside the agent, so on a new sandbox the first
install may still be running when the first session starts; the SessionStart
hook runs it in the foreground, so the session waits for it.

`sbx-native-deps.mjs` (adding Linux binaries into the host's macOS
`node_modules`) is deleted, as is the "never `npm install` in the sandbox"
rule: lockfile changes made in the sandbox reach the host as ordinary diffs.

**`files/home/sbx-claude-settings.json`** (loaded with `--settings`; sbx
manages `~/.claude/settings.json`):

- `env`: `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1`,
  `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`, `CLAUDE_CODE_NO_FLICKER=0`,
  `TMPDIR=/tmp`, `TZ=America/Los_Angeles`.
- `permissions.ask`: the 10 `git push` / `git remote` rules plus the 43
  claude.ai connector write rules from today's dotfiles settings.
- `hooks.SessionStart`: the #420 workaround, running both scripts and the
  superpowers install.
- `enabledPlugins`: `superpowers@claude-plugins-official` only.
- `editorMode: vim`, `preferredNotifChannel: notifications_disabled`,
  `promptSuggestionEnabled: false`, `skipAutoPermissionPrompt: true`.

**`permissions.network.allow`:**

- GitHub: `github.com`, `release-assets.githubusercontent.com`,
  `raw.githubusercontent.com`
- npm and PyPI: `registry.npmjs.org`, `pypi.org`, `files.pythonhosted.org`
- Container registries: `registry-1.docker.io`, `auth.docker.io`,
  `index.docker.io`, `production.cloudflare.docker.com`, `ghcr.io`,
  `pkg-containers.githubusercontent.com`, `mirror.gcr.io`
- Package mirrors: `dl-cdn.alpinelinux.org`, `deb.debian.org`,
  `security.debian.org`, `ports.ubuntu.com`, `archive.ubuntu.com`,
  `security.ubuntu.com`

**`agentInstructions`:** dependency directories are sandbox-private (install
freely); what the two scripts do and the commands to re-apply them; why
`--settings` matters; and sandbox differences from a host checkout —
`python3 -m venv` fails (use `uv venv`), an HTTP 403 means the network policy
(ask the user to check `sbx policy log`), dev servers must bind `0.0.0.0` and
be published with `sbx ports`, `git push` needs the host's
`sbx secret set github`, an older Node than `engines` is harmless.

**Kit catalog (in `agentInstructions`):** one line per kit — name, what it
provides, and the signals that it is needed (e.g. `command not found` for
`semgrep`/`gitleaks`/`trivy`/`hadolint` → `scanners`; `pg_dump`/`pg_restore` →
`postgres-client`; `gcloud`/`gsutil`/`bq`/`aws` → `cloud-clis`). It is framed
as a snapshot: "These were the kits available when this sandbox was created;
for the current list, fetch
`https://raw.githubusercontent.com/hulet/dotfiles/main/kits/README.md`" (the
host is in base's allowlist). Kits loaded in this sandbox are the ones listed
under the `## Kits` pointer. When a needed kit is missing, the agent:

1. Does not install the tool ad hoc or work around its absence — kits are
   pinned and allowlisted, ad hoc installs are not, and they vanish on
   recreate.
2. Stops and tells the user which kit is needed and why, with the steps, since
   it cannot run `sbx` on the host: commit and push work in progress; on the
   host, `sbx rm <sandbox>`, then `sbxc <kits…>` (or the project README's
   command plus the extra `--kit`); recreating reinstalls private dependency
   directories and loses cloud sign-ins.
3. If no kit covers the need, says so and suggests a new kit in
   `dotfiles/kits` or a one-off `sbx policy allow` plus manual install.

**WORKAROUND (docker/sbx-releases#420):** startup commands stop running after
an sbx daemon restart in affected versions, so the SessionStart hook re-runs
them. Removal: confirm the fix is in a release (issue loses
`awaiting-release`), then `sbx daemon restart`, start a sandbox, and check
`/var/log/sbx-kit-startup.log` for a new dispatcher run. Then delete the
settings `hooks` block, drop the session-start wording and #420 paragraph from
`agentInstructions` (keep the manual re-apply commands), drop the SessionStart
mention from the mounts script header, and delete the WORKAROUND comment.

## Kit: scanners

- **Installs:** gitleaks 8.30.1, hadolint 2.15.1, trivy 0.74.0 from GitHub
  release assets, one install step each, each checked against embedded
  per-architecture SHA256s taken from the vendor's published checksums and
  cross-checked once at implementation time; semgrep 1.178.0 via
  `uv tool install` under `/opt/sbx-scanners/`, behind a `/usr/local/bin/semgrep`
  wrapper that passes `--jobs 1`.
- **Trivy comment:** the trivy step's comment states why its hashes must never
  be dropped or fetched at install time: in 2026 Trivy's release tags were
  re-pointed to a credential-stealing build served through every official
  channel (see ward-manager's
  `docs/superpowers/specs/2026-09-19-local-quality-tooling-design.md`).
- **Out of scope:** Trivy's vulnerability database, downloaded at run time
  from `mirror.gcr.io` / `ghcr.io`, is not covered by the binary pin.
- **Network:** `semgrep.dev`, `metrics.semgrep.dev`.
- **`agentInstructions`:** scanners are on PATH; the host installs them with
  `brew bundle` (ignore a Brewfile here); `semgrep` is a `--jobs 1` wrapper
  because semgrep-core opens one io_uring per job and the sandbox's 8 MiB
  locked-memory cap makes it fail with `io_uring_queue_init` under load.
- **Licenses:** MIT, GPL-3.0-only, Apache-2.0, LGPL-2.1-only.

## Kit: cloud-clis

- **Installs:** gcloud from Google's versioned, checksummed tarball
  (`dl.google.com`) into `/opt/sbx-cloud-clis/`, with `gcloud`, `gsutil`, `bq`
  symlinked into `/usr/local/bin`; AWS CLI v2 from its versioned zip
  (`awscli.amazonaws.com`). Both pinned to a release at least 7 days old at
  implementation time, checked against embedded per-architecture SHA256s
  (gcloud's from Google's published hashes; AWS's computed after verifying the
  zip's PGP signature once), and version-asserted. Replaces
  `sbx-defaults`' unpinned `curl | bash`.
- **Network:** download hosts; `accounts.google.com`, `oauth2.googleapis.com`,
  `*.googleapis.com`; `sts.amazonaws.com`, `*.amazonaws.com`.
- **Known limit:** sbx enforces single-label wildcards only, so regional AWS
  endpoints (`s3.us-west-2.amazonaws.com`) need explicit entries or
  `sbx policy allow`. Stated in the spec comment and `kits/README.md`.
- **`agentInstructions`:** CLIs start signed out; sign in with
  `gcloud auth login --no-launch-browser` or `aws configure sso`; credentials
  live only in this sandbox and are lost on recreate.
- No persistent credential volumes.

## Kit: postgres-client

- **Argument:** `version`, default `18`, pattern `^[0-9]+$`.
- **Installs:** `postgresql-client-${{ kit.args.version }}` from the Ubuntu
  archive (hosts in `base`); asserts `pg_dump` and `pg_restore` report that
  major version; a version Ubuntu does not package fails with a clear message.
  No PGDG repository until needed.
- **`agentInstructions`:** `pg_dump` / `pg_restore` on PATH, matching the
  server's major version.
- **Licenses:** PostgreSQL.

## sbxc

`sbxc [kit ...] [-- claude-args]` in `dotfiles/zshrc`:

- Always includes `base`; each further name maps to the dotfiles kit URL. One
  variable at the top of the function holds the URL prefix (not named `SBX_*`).
- Names must match `^[a-z0-9-]+$`; paths and URLs are rejected, so kits only
  come from dotfiles. A name with no directory fails when sbx builds the
  sandbox. New kits need no `sbxc` change.
- Runs `sbx run claude . --no-share-skills --kit … -- --dangerously-skip-permissions --settings /home/agent/sbx-claude-settings.json <claude-args>`
  and lets sbx re-attach to this directory's sandbox or create it. If current
  sbx errors on the creation-only flags for an existing sandbox, keep the
  existing `sbx ls` check and re-attach without them.

## Project READMEs

ward-manager and spellcheck-app each get a "Develop in a sandbox" section:
the kits used and why (ward-manager: `base`, `scanners`, `postgres-client`;
spellcheck-app: `base`, `scanners`), the full create command, the re-attach
command (`sbx run claude -- --settings …` from the repo), a one-line
`sbxc` equivalent, and the first-run note: on a new sandbox, exit and
re-attach once to load plugins. Existing host-side tips stay. READMEs do not pass
`--dangerously-skip-permissions`. ward-manager's #420 paragraph and manual
re-apply commands point at the new script names.

## Migration

1. dotfiles, on a branch merged and pushed to `main` before use: add the four
   kits and `kits/README.md`; rewrite `sbxc`; delete `kits/sbx-defaults`. One
   logical change per commit.
2. ward-manager and spellcheck-app, each on a fresh branch from `main`: delete
   `sbx/`; rewrite the README sandbox section; move remaining project-specific
   sandbox notes into CLAUDE.md. Delete the superseded, unpushed `sbx-kit-dev`
   branches.
3. The user recreates sandboxes: commit and push work from existing sandboxes,
   `sbx rm` them, create new ones with the README commands or `sbxc`.

## Testing

On this Linux machine (no sbx installed):

- Every spec parses and has the required fields.
- Every install step that downloads a binary from a URL has an embedded
  SHA256 for each architecture and runs `sha256sum -c` before unpacking.
- A stubbed run of one pinned install step with a tampered download fails
  before the binary is unpacked or executed.
- The kit catalogs in `base`'s `agentInstructions` and in `kits/README.md`
  each name exactly the directories under `kits/` — no missing or extra
  entries.
- `zsh -n` on `sbxc`; dry run with a stub `sbx` recording its arguments.
- `shellcheck` on both scripts, if available.
- Stubbed runs of `sbx-workspace-mounts.sh` for a Node, Python, SvelteKit and
  empty repo.
- Stubbed runs of `sbx-deps-install.sh`: installs on lockfile change, skips
  otherwise.

On the Mac (checklist in the plan): `sbx kit validate` on each kit; create one
sandbox per combination; inside, check tool versions, `TZ` and `TMPDIR`,
`findmnt node_modules` reports a private mount and the host `node_modules` is
untouched, `npm test` / `npm run verify` (ward-manager), `pytest`
(spellcheck-app), `sbx policy log` shows nothing unexpected, plugins are
installed, and where mixin agent instructions land (`kits-memory` vs
`kits-agent-context`); exercise `sbxc` re-attach with kit names given.

**Done when** all three repos reference only `dotfiles/kits` and every
recreated sandbox passes the checklist.
