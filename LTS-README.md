# oleksandr-minakov/kubernetes — private fork

This is the **source fork** for the six k8s-core components under the LTS
service (kube-apiserver, kube-controller-manager, kube-scheduler, kube-proxy,
kubelet, kubectl). All artifact builds, SBOMs, signing, and policy gates
live in the **control repo** (`oleksandr-minakov/test-control-repo`) — this repo is source
only.

Base: upstream `v1.32.13` (https://github.com/kubernetes/kubernetes).

## How to seed this repo (one-time, by Ops)

```bash
git clone --bare https://github.com/kubernetes/kubernetes.git kubernetes.git
cd kubernetes.git
git push --mirror git@github.com:oleksandr-minakov/kubernetes.git
cd ..
git clone git@github.com:oleksandr-minakov/kubernetes.git
cd kubernetes
git remote add upstream https://github.com/kubernetes/kubernetes.git

# Drop in the staged files from this directory
cp -r ../source-fork-kubernetes/.github .github
cp ../source-fork-kubernetes/BRANCHING.md BRANCHING.md
cp -r ../source-fork-kubernetes/scripts scripts/lts

git add .github BRANCHING.md scripts/lts
git commit -m "LTS scaffolding (CODEOWNERS, PR template, branch init)"
git push origin main

# Cut the LTS branch from v1.32.13
./scripts/lts/lts-branch-init.sh v1.32.13
```

After that:

- `lts/k8s-1.32/kubernetes-1.32` is the maintained LTS branch.
- `upstream/release-1.32` is a mirror of upstream's release branch (synced
  weekly per §4, never patched).
- Backports happen on
  `backport/<CVE>/lts-k8s-1.32-kubernetes-1.32` → PR → review → merge.

See `BRANCHING.md` for the full branching model.
