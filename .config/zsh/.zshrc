# rehash path after pacman installation
TRAPUSR1() { rehash }

#
# INPUT/OUTPUT
#

WORDCHARS=${WORDCHARS//[\/\.&=-]}

bindkey '^[[3~' delete-char
bindkey "^[[Z" reverse-menu-complete

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A'  up-line-or-beginning-search    # Arrow up
bindkey '^[OA'  up-line-or-beginning-search
bindkey '^[[B'  down-line-or-beginning-search  # Arrow down
bindkey '^[OB'  down-line-or-beginning-search

forward-word() { [ $POSTDISPLAY ] && zle .forward-word || zle vi-forward-blank-word }
zle -N forward-word
bindkey "^[b" vi-backward-blank-word

# Use smart URL pasting and escaping.
autoload -Uz bracketed-paste-url-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-url-magic
zle -N self-insert url-quote-magic

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  # Enable application mode when zle is active
  start-application-mode() {
    echoti smkx
}
stop-application-mode() {
    echoti rmkx
}

autoload -Uz add-zle-hook-widget && \
add-zle-hook-widget -Uz line-init start-application-mode && \
add-zle-hook-widget -Uz line-finish stop-application-mode
fi


#
# HISTORY
#

# do not add incorrect commands to history
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

# History.
HISTFILE="$ZDOTDIR/zhistory"
HISTSIZE=100000
SAVEHIST=10000
HISTORY_IGNORE='([bf]g *|[bf]g|disown|cd ..|cd -)' # Don't add these to the history file.
setopt appendhistory notify
unsetopt beep nomatch
setopt histignorespace

setopt bang_hist                # Treat The '!' Character Specially During Expansion.
setopt inc_append_history       # Write To The History File Immediately, Not When The Shell Exits.
setopt share_history            # Share History Between All Sessions.
setopt hist_expire_dups_first   # Expire A Duplicate Event First When Trimming History.
setopt hist_ignore_dups         # Do Not Record An Event That Was Just Recorded Again.
setopt hist_ignore_all_dups     # Delete An Old Recorded Event If A New Event Is A Duplicate.
setopt hist_find_no_dups        # Do Not Display A Previously Found Event.
setopt extended_history         # Show Timestamp In History.

# - - - - - - - - - - - - - - - - - - - -

autoload -U colors && colors    # Load Colors.

zle_highlight=(region:bg=17 special:bg=17
               suffix:bg=17 paste:bg=17 isearch:bg=17)

setopt no_case_glob             # Make globbing case insensitive.
setopt extendedglob             # Use Extended Globbing.
setopt autocd                   # Automatically Change Directory If A Directory Is Entered.
LISTMAX=999                     # Disable 'do you wish to see all %d possibilities'


# Completion Options.
setopt complete_in_word         # Complete From Both Ends Of A Word.
setopt always_to_end            # Move Cursor To The End Of A Completed Word.
setopt path_dirs                # Perform Path Search Even On Command Names With Slashes.
setopt auto_menu                # Show Completion Menu On A Successive Tab Press.
setopt auto_list                # Automatically List Choices On Ambiguous Completion.
setopt auto_param_slash         # If Completed Parameter Is A Directory, Add A Trailing Slash.
setopt no_complete_aliases

setopt auto_resume              # Attempt To Resume Existing Job Before Creating A New Process.
setopt no_beep                  # Don't beep
setopt no_bg_nice               # Don't frob with nicelevels
setopt no_flow_control          # Disable ^S, ^Q, ^\ #
stty -ixon quit undef           # For Vim etc; above is just for zsh.

#
## ALIASES
#

alias -g sf='"$(subl --command doas_edit; cat /tmp/doasedit)"'

alias ports='doas /usr/bin/netstat -tunlp'
if command -v pacman &> /dev/null
then
    alias Syu='doas pacman -Syu'
    alias mus='ncmpcpp -q'
    alias S='doas pacman -S'
    alias U='doas pacman -U'
    alias Sy='doas pacman -Sy'
    alias Ss='yay -Ss'
    alias Rsn='doas pacman -Rsn'
    alias Rns='doas pacman -Rsn'
    alias Rdd='doas pacman -Rdd'
    alias Qs='pacman -Qs'
    # list packages owned by
    alias Qo='pacman -Qo'
    alias Qqs='pacman -Qqs'
    alias Qq='pacman -Qq'
    alias Qtdq='doas pacman -Rsn $(pacman -Qtdq)'
else
    alias -g Syu='sudo apt update && sudo apt upgrade'
    alias -g S='sudo apt install'
    alias U='dpkg -i'
    alias Sy='sudo apt update && sudo apt install'
    alias Ss='apt search'
    alias Rsn='sudo apt purge'
    alias Rns='sudo apt purge'
    alias Rdd='sudo dpkg -r --force-depends'
    alias -g Qs='apt list --installed | rg'
    alias Qo='dpkg -S'
    alias Qq='apt list --installed'
    alias Qtdq='sudo apt autoremove'
fi

if [ -n $SWAYSOCK ]; then
    alias reboot='dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Reboot" boolean:true'
    alias swaymsg='noglob swaymsg'
    # alias toggleTP='swaymsg input "1739:52552:SYNA1D31:00_06CB:CD48_Touchpad" events toggle disabled enabled'
    alias dvorak='swaymsg input "1:1:AT_Translated_Set_2_keyboard" xkb_layout us(dvorak)'
    alias qwerty='swaymsg input "1:1:AT_Translated_Set_2_keyboard" xkb_layout us'
fi

[ -d $HOME/.cliconfig ] && alias cliconfig='/usr/bin/git --git-dir=$HOME/.cliconfig/ --work-tree=$HOME'

if command -v exa &> /dev/null
then
    alias e='exa --group-directories-first'
    alias es='exa --sort=oldest --long --git'
    alias ee='exa --group-directories-first --long --git'
    alias ea='exa --group-directories-first --long --git --all'
else
    alias e='ls --color=auto --group-directories-first'
    alias es='ls --color=auto -lt --human-readable'
    alias ee='ls --color=auto --no-group --group-directories-first -l --human-readable'
    alias ea='ls --color=auto --group-directories-first --all --human-readable'
fi

alias rgg='rg --no-ignore-vcs --hidden'
alias fdd='fd --no-ignore-vcs --hidden'
alias has='transmission-remote -l'
alias df='df -h'
alias findip='curl -s icanhazip.com | tee >(wl-copy -n -- 2> /dev/null); return 0'
alias ssh='TERM=xterm-256color /usr/bin/ssh'
alias grep='grep --color=auto'


# Git aliases
alias gs='git status --porcelain --short'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gb='git branch'
alias gd='git diff'
alias ga='git add'
alias gap='git add -p'
alias gl='git log'
alias gcam='git commit -am'
alias gcm='git commit -m'
alias gpull='git pull --rebase'
alias gpush='git push'
alias gdn='git diff --name-only'
alias gdc='git diff --cached'
alias gdcn='git diff --cached --name-only'
alias gcfh='git diff-tree --no-commit-id --name-only -r HEAD'
alias gcf='git diff-tree --no-commit-id --name-only -r' #show changed files
alias gcoi='git diff --name-only | xargs -n 1 -p git checkout'
alias gri='git diff --cached --name-only | xargs -n 1 -p git reset HEAD'
alias gai='git diff --name-only | xargs -n 1 -p git add'
alias gluf='git ls-files --others --exclude-standard'
alias ggn='git grep -n'
alias gf='git fetch'

alias commit='swaymsg [app_id="^PopUp$"] move scratchpad\; [app_id="^subl$"] focus > /dev/null 2>&1; git commit -v; swaymsg [app_id="^PopUp$"] scratchpad show, fullscreen disable, move position center, resize set width 100ppt height 100ppt, resize grow width 2px, resize shrink up 1100px, resize grow up 340px, move down 1px'
alias push='git push'
alias add='git add'
alias pull='git pull --rebase'

# stdout in sublime or less, or clipboard
alias -g CC=' |& tee /dev/tty |& wl-copy -n'
if [[ $SSH_TTY ]]; then
    alias -g SS=' |& rmate -'
else
    alias -g SS=' |& subl -'
fi
alias -g LL=' |& less'
if command -v rg &> /dev/null; then
    alias -g G=' |& rg'
else
    alias -g G=' |& grep --color=auto'
fi
alias -g jsonl=' | jq -C "." | less -R'
alias -g jqc=' | jq -C "."'

# I always forget how to redirect
alias -g silent="> /dev/null 2>&1"
alias -g noerr="2> /dev/null"
alias -g onerr="1> /dev/null"
alias -g stdboth="2>&1"

change_font_size() {
     sed -r -i -e\
     "/font_size/s/$1/$2/" \
     $XDG_CONFIG_HOME/sublime-text/Packages/User/Preferences.sublime-settings
     sed -r -i -e\
     "/size: $1/s/$1/$2/" \
     $XDG_CONFIG_HOME/alacritty/alacritty.yml
}

_psql() {
     if [[ ${1:0:1} == "d" ]]; then
          myQuery="\\$@"
     else
          myQuery="$@"
     fi
     [[ -z ${PSQL_DB} ]] && print "PSQL_DB is unset" && return 1
     psql -U ${PSQL_USER:-postgres} -d ${PSQL_DB} <<< "$myQuery"
}
alias p='noglob _psql'

alias screen_share='change_font_size 9 19'
alias no_screen_share='change_font_size 19 9'

gch() {
     [ ! -d "${HOME}/gi" ] && mkdir -p "${HOME}/gi"
     if [[ "$PWD" == "$HOME" ]]; then
          cd "${HOME}/gi"
     fi

     if [[ "${#@}" -lt 1 ]]; then
          repo="$(wl-paste -n)"
     else
          repo="$1"
     fi

     if [[ "$repo" == *github.com* ]] && [[ ${repo:0:3} != "git" ]]; then
          # we are cloning from github, therefore automatically use ssh.
          repo="git@github.com:${${repo##*github.com/}%*/}.git"
     fi

     git clone "${repo}" &&\
     cd "${${${repo/%\//}##*/}//.git/}"
     # the expr is read inside out. First, if the last char is '/' ('%' means last) we replace it with ''.
     # then we remove everything before the last '/' (string has now mutated), and finally, if the string
     # ends with .git, we remove that
}


curlie() {
     local -a myargs
     for string in $@; do
          if [[ $string == http* ]]; then
               string=${string:gs/ /\%20}
          fi
          myargs+=$string
     done
     /usr/bin/curlie $myargs
}

activate() {
     if [[ "${#@}" -eq 1 ]]; then
          source "${1}/bin/activate" && return 0
          return 1
     fi
     typeset -aU venvs
     for file in ./.**/pyvenv.cfg; do
          if [[ -f "$file" ]]; then
               venvs+="${file%/*}"
          fi
     done
     if [[ "${#venvs}" -eq 1 ]]; then
          source "${venvs[@]:0}/bin/activate"
          _OLD_VIRTUAL_PS1="$PROMPT"
          export PROMPT="%2F%B(${VIRTUAL_ENV##/*/}) %b$PROMPT"
     elif [[ "${#venvs}" -gt 1 ]]; then
          print "More than one venv: \x1b[3m${venvs[@]##*/}\e[0m"
          return 1
     elif [[ "${#venvs}" -eq 0 ]]; then
          print "No venv: \x1b[3m${venvs[@]##*/}\e[0m"
          return 1
     fi
}

# disable python's built in manipulation of the prompt in favor of our own
export VIRTUAL_ENV_DISABLE_PROMPT=1


if [[ ! -d ${ZDOTDIR}/plugins ]]; then
    git clone --depth=1 https://github.com/trobjo/zsh-plugin-manager 2> /dev/null "${ZDOTDIR}/plugins/trobjo/zsh-plugin-manager"
    command chmod g-rwX "${ZDOTDIR}/plugins"
    [ ! -d "${HOME}/.local/bin" ] && mkdir -p "${HOME}/.local/bin"
fi
source "${ZDOTDIR}/plugins/trobjo/zsh-plugin-manager/zsh-plugin-manager.zsh"
# source "/user/code/zsh-plugin-manager/zsh-plugin-manager.zsh"


cdpath=("${XDG_CONFIG_HOME}/zsh" "${HOME}/gi" "${HOME}")

plug trobjo/zsh-completions
plug romkatv/gitstatus, defer:'-m'
# plug zsh-users/zsh-syntax-highlighting
plug zdharma/fast-syntax-highlighting
plug 'zsh-users/zsh-autosuggestions',\
     postload:'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=5,underline',\
     postload:'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(go_home bracketed-paste-url-magic url-quote-magic
              repeat-last-command-or-complete-entry expand-or-complete)'
