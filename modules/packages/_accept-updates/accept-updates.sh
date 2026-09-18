# Accept every open flake update in one command.
#
# Each update pull request rewrites the same file, so merging them one by one
# means the second merge fights the first. This applies them instead: it reads
# which inputs the open pull requests carry, bumps all of them in a single
# `nix flake update`, checks that both hosts still evaluate, pushes the result
# to testing, and closes the pull requests it applied.
#
# The work happens in a git worktree under /tmp, so the checkout you are
# sitting in is never touched.

set -euo pipefail

checkout="${ACCEPT_UPDATES_CHECKOUT:-$HOME/nixos}"
promote=0
skip_high=0

usage() {
  cat <<'USAGE'
accept-updates [--promote] [--skip-high]

  --promote     After CI passes on testing, fast-forward main as well.
  --skip-high   Leave lane:high pull requests open for a human.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --promote) promote=1 ;;
    --skip-high) skip_high=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "accept-updates: unknown argument $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

cd "$checkout"

filter='.[] | select(.state == "OPEN")'
if [ "$skip_high" = 1 ]; then
  filter="$filter | select([.labels[].name] | index(\"lane:high\") | not)"
fi

pulls=$(gh pr list --label flake-update --state open \
  --json number,headRefName,labels,state --jq "[$filter]")

count=$(jq 'length' <<<"$pulls")
if [ "$count" = 0 ]; then
  echo "accept-updates: nothing open."
  exit 0
fi

# flake-update/<input> is the branch this workflow pushes, so the branch name
# is the input name.
inputs=$(jq -r '.[].headRefName | sub("^flake-update/"; "")' <<<"$pulls")
numbers=$(jq -r '.[].number' <<<"$pulls")

echo "accept-updates: applying $count update(s):"
while read -r name; do
  [ -n "$name" ] || continue
  echo "  - $name"
done <<<"$inputs"

# `git worktree add` refuses a path that already exists, so mktemp makes the
# parent and git makes the leaf.
parent=$(mktemp -d /tmp/accept-updates.XXXXXX)
work="$parent/tree"
cleanup() {
  git -C "$checkout" worktree remove --force "$work" 2>/dev/null || true
  rm -rf "$parent"
}
trap cleanup EXIT

git fetch --quiet origin testing
git worktree add --quiet --detach "$work" origin/testing
cd "$work"

# shellcheck disable=SC2086
nix flake update $inputs --accept-flake-config

if git diff --quiet -- flake.lock; then
  echo "accept-updates: the lock did not move. Nothing to push."
  exit 0
fi

for host in chapel bigrig; do
  echo "accept-updates: evaluating $host"
  nix build --dry-run --accept-flake-config \
    ".#nixosConfigurations.$host.config.system.build.toplevel" >/dev/null
done

summary=$(echo "$inputs" | paste -sd ', ' -)
git add flake.lock
git -c user.name="retr0astic" -c user.email="sreejiraj2399@gmail.com" \
  commit --quiet -m "chore(flake): accept $count update(s)

$summary"

sha=$(git rev-parse HEAD)
git push --quiet origin HEAD:testing
echo "accept-updates: pushed ${sha:0:7} to testing"

while read -r number; do
  [ -n "$number" ] || continue
  gh pr close "$number" --delete-branch \
    --comment "Applied to testing in ${sha:0:7} with the other open updates." \
    >/dev/null
done <<<"$numbers"
echo "accept-updates: closed $count pull request(s)"

if [ "$promote" = 0 ]; then
  echo "accept-updates: run with --promote to move main once CI is green."
  exit 0
fi

echo "accept-updates: waiting for CI on testing"

# Match the run to this exact commit. Taking the newest run instead would
# watch the previous push whenever registration lags.
run=""
for _ in $(seq 1 12); do
  run=$(gh run list --branch testing --workflow flake.yml --limit 10 \
    --json databaseId,headSha \
    --jq "[.[] | select(.headSha == \"$sha\")] | .[0].databaseId // empty")
  [ -n "$run" ] && break
  sleep 10
done

if [ -z "$run" ]; then
  echo "accept-updates: no CI run appeared for ${sha:0:7}." >&2
  echo "accept-updates: testing carries the commit. main is unchanged." >&2
  exit 1
fi

gh run watch "$run" --exit-status

git push --quiet origin "$sha:main"
echo "accept-updates: main is at ${sha:0:7}"
