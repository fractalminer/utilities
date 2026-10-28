#!/bin/bash
set -eo pipefail

# This assumes that when we're connected to wifi and we plug in
# the usb tether (which appears as ethernet) that that ethernet
# route gets a lower metric, which we don't want because the wifi
# is often faster.
#
# For example if we see:
#
#   default via 10.132.249.51 dev enxb2eefa0f064c proto dhcp metric 100
#   default via 192.168.1.1 dev wlp47s0f0 proto dhcp metric 600
#
# then this script will swap them:
#
#   default via 192.168.1.1 dev wlp47s0f0 proto dhcp metric 50
#   default via 10.132.249.51 dev enxb2eefa0f064c proto dhcp metric 100
#
sudo ip route replace default via 192.168.1.1 dev wlp47s0f0 metric 50  proto dhcp
sudo ip route del     default via 192.168.1.1 dev wlp47s0f0 metric 600 proto dhcp