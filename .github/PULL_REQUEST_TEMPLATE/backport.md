<!--
Backport PR for the LTS service. Open against lts/k8s-1.32/kubernetes-1.32.
See BRANCHING.md for required commit trailers.
-->

## CVE / advisory

- ID: `CVE-YYYY-NNNN` (or `GHSA-xxxx-xxxx-xxxx`)
- Severity: `critical | high | medium | low`
- KEV / actively exploited: `yes | no`
- Upstream fix: <link to upstream PR/commit>

## Applicability per binary

Per §2 fix flow step 5, applicability is decided per-binary. Tick all that
apply. Anything left unticked must have a VEX `not_affected` justification.

- [ ] `kube-apiserver`
- [ ] `kube-controller-manager`
- [ ] `kube-scheduler`
- [ ] `kube-proxy`
- [ ] `kubelet`
- [ ] `kubectl`

## Strategy

- [ ] Clean cherry-pick
- [ ] Re-implemented (describe below; **Tier-1 → two-person review required**)
- [ ] Partial (describe below)

If non-clean, briefly justify the deviation.

## Tests

- [ ] `make test WHAT=./<affected paths>` passes locally
- [ ] kind smoke (`kind-cluster-smoke`) green for affected binaries
- [ ] Skipped upstream signal recorded in the release coverage matrix

## Required commit trailers (paste into the merge commit)

```
LTS-Patch: CVE-YYYY-NNNN
LTS-Strategy: cherry-pick
LTS-Component-Applicability: kube-apiserver,kubectl
```

## Two-person review

- [ ] Reviewer 1: ___________
- [ ] Reviewer 2: ___________  *(required for Tier-1 non-clean cherry-picks)*
