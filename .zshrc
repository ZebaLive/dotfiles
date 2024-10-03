if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config '~/zen.toml')"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

function docker_php {
    if [ -n "$(docker ps -f "name=local_webserver-php82" -f "status=running" -q )" ]; then
        result=${PWD##*/} 
        GO="cd $result && php ${@}"
        docker exec -it local_webserver-php82 bash -c "$GO"
    elif [ -n "$(docker ps -f "name=sst_webserver-php83 " -f "status=running" -q )" ]; then
        GO="php ${@}"
        docker exec -it sst_webserver-php83 bash -c "$GO"
    else
        echo "No running container found"
    fi
    return $?
}

function docker_cake {
    if [ -n "$(docker ps -f "name=local_webserver-php82" -f "status=running" -q )" ]; then
         result=${PWD##*/} 
        GO="cd $result && php ./bin/cake.php ${@}"
        docker exec -it local_webserver-php82 bash -c "$GO"
    elif [ -n "$(docker ps -f "name=sst_webserver-php83 " -f "status=running" -q )" ]; then
        GO="php ./bin/cake.php ${@}"
        docker exec -it sst_webserver-php83 bash -c "$GO"
    else
        echo "No running container found"
    fi
    return $?
}

function docker_exec {
    if [ -n "$(docker ps -f "name=local_webserver-php82" -f "status=running" -q )" ]; then
        result=${PWD##*/} 
        GO="cd $result && ${@}"
        docker exec -it local_webserver-php82 bash -c "$GO"
    elif [ -n "$(docker ps -f "name=sst_webserver-php83 " -f "status=running" -q )" ]; then
        GO="${@}"
        docker exec -it sst_webserver-php83 bash -c "$GO"
    else
        echo "No running container found"
    fi
    return $?
}

function docker_composer {
    SSH_START='eval $(ssh-agent -s);'
    SSH_ADD="ssh-add ${DOCKER_SSH_KEY_LOCATION:-/root/.ssh/id_ed25519};"
    if [ -n "$(docker ps -f "name=local_webserver-php82" -f "status=running" -q )" ]; then
        result=${PWD##*/} 
        GO="cd $result && php composer.phar ${@}"
        docker exec -it local_webserver-php82 bash -c "$SSH_START $SSH_ADD $GO"
    elif [ -n "$(docker ps -f "name=sst_webserver-php83 " -f "status=running" -q )" ]; then
        GO="php composer.phar ${@}"
        docker exec -it sst_webserver-php83 bash -c "$SSH_START $SSH_ADD $GO"
    else
        echo "No running container found"
    fi
   
    return $?
}

alias php=docker_php
alias docx=docker_exec
alias cake=docker_cake
alias composer=docker_composer
alias gl='git pull'
alias gp='git push'
alias ga='git add .'
alias gf='git fetch'
alias gm='git commit -m'
alias gam='git commit -am'
alias gs='git status'
alias gc='git checkout'
alias gb='git rebase'

# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init --cmd cd zsh)"

export DOCKER_CLI_HINTS=false

SSH_ENV="$HOME/.ssh/environment"

# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
	chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add  "${SSH_KEY_LOCATION:-$HOME/.ssh/id_ed25519}";
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

# https://github.com/zsh-users/zsh-syntax-highlighting
source ${ZSH_SYNTAX_HIGHLIGHTING:-/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}

source ~/.zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh

# https://github.com/zsh-users/zsh-autosuggestions
source ${ZSH_AUTOSUGGEST:-/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh}