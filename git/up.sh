#!/bin/bash
set -eo pipefail

pull_impl() {
  local branch="$1"
  cd "$where"
  git fetch origin "$branch" --quiet
  # If there are conflicts then we want it to fail and not mess
  # things up, so just disable the auto-stash, otherwise in some
  # cases it doesn't even return an error if there is a conflict.
  git merge "origin/$branch" --no-autostash
}

pull() {
  local where="$1"
  local branch="$2"
  echo -en "$(basename "$where"):\t"
  pull_impl "$branch"
}

# For shorter names that need two tabs.
pull2() {
  local where="$1"
  local branch="$2"
  echo -en "$(basename "$where"):\t\t"
  pull_impl "$branch"
}

pull  ~/dev/utilities master
pull  ~/dev/moonlib   main
pull  ~/.dotfiles     master
pull2 ~/dev/redist    main