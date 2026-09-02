#!/bin/bash
set -eo pipefail

# redis linode -> redis thelio.
# 12345 linode -> ssh thelio
#
# NOTE: The ExitOnForwardFailure helps to notify us (by exiting
# this ssh) when there are some stuck sshd on the linode from
# previous sessions that are still bound to those ports, which
# otherwise would just allow the ssh but silently not map the
# ports.
ssh -o ExitOnForwardFailure=yes linode \
  -R 127.0.0.1:6379:localhost:6379 \
  -R 127.0.0.1:12345:localhost:22