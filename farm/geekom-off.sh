#!/bin/bash
set -eo pipefail

host_off() {
  local host="$1"
  echo "powering off $host..."
  # This relies on us having given our user the ability to run
  # the poweroff (and reboot) systemctl commands using sudo
  # without a password on the hosts in question.
  ssh "$host" sudo /usr/bin/systemctl poweroff
}

host="${1:-ALL}"

ok=0

if [[ "$host" == ALL || "$host" == geekom1 ]]; then
  echo host_off geekom1
  ok=1
fi

if [[ "$host" == ALL || "$host" == geekom2 ]]; then
  echo host_off geekom2
  ok=1
fi

if [[ "$host" == ALL || "$host" == geekom3 ]]; then
  echo host_off geekom3
  ok=1
fi

if (( ok == 0 )); then
  echo "cannot power off host $host" 1>&2
  exit 1
fi

exit 0