# Load previous user .bashrc if present
if [ -f ~/.bashrc.backup ]; then
    . ~/.bashrc.backup
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Try to find an exe if the command is not found
function command_not_found_handle {
    if [ -x "$(command -v ${1}.exe)" ]; then
        ${1}.exe "${@:2}"
    else
        echo "command_not_found_handle - Command not found: $1"
        return 127
    fi
}

PATH="$HOME/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
export PATH
export KUBE_EDITOR="code -w"
export EDITOR="code"

# Check if brew is installed and add it to the PATH
if command -v brew &> /dev/null; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

[[ -f <BLESH_PATH>/share/blesh/ble.sh ]] && source <BLESH_PATH>/share/blesh/ble.sh
[[ :$SHELLOPTS: =~ :(vi|emacs): ]] && eval "$(<ATUIN_PATH>/bin/atuin init bash <ATUIN_FLAGS>)"