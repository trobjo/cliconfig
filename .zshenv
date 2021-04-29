# Remove path duplicates
typeset -U PATH path fpath
path=("$HOME/.local/bin" "$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin" "$HOME/.npm/bin" "$path[@]")
export PATH

if [[ $SSH_TTY ]]; then
    export TERM=xterm-256color
fi

export LESS_TERMCAP_md=$'\E[1;34m'   # Begins bold.
export LESS_TERMCAP_me=$'\E[0m'      # Ends mode.
export LESS="-F -g -i -M -R -w -z-4"
export PAGER=less
export SYSTEMD_LESS="FRSMK"

export BAT_THEME=base16
# see https://the.exa.website/docs/colour-themes
export LS_COLORS="*.pdf=31:*.PDF=31:*.djvu=31:*.DJVU=31:*.epub=31:*.EPUB=31:di=0;36;3:ln=0;36;1:*.zip=33:*.ZIP=33:*.xz=33:*.XZ=33:*.gz=38;5;215:*.zst=38;5;215:*.tz=38;5;215:*.sublime-package=33:ex=48;5;17:*.jpg=34:*.JPG=34:*.jpeg=34:*.JPEG=34:*.png=34:*.PNG=34:*.webp=34:*.WEBP=34:*.svg=34:*.SVG=34:*.gif=34:*.GIF=34:*.bmp=34:*.BMP=34:*.tif=34:*.TIF=34:*.tiff=34:*.TIFF=34:*.psd=34:*.PSD=34:*.mkv=35:*.mp4=35:*.mov=35:*.mp3=35:*.avi=35:*.mpg=35:*.m4v=35:*.oga=35:*.MKV=35:*.MP4=35:*.MOV=35:*.MP3=35:*.AVI=35:*.MPG=35:*.M4V=35:*.OGA=35:*.doc=36:*.docx=36:*.odt=36:*.ods=36:*.xlsx=36:*.xls=36:*.DOC=36:*.DOCX=36:*.ODT=36:*.ODS=36:*.XLSX=36:*.XLS=36:*.html=38;5;208:*.HTML=38;5;208:*.log=38;5;18:*.LOG=38;5;18:*.md=33;04;01:*.MD=33;04;01"


export FZF_DEFAULT_COMMAND="/usr/bin/fd --color always --exclude Pictures --exclude Music --exclude node_modules --exclude bin --exclude obj --exclude \*.out --exclude lib --exclude \*.srt --exclude \*.exe"

export FZF_DEFAULT_OPTS="--ansi --bind \"alt-t:page-down,alt-c:page-up,ctrl-e:replace-query,ctrl-b:toggle-all,change:top,alt-w:execute-silent(wl-copy -- {+})+abort,ctrl-/:execute-silent(rm -rf {+})+abort,ctrl-r:toggle-sort,ctrl-q:beginning-of-line+kill-line\" --multi --inline-info --reverse --color=bg+:-1,info:-1,prompt:-1,pointer:4:regular,hl:4,hl+:6,fg+:12,border:19,marker:2:regular --prompt='  '   --marker=❯ --pointer=❯ --margin 0,0 --multi --preview-window=right:50%:sharp:wrap --preview 'if [[ {} =~ \"\.(jpeg|JPEG|jpg|JPG|png|webp|WEBP|PNG|gif|GIF|bmp|BMP|tif|TIF|tiff|TIFF)$\" ]]; then identify -ping -format \"%f\\n%m\\n%w x %h pixels\\n%b\\n\\n%l\\n%c\\n\" {} ; elif [[ {} =~ \"\.(svg|SVG)$\" ]]; then tiv -h \$FZF_PREVIEW_LINES -w \$FZF_PREVIEW_COLUMNS {}; elif [[ {} =~ \"\.(pdf|PDF)$\" ]]; then pdfinfo {}; elif [[ {} =~ \"\.(zip|ZIP|sublime-package)$\" ]]; then zip -sf {};  else bat --style=header,numbers --terminal-width=\$FZF_PREVIEW_COLUMNS --force-colorization --italic-text=always --line-range :70 {} 2>/dev/null || exa -T -L 2 --color=always --long {}; fi'"

export GREP_COLOR='1;38;5;20;48;5;16'

export RIPGREP_CONFIG_PATH="${HOME}/.config/ripgreprc"

export ASPNETCORE_ENVIRONMENT=Development
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

export MSBUILD_EXE_PATH="$HOME/.omnisharp-recent/omnisharp/.msbuild/Current/Bin/MSBuild.exe"
#MONO_CFG_DIR=$HOME/.omnisharp-recent/etc
#MONO_ENV_OPTIONS=--assembly-loader=strict --config $HOME/.omnisharp-recent/etc/config
#MSBuildSDKsPath=/usr/share/dotnet/sdk/5.0.200/
#MSBuildSDKsPath=/usr/local/share/dotnet/sdk/2.2.207



export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

if [[ ! -d ${ZDOTDIR} ]]; then
    export INSTALLCMD="rm -fr $HOME/.zshenv $HOME/.gitignore ${HOME}/.cliconfig &&\
    git clone --depth=1 --bare https://github.com/trobjo/cliconfig $HOME/.cliconfig &&\
    /usr/bin/git --git-dir=$HOME/.cliconfig/ --work-tree=$HOME config --local core.bare false &&\
    /usr/bin/git --git-dir=$HOME/.cliconfig/ --work-tree=$HOME config --local core.worktree "$HOME" &&\
    /usr/bin/git --git-dir=$HOME/.cliconfig/ --work-tree=$HOME checkout &&\
    source $ZDOTDIR/.zshrc"
    printf "run \x1B[1;34meval \$INSTALLCMD\033[0m to install the dotfiles\n\n"
fi
