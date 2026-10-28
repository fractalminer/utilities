#!/bin/bash
set -eo pipefail

is_on() {
  local host="$1"
  ping -q -W1 -c1 "$host" >/dev/null || return 1
  ssh "$host" "echo $host is on." || return 1
  return 0
}

wait_on() {
  local host="$1"
  while true; do
    is_on "$host" && return
    echo "waiting for $host to be on..."
    sleep 1
  done
}

host="${1:-ALL}"

# NOTE: the wakeonlan command wants the MAC address of the host
# which you can get via:
#
#   ip link show enp2s0
#
# or substitute the relevant interface.

ok=0

if [[ "$host" == ALL || "$host" =~ geekom1.* ]]; then
  echo 'waking geekom1...'
  wakeonlan 38:f7:cd:da:5b:e6  # geekom1
  ok=1
fi

if [[ "$host" == ALL || "$host" =~ geekom2.* ]]; then
  echo 'waking geekom2...'
  wakeonlan 38:f7:cd:da:ba:08  # geekom2
  ok=1
fi

if [[ "$host" == ALL || "$host" =~ geekom3.* ]]; then
  echo 'waking geekom2...'
  wakeonlan 38:f7:cd:da:83:f8  # geekom3
  ok=1
fi

if (( ok == 0 )); then
  echo "cannot power on host $host" 1>&2
  exit 1
fi

# Note that we've initiated the turn on of all boxes above to-
# gether so that they can run in parallel before we start waiting
# for any one of them.
if [[ "$host" == ALL || "$host" =~ geekom1.* ]]; then wait_on geekom1.local; fi
if [[ "$host" == ALL || "$host" =~ geekom2.* ]]; then wait_on geekom2.local; fi
if [[ "$host" == ALL || "$host" =~ geekom3.* ]]; then wait_on geekom3.local; fi

exit 0