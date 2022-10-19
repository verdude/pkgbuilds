#!/usr/bin/env bash

set -euo pipefail

stashed=""
install=""

while getopts i flag
do
  case ${flag} in
    i) install="i";;
  esac
done

stash() {
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

pop() {
  if [[ -n "$stashed" ]]; then
    git stash pop
    git reset
  fi
}

function exit() {
  git clean -dff
  pop
}
trap exit EXIT

stash
makepkg -cCsrf$install
set +e
git diff-files --quiet
result=$?
set -e

if [[ $result -eq 1 ]]; then
  . PKGBUILD
  git add ./PKGBUILD
  git commit -m "$(basename $(pwd)) ${pkgver}"
  git push
fi
