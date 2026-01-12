# 대소문자 무시 + -/_ 등 유사 문자 매칭
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*'

# macOS(BSD ls) 컬러 출력 활성화
export CLICOLOR=1

# 컬러 스킴(원하시는 값)
export LSCOLORS=ExFxBxDxCxegedabagacad
