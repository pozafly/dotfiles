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

install_fastfetch_from_github() {
  if command -v fastfetch >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v dpkg >/dev/null 2>&1; then
    echo "dpkg not found. Skipping fastfetch GitHub release installation."
    return 0
  fi

  local arch
  arch="$(dpkg --print-architecture)"

  local asset_arch
  case "$arch" in
    amd64) asset_arch="amd64" ;;
    arm64) asset_arch="aarch64" ;;
    armhf) asset_arch="armv7l" ;;
    armel) asset_arch="armv6l" ;;
    i386) asset_arch="i686" ;;
    ppc64el) asset_arch="ppc64le" ;;
    riscv64) asset_arch="riscv64" ;;
    s390x) asset_arch="s390x" ;;
    *)
      echo "Unsupported architecture for fastfetch GitHub release: $arch"
      return 0
      ;;
  esac

  local tmpdir release_json deb_path url
  tmpdir="$(mktemp -d)"
  chmod 755 "$tmpdir"
  release_json="$tmpdir/fastfetch-release.json"
  deb_path="$tmpdir/fastfetch.deb"

  if ! curl -fsSL https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest -o "$release_json"; then
    echo "Failed to fetch fastfetch release metadata. Skipping."
    rm -rf "$tmpdir"
    return 0
  fi

  url="$(sed -n "s/.*\"browser_download_url\": \"\\([^\"]*fastfetch-linux-${asset_arch}\\.deb\\)\".*/\\1/p" "$release_json" | head -n 1)"
  if [ -z "$url" ]; then
    echo "No fastfetch .deb asset found for architecture: $arch"
    rm -rf "$tmpdir"
    return 0
  fi

  if ! curl -fL "$url" -o "$deb_path"; then
    echo "Failed to download fastfetch .deb. Skipping."
    rm -rf "$tmpdir"
    return 0
  fi
  chmod 644 "$deb_path"

  if ! "${sudo_cmd[@]}" apt-get install -y "$deb_path"; then
    echo "Failed to install fastfetch .deb. Continuing."
  fi

  rm -rf "$tmpdir"
}

packages=(zsh git curl ca-certificates)
for package in btop; do
  if apt-cache show "$package" >/dev/null 2>&1; then
    packages+=("$package")
  else
    echo "Package '$package' not found in apt cache. Skipping."
  fi
done

install_fastfetch_after_apt=false
if apt-cache show fastfetch >/dev/null 2>&1; then
  packages+=("fastfetch")
else
  echo "Package 'fastfetch' not found in apt cache. Will try GitHub release .deb after base packages."
  install_fastfetch_after_apt=true
fi

"${sudo_cmd[@]}" apt-get install -y "${packages[@]}"

if [ "$install_fastfetch_after_apt" = true ]; then
  install_fastfetch_from_github
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
