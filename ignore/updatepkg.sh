#!/usr/bin/env bash

set -euo pipefail

stashed=""

stash() {
  git diff-files --quiet
  if [[ $? -eq 1 ]]; then
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

stash
makepkg -cCsrf
git diff-files --quiet

if [[ $? -eq 1 ]]; then
  . PKGBUILD
  git add ./PKGBUILD
  git commit -m "$(basename $(pwd)) $(pkgver)"
  git push
fi

git clean -dff
pop
