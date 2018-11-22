#!/bin/sh

PROGNAME="${0}"

BASIC_PACKAGES="git vim zsh tmux gcc make"
MEDIUM_PACKAGES="htop unzip zip gcc-multilib"
FULL_PACKAGES="texlive-full inkscape gimp chromium-browser"

PKGMGRS="apt apt-get yum pkg"

usage() {
    eval 1>&2

    printf -- "Usage: %s [-bfhmuU]\n" ${PROGNAME}
    printf -- "\n"
    printf -- "Options:\n"
    printf -- "  -b    Install basic packages (default)\n"
    printf -- "  -m    Install basic and some complex packages\n"
    printf -- "  -f    Install all packages (full) install\n"
    printf -- "  -h    Show this help message\n"
    printf -- "  -u    Update repositories before installing\n"
    printf -- "  -U    Upgrade installed packages\n"

    exit ${1}
}

if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as administrator" 1>&2
    echo "Use 'sudo ${PROGNAME}' or switch user to root before running" 1>&2
    exit 2
fi

for P in ${PKGMGRS}; do
    if command -v ${P} 2>&1 >/dev/null; then
        PKGMGR=${P}
        break
    fi
done

if [ -z "${PKGMGR}" ]; then
    echo "Unknown package manager!" 1>&2
    exit 3
fi

while getopts "bfhmuU" opt; do
    case "${opt}" in
    b) INSTALL_BASIC=1 ;;
    m) INSTALL_BASIC=1; INSTALL_MEDIUM=1;;
    f) INSTALL_BASIC=1; INSTALL_MEDIUM=1; INSTALL_FULL=1 ;;
    u) UPDATE_REPOS=1 ;;
    U) UPGRADE_PACKAGES=1 ;;
    h) usage 0 ;;
    *) usage 1 ;;
    esac
done

if [ $# -eq 0 ]; then
    INSTALL_BASIC=1
fi

if [ ${UPDATE_REPOS:-0} -eq 1 ]; then
    ${PKGMGR} update
fi

if [ ${INSTALL_BASIC:-0} -eq 1 ]; then
    ${PKGMGR} install -y ${BASIC_PACKAGES}
fi

if [ ${INSTALL_MEDIUM:-0} -eq 1 ]; then
    ${PKGMGR} install -y ${MEDIUM_PACKAGES}
fi

if [ ${INSTALL_FULL:-0} -eq 1 ]; then
    ${PKGMGR} install -y ${FULL_PACKAGES}
fi

if [ ${UPGRADE_PACKAGES:-0} -eq 1 ]; then
    ${PKGMGR} upgrade -y
fi

if [ ! -z "${SUDO_USER}" ]; then
    FOR_USER="${SUDO_USER}"
else
    echo "Command not ran using sudo. Using 'logname' in stead" 1>&2
    FOR_USER="$(logname)"
fi

# Configuration files should be placed for the regular user
if [ -z "${FOR_USER}" ]; then
    echo "Could not get user who ran the script!" 1>&2
    exit 4
fi

su "${FOR_USER}" -c "
# Get the configuration files and install them
git clone https://github.com/darius-m/vim ~/.vim.git
git clone https://github.com/darius-m/config-files ~/.config-files.git
mv -T -v ~/.vim.git/_vimrc ~/.vimrc
mv -T -v ~/.vim.git/_vim ~/.vim
mv -T -v ~/.config-files.git/_tmux.conf ~/.tmux.conf
mv -T -v ~/.config-files.git/_zshrc ~/.zshrc
rm -rf ~/.vim.git
rm -rf ~/.config-files.git
"

echo -n 'Do you want zsh as the default shell? [y/N] '
read ANSWER

case "${ANSWER}" in
    y*|Y*) chsh -s "$(command -v zsh)" "${FOR_USER}"
esac
