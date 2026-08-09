#!/bin/bash
set -eo pipefail

die() {
  echo 1>&2 "error: $@"
  exit 1
}

latest_name=fractalminer

origin="$(git remote get-url origin)"
old_origin="$origin"

if [[ "$origin" =~ $latest_name ]]; then
  echo "origin is already latest: $latest_name"
  exit 0
fi

past_names='
  dpacbach
  no-more-secrets
'

for past_name in $past_names; do
  origin="${origin//$past_name/$latest_name}"
done

[[ -n "$origin" ]] || die "new origin is empty"

[[ "$origin" == "$old_origin" ]] && \
  die 'this repo does not use any past usernames.'

echo "setting origin to: $origin"
git remote remove origin
git remote add    origin "$origin"