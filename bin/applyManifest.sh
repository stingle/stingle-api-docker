#!/bin/bash
#
# Materialize a reproducible deployment from a private composition-lock repo.
#
# When MANIFEST_REPO is set in .env, this clones/updates that private repo and,
# for every addon it pins, checks the addon out at the exact commit the merged
# composer.lock was built from, then drops that lock into ./composer/. The
# deployment's `composer install` then installs exactly the resolved dependency
# set -- core + all addons -- with no `composer update` on the server.
#
# When MANIFEST_REPO is empty this is a successful no-op, so the public repo
# keeps working with no addons and no private manifest.
#
set -e
source .env

[ -z "${MANIFEST_REPO:-}" ] && exit 0

command -v jq >/dev/null || { echo "jq is required for manifest-based deploys; install jq" >&2; exit 1; }

if [ -d manifest/.git ]; then
  git -C manifest fetch -q origin && git -C manifest reset --hard -q origin/HEAD
else
  git clone -q "$MANIFEST_REPO" manifest
fi

# Pin each addon at the manifest's sha, cloning it first (from the URL recorded
# in the private sources.json) if it isn't present yet.
jq -r '.addons | to_entries[] | "\(.key)\t\(.value)"' manifest/manifest.json |
while IFS=$'\t' read -r name sha; do
  if [ ! -d "addons/$name/.git" ]; then
    url=$(jq -r --arg n "$name" '.addons[] | select(.name==$n) | .repo' manifest/sources.json)
    if [ -n "$url" ] && [ "$url" != "null" ]; then
      git clone -q "$url" "addons/$name"
    else
      echo "warning: no repo URL for addon '$name' in manifest/sources.json; skipping clone" >&2
    fi
  fi
  git -C "addons/$name" fetch -q origin
  git -C "addons/$name" checkout -q "$sha"
done

mkdir -p composer
cp manifest/composer.lock composer/composer.lock

echo "Applied manifest $(git -C manifest rev-parse --short HEAD): pinned $(jq '.addons | length' manifest/manifest.json) addon(s)"
