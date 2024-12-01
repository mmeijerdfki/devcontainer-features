#!/bin/sh
set -e

echo "Activating feature 'neovim-appimage'"

VERSION=${VERSION:-stable}
NEOVIM_RELEASE_REPO=${NEOVIMRELEASEREPO:-neovim/neovim}

echo "The version to be installed is: $VERSION"

# Debian / Ubuntu dependencies
install_debian_dependencies() {
  apt-get update -y
  apt-get -y install fuse curl

  apt-get -y clean
  rm -rf /var/lib/apt/lists/*
}

# ******************
# ** Main section **
# ******************

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

ADJUSTED_VERSION=$VERSION

if [  "$VERSION" != "stable" ] && [  "$VERSION" != "nightly" ]; then
    ADJUSTED_VERSION="v$VERSION"
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
# other distros to be implemented
# elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID}" = "mariner" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* || "${ID_LIKE}" = *"mariner"* ]]; then
  # todo
# elif [ "${ID}" = "alpine" ]; then
  # todo
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_dependencies
        ;;
esac

echo "Downloading neovim appimage ${ADJUSTED_VERSION}..."

nvim_download_url=https://github.com/${NEOVIM_RELEASE_REPO}/releases/download/${ADJUSTED_VERSION}/nvim.appimage
nvim_install_exe=/opt/nvim/nvim
mkdir -p /opt/nvim
http_response=$(curl -sfL "$nvim_download_url" -o "$nvim_install_exe" -w "%{http_code}")

if [ $http_response != "200" ] || [ ! -f $posh_install_script ]; then
    printf "Unable to download executable from ${nvim_download_url}\nPlease validate your curl, connection and/or proxy settings"
fi
chmod +x "$nvim_install_exe"

echo "Installed! Setting up PATH..."

echo 'export PATH=/opt/nvim${PATH:+:${PATH}}' >> "/etc/profile"
echo "Finished installing nvim-appimage!"
