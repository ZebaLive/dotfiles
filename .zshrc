# Use powerline
USE_POWERLINE="true"
# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

function docker_php {
    result=${PWD##*/} 
    GO="cd $result && php ${@}"
    docker exec -it local_webserver-php82 bash -c "$GO"
    return $?
}

function docker_cake {
    result=${PWD##*/} 
    GO="cd $result && php ./bin/cake.php ${@}"
    docker exec -it local_webserver-php82 bash -c "$GO"
    return $?
}

function docker_exec {
    result=${PWD##*/} 
    GO="cd $result && ${@}"
    docker exec -it local_webserver-php82 bash -c "$GO"
    return $?
}

function docker_composer {
    result=${PWD##*/} 
    GO="cd $result && php composer.phar ${@}"
    AGENT='eval $(ssh-agent -s); ssh-add;'
    docker exec -it local_webserver-php82 bash -c "$AGENT $GO"
    
    return $?
}

alias php=docker_php
alias docx=docker_exec
alias cake=docker_cake
alias composer=docker_composer
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias gl='git pull'
alias gp='git push'
alias ga='git add .'
alias gf='git fetch'
alias gm='git commit -m'
alias gam='git commit -am'
alias gs='git status'
alias gc='git checkout'
alias gb='git rebase'

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
    /usr/bin/ssh-add ~/.ssh/id_ed25519;
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
