if [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi
