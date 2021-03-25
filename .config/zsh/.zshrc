compile_or_recompile() {
  local file
  for file in "$@"; do
    if [[ -f $file ]] && [[ ! -f ${file}.zwc ]] \
      || [[ $file -nt ${file}.zwc ]]; then
      zcompile "$file"
    fi
  done
}
compile_or_recompile "${ZDOTDIR}/.zshrc"

# rehash path after pacman installation
TRAPUSR1() { rehash }

#
# Input/output
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
# History
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

setopt bang_hist                # Treat The '!' Character Specially During Expansion.
setopt inc_append_history       # Write To The History File Immediately, Not When The Shell Exits.
setopt share_history            # Share History Between All Sessions.
setopt hist_expire_dups_first   # Expire A Duplicate Event First When Trimming History.
setopt hist_ignore_dups         # Do Not Record An Event That Was Just Recorded Again.
setopt hist_ignore_all_dups     # Delete An Old Recorded Event If A New Event Is A Duplicate.
setopt hist_find_no_dups        # Do Not Display A Previously Found Event.
setopt hist_ignore_space        # Do Not Record An Event Starting With A Space.
setopt extended_history         # Show Timestamp In History.

# - - - - - - - - - - - - - - - - - - - -

autoload -U colors && colors    # Load Colors.

zle_highlight=(region:bg=17 special:bg=17
               suffix:bg=17 paste:bg=17 isearch:bg=17)

setopt no_case_glob             # Make globbing case insensitive.
setopt extendedglob             # Use Extended Globbing.
setopt autocd                   # Automatically Change Directory If A Directory Is Entered.
LISTMAX=9999                    # Disable 'do you wish to see all %d possibilities'


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
## Zgen
#

if [[ ! -f ${ZDOTDIR}/zgen/zgen.zsh ]]; then
    print -P "%F{5}Installing %F{33}Z.lua%F{5}…%f"
    command mkdir -p "${HOME}/.local/bin"
    command curl 'https://raw.githubusercontent.com/trobjo/czmod-compiled/master/czmod' > "${HOME}/.local/bin/czmod"
    command chmod +x "${HOME}/.local/bin/czmod"
    command curl 'https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua' > "${ZDOTDIR}/z.lua"


    print -P "%F{5}Installing the %F{33}Zgen%F{5} Plugin Manager…%f"
    command mkdir -p "$ZDOTDIR/zgen" && command chmod g-rwX "${ZDOTDIR}/zgen"
    command git clone https://github.com/tarjoilija/zgen.git "${ZDOTDIR}/zgen" && \
        print -P "%F{2}%{\e[3m%}Installation successful.%f%b" || \
        print -P "%F{2}%{\e[3m%}The clone has failed.%f%b"
fi

if [[ -f ${ZDOTDIR}/zgen/zgen.zsh ]]; then
    ZGEN_DIR="${ZDOTDIR}/zgen"
    source "${ZDOTDIR}/zgen/zgen.zsh"

    zgen load le0me55i/zsh-extract
    zgen load trobjo/zsh-file-opener

    zgen load trobjo/zsh-goodies
    zgen load trobjo/zsh-prompt-compact
    [ $WAYLAND_DISPLAY ] && zgen load trobjo/zsh-wayland-utils
    command -v fzf &> /dev/null && zgen load trobjo/zsh-fzf-functions

    zgen load zsh-users/zsh-autosuggestions
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(go_home toggle_info bracketed-paste-url-magic url-quote-magic repeat-last-command-or-complete-entry expand-or-complete)
    ZSH_AUTOSUGGEST_IGNORE_WIDGETS[$ZSH_AUTOSUGGEST_IGNORE_WIDGETS[(i)yank]]=()
    ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(nice-escape)
    ZSH_AUTOSUGGEST_STRATEGY=(history)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=5,underline

    export KEYTIMEOUT=1
    bindkey -e '\e' autosuggest-execute

    zgen load zsh-users/zsh-syntax-highlighting
fi

#
# Completion enhancements
#

# Load The Prompt System And Completion System And Initilize Them.
autoload -Uz compinit

# Load And Initialize The Completion System Ignoring Insecure Directories With A
# Cache Time Of 20 Hours, So It Should Almost Always Regenerate The First Time A
# Shell Is Opened Each Day.
# See: https://gist.github.com/ctechols/ca1035271ad134841284
_comp_files=(${ZDOTDIR:-$HOME}/.zcompdump(Nm-20))
if (( $#_comp_files )); then
    compinit -i -C
else
    compinit -i
fi
unset _comp_files

#
### ZLUA config
#

# use h instead of z as that is the easiest key to reach on dvorak
_ZL_CMD=h
export _ZL_DATA=${ZDOTDIR}/zlua_data

eval "$(lua ${ZDOTDIR}/z.lua --init zsh enhanced once)"
_zlua_precmd() {
  (czmod --add "${PWD:a}" &)
}


#
# Completion module options
#

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:|?=**'

# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'expand'
zstyle ':completion:*' squeeze-slashes true

# Enable caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-${HOME}}/.zcompcache"

# Ignore useless commands and functions
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'

# Completion sorting
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# If the _my_hosts function is defined, it will be called to add the ssh hosts
# completion, otherwise _ssh_hosts will fall through and read the ~/.ssh/config
zstyle -e ':completion:*:*:ssh:*:my-accounts' users-hosts \
'[[ -f ${HOME}/.ssh/config && ${key} == hosts ]] && key=my_hosts reply=()'


# # makes sure .subtitles are not part of the tab completion when using u()
zstyle ':completion:*:*:u:*' file-patterns '^*.(srt|part|ytdl|vtt|log):source-files' '*:all-files'
zstyle ':completion:*:*:cast:*' file-patterns '*.mkv:all-files'

# Use smart URL pasting and escaping.
autoload -Uz bracketed-paste-url-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-url-magic
zle -N self-insert url-quote-magic



if command -v pacman &> /dev/null
then
    alias Syu='yay -Syu --devel'
    alias mus='ncmpcpp -q'
    alias S='yay -Sy'
    alias U='yay -U'
    alias Sy='yay -Sy'
    alias Ss='yay -Ss'
    alias Rsn='yay -Rsn'
    alias Rns='yay -Rns'
    alias Rdd='yay -Rdd'
    alias Qs='yay -Qs'
    # list packages owned by
    alias Qo='pacman -Qo'
    alias Qqs='yay -Qqs'
    alias Qq='yay -Qq'
    alias Qtdq='yay -Rsn $(pacman -Qtdq)'
    alias reboot='dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Reboot" boolean:true'

    alias findip='curl -s icanhazip.com | tee /dev/tty | wl-copy -n'
    alias swaymsg='noglob swaymsg'
    # alias toggleTP='swaymsg input "1739:52552:SYNA1D31:00_06CB:CD48_Touchpad" events toggle disabled enabled'
    alias dvorak='swaymsg input "1:1:AT_Translated_Set_2_keyboard" xkb_layout us(dvorak)'
    alias qwerty='swaymsg input "1:1:AT_Translated_Set_2_keyboard" xkb_layout us'
else
    alias -g fd='fdfind'
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

alias install='touch ~/.gitignore && echo ".dotfiles" >> .gitignore && git clone --bare "https://git.sr.ht/~troels/dotfiles/" $HOME/.dotfiles && /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout --force'

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

if command -v exa &> /dev/null
then
    alias e='exa --group-directories-first'
    alias es='exa --sort=oldest --long --git'
    alias ee='exa --group-directories-first --long --git'
    alias ea='exa --group-directories-first --long --git --all'
else
    alias e='ls --color=auto'
fi

alias rgg='rg --no-ignore-vcs --hidden'
alias fdd='fd --no-ignore-vcs --hidden'
alias has='transmission-remote -l'
alias df='df -h'


# Git aliases
alias g='git status --porcelain --short'
alias gc='git clone'
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

# stdout in sublime or less, or clipboard
alias -g CC=' |& tee /dev/tty |& wl-copy -n'
alias -g SS=' |& subl -'
alias -g LL=' |& less'
alias -g G=' |& rg'
alias -g jsonl=' | jq -C "." | less -R'
alias -g json=' | jq -C "."'

# I always forget how to redirect
alias -g silent="> /dev/null 2>&1"
alias -g noerr="2> /dev/null"
alias -g onerr=" & 1> /dev/null"
alias -g stdboth="2>&1"


if [ -z "$TMUX" ] && [ ${UID} != 0 ] && [[ $SSH_TTY ]] && which tmux >/dev/null 2>&1
then
    tmux new-session -A -s main
fi
