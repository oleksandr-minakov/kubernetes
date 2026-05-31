#!/usr/bin/env bash
# Cut the LTS branch from an upstream tag. Idempotent: re-running with the
# same tag is a no-op.
#
# Usage:  scripts/lts/lts-branch-init.sh v1.32.13
#
# Pre-conditions:
#   * Working tree is a clean clone of oleksandr-minakov/kubernetes.
#   * `upstream` remote points at https://github.com/kubernetes/kubernetes.git
#     (the README seeds this).
set -euo pipefail

tag="${1:?upstream tag required (e.g. v1.32.13)}"

if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "lts-branch-init: tag must be vMAJOR.MINOR.PATCH, got '$tag'" >&2
  exit 1
fi

# Derive bundle from MAJOR.MINOR
mm="${tag#v}"; mm="${mm%.*}"     # 1.32
bundle="k8s-${mm}"               # k8s-1.32
lts_branch="lts/${bundle}/kubernetes-${mm}"
mirror_branch="upstream/release-${mm}"

git remote get-url upstream >/dev/null 2>&1 || {
  echo "lts-branch-init: 'upstream' remote not configured" >&2
  echo "  git remote add upstream https://github.com/kubernetes/kubernetes.git" >&2
  exit 1
}

git fetch upstream --tags
git fetch upstream "refs/heads/release-${mm}:refs/heads/${mirror_branch}" || true
git push origin "${mirror_branch}" || true

if git show-ref --quiet "refs/heads/${lts_branch}" \
   || git ls-remote --exit-code origin "refs/heads/${lts_branch}" >/dev/null 2>&1; then
  echo "lts-branch-init: ${lts_branch} already exists; nothing to do."
  exit 0
fi

git checkout -b "${lts_branch}" "${tag}"
git push -u origin "${lts_branch}"

cat <<EOF
✓ Created ${lts_branch} from ${tag}
  Next:
    * Configure branch protection on origin for ${lts_branch}
      (2 reviews, CODEOWNERS, required status checks). See BRANCHING.md.
    * In the control repo, ensure components/*.yaml fork.lts_branch matches.
EOF
