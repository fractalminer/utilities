#!/bin/bash
set -eo pipefail

# When using the Keychron web launcher to connect to the keyboard
# on Linux it will see the device but not be able to connect due
# to a permissions issue. The below should fix that.

sudo tee /etc/udev/rules.d/70-keychron.rules >/dev/null <<'EOF'
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e40", MODE="0660", TAG+="uaccess"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger