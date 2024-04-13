참고

- https://songkg7.github.io/posts/chezmoi-awesome-dotfile-manager/
- https://www.chezmoi.io/

암호화 참고

- https://blog.lazkani.io/posts/dotfiles-with-chezmoi/

설치 스크립트 실행 명령어

- $ sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply pozafly

dotfiles 만들기 (https://blog.appkr.dev/work-n-play/dotfiles/)

- brew bundler 등

brew bundle dump 명령어 (vscode 포함시키지 않음)

- `$ brew bundle dump --brews --casks --taps --mas`

<br/>

## 설정 파일 관리

.chezmoi.toml.tmpl에는 아래와 같이 적혀 있음.

```toml
{{- $email := promptStringOnce . "email" "Email address" -}}
{{- $name := promptStringOnce . "name" "Name" -}}

[data]
  email = {{ $email | quote }}
  name = {{ $name | quote }}
```

`chezmoi init` 명령어를 치면, email과, name을 물어보는게 차례로 나타나고, 적으면 실제 로컬 컴퓨터에 `~/.config/chezmoi/chezmoi.toml` 파일에 방금 입력한 데이터가 치환되어 들어가게 된다.

<br/>
