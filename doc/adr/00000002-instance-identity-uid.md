# ADR-00000002: Instance identity is a leaf name plus a permanent UID

- **Date:** 2026-09-05
- **Status:** Accepted
- **Relates to:** #26 (the rebuild), #15; ADR-00000001 (fan-out, which makes the
  project name the only isolation axis)

## Context

Under ADR-00000001 each instance is its own compose project, so **the project
name is the only namespacing primitive available**. Compose has no instance axis
of its own: it models project, service and `replicas`, but not "the same service
run N times with per-instance parameters" — base's ADR-00000022 opens with
exactly that observation.

Instances are organised into named groups, groups may contain other groups, and
the same group may be included more than once. Some scheme has to turn a position
in that tree into a project name that is unique on the host.

Two measured facts constrain the scheme.

**Renaming a project strands what is running.** Same compose file, run once as
`mr_alpha` and once as `mr_bravo`: `mr_alpha` wrote a marker into its volume and
`mr_bravo` reading the same path got `No such file or directory`; two volumes
existed (`mr_alpha_data`, `mr_bravo_data`); and `mr_alpha` kept running after
`mr_bravo` started. Reproduced independently on a second machine, on Compose
v5.3.0 and v5.5.0. A rename is therefore not a rename — it is a new project, and
the old containers and volumes remain, invisible to the new name.

**Length is not the constraint.** Container names of 70 and 100 characters work,
and compose does not derive a hostname from the project name (a 60-character
project name emitted no `hostname:`). The 64-byte hostname limit is real —
`hostname ... is too long (maximum 64 bytes)` at 65 — but is not reached through
this path. So the choice is not forced by a length budget; it is a question of
what a name should mean.

## Decision

**A project name is `<leaf name>_<permanent UID>`.**

The UID is issued once when the instance is first created and never changes
afterwards — not when the instance moves to a different group, not when an
enclosing group is renamed, not when entries are reordered. The leaf name is
carried as a prefix purely so `docker ps` is legible to a human.

A group included more than once is **named at the point of use** rather than
auto-numbered. This follows the unanimous convention among tools that solved the
same problem: Helm's subchart `alias`, Terraform's "you must use unique labels
for each block", DevSpace's "use a different name for each of those instances",
Terragrunt's `stack "dev"` / `stack "prod"`. The one system that behaves
differently, Ansible, does not produce copies at all — a group appearing twice
"remains the same entity".

Two corollaries follow from the identity being stable rather than derived.

**The scheme is self-recovering.** Because the UID lives inside the project name,
and compose stamps `com.docker.compose.project` on every container, network and
named volume it creates, the UID can be read back out of docker itself.
Measured: containers additionally carry
`com.docker.compose.project.working_dir` (the repo path), and a named volume
keeps its project label after `down` without `-v`. So an instance that has
anything worth stranding is recoverable; an instance with neither containers nor
volumes has nothing to strand, and re-issuing its UID is harmless.

**An absence is never an instruction.** Seven documented incidents across
Terraform, Argo CD, Puppet, Compose and systemd share one mechanism: something
was not found — not in the configuration, not under this label, not in this
region — and the tool read that as "therefore act". Terraform #34475 is the
sharpest: `removed` blocks, the feature whose entire purpose is to *forget*
without destroying, did not recurse into submodules, so the plan reported a
state-only removal while destroying six real resources. Consequently, any
operation here that reasons from a missing entry — orphan cleanup in particular —
**reports by default and destroys only under an explicit flag**.

## Alternatives

- **Encode the full path in the name** (`site_front_cam`). Rejected: moving an
  instance between groups changes its name, and per the measurement above that
  orphans its containers and volumes. Every system that does encode a path either
  bounds the depth by convention (DNS labels, PEP 423's "two levels is almost
  always enough") or enforces ancestry mechanically (systemd slices, Bazel
  labels). The one project built specifically to add hierarchy to a flat
  namespace — Kubernetes' HNC — kept names flat, put the tree in metadata, and
  cited re-parenting-without-rename as the payoff. It has since been archived,
  and Kubernetes still has no hierarchical namespaces.
- **Auto-number repeated uses** (`cam_1`, `cam_2`). Rejected: the resulting
  address is positional, so inserting an entry silently repoints every address
  written down elsewhere. This was the working assumption until the question
  "how do I select just one of them" exposed it.
- **Require every leaf name to be globally unique, with no suffix.** Rejected:
  it forbids reusing a group, which is the core requirement.
- **Hash the logical path into a short suffix.** Rejected: the hash changes when
  the path changes, so it inherits the rename problem while being less readable
  than the path it replaces.
- **Reuse base's derived name plus a suffix**, which is what base's retired
  `INSTANCE_SUFFIX` did (`${DOCKER_HUB_USER}-${IMAGE_NAME}-<instance>`).
  Rejected: base removed that mechanism deliberately in #600, and its derived
  half re-detects `DOCKER_HUB_USER` on every `setup apply`, so the name drifts on
  a `docker logout` or a different login.

## Consequences

- Reorganising the configuration — moving an instance between groups, renaming an
  enclosing group, reordering entries — does not touch what is running.
- Renaming a *leaf* still changes the project name, and therefore still strands
  the old project. Making the name purely opaque would remove even that, at the
  cost of an unreadable `docker ps`; the readability was judged worth the
  residual case, which is rare and visible.
- Orphan cleanup (`prune`) becomes a responsibility this scheme creates: an
  instance removed from the configuration leaves a project whose UID nothing
  references any more. Per the "absence is not an instruction" rule above, that
  operation reports by default.
- The UID must survive being copied. systemd's `/etc/machine-id` history is the
  cautionary case: duplicates arose not from generation but from *cloning* — an
  image built with the generator run in the host namespace gave every instance
  the host's ID, and a shadow copy in `/var/lib/dbus/machine-id` silently
  defeated the documented reset procedure. The UID is therefore stored in exactly
  one place, and a way to detect duplication is required.
- Where the configuration file lives and how it is version-controlled is out of
  scope here; a separate repo owns that. This ADR fixes only what an identity is
  and how it behaves, not where it is recorded.
