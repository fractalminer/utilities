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

host_off geekom1
host_off geekom2