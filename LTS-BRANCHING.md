# Branching — `oleksandr-minakov/kubernetes`

Authoritative reference: `oleksandr-minakov/test-control-repo/docs/branching.md`.

## Six components, one release branch per minor

All six k8s-core components share **one** release branch per upstream minor
(`release-1.32`) because they all build from this single upstream tree.
Per-binary applicability is a property of the **patch** (recorded in the
patch manifest), not the branch. The build repo carries a matching
`release-1.32` so source and build move together.

## Branch names

```
upstream/main                                       # mirror only, never patched
upstream/release-1.32                               # mirror, never patched
release-1.32                                        # the LTS release branch (this fork)
backport/<CVE>/release-1.32                         # working branch per CVE
core-assurance/INC-<ID>/release-1.32
```

## Branch protection (required at GitHub level)

For `release-1.32`:

- Require pull request reviews — **2 approvals** (Tier-1).
- Require review from CODEOWNERS.
- Require status checks: the source-native test job(s) defined in
  `.github/workflows/lts-tests.yml` and the per-component `gate` job
  dispatched from the build repo.
- Disallow force pushes, disallow deletions.
- Restrict who can push (LTS engineers only).

## Commit trailers

Every backport merge commit MUST carry:

```
LTS-Patch: CVE-YYYY-NNNN
LTS-Strategy: cherry-pick | reimplemented | partial
LTS-Component-Applicability: kube-apiserver,kubectl
```

The build-repo's `scripts/render-release-metadata.sh` parses these to build
the generated release metadata.
