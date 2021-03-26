compile_or_recompile() {
  local file
  for file in "$@"; do
    if [[ -f $file ]] && [[ ! -f ${file}.zwc ]] \
      || [[ $file -nt ${file}.zwc ]]; then
      zcompile "$file"
    fi
  done
}
compile_or_recompile "${ZDOTDIR}/.zshrc" "${ZDOTDIR}/.zcompdump"

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
## Begin plugin manager
#

if [[ ! -d ${ZDOTDIR}/plugins ]]; then

    print -P "%F{5}Installing %F{33}Z.lua%F{5}…%f"
    command mkdir -p "${HOME}/.local/bin"
    command curl --silent 'https://raw.githubusercontent.com/trobjo/czmod-compiled/master/czmod' > "${HOME}/.local/bin/czmod" &&\
    command chmod +x "${HOME}/.local/bin/czmod" &&\
    command curl --silent 'https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua' > "${ZDOTDIR}/z.lua" &&\
        print -P "%F{2}%{\e[3m%}Z.lua installed successfully.%f%b" || \
        print -P "%F{2}%{\e[3m%}The clone has failed.%f%b"

    print -P "%F{5}Installing the %F{33}zsh-defer%F{5} Plugin Manager…%f"
    command mkdir -p "$ZDOTDIR/plugins" && command chmod g-rwX "${ZDOTDIR}/plugins"
    command git clone https://github.com/romkatv/zsh-defer.git "${ZDOTDIR}/zsh-defer" && \
        print -P "%F{2}%{\e[3m%}ZSH defer installed successfully.%f%b" || \
        print -P "%F{1}%{\e[3m%}ZSH defer failed to install.%f%b"
fi

if [[ -d ${ZDOTDIR}/plugins ]]; then
    source "${ZDOTDIR}/zsh-defer/zsh-defer.plugin.zsh"

    # plugin_manager documentation:
    # arguments can be passed to plugin_manager separated by ':'.
    # The second field is the name of the file to source if it is
    # named differently than the plugin. The third field may contain
    # a command that must return exit code 0 for the plugin to load.
    # For example, you can avoid loading plugins if dependencies are
    # not found in $PATH.
    plugin_manager() {
        local myarr=($@)

        if [[ "${1}" == "remove" ]]; then

            myarr=($synchronous_plugins $asynchronous_plugins)
            local filelist=($(cd ${ZDOTDIR}/plugins; find * -type d -path '*/*' -prune -print))

            local parts
            for plug in "${myarr[@]}"; do
                parts=("${(@s[:])plug}")
                filelist=(${filelist[@]//*${parts[1]}*})
            done

            for elem in "${filelist[@]}"; do
                rm -rf "${ZDOTDIR}/plugins/${elem}"
                printf "Removed \x1B[31m\033[3m${elem}\033[0m …\n"
            done

            printf "Removed \x1B[31m\033[1m${#filelist}\033[0m elements\n"
            return
        fi

        # we construct an array if only 1 arg is given.
        # to be run interactively
        if [[ ${#myarr[@]} -eq 1 ]]; then
            myarr+=($synchronous_plugins $asynchronous_plugins)
        fi

        local filetosource
        local plugin
        for plugin in "${myarr[@]:1}"; do
            # split strings by args
            parts=("${(@s[:])plugin}")

            if [[ ! -z ${parts[2]} ]]; then
                filetosource=${parts[2]}
            else
                filetosource=${parts[1]}
            fi

            if [[ ! -z ${parts[3]} ]] && [[ ! $(eval ${parts[3]}) ]]; then
                    continue
            fi

            local dir="${ZDOTDIR}/plugins/${parts[1]%%/*}"
            if [[ ! -d "$dir" ]]; then
                mkdir -p "$dir"
            fi

            local plugindir="${ZDOTDIR}/plugins/${parts[1]}"
            local pluginfile="${plugindir}/${${filetosource##*/}//.zsh/}.zsh"

            case "${1}" in
                (update|pull)
                    printf "Updating \x1B[35m\033[3m${(r:38:)parts[1]}\033[0m… "
                    git -C ${plugindir} pull
                    ;;
                (install)
                    if [[ ! -f $pluginfile ]]; then
                    printf "Installing \x1B[35m\033[3m${parts[1]}\033[0m …\n"
                    git clone https://github.com/${parts[1]}.git ${plugindir} 2> /dev/null
                    fi
                    ;;
                (*)
                ;;
            esac

            compile_or_recompile "$pluginfile"
            source "$pluginfile"
        done
    }

    synchronous_plugins=(trobjo/zsh-prompt-compact\
                          zsh-users/zsh-autosuggestions)

    asynchronous_plugins=(le0me55i/zsh-extract:"extract.plugin.zsh"\
             trobjo/zsh-goodies\
             trobjo/zsh-file-opener\
             trobjo/zsh-fzf-functions::"command -v fzf" \
             trobjo/zsh-wayland-utils::"printf \$WAYLAND_DISPLAY"\
             trobjo/zsh-autosuggestions-override\
             zsh-users/zsh-syntax-highlighting)

    plugin_manager install ${synchronous_plugins}
    zsh-defer plugin_manager install ${asynchronous_plugins}

    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(go_home bracketed-paste-url-magic url-quote-magic
                                    repeat-last-command-or-complete-entry expand-or-complete)
    ZSH_AUTOSUGGEST_IGNORE_WIDGETS[$ZSH_AUTOSUGGEST_IGNORE_WIDGETS[(i)yank]]=()
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=5,underline

    zsh-defer eval "$(lua ${ZDOTDIR}/z.lua --init zsh enhanced once)"
    ### ZLUA config
    _ZL_CMD=h
    export _ZL_DATA=${ZDOTDIR}/zlua_data
    _zlua_precmd() {(czmod --add "${PWD:a}" &) }
fi



#
# Completion enhancements
#
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

zstyle ':completion:*:*:cast:*' file-patterns '*.mkv:all-files'

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

if [ ! -z $SWAYSOCK ]; then
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
    alias ea='ls --color=auto --group-directories-first --all'
    alias es='ls --color=auto -lt'
    alias ee='ls --color=auto --group-directories-first -l'
    alias e='ls --color=auto --group-directories-first'
fi

alias rgg='rg --no-ignore-vcs --hidden'
alias fdd='fd --no-ignore-vcs --hidden'
alias has='transmission-remote -l'
alias df='df -h'
alias findip='curl -s icanhazip.com | tee >(wl-copy -n -- 2> /dev/null || exit 0)'


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


# if [ -z "$TMUX" ] && [ ${UID} != 0 ] && [[ $SSH_TTY ]] && which tmux >/dev/null 2>&1
# then
#     tmux new-session -A -s main
# fi
