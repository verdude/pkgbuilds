#!/usr/bin/env bash

set -xeuo pipefail

stashed=""

stash() {
  git diff-files --quiet
  test $? -eq 1 && git reset && git stash save -u && stashed="1" ||:
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

pop