plug trobjo/zsh-autosuggestions-override,\
     defer:'-m',\
     if:'[[ $ZSH_AUTOSUGGEST_CLEAR_WIDGETS ]]'
plug trobjo/ZshGotoSublimeCurrentDir,\
     where:'$XDG_CONFIG_HOME/sublime-text/Packages/ZshGotoSublimeCurrentDir',\
     defer:'-m',\
     if:'command -v subl'
plug trobjo/zsh-goodies,\
     defer:'-m'
plug trobjo/zsh-wayland-utils,\
     defer:'-m',\
     if:'[[ $WAYLAND_DISPLAY ]]'
plug trobjo/zsh-file-opener,\
     preload:'_ZSH_FILE_OPENER_CMD=u',\
     where:'/user/code/zsh-file-opener',\
     preload:'_ZSH_FILE_OPENER_EXCLUDE_SUFFIXES=srt,part,ytdl,vtt,log,zwc,dll,otf,ttf,iso,img,mobi',\
     if:'[[ $WAYLAND_DISPLAY ]]',\
     defer:'-m'
plug 'https://raw.githubusercontent.com/aurora/rmate/master/rmate',\
     if:'[[ $SSH_TTY ]]',\
     where:'$HOME/.local/bin/rmate',\
     ignore,\
     postload:'alias u="_file_opener"',\
     postload:'_file_opener() {cd "\$@" > /dev/null 2>&1 && return 0; [[ -d "\$1" ]] && [[ ! -r "\$1" ]] && echo "Permission denied: \$1" && return 1; [[ -w "\$@" ]] && \$HOME/.local/bin/rmate "\$@" || sudo \$HOME/.local/bin/rmate "\$@"}'
