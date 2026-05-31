# Branching — `oleksandr-minakov/kubernetes`

Authoritative reference: `oleksandr-minakov/test-control-repo/docs/branching.md`.

## Six components, one LTS branch

All six k8s-core components share **one** LTS branch
(`lts/k8s-1.32/kubernetes-1.32`) because they all build from this single
upstream tree. Per-binary applicability is a property of the **patch**
(recorded in the patch manifest), not the branch.

## Branch names

```
upstream/main                                       # mirror only, never patched
upstream/release-1.32                               # mirror, never patched
lts/k8s-1.32/kubernetes-1.32                        # the LTS branch
backport/<CVE>/lts-k8s-1.32-kubernetes-1.32         # working branch per CVE
core-assurance/INC-<ID>/lts-k8s-1.32-kubernetes-1.32
```

## Branch protection (required at GitHub level)

For `lts/k8s-1.32/kubernetes-1.32`:

- Require pull request reviews — **2 approvals** (Tier-1).
- Require review from CODEOWNERS.
- Require status checks: the source-native test job(s) defined in
  `.github/workflows/lts-tests.yml` (to be added) and the per-component
  `gate` job dispatched from the control repo.
- Disallow force pushes, disallow deletions.
- Restrict who can push (LTS engineers only).

## Commit trailers

Every backport merge commit MUST carry:

```
LTS-Patch: CVE-YYYY-NNNN
LTS-Strategy: cherry-pick | reimplemented | partial
LTS-Component-Applicability: kube-apiserver,kubectl
```

The control-repo's `scripts/render-patch-manifest.sh` parses these to build
the generated patch manifest (§4).
