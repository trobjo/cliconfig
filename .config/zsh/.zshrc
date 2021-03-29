
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
## ALIASES
#

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
    alias ea='ls --color=auto --group-directories-first --all'
    alias es='ls --color=auto -lt'
    alias ee='ls --color=auto --group-directories-first -l'
    alias e='ls --color=auto --group-directories-first'
fi

alias rgg='rg --no-ignore-vcs --hidden'
alias fdd='fd --no-ignore-vcs --hidden'
alias has='transmission-remote -l'
alias df='df -h'
alias findip='curl -s icanhazip.com | tee >(wl-copy -n -- 2> /dev/null)'


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
alias -g json=' | jq -C "."'

# I always forget how to redirect
alias -g silent="> /dev/null 2>&1"
alias -g noerr="2> /dev/null"
alias -g onerr="1> /dev/null"
alias -g stdboth="2>&1"



if [[ ! -d ${ZDOTDIR}/plugins ]]; then
    git clone --depth=1 https://github.com/trobjo/zsh-plugin-manager 2> /dev/null "${ZDOTDIR}/plugins/trobjo/zsh-plugin-manager"
    command chmod g-rwX "${ZDOTDIR}/plugins"
fi
source "${ZDOTDIR}/plugins/trobjo/zsh-plugin-manager/zsh-plugin-manager.zsh"

# plug romkatv/gitstatus
# plug trobjo/zsh-prompt-compact

plug 'sindresorhus/pure',\
     env:'PURE_PROMPT_SYMBOL=%Bλ%b',\
     source:'async.zsh',\
     source:'pure.zsh'

plug 'zsh-users/zsh-autosuggestions',\
     env:'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=5,underline',\
     postload_hook:'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(go_to_old_pwd bracketed-paste-url-magic url-quote-magic
                                repeat-last-command-or-complete-entry expand-or-complete)\
                    ZSH_AUTOSUGGEST_IGNORE_WIDGETS[$ZSH_AUTOSUGGEST_IGNORE_WIDGETS[(i)yank]]=()'
plug trobjo/zsh-autosuggestions-override,\
     if:'printf $ZSH_AUTOSUGGEST_CLEAR_WIDGETS'


plug async 'https://github.com/junegunn/fzf/releases/download/0.26.0/fzf-0.26.0-linux_amd64.tar.gz',\
            if:'! command -v fzf',\
            where:'$HOME/.local/bin/fzf',\
            ignorelevel:ignore,\
            postinstall_hook:'tar zxvf \$filename --directory ${HOME}/.local/bin/ && rm \$filename'
plug async 'https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb',\
            if:'! command -v rg && command -v apt',\
            where:'$HOME/.local/bin/rg',\
            ignorelevel:ignore,\
            postinstall_hook:'sudo dpkg -i \$filename && rm \$filename'
plug async trobjo/zsh-completions
plug async skywind3000/z.lua,\
           if:'command -v lua',\
           env:'_ZL_CMD=h',\
           env:'_ZL_DATA=${ZDOTDIR}/zlua_data',\
           ignorelevel:ignore,\
           postinstall_hook:'mkdir -p "${HOME}/.local/bin" && curl --silent https://raw.githubusercontent.com/trobjo/czmod-compiled/master/czmod > "${HOME}/.local/bin/czmod" && chmod +x "${HOME}/.local/bin/czmod"',\
           postload_hook:'eval "$(lua ${plugin_dir_local_location}/z.lua --init zsh enhanced once); _zlua_precmd() {(czmod --add "\${PWD:a}" &) }"'
plug async le0me55i/zsh-extract,\
           source:extract.plugin.zsh
plug async trobjo/zsh-goodies
plug async trobjo/zsh-wayland-utils,\
           if:'printf $WAYLAND_DISPLAY'
plug async trobjo/zsh-file-opener
plug async wfxr/forgit
plug async trobjo/zsh-fzf-functions,\
           if:'command -v fzf && command -v fd'
plug async zsh-users/zsh-syntax-highlighting
plug async trobjo/Neovim-config,\
           if:'command -v nvim',\
           where:'$XDG_CONFIG_HOME/nvim',\
           postinstall_hook:'nvim +PlugInstall +qall; printf "\e[6 q"',\
           ignorelevel:ignore
plug async trobjo/Sublime-Text-Config,\
           where:'$XDG_CONFIG_HOME/sublime-text/Packages/User',\
           if:'command -v subl',\
           ignorelevel:ignore
plug async trobjo/Sublime-Merge-Config,\
           where:'$XDG_CONFIG_HOME/sublime-merge/Packages/User',\
           if:'command -v smerge',\
           ignorelevel:ignore

plug init
plug trobjo/zsh-plugin-manager


# if [ -z "$TMUX" ] && [ ${UID} != 0 ] && [[ $SSH_TTY ]] && which tmux >/dev/null 2>&1
# then
#     tmux new-session -A -s main
# fi
