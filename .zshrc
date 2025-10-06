export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export SKIM_DEFAULT_OPTIONS="$SKIM_DEFAULT_OPTIONS \
--color=fg:#c6d0f5,bg:#303446,matched:#414559,matched_bg:#eebebe,current:#c6d0f5,current_bg:#51576d,current_match:#303446,current_match_bg:#f2d5cf,spinner:#a6d189,info:#ca9ee6,prompt:#8caaee,cursor:#e78284,selected:#ea999c,header:#81c8be,border:#737994"

export LANG=en_US.UTF-8
export QT_QPA_PLATFORM=wayland
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="code --wait"
export TERMINAL=kitty


# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init --cmd cd zsh)"

# Custom aliases
## Quick edit
alias zshrc="code --wait ~/.zshrc"
alias hc="code --wait ~/.config/hypr/"
## Drop-in replacements
alias cat="bat"
alias pcat="bat -p"
alias l="lsd -lA --date relative"
## Beauty
alias m="cmatrix"
alias b="cbonsai --live"
alias n="fastfetch"
## Other
alias icat="kitten icat"
alias ls="lsd"

# start the ssh-agent
function start_agent {
    # spawn ssh-agent
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add "${SSH_KEY_LOCATION:-$HOME/.ssh/id_ed25519}" >/dev/null 2>&1
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    # start_agent;
fi


# eval "$(register-python-argcomplete pipx)"

source ${ZSH_SYNTAX_HIGHLIGHTING:-/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}

source ~/.config/zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh

# https://github.com/zsh-users/zsh-autosuggestions
source ${ZSH_AUTOSUGGEST:-/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh}

if [ -n "$PYENV_ROOT" ]; then
    eval "$(pyenv init - bash)"
    eval "$(pyenv virtualenv-init -)"
fi

if [ -n "$NVM_DIR" ]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config '~/.config/oh-my-posh/zen.toml')"
fi

bindkey "^[[3~" delete-char

if command -v fastfetch >/dev/null 2>&1 && [ -z "$TERM_PROGRAM" ]; then
    fastfetch
fi
fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select
# export LD_LIBRARY_PATH="/home/zeba/binaryninja:/home/zeba/binaryninja/plugins:$LD_LIBRARY_PATH"
