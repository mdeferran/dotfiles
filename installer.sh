#!/bin/bash
# Modern dotfiles installer for Ubuntu 24.04/25.04
#
# Usage:
#   ./installer.sh base     # Install base configuration
#   ./installer.sh dev      # Install development tools
#   ./installer.sh all      # Install everything
#   ./installer.sh link     # Just link dotfiles to $HOME

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Get script directory
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    while [ -h "$source" ]; do
        local dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done
    echo "$(cd -P "$(dirname "$source")" && pwd)"
}

readonly SCRIPT_DIR="$(get_script_dir)"
readonly BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on supported Ubuntu version
check_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            local version="${VERSION_ID%.*}"
            if [[ "$version" -ge 24 ]]; then
                log_info "Detected Ubuntu $VERSION_ID - supported!"
                return 0
            fi
        fi
    fi
    log_error "This script requires Ubuntu 24.04 or later"
    return 1
}

# Update package lists if stale
apt_update_if_needed() {
    local apt_lists="/var/lib/apt/lists"
    if [ ! -d "$apt_lists" ] || [ -z "$(find "$apt_lists" -maxdepth 1 -mmin -60 2>/dev/null)" ]; then
        log_info "Updating package lists..."
        sudo apt update
    fi
}

# Install packages
install_packages() {
    local packages=("$@")
    log_info "Installing packages: ${packages[*]}"
    apt_update_if_needed
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${packages[@]}" --no-install-recommends
}

# Link dotfiles to home directory
link_dotfiles() {
    log_info "Linking dotfiles to $HOME"

    local files=(
        .zshrc .zshrc_helpers .zshrc_python .zshrc_go .zshrc_gpg .zshrc_ops
        .gitconfig .tmux.conf .vimrc
    )

    # Create backup directory if any files exist
    local needs_backup=false
    for file in "${files[@]}"; do
        if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            needs_backup=true
            break
        fi
    done

    if [ "$needs_backup" = true ]; then
        log_warn "Creating backup of existing dotfiles in $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi

    # Link files
    for file in "${files[@]}"; do
        local src="$SCRIPT_DIR/$file"
        local dst="$HOME/$file"

        if [ ! -e "$src" ]; then
            log_warn "Source file not found: $src"
            continue
        fi

        # Backup existing file
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            log_info "Backing up $file"
            mv "$dst" "$BACKUP_DIR/"
        fi

        # Create symlink
        ln -snf "$src" "$dst"
        log_info "Linked $file"
    done

    # Link .config directories
    mkdir -p "$HOME/.config"

    if [ -d "$SCRIPT_DIR/.config/ghostty" ]; then
        ln -snf "$SCRIPT_DIR/.config/ghostty" "$HOME/.config/ghostty"
        log_info "Linked .config/ghostty"
    fi

    # Link Sheldon config
    if [ -f "$SCRIPT_DIR/plugins.toml" ]; then
        mkdir -p "$HOME/.config/sheldon"
        ln -snf "$SCRIPT_DIR/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
        log_info "Linked .config/sheldon/plugins.toml"
    fi

    # Link .gnupg config
    if [ -d "$SCRIPT_DIR/.gnupg" ]; then
        mkdir -p "$HOME/.gnupg"
        chmod 700 "$HOME/.gnupg"
        ln -snf "$SCRIPT_DIR/.gnupg/gpg.conf" "$HOME/.gnupg/gpg.conf"
        ln -snf "$SCRIPT_DIR/.gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
        log_info "Linked .gnupg config"
    fi

    # Link .ssh config
    if [ -f "$SCRIPT_DIR/.ssh/config" ]; then
        mkdir -p "$HOME/.ssh"
        mkdir -p "$HOME/.ssh/sockets"
        chmod 700 "$HOME/.ssh"
        ln -snf "$SCRIPT_DIR/.ssh/config" "$HOME/.ssh/config"
        log_info "Linked .ssh/config"
    fi

    # Link .zsh directory (custom themes)
    if [ -d "$SCRIPT_DIR/.zsh" ]; then
        ln -snf "$SCRIPT_DIR/.zsh" "$HOME/.zsh"
        log_info "Linked .zsh directory"
    fi
}

