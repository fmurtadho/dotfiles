#!/bin/sh
# Status kanan tmux: git branch kalau pane ada di repo git, kalau tidak nama folder.
# Dipanggil dari status-right dengan argumen #{pane_current_path}.
cd "$1" 2>/dev/null || exit 0

if branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null); then
  # U+F418 nf-oct-git_branch
  printf '#[fg=#83c092]\357\220\230  #[fg=#9da9a0]%s' "$branch"
else
  name=$(basename "$PWD")
  [ "$PWD" = "$HOME" ] && name="~"
  # U+F07B nf-fa-folder
  printf '#[fg=#83c092]\357\201\273  #[fg=#9da9a0]%s' "$name"
fi
