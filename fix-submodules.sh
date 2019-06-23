#!/bin/sh
#
# Git clones submodules as "detached head". This fixes that so they're
# checked out to a branch.

branch_name=$(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)
git submodule foreach -q --recursive 'git checkout $branch_name'