plug skywind3000/z.lua,\
     if:'command -v lua',\
     preload:'export _ZL_CMD=h',\
     preload:'export _ZL_DATA=${ZDOTDIR}/zlua_data',\
     ignore,\
     postload:'_zlua_precmd() {(czmod --add "\${PWD:a}" &) }',\
     postload:'$(lua ${plugin_location}/z.lua --init zsh enhanced once)'
plug 'https://raw.githubusercontent.com/trobjo/czmod-compiled/master/czmod',\
     if:'command -v lua',\
     where:'$HOME/.local/bin/czmod',\
     ignore
plug le0me55i/zsh-extract,\
     if:'[[ $SSH_TTY ]]',\
     defer:'-m'
plug 'https://github.com/junegunn/fzf/releases/download/0.27.1/fzf-0.27.1-linux_amd64.tar.gz',\
     if:'! command -v fzf',\
     where:'$HOME/.local/bin/fzf',\
     ignore
plug 'https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb',\
     if:'! command -v rg && command -v apt',\
     ignore,\
     postinstall:'rm ${filename}'
plug 'https://github.com/sharkdp/fd/releases/download/v8.2.1/fd_8.2.1_amd64.deb',\
     if:'! command -v fd && command -v apt',\
     ignore,\
     postinstall:'rm ${filename}'
