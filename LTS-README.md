# oleksandr-minakov/kubernetes — LTS source fork

Source fork for the six k8s-core components under the LTS service. Per LTS
plan v3 §9, **source tests live here** — every backport PR runs upstream's
own unit suites via `.github/workflows/lts-tests.yml`. Artifact builds,
SBOMs, signing, scanning, and the release gate live in the **build repo**
(`oleksandr-minakov/test-control-repo`).

Base: upstream **`v1.32.13`** (https://github.com/kubernetes/kubernetes).
LTS branch: **`lts/k8s-1.32/kubernetes-1.32`**.

## LTS-scaffolding files on this fork

| Path                                  | Purpose                                                                |
|---------------------------------------|------------------------------------------------------------------------|
| `.github/workflows/lts-tests.yml`     | Per-PR test runner — bucket A units per matrix + six-binary compile  |
| `.github/CODEOWNERS.lts`              | Path-scoped ownership for the 6 k8s-core dirs (cmd/<x>/)              |
| `.github/PULL_REQUEST_TEMPLATE/backport.md` | Required PR template for any CVE backport                       |
| `LTS-BRANCHING.md`                    | Branching model + commit-trailer spec                                  |
| `scripts/lts/lts-branch-init.sh`      | Idempotent helper to cut new LTS branches from upstream tags          |
| Everything else                       | Upstream kubernetes/kubernetes source                                  |

## How this fork was seeded

```bash
git clone --bare https://github.com/kubernetes/kubernetes.git kubernetes.git
git -C kubernetes.git push --mirror git@github.com:oleksandr-minakov/kubernetes.git
# Then `lts-branch-init.sh v1.32.13` to cut the LTS branch (already done).
```

## How releases happen (v3)

1. Open a `backport/<CVE>/lts-k8s-1.32-kubernetes-1.32` PR with the CVE fix.
2. `lts-tests.yml` runs upstream unit suites for each of the six binaries
   (matrix per `cmd/<component>/...`) plus a compile-check. This is the
   canonical patch validation — every CVE fix is tested here.
3. Tier-1 non-clean cherry-picks require two-person review (CODEOWNERS).
4. Merge into `lts/k8s-1.32/kubernetes-1.32`.
5. The build repo's `component-<X>.yml` picks up the merged commit, runs the
   hermetic build + artifact validation, and gates the release on the
   `lts-tests` check-run status at this commit.
