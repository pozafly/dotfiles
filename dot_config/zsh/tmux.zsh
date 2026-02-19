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