# Install base packages and configuration
setup_base() {
    log_info "Setting up base environment..."

    local packages=(
        # Core tools
        git
        tmux
        curl
        wget
        ca-certificates
        gnupg

        # Modern CLI tools
        ripgrep
        fd-find
        fzf
        bat
        eza
        jq
        yq
        just

        # Network tools
        openssh-client
        net-tools
        dnsutils

        # Compression
        zip
        unzip
        bzip2

        # Build essentials
        build-essential

        # Fonts
        fonts-firacode
    )

    install_packages "${packages[@]}"
    link_dotfiles

    # Update font cache
    if command -v fc-cache &> /dev/null; then
        log_info "Updating font cache..."
        fc-cache -f
    fi

    # Setup Ghostty (check if available)
    setup_ghostty

    # Setup git-delta (modern diff viewer)
    setup_delta

    # Setup ast-grep (AST-based code searching)
    setup_ast_grep

    log_info "Base setup complete!"
}

# Install ZSH and configure
setup_zsh() {
    log_info "Setting up ZSH..."

    install_packages zsh

    # Install Sheldon (fast Rust-based plugin manager)
    if ! command -v sheldon &> /dev/null; then
        log_info "Installing Sheldon..."
        curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
            | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

        # Add ~/.local/bin to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi

    # Initialize Sheldon plugins on first run
    if command -v sheldon &> /dev/null; then
        log_info "Initializing Sheldon plugins..."
        sheldon lock --update
    fi

    # Change shell to ZSH
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Changing default shell to ZSH..."
        sudo chsh -s "$(which zsh)" "$USER"
        log_info "Shell changed to ZSH (logout and login to take effect)"
    fi

    log_info "ZSH setup complete!"
}

# Install Neovim
setup_neovim() {
    log_info "Setting up Neovim..."

    # Install neovim and dependencies
    install_packages neovim python3-neovim

    # Link neovim config to vim config
    mkdir -p "$HOME/.config/nvim"
    ln -snf "$SCRIPT_DIR/.vimrc" "$HOME/.config/nvim/init.vim"

    # Update alternatives
    if command -v update-alternatives &> /dev/null; then
        sudo update-alternatives --install /usr/bin/vi vi "$(which nvim)" 60 || true
        sudo update-alternatives --install /usr/bin/vim vim "$(which nvim)" 60 || true
        sudo update-alternatives --install /usr/bin/editor editor "$(which nvim)" 60 || true
    fi

    log_info "Neovim setup complete!"
    log_info "Plugins will auto-install on first run (lazy.nvim)"
    log_info "Use :Lazy to manage plugins and :Lazy restore to sync from lockfile"
}

# Install Python development tools
setup_python() {
    log_info "Setting up Python environment..."

    install_packages python3 python3-venv

    # Install uv (modern Python package manager)
    log_info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Source uv in current shell
    export PATH="$HOME/.cargo/bin:$PATH"

    # Install common Python tools with uv
    if command -v uv &> /dev/null; then
        log_info "Installing Python development tools with uv..."
        uv tool install black
        uv tool install flake8
        uv tool install pylint
        uv tool install isort
        uv tool install ty
        uv tool install ruff
    else
        log_warn "uv installation failed, skipping tool installation"
    fi

    log_info "Python setup complete!"
    log_info "Restart your shell or run: source ~/.zshrc"
}

# Install Go
setup_go() {
    log_info "Setting up Go environment..."

    # Install Go from official repository
    install_packages golang-go

    # Create Go workspace
    mkdir -p "$HOME/go/bin"

    log_info "Go setup complete!"
    log_info "Go workspace: $HOME/go"
}

# Install GPG and related tools
setup_gpg() {
    log_info "Setting up GPG..."

    install_packages gnupg2 gnupg-agent scdaemon pcscd

    log_info "GPG setup complete!"
}

# Install Ghostty terminal (if available)
setup_ghostty() {
    log_info "Checking for Ghostty terminal..."

    # Ghostty installation varies by version - check if it's already installed
    if command -v ghostty &> /dev/null; then
        log_info "Ghostty is already installed"
        return 0
    fi

    log_warn "Ghostty not found in PATH"
    log_info "Please install Ghostty manually from: https://ghostty.org"
    log_info "The Ghostty configuration is ready in .config/ghostty/"
}

