#!/bin/bash
set -eo pipefail

# This runs on darter2 to bring the linode redis to localhost. It
# is used in conjunction with forward-thelio.sh (which runs on
# thelio).

# redis localhost <- redis linode
ssh -N -L 6379:localhost:6379 linode