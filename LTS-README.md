# oleksandr-minakov/kubernetes — Mirantis LTS source fork

Source fork for the six k8s-core components under the Mirantis LTS service.
This repo holds the **kubernetes source tree + lts-tests + release-please**;
the paired build repo (`oleksandr-minakov/test-control-repo`) holds
**`VERSION` + `build.sh` + `build.yaml`** and produces the artifacts.

Base: upstream **`v1.32.13`** (https://github.com/kubernetes/kubernetes).
Release branch: **`release-1.32`** (paired with `release-1.32` on the build
repo). Per-PR source tests still target backport branches under `lts/**`.

## What lives here

| Path                                       | Purpose                                                              |
|--------------------------------------------|----------------------------------------------------------------------|
| `version.txt`                              | Current LTS version (`1.32.13-lts.0`). Maintained by release-please. |
| `CHANGELOG.md`                             | release-please-generated changelog.                                  |
| `.github/workflows/lts-tests.yml`          | Per-PR upstream unit + compile-check matrix across the six binaries. |
| `.github/workflows/release-please.yaml`    | Manual-trigger tag-cutter that cascades a VERSION-bump PR downstream.|
| `.github/CODEOWNERS.lts`                   | Path-scoped ownership for the 6 k8s-core dirs (`cmd/<x>/`).          |
| `.github/PULL_REQUEST_TEMPLATE/backport.md`| Required PR template for any CVE backport.                           |
| `BRANCHING.md`                             | Branching model + commit-trailer spec.                               |
| `scripts/lts/lts-branch-init.sh`           | Idempotent helper to cut release branches from upstream tags.        |
| Everything else                            | Upstream `kubernetes/kubernetes` source.                             |

## The release cascade

Two repos, one direction:

```
 source fork (this repo)                       build repo (test-control-repo)
 ─────────────────────────                     ───────────────────────────────
  release-please.yaml  ──┐
   (manual dispatch)     │
                         ├──> tags v1.32.13-lts.X here
                         │
                         └──> opens "chore: bump VERSION" PR
                               in build repo against release-1.32
                                                                │
                                                                ▼
                                                       build.yaml on merge:
                                                       reads VERSION, checks
                                                       out source @ that tag,
                                                       runs build.sh, pushes
                                                       images + .debs, scans.
```

## Bootstrap (one-time, done manually)

After this README + version.txt + CHANGELOG land on `release-1.32`, tag the
initial release **manually** so release-please has a starting point:

```bash
git checkout release-1.32
git tag v1.32.13-lts.0
git push origin v1.32.13-lts.0
# Then create a GitHub Release pointing at that tag (UI or `gh release create`):
gh release create v1.32.13-lts.0 --target release-1.32 \
  --title "v1.32.13-lts.0" --notes "Initial LTS cut from upstream v1.32.13."
```

Subsequent releases (`-lts.1`, `-lts.2`, …) come from running the
`release-please` workflow from the Actions tab.

## How this fork was seeded

```bash
git clone --bare https://github.com/kubernetes/kubernetes.git kubernetes.git
git -C kubernetes.git push --mirror git@github.com:oleksandr-minakov/kubernetes.git
# Then `lts-branch-init.sh v1.32.13` cut release-1.32.
```

## Per-PR flow (CVE backport)

1. Open a `backport/<CVE>/lts-k8s-1.32-kubernetes-1.32` PR against
   `release-1.32` (or the matching `lts/**` working branch).
2. `lts-tests.yml` runs upstream unit suites for each of the six binaries
   plus a compile-check.
3. Tier-1 non-clean cherry-picks require two-person review (CODEOWNERS).
4. Merge into `release-1.32`.
5. Once the monthly window opens, an operator triggers `release-please` →
   the build repo gets the bump PR → merging it builds artifacts.
