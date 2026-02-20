#!/bin/bash

# Configuration
REPO_URL="git@github.com:serosme/git-setup.git"
REPO_PATH="$HOME/workspace/personal/git-setup"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

# NEW: put all git configs under ~/.config/git/
GIT_CONFIG_DIR="$HOME/.config/git"
GIT_CONFIG_GLOBAL="$GIT_CONFIG_DIR/config"

# Function to add a Git configuration
add_git_config() {
    echo "Adding new Git configuration:"
    read -p "  Configuration name (e.g., personal, professional): " config_name
    read -p "  Your name: " user_name
    read -p "  Your email: " user_email
    read -p "  Directory path (e.g., ~/workspace/personal, ~/workspace/professional): " directory_path
    echo

    # Validate input
    if [[ -z "$config_name" || -z "$user_name" || -z "$user_email" || -z "$directory_path" ]]; then
        echo "Error: All fields are required."
        return 1
    fi

    # NEW: ensure git config dir exists
    mkdir -p "$GIT_CONFIG_DIR"

    # NEW: Create configuration file in ~/.config/git/
    config_file="$GIT_CONFIG_DIR/config-$config_name"
    cat > "$config_file" << EOF
[user]
    name = $user_name
    email = $user_email
EOF

    # NEW: Add includeIf rule to main config at ~/.config/git/config
    cat >> "$GIT_CONFIG_GLOBAL" << EOF
[includeIf "gitdir:$directory_path/"]
    path = $config_file
EOF

    # Create directory
    mkdir -p "$directory_path"

    echo "Created configuration: $config_name"
    echo "  Config file: $config_file"
    echo "  Directory: $directory_path"
    echo
}

# Function to generate SSH key
generate_ssh_key() {
    clear
    if [[ ! -f "$SSH_KEY_PATH" ]]; then
        echo "Generating SSH key..."
        ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N ""
    fi
}

# Function to confirm SSH key setup
confirm_ssh_setup() {
    clear
    cat "$SSH_KEY_PATH.pub"
    echo
    read -p "Please make sure your SSH public key has been added to GitHub. (y/N): " -r response
    echo
}

# Function to clone repository
clone_repository() {
    if [ -d "$REPO_PATH" ]; then
        echo "$REPO_PATH already exists."
    else
        echo "Cloning repository..."
        git clone "$REPO_URL" "$REPO_PATH"
    fi
    echo
}

# Function to copy configuration files
copy_configuration_files() {
    # NEW: ensure git config dir exists
    mkdir -p "$GIT_CONFIG_DIR"

    echo "source $REPO_PATH/.gitconfig"
    echo
    cat "$REPO_PATH/.gitconfig"
    echo

    # NEW: switch from ~/.gitconfig to ~/.config/git/config
    if [[ -f "$GIT_CONFIG_GLOBAL" ]]; then
        echo "Existing Git config found at $GIT_CONFIG_GLOBAL"
        echo
        cat "$GIT_CONFIG_GLOBAL"
        echo
    else
        echo "No existing Git config found, copying default configuration..."
        cp "$REPO_PATH/.gitconfig" "$GIT_CONFIG_GLOBAL"
        echo
        cat "$GIT_CONFIG_GLOBAL"
        echo
    fi

    echo "source $REPO_PATH/.gitconfig"
    echo
    cat "$REPO_PATH/config"
    echo
    if [[ -f "$HOME/.ssh/config" ]]; then
        echo "Existing SSH config found at $HOME/.ssh/config"
        echo
        cat "$HOME/.ssh/config"
        echo
    else
        echo "No existing SSH config found, copying default configuration..."
        cp "$REPO_PATH/config" "$HOME/.ssh/config"
        echo
        cat "$HOME/.ssh/config"
        echo
    fi
}

# Function to setup Git configurations interactively
setup_git_configurations() {
    while true; do
        read -p "Do you want to add a Git configuration? (y/N): " -r add_config
        echo
        case ${add_config,,} in
            y)
                add_git_config
                ;;
            *)
                break
                ;;
        esac
    done
}

# Main execution
main() {
    generate_ssh_key
    confirm_ssh_setup
    clone_repository
    copy_configuration_files
    setup_git_configurations
}

# Execute main function
main
