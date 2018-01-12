#!/bin/bash
# The script can be sourced or run with args
#
# Usage: run 'installer.sh sudo' as root
#        run 'installer.sh base' as user
#

# source: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

# non interactive package configuration
export DEBIAN_FRONTEND=noninteractive

# cleanup after package installation
clean_apt() {
    sudo apt autoremove
    sudo apt autoclean
    sudo apt clean
}

# get the script location
get_script_dir() {
    SOURCE="${BASH_SOURCE[0]}"
     while [ -h "$SOURCE" ]; do
          DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
          SOURCE="$(readlink "$SOURCE")"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
     echo "$DIR"
}
DIRSELF="$(get_script_dir)"

# remove default junk
clean_home() {
    rmdir Videos Pictures Public Music
    rm -f examples.desktop
}

# test command rc with euxo mode on
test_cmd() {
    local cmd=$@
    local rc=0
    $cmd > /dev/null 2>&1 || rc=$? && true
    return $rc
}

# run apt update if none has been run recently
lazy_update() {
    if [ $(expr $(date +%s) - $(stat -c %Y /var/lib/apt/lists/partial)) \
         -gt 600 ]; then
        sudo apt update
    fi
}

# install dotfiles to $HOME, accept list of path
link_to_home() {
    local files=("$@")
    [ ${#files[@]} -eq 0 ] && return 1
    for src in "${files[@]}"; do
        fp_src="${DIRSELF}/${src}"
        if [ -e "$fp_src" ]; then
            ln -snf "$fp_src" "$HOME"
        fi
    done
}

# install sudo, requires root
setup_sudo() {
    test_cmd sudo -v || {
        # If not root, exit
        if [ "$EUID" -ne 0 ]; then
            echo Run the following as root
            echo 'su -c "(source installer.sh; setup_sudo)"'
            return 1
        fi

        # install the sudo package
        apt update
        apt install -y sudo --no-install-recommends
    }

    # add mdeferran system account
    test_cmd id mdeferran || sudo useradd mdeferran

    # add mdeferran to sudoers
    sudo usermod -a -G sudo mdeferran
    sudo gpasswd -a mdeferran systemd-journal
    sudo gpasswd -a mdeferran systemd-network
    local line='mdeferran ALL=(ALL) NOPASSWD:ALL'
    test_cmd grep mdeferran /etc/sudoers || \
        sudo sed -i "\$a$line" /etc/sudoers
}

# install base package
setup_base() {
    lazy_update
    sudo apt install -y git tmux rsync lsof net-tools silversearcher-ag \
        zip unzip dnsutils apt-transport-https ca-certificates lsb-release \
        curl less openssh-client \
        --no-install-recommends

    link_to_home .gitconfig .tmux.conf .agignore

    link_to_home .zshrc_helpers
}

# install ZSH
setup_zsh() {
    sudo apt install -y zsh --no-install-recommends

    # Install ZSH Antigen
    curl -L git.io/antigen > $HOME/.antigen.zsh

    # Install dotfiles
    link_to_home .zshrc .zsh .zsh-dircolors.config .antigenrc

    # set ZSH as user shell
    sudo usermod -s /bin/zsh mdeferran

    # Add default python for Git prompt info
    sudo apt install -y python-minimal --no-install-recommends
}

# install python playground
setup_python() {
    lazy_update
    sudo apt install -y \
            python3-pip \
            python3-setuptools \
            --no-install-recommends

    # virtualenvwrapper
    pip3 install -U wheel
    pip3 install -U virtualenvwrapper

    # create venv directory
    install -d $HOME/.virtualenvs

    link_to_home .zshrc_python
}

# install neovim
setup_neovim() {
    # add pkg repo
    cat <<-EOF | sudo tee /etc/apt/sources.list.d/neovim.list
    deb http://ppa.launchpad.net/neovim-ppa/unstable/ubuntu xenial main
    deb-src http://ppa.launchpad.net/neovim-ppa/unstable/ubuntu xenial main
EOF

    # add the git-core ppa gpg key
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24

    # add the neovim ppa gpg key
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 9DBB0BE9366964F134855E2255F96FCF8231B6DD

    # actually install the package
    sudo apt update
    sudo apt install -y neovim

    # install .vimrc files
    link_to_home .vimrc

    # install vim-plug
    curl -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # alias vim dotfiles to neovim
    mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}"
    ln -snf "${HOME}/.vim" "${XDG_CONFIG_HOME}/nvim"
    ln -snf "${DIRSELF}/.vimrc" "${XDG_CONFIG_HOME}/nvim/init.vim"

    # update alternatives to neovim
    sudo update-alternatives --install /usr/bin/vi vi "$(which nvim)" 60
    sudo update-alternatives --config vi --skip-auto
    sudo update-alternatives --install /usr/bin/vim vim "$(which nvim)" 60
    sudo update-alternatives --config vim --skip-auto
    sudo update-alternatives --install /usr/bin/editor editor "$(which nvim)" 60
    sudo update-alternatives --config editor --skip-auto

    # install things needed for deoplete for vim
    lazy_update
    sudo apt install -y \
            python3-pip \
            python3-setuptools \
            --no-install-recommends

    # install python lib deps
    pip3 install -U wheel
    pip3 install -U neovim flake8

    # install the plugins
    vim +PlugInstall +qall
}

# install crypto things
setup_gpg() {
    cat <<-EOF | sudo tee -a /etc/apt/sources.list.d/yubiko.list
    # yubico
    deb http://ppa.launchpad.net/yubico/stable/ubuntu xenial main
    deb-src http://ppa.launchpad.net/yubico/stable/ubuntu xenial main
EOF

    # add the yubico ppa gpg key
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 3653E21064B19D134466702E43D5C49532CBA1A9

    # TODO yubico-piv-tool ykpersonalize ykman
    # https://github.com/drduh/YubiKey-Guide

    # install packages
    sudo apt update
    sudo apt install -y gnupg gnupg2 gnupg-agent scdaemon

    # use GPG agent as SSH agent
    sudo sed -i "s/^use-ssh-agent/# use-ssh-agent/" /etc/X11/Xsession.options
    link_to_home .zshrc_gpg
    install -d ${HOME}/.gnupg
    ln -snf "${DIRSELF}/.gnupg/gpg-agent.conf" "${HOME}/.gnupg/"
    ln -snf "${DIRSELF}/.gnupg/gpg.conf" "${HOME}/.gnupg/"
}

# install i3
setup_wm() {
    lazy_update
    sudo apt install -y i3 i3lock i3status scrot suckless-tools \
	xfonts-terminus sakura rxvt-unicode-256color scrot slop --no-install-recommends

    # alias vim dotfiles to neovim
    mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}"
    ln -snf "${DIRSELF}/.config/i3" "${XDG_CONFIG_HOME}/i3"
    ln -snf "${DIRSELF}/.config/sakura" "${XDG_CONFIG_HOME}/sakura"

    sudo update-alternatives --install /usr/bin/x-window-manager x-window-manager /usr/bin/i3 20
}

# install go playground
setup_go() {
    # add GO env to .zshrc
    link_to_home .zshrc_go
}

# install ops: ansible, awscli, awless
setup_ops() {
    # Install from Github
    go get -u github.com/wallix/awless

    # add AWS and ansible env to .zshrc
    link_to_home .zshrc_ops
}

# install android dev env
setup_android() {
    # add JAVA and Android env to .zshrc
    link_to_home .zshrc_android
}

usage() {
    echo "installer.sh  usage|nase|wm|extra|clean  # as normal user"
    echo "installer.sh  sudo                       # as root"
}

# main when interactive
main() {
    local cmd=${1:-usage}

    if [[ $cmd == "usage" ]]; then
        usage
        exit 1

    elif [[ $cmd == "sudo" ]]; then
        setup_sudo

    elif [[ $cmd == "base" ]]; then
        setup_base
        setup_zsh
        setup_python
        setup_neovim

    elif [[ $cmd == "wm" ]]; then
        setup_wm

    elif [[ $cmd == "extra" ]]; then
        setup_gpg
        setup_go
        setup_ops

    elif [[ $cmd == "clean" ]]; then
        clean_home
        clean_apt
    fi
}

# Call main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
