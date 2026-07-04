export PATH="$HOME/.local/bin:$PATH"

# oh-my-zsh
zstyle ':omz:update' mode auto

plugins=(
  git
  encode64
)

export ZSH="$HOME/.oh-my-zsh"
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi
