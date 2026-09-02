#!/bin/bash
set -eo pipefail

# NOTE: the wakeonlan command wants the MAC address of the host
# which you can get via:
#
#   ip link show enp2s0
#
# or substitute the relevant interface.

echo 'waking geekom1...'
wakeonlan 38:f7:cd:da:5b:e6  # geekom1

echo 'waking geekom2...'
wakeonlan 38:f7:cd:da:ba:08  # geekom2