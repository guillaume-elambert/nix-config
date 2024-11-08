#=============================
# START MANUAL .BASHRC SCRIPT
#=============================

# Load previous user .bashrc if present
if [ -f ~/.bashrc.backup ]; then
    . ~/.bashrc.backup
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
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

export KUBECONFIG="$HOME/.kube/config"
export KUBE_EDITOR="code -w"
export EDITOR="code"

# Check if brew is installed and add it to the PATH
if command -v brew &> /dev/null; then
    eval "$(brew shellenv)"
fi

# Load atuin and ble.sh
[[ -f ${BLESH_PATH}/share/blesh/ble.sh ]] && source ${BLESH_PATH}/share/blesh/ble.sh
[[ :$SHELLOPTS: =~ :(vi|emacs): ]] && eval "$($ATUIN_PATH/bin/atuin init bash $ATUIN_FLAGS)"


# Function to source each files in folders
function source_files_in_folder() {
    local folder=$1
    for file in $folder/*; do
        if [ -f $file ]; then
            source $file
        fi
    done
}

# Aliases
if command -v kubectl &> /dev/null; then
    source <(kubectl completion bash)
fi
source_files_in_folder ~/.bash_completion.d
source_files_in_folder ~/.bash_alias

# Create aliases for each kubeconfig and each kubecontext for the following apps
apps_to_alias=("k9s")

for app in "${apps_to_alias[@]}"; do
    remove_kubectl_aliases $app
    generate_aliases_from_kubeconfigs $app
done

# generate_aliases_from_kubecontexts k9s

#==============================
# START AUTO GENERATION BY NIX
#==============================