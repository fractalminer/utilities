#!/bin/bash
set -eo pipefail

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

exit 0