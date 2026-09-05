# ADR-00000003: TOML for the configuration, parsed with stdlib `tomllib`

- **Date:** 2026-09-05
- **Status:** Accepted
- **Relates to:** #26 (the rebuild); ADR-00000002 (the nesting the format has to
  express)

## Context

The configuration is hand-edited, describes nested groups where the same group
may be included more than once, and carries per-instance override values. It is
read, never round-tripped. Robustness was stated as the governing requirement.

The obvious candidate was YAML, both because the previous implementation already
depended on `pyyaml` and because the surrounding ecosystem — compose itself — is
YAML. Two investigations changed that.

**INI, base's format, cannot express the shape.** base parses its `.setup.conf`
in pure bash (`_ini_tokenize` / `_parse_ini_section`), and that is why it is INI:
base's host-side wrappers use no Python at all, and its declared host
prerequisites are Docker, Docker Compose and `just`. The format follows from
where the code runs. base gets one level of parameterisation out of INI via
`[stage:<name>]` sections plus dotted keys, and that is its ceiling — groups
containing groups, with a group reusable twice, is past it. Ansible made the same
migration for the same reason, noting that in its INI inventory "you can also use
lists and hash data in these files, which you cannot do in your main inventory
file".

**PyYAML is the official Python YAML library and is not fit for this.** All of
the following was measured on PyYAML 5.4.1, and `constructor.py` is
byte-identical in the current 6.0.3, so the newest release behaves the same:

- **Duplicate keys are accepted silently.** `a: 1` / `a: 2` yields `{a: 2}` with
  no warning. Open upstream since 2016. For a hand-edited file this is the single
  most likely way it goes wrong — the forgotten, uncommented old key.
- **Merge keys expand exponentially.** A 720-byte file took 131 seconds and
  1.07 GB. Present in every released version; fixed only on an unreleased `main`
  whose fix introduced a precedence regression with an unreviewed patch.
- **YAML 1.1 implicit typing corrupts ordinary values.** `013` becomes `11`
  (octal), `no` and `NO` become `False`, `1.10` becomes `1.1`. In a Docker
  configuration these are not hypothetical: a UID of `01000` parses as `512`.
- **This will not be fixed.** PyYAML has never implemented YAML 1.2; the request
  has been open since 2017 across three superseded attempts, and a maintainer's
  own explanation is that it is unstaffed volunteer work. It also accepts a
  `%YAML 1.2` directive and silently ignores it.

Upgrading 5.4.1 to 6.0.3 changes one character class in the resolver and closes
no CVE — 5.4.1 has none. Upgrading is not a remedy.

Crucially, the constraint that previously forced this choice has been lifted:
under the rebuild the configuration is parsed **inside an image this repo
builds**, so the Python version and the parser are pinned here rather than
inherited from whatever a given host ships. Ubuntu 22.04's Python 3.10 and its
`python3-yaml 5.4.1` are no longer load-bearing.

## Decision

**TOML, parsed with `tomllib` from the Python standard library.**

The properties that decide it are structural rather than incidental: TOML has no
implicit typing, no anchors or aliases, no merge keys, and duplicate keys are a
spec error rather than a silent overwrite. Measured: `a = 1` / `a = 2` raises
`Duplicate keys!` naming the line. `tomllib` has been in the standard library
since Python 3.11 (PEP 680), so the dependency count is zero.

The shape the configuration needs was validated by parsing it rather than by
inspection — nested groups, a group included twice under different aliases, and
per-use overrides all express cleanly:

    [groups.sensing.cam]
    repo = "app/realsense_ros2"

    [[groups.site.use]]
    group = "sensing"
    as    = "front"

    [[groups.site.use]]
    group = "sensing"
    as    = "rear"
    env   = { WS_PATH = "~/ws/rear" }

## Alternatives

- **YAML via PyYAML, hardened.** The YAML 1.1 problem alone is solvable: strip
  the implicit resolvers on an isolated subclass and `no` stays a string,
  verified working with the C loader too. But it does not touch duplicate keys,
  the merge-key blowup, deep-nesting recursion, or the fact that `safe_load`
  leaks `KeyError` / `ValueError` past `except yaml.YAMLError` on malformed
  input. Four separate pieces of defensive code would have to be written and
  owned here. Rejected as buying a worse position for more work.
- **YAML via ruamel.yaml.** Genuinely implements YAML 1.2, rejects duplicate keys
  by default, and is the only option with a built-in recursion guard
  (`max_depth`). Rejected on supply chain: single maintainer, hosted on
  SourceForge, still classified Beta, a maintainer-stated risk that PyPI uploads
  may become impossible under a naming conflict, and 0.19.x dropping prebuilt
  wheels in favour of compile-on-install. Also `typ='safe'` silently falls back
  to 1.1-ish C-loader behaviour unless `pure=True` is passed.
- **INI, matching base.** Rejected on expressiveness, as above. Consistency with
  base would have been worth real cost, but not the loss of nested reusable
  groups.
- **Keep YAML because compose uses YAML.** Rejected: the configuration is not a
  compose file and is never handed to compose. The surface similarity would buy
  familiarity at the price of the failure modes above.

## Consequences

- The assembly phase requires Python 3.11 or newer, which is satisfied by pinning
  it in this repo's own image rather than by asking anything of the host.
- The configuration is more verbose than the equivalent YAML. This was accepted
  explicitly.
- A malformed configuration fails loudly with a line number instead of parsing
  into something subtly wrong. That is the whole point.
- Nothing in this repo may write the configuration back out. TOML round-tripping
  loses comments and ordering, and more importantly the file is the operator's.
  Any tool-owned data belongs in a separate file.
