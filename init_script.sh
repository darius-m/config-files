#!/bin/sh

set -u

PROGNAME="${0}"

BASIC_PACKAGES="git vim zsh tmux gcc make "
MEDIUM_PACKAGES="htop unzip zip gcc-multilib firefox termite zathura pstree cscope ctags"
FULL_PACKAGES="texlive-full inkscape gimp chromium-browser i3 i3blocks polybar
    xautolock lm-sensors filezilla gnome-screenshot pavucontrol fzf gnome-terminal
    gparted virtualbox virtualbox-ext-pack openvpn ntpdate vinagre thunderbird
    graphicsmagick scrot compton hexchat ttf-mscorefonts-installer
"
FAILED_PACKAGES=""

PKGMGRS="apt apt-get yum pkg pacman"

usage() {
	eval 1>&2

	printf -- "Usage: %s [-bfhmuU]\n" ${PROGNAME}
	printf -- "\n"
	printf -- "Options:\n"
	printf -- "  -b	Install basic packages (default)\n"
	printf -- "  -m	Install basic and some complex packages\n"
	printf -- "  -f	Install all packages (full) install\n"
	printf -- "  -h	Show this help message\n"
	printf -- "  -u	Update repositories before installing\n"
	printf -- "  -U	Upgrade installed packages\n"

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
		if [ ${PKGMGR} = pacman ]; then
			INSTALL=-Sy
			UPDATE=-Syu
			UPGRADE=-U
			NOCONFIRM=--noconfirm
		else
			INSTALL=install
			UPDATE=update
			UPGRADE=upgrade
			NOCONFIRM=-y
		fi
		break
	fi
done

if [ -z "${PKGMGR}" ]; then
	echo "Unknown package manager!" 1>&2
	exit 3
fi

while getopts "bdfhmuU" opt; do
	case "${opt}" in
	b) INSTALL_BASIC=1 ;;
	m) INSTALL_BASIC=1; INSTALL_MEDIUM=1 ;;
	d) DELETE_CONF=1 ;;
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

install() {
	for PACKAGE in "$@"; do
		if ! ${PKGMGR} ${INSTALL} ${NOCONFIRM} "${PACKAGE}"; then
			FAILED_PACKAGES="${FAILED_PACKAGES} ${PACKAGE}"
		fi
	done
}

if [ ${UPDATE_REPOS:-0} -eq 1 ]; then
	${PKGMGR} ${UPDATE}
fi

if [ ${INSTALL_BASIC:-0} -eq 1 ]; then
	install ${BASIC_PACKAGES}
fi

if [ ${INSTALL_MEDIUM:-0} -eq 1 ]; then
	install ${MEDIUM_PACKAGES}
fi

if [ ${INSTALL_FULL:-0} -eq 1 ]; then
	install ${FULL_PACKAGES}
fi

if [ ${UPGRADE_PACKAGES:-0} -eq 1 ]; then
	${PKGMGR} ${UPGRADE} ${NOCONFIRM}
fi

if [ ! -z "${SUDO_USER:-}" ]; then
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

DELCMD=""
if [ ${DELETE_CONF:-0} -eq 0 ]; then
	echo -n 'Delete the config files: '
	echo -n '~/.vimrc ~/.i3 ~/.vim ~/.tmux.conf ~/.zshrc ~/.config/i3blocks ~/.config/termite ~/.config/polybar ? '
	read ANSWER

	case ${ANSWER} in
		y*|Y*) DELETE_CONF=1 ;;
	esac
fi

if [ ${DELETE_CONF:-0} -eq 1 ]; then
	DELCMD="rm -rf ~/.i3 ~/.vimrc ~/.vim ~/.tmux.conf ~/.zshrc ~/.config/i3blocks ~/.config/termite ~/.config/polybar"
fi

# Perform a font cache refresh after installing the mscore fonts
fc-cache -fv

su "${FOR_USER}" -c "
# Get the configuration files and install them
if [ -d ~/.config-files.git ]; then
    pushd ~/.config-files.git
    git pull origin master || exit 1
    popd
else
    git clone https://github.com/darius-m/config-files ~/.config-files.git
fi

${DELCMD}

mkdir -p ~/.config/
command -v vim > /dev/null && ln -s ~/.config-files.git/vim/_vim ~/.vim && ln -s ~/.config-files.git/vim/_vimrc ~/.vimrc
command -v tmux > /dev/null && ln -s ~/.config-files.git/_tmux.conf ~/.tmux.conf
command -v zsh > /dev/null && ln -s ~/.config-files.git/_zshrc ~/.zshrc
command -v termite > /dev/null && ln -s ~/.config-files.git/_config/termite ~/.config/termite
command -v polybar > /dev/null && ln -s ~/.config-files.git/_config/polybar ~/.config/polybar
command -v i3 > /dev/null && ln -s ~/.config-files.git/_i3 ~/.i3
command -v i3blocks > /dev/null && ln -s ~/.config-files.git/_config/i3blocks ~/.config/i3blocks
command -v compton > /dev/null && ln -s ~/.config-files.git/_config/compton.conf ~/.config/compton.conf
command -v zathura > /dev/null && xdg-mime default zathura.desktop application/pdf
"

if [ ! -z "${FAILED_PACKAGES}" ]; then
	printf '\e[1;31mFailed to install:%s\e[m\n' "${FAILED_PACKAGES}"
fi

echo -n 'Do you want zsh as the default shell? [y/N] '
read ANSWER

case "${ANSWER}" in
	y*|Y*) chsh -s "$(command -v zsh)" "${FOR_USER}"
esac