plug wfxr/forgit,\
     defer:'-m',\
     if:'command -v fzf'
plug trobjo/zsh-fzf-functions,\
     defer:'-m',\
     if:'command -v fzf && command -v fd'
plug trobjo/zsh-multimedia,\
     if:'[[ ! $SSH_TTY ]]',\
     defer:'-m'
plug trobjo/zsh-prompt-compact,\
     defer:'-1',\
     where:'/user/code/zsh-prompt-compact',\
     preload:'setopt no_prompt_bang prompt_percent prompt_subst',\
     preload:'PROMPT=""',\
     preload:'[ $PopUp ] && PROHIBIT_TERM_TITLE=true',\
     preload:'READ_ONLY_ICON=""'
# plug trobjo/Sublime-Text-Config,\
#      where:'$XDG_CONFIG_HOME/sublime-text/Packages/User',\
#      if:'command -v subl',\
#      ignore
# plug trobjo/Sublime-Merge-Config,\
#      where:'$XDG_CONFIG_HOME/sublime-merge/Packages/User',\
#      if:'command -v smerge',\
#      ignore
plug trobjo/Neovim-config,\
     if:'command -v nvim',\
     where:'$XDG_CONFIG_HOME/nvim',\
     postinstall:'nvim +PlugInstall +qall; printf "\e[6 q\n\n"',\
     ignore

plug 'https://raw.githubusercontent.com/trobjo/roslyn_analyzers/master/roslyn_analyzers.zip',\
     if:'command -v subl && command -v dotnet',\
     where:'${HOME}/.roslyn_analyzers',\
     ignore

plug 'https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v1.37.10/omnisharp-linux-x64.tar.gz',\
     if:'command -v subl && command -v dotnet',\
     where:'${HOME}/.omnisharp',\
     postinstall:'chmod +x "${where}/bin/mono" "${where}/omnisharp/OmniSharp.exe"',\
     ignore

plug init

if [[ -f ${ZDOTDIR}/novcs.zsh ]]; then
     # compile_or_recompile ${ZDOTDIR}/novcs.zsh
     source ${ZDOTDIR}/novcs.zsh
fi

