참고

- https://songkg7.github.io/posts/chezmoi-awesome-dotfile-manager/
- https://www.chezmoi.io/
- https://github.com/narze/dotfiles(예시)

암호화 참고

- https://blog.lazkani.io/posts/dotfiles-with-chezmoi/

dotfiles 만들기 (https://blog.appkr.dev/work-n-play/dotfiles/)

- brew bundler 등

brew bundle dump 명령어 (vscode 포함시키지 않음)

- `$ brew bundle dump --brews --casks --taps --mas`

<br/>

## macOS 초기화

새 Mac에서는 먼저 App Store에 로그인해 둔다. `Brewfile`에 `mas` 앱이 포함되어 있어서 로그인되어 있지 않으면 App Store 앱 설치가 실패할 수 있다.

암호화된 파일까지 바로 복호화하려면 `age-key.txt`를 홈 디렉터리에 먼저 둔다.

```sh
ls ~/age-key.txt
```

chezmoi 설치와 dotfiles 적용은 한 번에 실행한다.

```sh
export PATH="$HOME/.local/bin:$PATH"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply pozafly
```

이때 `GitHub email`, `GitHub name`을 한 번 물어본다. macOS에서는 `.chezmoi.os == "darwin"`으로 판별되어 macOS 전용 설정이 적용된다.

적용 스크립트는 Homebrew가 없으면 설치하고, `Brewfile` 기준으로 패키지와 앱을 설치한다. 이후 `oh-my-zsh`, `age`, `~/Documents/dev`, `~/.hushlogin`, `.macos` 설정을 처리한다.

적용 후에는 새 터미널을 열고 확인한다.

```sh
chezmoi status
git config --global core.editor
command -v brew
command -v zsh
command -v age
```

이미 chezmoi가 설치된 Mac이라면 repo 변경사항을 가져오고 적용한다.

```sh
chezmoi update
```

<br/>

## Linux 적용

처음 들어가는 Linux에서 `curl`이 없다면 먼저 설치한다.

```sh
sudo apt-get update
sudo apt-get install -y curl ca-certificates
```

root로 들어간 LXC처럼 `sudo`가 없다면 `sudo`만 빼고 실행한다.

```sh
apt-get update
apt-get install -y curl ca-certificates
```

chezmoi 설치와 dotfiles 적용은 한 번에 실행한다.

```sh
export PATH="$HOME/.local/bin:$PATH"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply pozafly
```

이때 `GitHub email`, `GitHub name`을 한 번 물어본다. `env` 값은 쓰지 않는다. OS 분기는 chezmoi가 자동으로 제공하는 `.chezmoi.os`만 사용한다.

Linux에서 현재 적용되는 핵심 설정은 `~/.zshrc`, `~/.config/git`, `~/.config/btop`이다. `fastfetch`는 명령어만 설치하고 설정 파일은 가져가지 않으며, interactive zsh가 열릴 때 기본 설정으로 실행한다.

적용 스크립트는 Debian/Ubuntu 계열처럼 `apt-get`이 있는 환경에서 `zsh`, `git`, `curl`, `ca-certificates`를 설치한다. `btop`은 apt 저장소에 있을 때 설치한다. `fastfetch`는 apt 저장소에 있으면 apt로 설치하고, 없으면 GitHub release의 `.deb` 파일로 설치를 시도한다. 이후 `oh-my-zsh`와 `zsh-autosuggestions`, `zsh-syntax-highlighting`을 설치한다.

SSH로 접속했을 때 바로 zsh를 쓰려면 login shell을 바꾼다. dotfiles 적용 스크립트는 shell을 자동 변경하지 않는다.

```sh
chsh -s "$(command -v zsh)"
```

`chsh`가 없거나 root 계정에서 직접 바꿔야 하면 아래처럼 바꾼다.

```sh
usermod -s "$(command -v zsh)" "$USER"
```

적용 후에는 재접속하고 확인한다.

```sh
echo "$SHELL"
echo "$0"
locale
zsh -i -c 'echo zsh ok'
chezmoi status
git config --global core.editor
command -v btop
command -v fastfetch
```

이미 chezmoi가 설치된 Linux라면 repo 변경사항을 가져오고 적용한다.

```sh
chezmoi update
```

예전 명령으로 설치해서 `~/bin/chezmoi`에 바이너리가 생긴 상태라면, 한 번만 아래처럼 실행해도 된다.

```sh
~/bin/chezmoi update
```

<br/>

## macOS / Linux 분기

chezmoi의 자동 값인 `.chezmoi.os`를 사용해 OS별 적용 대상을 나눈다.

- macOS: `.chezmoi.os == "darwin"`
- Linux: `.chezmoi.os == "linux"`

분기 기준은 `.chezmoiignore.tmpl`와 템플릿 파일에 있다. Linux에서는 macOS 전용 파일을 제외하고, macOS에서는 Linux 전용 파일을 제외한다.

zsh는 chezmoi 공식 문서의 `include` 방식으로 나눈다.

- `dot_zshrc.tmpl`: OS를 판별하고 아래 파일 중 하나를 include
- `.zshrc_darwin`: macOS에서 렌더링될 `~/.zshrc`
- `.zshrc_linux`: Linux에서 렌더링될 `~/.zshrc`

예를 들어 Linux에서는 `dot_zshrc.tmpl`이 `.zshrc_linux`를 include해서 `~/.zshrc`를 만든다.

git 설정은 macOS와 Linux 둘 다 적용한다. 단, `dot_config/git/config.tmpl`에서 editor만 OS별로 다르게 렌더링한다.

수정할 때는 source state를 먼저 수정하고 실제 파일에 적용한다. 예를 들어 macOS 전용 zsh 설정을 수정하려면:

```sh
chezmoi cd
code .zshrc_darwin
chezmoi diff
chezmoi apply
```

Linux 전용 zsh 설정도 같은 방식으로 수정한다.

```sh
chezmoi cd
code .zshrc_linux
chezmoi diff
chezmoi apply
```

Linux 기준으로 어떤 파일이 관리되는지 macOS에서도 미리 확인할 수 있다.

```sh
chezmoi --override-data '{"chezmoi":{"os":"linux"}}' managed | sort
```

<br/>

## 설정 파일 관리

.chezmoi.toml.tmpl에는 아래와 같이 적혀 있음.

```toml
{{- $email := promptStringOnce . "email" "GitHub email" -}}
{{- $name := promptStringOnce . "name" "GitHub name" -}}

[data]
  email = {{ $email | quote }}
  name = {{ $name | quote }}
```

`chezmoi init` 명령어를 치면 GitHub email과 GitHub name을 물어본다. 입력한 값은 로컬 컴퓨터의 `~/.config/chezmoi/chezmoi.toml` 파일에 `email`, `name` 키로 저장되고, 템플릿에서 `{{ .chezmoi.config.data.name }}` 같은 값으로 사용할 수 있다.

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
`$ chezmoi add --encrypt ~/.ssh/id_ed25519` 그러면 `encrypted_private_id_ed25519.age` 파일이 dot_config/private_dot_ssh 경로에 생성된다. 이 비밀 키는 아까 생성한 age-key.txt로 복호화 할 수 있다. 공개키는 이미 GitHub에 올라가 있을 것이기 때문에 문제가 되지 않는다.

<br/>
