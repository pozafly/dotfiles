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

## gitconfig

`git config --global core.pager ''` 와 같은 명령어를 사용하면, `~/.gitconfig` 파일에 저장되며 git을 사용할 때 해당 파일을 참조하게 된다. 하지만, `~/.config/git/config` 파일도 동일하게 전역적으로 git 설정을 할 수 있다.
실제로 `git config --list` 를 사용해보면 컴퓨터의 git 설정에 어떤 값이 적용되어있는지 알 수 있는데, `~/.gitconfig` 와 `~/.config/git/config` 둘 다 적용되어 있을 경우 두개의 파일 모두의 설정 값이 한 번에 출력되는 것을 볼 수 있다.
(하지만 우선순위는 `~/.gitconfig` 가 더 높음)
따라서 `~/.gitconfig` 파일을 지우고 chezmoi로 `dot_confit/git/config.tmpl` 파일을 만들어 관리하기로 한다.

마찬가지로 전역 `gitignore`도 생성할 수 있는데, 파일명은 상관 없고 gitconfig의 core에 `excludesfile = {{ .chezmoi.homeDir }}/.gitignore_global` 이와 같이 전역 ignore 파일을 할당해두면 된다.
