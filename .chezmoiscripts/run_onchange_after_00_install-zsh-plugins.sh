#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "oh-my-zsh not found. Skipping zsh plugin installation."
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Skipping zsh plugin installation."
  exit 0
fi

plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$plugin_dir"

if [ ! -d "$plugin_dir/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir/zsh-autosuggestions"
fi

if [ ! -d "$plugin_dir/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir/zsh-syntax-highlighting"
fi
