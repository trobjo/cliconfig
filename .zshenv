# Remove path duplicates
typeset -U PATH path
path=("$HOME/.local/bin" "$path[@]")
export PATH

export LESS_TERMCAP_md=$'\E[1;34m'   # Begins bold.
export LESS_TERMCAP_me=$'\E[0m'      # Ends mode.
export LESS="-F -g -i -M -R -w -z-4 -X"
export PAGER=less

export BAT_THEME=base16
# see https://the.exa.website/docs/colour-themes
export LS_COLORS="*.pdf=31:*.PDF=31:*.djvu=31:*.DJVU=31:*.epub=31:*.EPUB=31:di=0;36;3:*.zip=33:*.ZIP=33:*.xz=33:*.XZ=33:*.gz=38;5;215:*.zst=38;5;215:*.tz=38;5;215:*.sublime-package=33:ex=48;5;17:*.jpg=34:*.JPG=34:*.jpeg=34:*.JPEG=34:*.png=34:*.PNG=34:*.webp=34:*.WEBP=34:*.svg=34:*.SVG=34:*.gif=34:*.GIF=34:*.bmp=34:*.BMP=34:*.tif=34:*.TIF=34:*.tiff=34:*.TIFF=34:*.psd=34:*.PSD=34:*.mkv=35:*.mp4=35:*.mov=35:*.mp3=35:*.avi=35:*.mpg=35:*.m4v=35:*.oga=35:*.MKV=35:*.MP4=35:*.MOV=35:*.MP3=35:*.AVI=35:*.MPG=35:*.M4V=35:*.OGA=35:*.doc=36:*.docx=36:*.odt=36:*.ods=36:*.xlsx=36:*.xls=36:*.DOC=36:*.DOCX=36:*.ODT=36:*.ODS=36:*.XLSX=36:*.XLS=36:*.html=38;5;208:*.HTML=38;5;208:*.log=38;5;18:*.LOG=38;5;18:*.md=33;04;01:*.MD=33;04;01"

export RIPGREP_CONFIG_PATH=/home/tb/.config/ripgreprc

export ASPNETCORE_ENVIRONMENT=Development
export Ulrik=Ulrik
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=yes


export ZDOTDIR=(${XDG_CONFIG_HOME:-$HOME/.config}/zsh)

if [[ ! -d ${ZDOTDIR} ]]; then
    INSTALLCMD="rm -f $HOME/.zshenv $HOME/.gitignore &&\
    git clone --bare https://github.com/trobjo/cliconfig $HOME/.cliconfig &&\
    /usr/bin/git --git-dir=$HOME/.cliconfig/ --work-tree=$HOME config --local core.bare false &&\
    /usr/bin/git --git-dir=$HOME/.cliconfig/ --work-tree=$HOME config --local core.worktree "$HOME" &&\
    /usr/bin/git --git-dir=$HOME/.cliconfig/ --work-tree=$HOME checkout &&\
    source $ZDOTDIR/.zshrc"
    printf "run 'eval \$INSTALLCMD' to install the dotfiles\n"
fi
