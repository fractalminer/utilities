#!/bin/bash
set -eo pipefail

is_off() {
  local host="$1"
  ping -q -W1 -c1 "$host" >/dev/null || return 0
  return 1
}

host_off() {
  local host="$1"
  if is_off "$host"; then return; fi
  echo "powering off $host..."
  # This relies on us having given our user the ability to run
  # the poweroff (and reboot) systemctl commands using sudo
  # without a password on the hosts in question.
  ssh "$host" sudo /usr/bin/systemctl poweroff
}

wait_off() {
  local host="$1"
  while true; do
    if is_off "$host"; then
      echo "$host is off."
      return
    fi
    echo "waiting for $host to be off..."
    sleep 1
  done
}

host="${1:-ALL}"

ok=0

if [[ "$host" == ALL || "$host" =~ geekom1.* ]]; then host_off geekom1; ok=1; fi
if [[ "$host" == ALL || "$host" =~ geekom2.* ]]; then host_off geekom2; ok=1; fi
if [[ "$host" == ALL || "$host" =~ geekom3.* ]]; then host_off geekom3; ok=1; fi

if (( ok == 0 )); then
  echo "cannot power off host $host" 1>&2
  exit 1
fi

# Note that we've initiated the turn off of all boxes above to-
# gether so that they can run in parallel before we start waiting
# for any one of them.
if [[ "$host" == ALL || "$host" =~ geekom1.* ]]; then wait_off geekom1; fi
if [[ "$host" == ALL || "$host" =~ geekom2.* ]]; then wait_off geekom2; fi
if [[ "$host" == ALL || "$host" =~ geekom3.* ]]; then wait_off geekom3; fi

exit 0