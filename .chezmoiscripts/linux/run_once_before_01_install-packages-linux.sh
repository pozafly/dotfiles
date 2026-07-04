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

install_btop_from_github() {
  if ! command -v tar >/dev/null 2>&1; then
    echo "tar not found. Skipping btop GitHub release installation."
    return 0
  fi

  local machine
  machine="$(uname -m)"

  local asset_arch
  case "$machine" in
    x86_64|amd64) asset_arch="x86_64" ;;
    aarch64|arm64) asset_arch="aarch64" ;;
    armv7l) asset_arch="armv7" ;;
    armv6l) asset_arch="arm" ;;
    i686) asset_arch="i686" ;;
    i386|i586) asset_arch="i586" ;;
    m68k) asset_arch="m68k" ;;
    mips64) asset_arch="mips64" ;;
    ppc64|powerpc64) asset_arch="powerpc64" ;;
    riscv64) asset_arch="riscv64" ;;
    s390x) asset_arch="s390x" ;;
    *)
      echo "Unsupported architecture for btop GitHub release: $machine"
      return 0
      ;;
  esac

  local tmpdir release_json archive_path url
  tmpdir="$(mktemp -d)"
  chmod 755 "$tmpdir"
  release_json="$tmpdir/btop-release.json"
  archive_path="$tmpdir/btop.tar.gz"

  if ! curl -fsSL https://api.github.com/repos/aristocratos/btop/releases/latest -o "$release_json"; then
    echo "Failed to fetch btop release metadata. Skipping."
    rm -rf "$tmpdir"
    return 0
  fi

  url="$(sed -n "s/.*\"browser_download_url\": \"\\([^\"]*btop-${asset_arch}[^\"/]*linux-musl[^\"]*\\.tar\\.gz\\)\".*/\\1/p" "$release_json" | head -n 1)"
  if [ -z "$url" ]; then
    echo "No btop tar.gz asset found for architecture: $machine"
    rm -rf "$tmpdir"
    return 0
  fi

  if ! curl -fL "$url" -o "$archive_path"; then
    echo "Failed to download btop tar.gz. Skipping."
    rm -rf "$tmpdir"
    return 0
  fi
  chmod 644 "$archive_path"

  if ! tar -xzf "$archive_path" -C "$tmpdir"; then
    echo "Failed to extract btop tar.gz. Skipping."
    rm -rf "$tmpdir"
    return 0
  fi

  if [ ! -x "$tmpdir/btop/bin/btop" ]; then
    echo "Downloaded btop archive did not contain bin/btop. Skipping."
    rm -rf "$tmpdir"
    return 0
  fi

  "${sudo_cmd[@]}" install -D -m 755 "$tmpdir/btop/bin/btop" /usr/local/bin/btop
  if [ -d "$tmpdir/btop/themes" ]; then
    "${sudo_cmd[@]}" install -d -m 755 /usr/local/share/btop/themes
    "${sudo_cmd[@]}" cp "$tmpdir"/btop/themes/*.theme /usr/local/share/btop/themes/
    "${sudo_cmd[@]}" chmod 644 /usr/local/share/btop/themes/*.theme
  fi

  rm -rf "$tmpdir"
}

packages=(zsh git curl ca-certificates)

install_fastfetch_after_apt=false
if apt-cache show fastfetch >/dev/null 2>&1; then
  packages+=("fastfetch")
else
  echo "Package 'fastfetch' not found in apt cache. Will try GitHub release .deb after base packages."
  install_fastfetch_after_apt=true
fi

"${sudo_cmd[@]}" apt-get install -y "${packages[@]}"

install_btop_from_github

if [ "$install_fastfetch_after_apt" = true ]; then
  install_fastfetch_from_github
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
