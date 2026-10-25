#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# Constants.
# ---------------------------------------------------------------
LINODE_HOST=45.79.170.240

WIFI_IF=wlp47s0f0
USBX_IF=enxb2eefa0f064c

# Reserved for this script.
WIFI_TABLE=50100
USBX_TABLE=50101

WIFI_PRIO=10000
USBX_PRIO=10001

WIFI_PORT=6379
USBX_PORT=6381

REMOTE_REDIS_HOST=127.0.0.1
REMOTE_REDIS_PORT=6379

# ---------------------------------------------------------------
# Helper Functions.
# ---------------------------------------------------------------
get_ip() {
  local interface="$1"
  ip -4 addr show dev "$interface" \
    | awk '/inet / { sub(/\/.*/, "", $2); print $2; exit }'
}

get_gw() {
  local interface="$1"
  ip -4 route show default dev "$interface" \
    | awk '/default/ { print $3; exit }'
}

get_sn() { # Get Subnet.
  local interface="$1"
  ip -4 route show dev "$interface" proto kernel scope link \
    | awk 'NR == 1 { print $1 }'
}

# ---------------------------------------------------------------
# Query IP/Gateway and check for collisions.
# ---------------------------------------------------------------
wifi_ip=$(get_ip "$WIFI_IF")
usbx_ip=$(get_ip "$USBX_IF")
wifi_gw=$(get_gw "$WIFI_IF")
usbx_gw=$(get_gw "$USBX_IF")
wifi_sn=$(get_sn "$WIFI_IF")
usbx_sn=$(get_sn "$USBX_IF")

[[ -n "$wifi_ip" ]] || { echo "No IPv4 address on $WIFI_IF"; exit 1; }
[[ -n "$usbx_ip" ]] || { echo "No IPv4 address on $USBX_IF"; exit 1; }
[[ -n "$wifi_gw" ]] || { echo "No gateway for $WIFI_IF";     exit 1; }
[[ -n "$usbx_gw" ]] || { echo "No gateway for $USBX_IF";     exit 1; }
[[ -n "$wifi_sn" ]] || { echo "No subnet for $WIFI_IF";      exit 1; }
[[ -n "$usbx_sn" ]] || { echo "No subnet for $USBX_IF";      exit 1; }

# Make sure our reserved rule priorities are free.
for prio in "$WIFI_PRIO" "$USBX_PRIO"; do
  if ip rule show | grep -q "^${prio}:"; then
    echo "Routing rule priority $prio is already in use."
    exit 1
  fi
done

# Make sure our reserved routing tables are empty.
for table in "$WIFI_TABLE" "$USBX_TABLE"; do
  if ip route show table "$table" 2>/dev/null | grep -q .; then
    echo "Routing table $table is already in use."
    exit 1
  fi
done

# ---------------------------------------------------------------
# Cleanup.
# ---------------------------------------------------------------
wifi_table_created=false
usbx_table_created=false
wifi_rule_added=false
usbx_rule_added=false

cleanup() {
  trap - EXIT INT TERM

  echo
  echo "Cleaning up..."

  for pid in "${wifi_ssh_pid:-}" "${usbx_ssh_pid:-}"; do
    if [[ -n "$pid" ]]; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done

  if $wifi_rule_added; then
    sudo ip rule del priority "$WIFI_PRIO" \
      oif "$WIFI_IF" table "$WIFI_TABLE" 2>/dev/null || true
  fi

  if $usbx_rule_added; then
    sudo ip rule del priority "$USBX_PRIO" \
      oif "$USBX_IF" table "$USBX_TABLE" 2>/dev/null || true
  fi

  if $wifi_table_created; then
    sudo ip route flush table "$WIFI_TABLE" 2>/dev/null || true
  fi

  if $usbx_table_created; then
    sudo ip route flush table "$USBX_TABLE" 2>/dev/null || true
  fi
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# ---------------------------------------------------------------
# Summary.
# ---------------------------------------------------------------
echo "Wi-Fi:"
echo "  interface: $WIFI_IF"
echo "  address:   $wifi_ip"
echo "  gateway:   $wifi_gw"

echo
echo "USB:"
echo "  interface: $USBX_IF"
echo "  address:   $usbx_ip"
echo "  gateway:   $usbx_gw"

# ---------------------------------------------------------------
# Populate the routing tables.
# ---------------------------------------------------------------
sudo -v

sudo ip route add table "$WIFI_TABLE" "$wifi_sn" dev "$WIFI_IF" src "$wifi_ip"; wifi_table_created=true
sudo ip route add table "$USBX_TABLE" "$usbx_sn" dev "$USBX_IF" src "$usbx_ip"; usbx_table_created=true

sudo ip route add table "$WIFI_TABLE" default via "$wifi_gw" dev "$WIFI_IF"
sudo ip route add table "$USBX_TABLE" default via "$usbx_gw" dev "$USBX_IF"

# ---------------------------------------------------------------
# Select routing table according to the bound output interface.
# ---------------------------------------------------------------
sudo ip rule add priority "$WIFI_PRIO" oif "$WIFI_IF" table "$WIFI_TABLE"; wifi_rule_added=true
sudo ip rule add priority "$USBX_PRIO" oif "$USBX_IF" table "$USBX_TABLE"; usbx_rule_added=true

echo
echo "Routes to Linode:"
ip -4 route get "$LINODE_HOST" oif "$WIFI_IF"
ip -4 route get "$LINODE_HOST" oif "$USBX_IF"

# ---------------------------------------------------------------
# Create SSH tunnels.
# ---------------------------------------------------------------
echo
echo "Starting SSH tunnels..."

ssh -N \
  -B "$WIFI_IF" \
  -o ExitOnForwardFailure=yes \
  -L "127.0.0.1:$WIFI_PORT:$REMOTE_REDIS_HOST:$REMOTE_REDIS_PORT" \
  "$LINODE_HOST" &
wifi_ssh_pid=$!

ssh -N \
  -B "$USBX_IF" \
  -o ExitOnForwardFailure=yes \
  -L "127.0.0.1:$USBX_PORT:$REMOTE_REDIS_HOST:$REMOTE_REDIS_PORT" \
  "$LINODE_HOST" &
usbx_ssh_pid=$!

echo
echo "Wi-Fi Redis: 127.0.0.1:$WIFI_PORT"
echo "USB Redis:   127.0.0.1:$USBX_PORT"
echo
echo "Press Ctrl-C to stop."

# Exit and clean up if either tunnel terminates.
wait -n "$wifi_ssh_pid" "$usbx_ssh_pid"