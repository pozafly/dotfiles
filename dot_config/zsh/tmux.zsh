# tmux 안인지 판별
if [[ -n "$TMUX" ]]; then
  export TERM="screen-256color"
fi

# tmux.zsh
# 목적:
# - tmux 자동 attach 없음
# - 특정 명령을 tmux 세션에서 실행하기 위한 최소 래퍼 제공

# tmux가 설치돼 있지 않으면 아무것도 하지 않음
command -v tmux >/dev/null 2>&1 || return


#######################################
# 공통 헬퍼: tmux 밖이면 tmux에서 실행
#
# 사용법:
#   t <session> -- <command ...>
#
# 예:
#   t adhoc -- ssh user@host
#######################################
t() {
  local session="$1"
  shift

  # -- 구분자 처리
  if [[ "$1" == "--" ]]; then
    shift
  fi

  # 이미 tmux 안이면 그냥 실행
  if [[ -n "$TMUX" ]]; then
    command "$@"
    return $?
  fi

  # 세션 없으면 생성
  if ! tmux has-session -t "$session" 2>/dev/null; then
    tmux new-session -d -s "$session"
  fi

  # 새 window에서 명령 실행 (현재 경로 유지)
  tmux new-window -t "$session" -c "$PWD" "$@"

  # tmux로 진입
  exec tmux attach -t "$session"
}


#######################################
# ssh 래퍼
# - tmux 밖에서 ssh 실행하면 tmux에서 실행
#######################################
ssh() {
  if [[ -n "$TMUX" ]]; then
    command ssh "$@"
  else
    t ssh -- ssh "$@"
  fi
}


#######################################
# claude 래퍼 (있을 경우)
#######################################
if command -v claude >/dev/null 2>&1; then
  claude() {
    if [[ -n "$TMUX" ]]; then
      command claude "$@"
    else
      t claude -- claude "$@"
    fi
  }
fi
