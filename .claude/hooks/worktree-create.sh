#!/usr/bin/env bash

# MIT Copyright (C) 2026 Nikolas Schröter. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the “Software”), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

set -e

###
# Prints the folder for new worktrees, next to the worktree that Claude Code started in.
# Repositories that are not bare keep the default of Claude Code.
#
# @since 1.0.0
# @category Utils
##
__worktree_root() {
  if [ "$( git config --bool core.bare )" != "true" ]; then
    echo "$PWD/.claude/worktrees"
  elif [ "$( git -C "$CLAUDE_PROJECT_DIR" rev-parse --is-inside-work-tree )" = "true" ]; then
    dirname -- "$( git -C "$CLAUDE_PROJECT_DIR" rev-parse --show-toplevel )"
  else
    echo "$CLAUDE_PROJECT_DIR"
  fi
}

###
# Creates the worktree that Claude Code asks for and prints its path.
# Existing folders are reused, and new ones get a mark for the remove hook.
#
# @since 1.0.0
# @category Utils
##
__worktree_create() {
  local name="$( jq -r '.name' )"
  local root="$( __worktree_root )"
  local dir="$root/$name"

  if [ -e "$dir" ]; then
    echo "$dir"
    return
  fi

  if ! git show-ref --quiet "refs/heads/$name" "refs/remotes/origin/$name"; then
    git branch "$name"
  fi

  git worktree add "$dir" "$name" >&2
  touch "$( git -C "$dir" rev-parse --path-format=absolute --git-path claude-hook-created )"

  echo "$dir"
}

__worktree_create
