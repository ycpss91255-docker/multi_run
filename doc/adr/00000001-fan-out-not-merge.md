# ADR-00000001: Fan out to N compose projects; never merge compose files

- **Date:** 2026-09-05
- **Status:** Accepted
- **Relates to:** #26 (the rebuild), #14, #15, #18;
  `ycpss91255-docker/base` #600 (the layering that assigns this work here),
  ADR-00000022 in `base` (the overlay contract this consumes)

## Context

`multi_run` starts many Docker environments at once. Until now it did that by
reading each repo's `compose.yaml`, extracting the service named `devel`,
renaming it to `{IMAGE_NAME}_{md5[0:4]}`, and appending the result to a single
generated `.multi_compose.yaml`.

Three forces made that untenable.

**Merging silently loses repos.** Every one of the 14 base downstream checkouts
inspected has exactly one service named `devel`. Measured on Compose v5.5.0: a
file that `include:`s two compose files which both define `devel` exits 0, writes
nothing to stderr, and emits **one** service — the other repo is gone. Top-level
named volumes fuse the same way, so two repos each declaring `volumes: shared:`
end up sharing one volume, the second inheriting the first's `driver_opts`.
Merging N repos means silently collapsing them, with no diagnostic.

**`devel` was never a contract.** base's ADR-00000022 s4 states that stage
identity is not tied to that literal string and that consumers must read
`build.target` / `profiles`. Repos carry 5-7 services, the set is derived from
each repo's own Dockerfile stages, and it changes whenever that Dockerfile
changes. `resolve_compose.py` returned 0 and emitted nothing when `devel` was
absent, so such a repo disappeared from the merged output without an error.

**The work belongs here, not in base.** base issue #600 removed `--instance` /
`INSTANCE_SUFFIX` from base in v0.42.0 on layering grounds, stating
`base : docker :: <compose layer> : docker compose` — base operates a single
instance, and the compose layer owns *all* multi-instance orchestration
"including the per-instance naming, ports, and isolation". Reimplementing what
base emits is therefore not just fragile, it is the wrong layer.

## Decision

**One independent compose project per instance. No compose file is parsed,
rewritten, or merged.**

Each instance is started with:

    docker compose -p <project> \
      --project-directory <repo> \
      --env-file <repo>/.env.generated \
      up -d

with per-instance values supplied as environment variables through the overlay
channel base guarantees in ADR-00000022 (`WS_PATH`, `NETWORK_MODE`, `PORT_<n>`,
`PRIVILEGED`, `IPC_MODE`, `PID_MODE`), plus `.env.local` for container
environment.

Three details of that invocation are load-bearing, each verified by measurement:

- **`--project-directory`, not `-f`.** Passing only `-f <repo>/compose.yaml`
  silently skips that repo's `compose.override.yaml`, so the user would get
  different behaviour from `multi_run` than from running compose themselves.
  `--project-directory` with no `-f` reproduces `cd`-into-the-repo semantics
  exactly, including file discovery.
- **`--env-file` is still required.** `--project-directory` alone does not load
  `.env.generated`; compose auto-discovers `.env` only.
- **`-p`, not an exported `PROJECT_NAME`.** On this org's real
  `realsense_ros2` checkout the generated `compose.yaml` still reads
  `name: ${DOCKER_HUB_USER}-${IMAGE_NAME}${INSTANCE_SUFFIX:-}` — a v0.41-era
  emission that never mentions `PROJECT_NAME`. Setting `PROJECT_NAME` there does
  nothing; `-p inst_a` works. `-p` is also compose's highest-precedence project
  name input, beating the file's `name:` and `COMPOSE_PROJECT_NAME`.

Verb semantics are inherited rather than reimplemented: a `multi_run` verb is the
corresponding `docker compose` verb applied to N projects, with compose's flags
passed through. `docker compose up` already builds a missing image — its
`--no-build` flag is documented as "Don't build an image, even if it's policy" —
so auto-build is inherited, not rebuilt.

## Alternatives

- **`include:` the downstream compose files.** Rejected on measurement: silent
  first-wins merge on service-name collision, no warning, exit 0 — and the
  published spec claims a warning is emitted, so the documented safety net does
  not exist. `include:` also has no namespacing mechanism whatsoever, so with
  every repo naming its service `devel` the collapse is guaranteed rather than
  incidental.
- **Multiple `-f` across directories.** Rejected: relative paths in the second
  file resolve against the *first* file's directory. Measured: an override in
  `over/` declaring `./localdata` resolved to `foreign/localdata`, which does not
  exist, with exit 0 and no diagnostic.
- **Keep the programmatic YAML surgery, but fix it.** Rejected: it requires
  tracking base's emitter shape forever. The setup-wrapper path alone moved three
  times (`template/script/docker/setup.sh` -> `script/docker/setup.sh` ->
  `script/setup.sh`), which is what #17 and #18 were about. Every such move is a
  symptom of reimplementing something base already provides.
- **Drive each repo through its own `just docker run`.** Rejected on
  measurement: `_compose_project` (base `lib/compose.sh:323`) hardcodes
  `-p "${PROJECT_NAME}"`, so every call for a given repo uses one project name;
  and `run -d` runs `_compose_project down` before `up -d`, so a second
  invocation destroys the first instance. base is single-instance on purpose.

## Consequences

- `script/resolve_compose.py`, the `devel` hard-coding, the md5 path-hash naming
  and the setup-wrapper probe are all deleted. So is the `template/` test
  subtree, which existed only to exercise the merge path (#18 is absorbed).
- `multi_run` becomes indifferent to which base generation a downstream repo is
  on, because `-p` works across all of them. That also makes non-base repos with
  a conforming `compose.yaml` usable as secondary targets.
- No single merged artifact exists any more. Anyone who wants to inspect the
  resolved configuration reads it per project via `docker compose config`.
- Operations are N invocations rather than one, so partial failure is now a real
  state the tool must report rather than something compose handles. Compose
  offers no all-or-nothing `up`, and its `--wait` has several open correctness
  bugs, so exit codes alone cannot be trusted; per-project status is queried
  instead.
- Concurrency needs care: `docker network create` is not atomic, and concurrent
  `up` runs have been observed upstream to produce two networks with the same
  name, of which `down` removes only one. This is the documented mechanism behind
  "network has active endpoints" errors.
