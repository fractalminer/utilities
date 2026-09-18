#!/bin/bash
# ---------------------------------------------------------------
# libxdelta3
# ---------------------------------------------------------------
set -eE
set -o pipefail

# Must be done first.
this=$(cd $(dirname $0) && pwd)
cd $this

# ---------------------------------------------------------------
# Includes
# ---------------------------------------------------------------
source util.sh

# ---------------------------------------------------------------
# Initialization
# ---------------------------------------------------------------
# This must be a lowercase short word with no spaces describing
# the software being built. Folders/links will be named with
# this.
project_key="libxdelta3"
bin_name="xdelta3"

tools="$HOME/dev/tools"
mkdir -p "$tools"

# ---------------------------------------------------------------
# Create Work Area
# ---------------------------------------------------------------
cd /tmp

work=$project_key-build

[[ -d $work ]] && /bin/rm -rf "$work"
mkdir -p $work
cd $work

# ---------------------------------------------------------------
# Functions
# ---------------------------------------------------------------
latest_github_repo_tag() {
    local acct="$1"
    local repo="$2"
    local api_url="https://api.github.com/repos/$acct/$repo/tags"
    # FROM: "name": "v8.1.0338",
    # TO:   v8.1.0338
    curl --silent $api_url | grep '"name":'       \
                           | head -n1             \
                           | sed 's/.*: "\(.*\)".*/\1/'
}

clone_latest_tag() {
    local acct="$1"
    local repo="$2"
    # non-local
    version=$(latest_github_repo_tag $acct $repo)
    log "latest version of $acct/$repo: $version"
    sleep 3
    git clone --depth=1         \
              --branch=$version \
              --recursive       \
              https://github.com/$acct/$repo
}

# ---------------------------------------------------------------
# Project specific post-install steps.
# ---------------------------------------------------------------
supplemental_install() {
    [[ -n "$prefix" ]]
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/include"
    mkdir -p "$HOME/.local/lib"
    ln -sf "$prefix/bin/xdelta3"       "$HOME/.local/bin/xdelta3"
    ln -sf "$prefix/include/xdelta3.h" "$HOME/.local/include/xdelta3.h"
    ln -sf "$prefix/lib/libxdelta3.a"  "$HOME/.local/lib/libxdelta3.a"
}

# ---------------------------------------------------------------
# Check version and if it already exists.
# ---------------------------------------------------------------
acct="jmacd"
repo="xdelta"

version=$(latest_github_repo_tag $acct $repo)
prefix="$tools/$project_key-$version"

[[ -e "$tools/$project_key-$version" ]] && {
    log "$project_key-$version already exists, activating it."
    tools_link $project_key
    bin_links $project_key $bin_name
    supplemental_install
    exit 0
}

log "latest version: $version"

# ---------------------------------------------------------------
# Clone Repo
# ---------------------------------------------------------------
clone_latest_tag "$acct" "$repo"
cd $repo

# ---------------------------------------------------------------
# Configure
# ---------------------------------------------------------------
cd xdelta3
mkdir build
cd build
run_cmake ..                        \
         -G Ninja                   \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=$prefix

# ---------------------------------------------------------------
# Build
# ---------------------------------------------------------------
ninja

# ---------------------------------------------------------------
# Test
# ---------------------------------------------------------------
ninja test

# ---------------------------------------------------------------
# Install
# ---------------------------------------------------------------
ninja install

# ---------------------------------------------------------------
# Test Run
# ---------------------------------------------------------------
# For some reason xdelta3 returns an error when run with no args.
{ $prefix/bin/xdelta3 --version 2>&1 || true; } | grep "Xdelta version"

# ---------------------------------------------------------------
# Make Links
# ---------------------------------------------------------------
tools_link $project_key
bin_links $project_key $bin_name

# ---------------------------------------------------------------
# Extra custom install steps.
# ---------------------------------------------------------------
supplemental_install

# ---------------------------------------------------------------
# Finish
# ---------------------------------------------------------------
log "success."
