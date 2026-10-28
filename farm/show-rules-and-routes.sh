#!/bin/bash
set -eo pipefail

bar() { printf "%${COLUMNS}s" | tr ' ' '-'; }

title() { bar; echo "$@"; bar; }

indent() { sed -r 's|(.*)|  \1|'; }

title 'Rules'
ip rule show | indent
title 'Table: main'
ip route show table main | indent
title 'Table: wifi (50100)'
ip route show table 50100 | indent
title 'Table: usb  (50101)'
ip route show table 50101 | indent