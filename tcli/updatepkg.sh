#!/usr/bin/env bash

set -euo pipefail

declare -r myname="updatepkg.sh"
declare -i skipcleanup=0 runstash=0
declare install="" stashed=""

function stash() {
  set +e
  git diff-files --quiet
  result=$?
  set -e
  if [[ $result -eq 1 ]]; then
    git reset
    git stash save -u
    stashed="1"
  fi
}

function pop() {
  if [[ -n "$stashed" ]]; then
    git stash pop
    git reset
  fi
}

function exit() {
  (( skipcleanup )) && return
  git clean -dff
  (( runstash )) && pop
}
trap exit EXIT

function usage() {
  cat << EOF
PKGBUILD builder/installer.

Usage: bash ${myname} [options]

Options:
  -i    install package after build.
  -s    skip cleanup after build.
  -r    stash changes in this repo before starting.
EOF

  exit
}

while getopts :isrh flag; do
  case ${flag} in
    i) install="i" ;;
    s) skipcleanup=1 ;;
    r) runstash=1 ;;
    h) usage ;;
    :) ;;
    ?) ;;
  esac
done

(( runstash )) && stash
makepkg -cCsrf${install}
set +e
git diff-files --quiet
result=$?
set -e

if [[ $result -eq 1 ]]; then
  if [[ ! -f PKGBUILD ]]; then
    echo "PKGBUILD not found."
    exit 1
  fi
  source PKGBUILD
  git add ./PKGBUILD
  git commit -m "$(basename "$(pwd)") ${pkgver}"
  git push
fi