# Install fonts
setup_fonts() {
    log_info "Setting up fonts..."

    install_packages fonts-firacode

    # Update font cache
    if command -v fc-cache &> /dev/null; then
        fc-cache -f
    fi

    log_info "Fonts setup complete!"
}

# Install git-delta (modern diff viewer)
setup_delta() {
    log_info "Setting up git-delta..."

    # Check if already installed
    if command -v delta &> /dev/null; then
        log_info "git-delta is already installed"
        return 0
    fi

    # Get the latest version tag
    log_info "Fetching latest git-delta release..."
    local version
    version=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

    if [ -z "$version" ]; then
        log_error "Failed to fetch git-delta version"
        return 1
    fi

    log_info "Installing git-delta ${version}..."

    # Download and install
    local deb_file="git-delta_${version}_amd64.deb"
    wget "https://github.com/dandavison/delta/releases/download/${version}/${deb_file}"
    sudo dpkg -i "${deb_file}"
    rm "${deb_file}"

    log_info "git-delta setup complete!"
}

# Install ast-grep (AST-based code searching and rewriting)
setup_ast_grep() {
    log_info "Setting up ast-grep..."

    # Check if already installed
    if command -v ast-grep &> /dev/null; then
        log_info "ast-grep is already installed"
        return 0
    fi

    # Get the latest version tag
    log_info "Fetching latest ast-grep release..."
    local version
    version=$(curl -fsSL https://api.github.com/repos/ast-grep/ast-grep/releases/latest | grep -oP '"tag_name": "\K[^"]+')

    if [ -z "$version" ]; then
        log_error "Failed to fetch ast-grep version"
        return 1
    fi

    log_info "Installing ast-grep ${version}..."

    # Download and install
    local arch="x86_64"
    local zip_file="ast-grep.zip"
    curl -fsSL -o "${zip_file}" "https://github.com/ast-grep/ast-grep/releases/download/${version}/app-x86_64-unknown-linux-gnu.zip"
    unzip -q "${zip_file}" sg
    sudo mv sg /usr/local/bin/ast-grep
    sudo chmod +x /usr/local/bin/ast-grep
    rm -f "${zip_file}"

    log_info "ast-grep setup complete!"
}

# Install Docker
setup_docker() {
    log_info "Setting up Docker..."

    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    # Add repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt update
    install_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker "$USER"

    log_info "Docker setup complete!"
    log_info "Logout and login for docker group membership to take effect"
}

# Install Kubernetes tools
setup_k8s() {
    log_info "Setting up Kubernetes tools..."

    # Install kubectl
    if ! command -v kubectl &> /dev/null; then
        log_info "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi

    # Install helm
    if ! command -v helm &> /dev/null; then
        log_info "Installing helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi

    log_info "Kubernetes tools setup complete!"
}

# Usage information
usage() {
    cat <<EOF
Modern dotfiles installer for Ubuntu 24.04/25.04

Usage: $(basename "$0") <command>

Commands:
    base        Install base packages and link dotfiles (includes fonts and Ghostty config)
    dev         Install development tools (Python with uv, Go)
    neovim      Install and configure Neovim with plugins
    docker      Install Docker
    k8s         Install Kubernetes tools (kubectl, helm)
    all         Install everything
    link        Just link dotfiles (no package installation)

Examples:
    $(basename "$0") base      # Minimal setup with modern tools
    $(basename "$0") all       # Full setup
    $(basename "$0") dev       # Add dev tools to existing setup
    $(basename "$0") neovim    # Just install Neovim
EOF
}

# Main installation logic
main() {
    local command="${1:-}"

    # Check Ubuntu version first
    check_ubuntu_version || exit 1

    case "$command" in
        base)
            setup_base
            setup_zsh
            setup_gpg
            ;;
        dev)
            setup_python
            setup_go
            ;;
        neovim)
            setup_neovim
            ;;
        docker)
            setup_docker
            ;;
        k8s)
            setup_k8s
            ;;
        all)
            setup_base
            setup_zsh
            setup_gpg
            setup_python
            setup_go
            setup_neovim
            setup_docker
            setup_k8s
            ;;
        link)
            link_dotfiles
            ;;
        *)
            usage
            exit 1
            ;;
    esac

    log_info "Done! 🎉"
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
