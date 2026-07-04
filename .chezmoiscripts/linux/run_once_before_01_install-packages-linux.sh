#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Linux" ]; then
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. Skipping Linux package installation."
  exit 0
fi

sudo_cmd=()
if [ "$(id -u)" -ne 0 ]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo not found. Install packages as root or install sudo first."
    exit 1
  fi
  sudo_cmd=(sudo)
fi

"${sudo_cmd[@]}" apt-get update

packages=(zsh git curl ca-certificates)
for package in btop fastfetch; do
  if apt-cache show "$package" >/dev/null 2>&1; then
    packages+=("$package")
  else
    echo "Package '$package' not found in apt cache. Skipping."
  fi
done

"${sudo_cmd[@]}" apt-get install -y "${packages[@]}"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
