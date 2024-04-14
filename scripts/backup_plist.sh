#!/bin/bash

# plist 관리 (백업)

# .chezmoiignore 파일의 내용을 백업합니다.
cp ~/.local/share/chezmoi/.chezmoiignore ~/.local/share/chezmoi/.chezmoiignore.backup

# .chezmoiignore 파일의 내용을 비웁니다.
> ~/.local/share/chezmoi/.chezmoiignore

# /private_Library/private_Preferences 에 존재하는 plist 파일 이름을 가져와서
for file in ~/.local/share/chezmoi/private_Library/private_Preferences/*.plist; do
    # 파일이 심볼릭 링크인지 확인하고, 심볼릭 링크라면 건너뜀
    if [ -L "$file" ]; then
        continue
    fi

    # 파일 이름 추출
    filename=$(basename "$file")

    # 파일을 /Library/Preferences로 복사
    chezmoi add "~/Library/Preferences/$filename"
done

# .chezmoiignore 파일을 원래 상태로 되돌립니다.
cp ~/.local/share/chezmoi/.chezmoiignore.backup ~/.local/share/chezmoi/.chezmoiignore

# 백업 파일을 삭제합니다.
rm ~/.local/share/chezmoi/.chezmoiignore.backup

printf '\nplist backup Done!!\n'