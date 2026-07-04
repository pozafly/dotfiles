# homebrew
export PATH="/opt/homebrew/bin:$PATH"

if command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix)"

  [[ -r "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

  [[ -r "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
    source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  fpath+=("$brew_prefix/share/zsh/site-functions")
  autoload -U promptinit; promptinit
  PURE_CMD_MAX_EXEC_TIME=0
  prompt pure
fi

# fnm
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# pnpm
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# fastfetch
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch --logo XeroArch
fi

# Docker CLI
if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# macOS(BSD ls) 컬러 출력 활성화
export CLICOLOR=1

# 컬러 스킴(원하시는 값)
export LSCOLORS=ExFxBxDxCxegedabagacad

# claude code
alias c='claude'
alias cc='claude --dangerously-skip-permissions'
alias cr='claude -r' # 최근대화 목록
alias cs='claude -c' # 이전 대화 이어가기
alias brewup='brew update && brew upgrade --yes'

# tmux 안인지 판별
if [[ -n "$TMUX" ]]; then
  export TERM="screen-256color"
fi

# --- Ghostty: auto attach/create tmux "default" ---
[[ -o interactive ]] || return
[[ -n "$TMUX" ]] && return
[[ "${TERM_PROGRAM:-}" != "ghostty" ]] && return
command -v tmux >/dev/null 2>&1 || return

if tmux has-session -t default 2>/dev/null; then
  exec tmux attach -t default
else
  exec tmux new-session -s default
fi
# --- Ghostty: auto attach/create tmux "default" end ---
