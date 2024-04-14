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

그리고 `.chezmoi.toml.tmpl` 파일을 변경했다면 `$ chezmoi init` 명령어를 통해 반드시 초기화 시켜주어야만 local의 `~/.config/chezmoi/chezmoi.toml` 파일이 변경된다.

<br/>

## gitconfig

`git config --global core.pager ''` 와 같은 명령어를 사용하면, `~/.gitconfig` 파일에 저장되며 git을 사용할 때 해당 파일을 참조하게 된다. 하지만, `~/.config/git/config` 파일도 동일하게 전역적으로 git 설정을 할 수 있다.
실제로 `git config --list` 를 사용해보면 컴퓨터의 git 설정에 어떤 값이 적용되어있는지 알 수 있는데, `~/.gitconfig` 와 `~/.config/git/config` 둘 다 적용되어 있을 경우 두개의 파일 모두의 설정 값이 한 번에 출력되는 것을 볼 수 있다.
(하지만 우선순위는 `~/.gitconfig` 가 더 높음)
따라서 `~/.gitconfig` 파일을 지우고 chezmoi로 `dot_confit/git/config.tmpl` 파일을 만들어 관리하기로 한다.

마찬가지로 전역 `gitignore`도 생성할 수 있는데, 파일명은 상관 없고 gitconfig의 core에 `excludesfile = {{ .chezmoi.homeDir }}/.gitignore_global` 이와 같이 전역 ignore 파일을 할당해두면 된다.

<br/>

## encryption

age를 사용할 것이다.

`$ age-keygen -o ~/age-key.txt` 명령어를 사용하면 아래와 같이 공개 키를 준다.
Public key: age1k3dd5wtylpz6um3wz2sgyr6ek0zn4mvc8mknaf9tjdjxh7n953psf8gw40

`$ cat age-key.txt` 출럭해보면, 생성 날짜와 공개 키, 비밀 키를 보여준다. 비밀 키는 다른 컴퓨터 환경에서 앞으로 age로 암호화 할 파일을 복호화해 사용할 것이므로 반드시 가지고 있어야 한다. ~/.config/chezmoi/chezmoi.toml에 아래와 같이 암호화가 필요한 파일명을 적어준다.

```toml
encryption = "age"
[age]
    identity = "./age-key.txt"
    recipient = "age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p"
```

그리고 git ssh 비밀키를 암호화 하자.
`$ chezmoi add --encrypt ~/.ssh/id_ed25519` 그러면 `encrypted_private_id_ed25519.age` 파일이 dot_config/private_dot_ssh 경로에 생성된다. 이 비밀 키는 아까 생성한 age-key.txt로 복호화 할 수 있다.
