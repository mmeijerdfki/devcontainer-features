#!/bin/bash
# based on https://github.com/devcontainers/features/tree/main/src/common-utils
set -e

CONFIGURE_ZSH_AS_DEFAULT_SHELL="${CONFIGUREZSHASDEFAULTSHELL:-"false"}"
CONFIGURE_OH_MY_POSH="${CONFIGUREOHMYPOSH:-"true"}"
POSH_INSTALLSH_COMMIT_HASH="${POSHINSTALLSHCOMMITHASH:-"5937cf8e3b76b58a9df890869a1c83f1538e448d"}"
POSH_VERSION="${POSHVERSION:-""}"

MARKER_FILE="/usr/local/etc/dev-containers/zsh-posh-vi"
TMP_DIR=$(mktemp -d)

FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Debian / Ubuntu packages
install_debian_zsh() {
    # Ensure apt is in non-interactive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get install -y zsh

    # Clean up
    apt-get -y clean
    rm -rf /var/lib/apt/lists/*
    ZSH_ALREADY_INSTALLED="true"
}

# RedHat / RockyLinux / CentOS / Fedora packages
install_redhat_zsh() {
    local package_list=""
    local remove_epel="false"
    local install_cmd=microdnf
    if ! type microdnf > /dev/null 2>&1; then
        install_cmd=dnf
        if ! type dnf > /dev/null 2>&1; then
            install_cmd=yum
        fi
    fi

    # Install zsh if needed
    if ! type zsh > /dev/null 2>&1; then
        package_list="${package_list} zsh"
    fi

    if [ -n "${package_list}" ]; then
        ${install_cmd} -y install ${package_list}
    fi

    ZSH_ALREADY_INSTALLED="true"
}

# Alpine Linux packages
install_alpine_zsh() {
    apk update

    apk add --no-cache zsh
    ZSH_ALREADY_INSTALLED="true"
}

# ******************
# ** Main section **
# ******************

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Load markers to see which steps have already run
if [ -f "${MARKER_FILE}" ]; then
    echo "Marker file found:"
    cat "${MARKER_FILE}"
    source "${MARKER_FILE}"
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID}" = "mariner" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* || "${ID_LIKE}" = *"mariner"* ]]; then
    ADJUSTED_ID="rhel"
    VERSION_CODENAME="${ID}${VERSION_ID}"
elif [ "${ID}" = "alpine" ]; then
    ADJUSTED_ID="alpine"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

if [ "${ADJUSTED_ID}" = "rhel" ] && [ "${VERSION_CODENAME-}" = "centos7" ]; then
    # As of 1 July 2024, mirrorlist.centos.org no longer exists.
    # Update the repo files to reference vault.centos.org.
    sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
    sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
    sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
fi

if [ "${ADJUSTED_ID}" = "rhel" ] && [ "${VERSION_CODENAME-}" = "centos7" ]; then
    # As of 1 July 2024, mirrorlist.centos.org no longer exists.
    # Update the repo files to reference vault.centos.org.
    sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
    sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
    sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
fi

# Install packages for appropriate OS
if [ "${ZSH_ALREADY_INSTALLED}" != "true" ]; then
    case "${ADJUSTED_ID}" in
        "debian")
            install_debian_zsh
            ;;
        "rhel")
            install_redhat_zsh
            ;;
        "alpine")
            install_alpine_zsh
            ;;
    esac
fi

# assume that atleast the root user is present
USERNAME="$(getent passwd \
            $(seq $(awk '/^UID_MIN/ {print $2}' /etc/login.defs) $(awk '/^UID_MAX/ {print $2}' /etc/login.defs))\
            | head -n1 | awk -F ':' '{print $1}')"

if [ -z "$USERNAME" ]; then
    USERNAME="root"
fi
group_name="$(id -gn $USERNAME)"

# *********************************
# ** Shell customization section **
# *********************************

if [ "${USERNAME}" = "root" ]; then
    user_home="/root"
# Check if user already has a home directory other than /home/${USERNAME}
elif [ "/home/${USERNAME}" != $( getent passwd $USERNAME | cut -d: -f6 ) ]; then
    user_home=$( getent passwd $USERNAME | cut -d: -f6 )
else
    user_home="/home/${USERNAME}"
    if [ ! -d "${user_home}" ]; then
        mkdir -p "${user_home}"
        chown ${USERNAME}:${group_name} "${user_home}"
    fi
fi

# Restore user .bashrc / .profile / .zshrc defaults from skeleton file if it doesn't exist or is empty
possible_rc_files=( ".bashrc" ".profile" ".zprofile" ".zshrc" )
for rc_file in "${possible_rc_files[@]}"; do
    if [ -f "/etc/skel/${rc_file}" ]; then
        if [ ! -e "${user_home}/${rc_file}" ] || [ ! -s "${user_home}/${rc_file}" ]; then
            cp "/etc/skel/${rc_file}" "${user_home}/${rc_file}"
            chown ${USERNAME}:${group_name} "${user_home}/${rc_file}"
        fi
    fi
done

# configure zsh
if [ ! -f "${user_home}/.zprofile" ] && [ "${ZSH_BASE_ALREADY_CONFIGURED}" != "true" ] ; then
    touch "${user_home}/.profile"
    ln -s "${user_home}/.profile" "${user_home}/.zprofile"
    chown ${USERNAME}:${group_name} "${user_home}/.zprofile" "${user_home}/.profile"

    zsh_config_dir="${user_home}/.config/zsh"
    if [ ! -d "${zsh_config_dir}" ]; then
        install -d -o "${USERNAME}" -g "${group_name}" -m 0755 "$zsh_config_dir"
    fi

    # copy over default config
    cp -f "${FEATURE_DIR}/config/.zshrc" "$zsh_config_dir"
    chown ${USERNAME}:${group_name} "${zsh_config_dir}/.zshrc"

    # set some default options for xdg directories
    printf '\n# XDG_PATHS and config directories\n' >> "${user_home}/.profile"
    echo 'export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"' >> "${user_home}/.profile"
    echo 'export XDG_CONFIG_HOME="$HOME/.config"' >> "${user_home}/.profile"
    echo 'export XDG_DATA_HOME="$HOME/.local/share"' >> "${user_home}/.profile"
    echo 'export XDG_CACHE_HOME="$HOME/.cache"' >> "${user_home}/.profile"
    echo 'export XDG_STATE_HOME="$HOME/.local/share"' >> "${user_home}/.profile"

    # Copy to root user if atleast one non-root user is present
    if [ "${USERNAME}" != "root" ]; then
        user_files=("$zsh_config_dir" "${user_home}/.profile")

        # remove the first two components of the path
        root_files=("${user_files[@]#/*/*/}")

        # prepend /root/ on those elements
        root_files=("${root_files[@]/#//root/}")

        # remove the last part to make sure files are correctly copied
        root_files=("$(dirname ${root_files[@]})")

        for (( i=0; i<${#root_files[*]}; ++i)); do
            if [ ! -f "${user_files[$i]}" ]; then
                mkdir -p "${root_files[$i]}"
            fi
            cp -rf "${user_files[$i]}" "${root_files[$i]}"
        done
        chown -R root:root "${root_files[@]}"

        ln -s "/root/.profile" "/root/.zprofile"
    fi

    if [ "${CONFIGURE_ZSH_AS_DEFAULT_SHELL}" == "true" ]; then
    # Fixing chsh always asking for a password on alpine linux
    # ref: https://askubuntu.com/questions/812420/chsh-always-asking-a-password-and-get-pam-authentication-failure.
    if [ ! -f "/etc/pam.d/chsh" ] || ! grep -Eq '^auth(.*)pam_rootok\.so$' /etc/pam.d/chsh; then
        echo "auth sufficient pam_rootok.so" >> /etc/pam.d/chsh
    elif [[ -n "$(awk '/^auth(.*)pam_rootok\.so$/ && !/^auth[[:blank:]]+sufficient[[:blank:]]+pam_rootok\.so$/' /etc/pam.d/chsh)" ]]; then
        awk '/^auth(.*)pam_rootok\.so$/ { $2 = "sufficient" } { print }' /etc/pam.d/chsh > /tmp/chsh.tmp && mv /tmp/chsh.tmp /etc/pam.d/chsh
    fi

    chsh --shell /bin/zsh ${USERNAME}
fi

    ZSH_BASE_ALREADY_CONFIGURED="true"
fi


## rebuild to use oh my posh
if [ "${CONFIGURE_OH_MY_POSH}" == "true" ] && [ "$OHMYPOSH_ALREADY_CONFIGURED" != "true" ]; then
    # fetch the installation script from github
    posh_download_url="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/${POSH_INSTALLSH_COMMIT_HASH}/website/static/install.sh"
    posh_install_script="${TMP_DIR}/install.sh"

    posh_install_dir="${user_home}/.local/bin"
    posh_themes_dir="${user_home}/.config/zsh/ohmyposh"

    http_response=$(curl -s -f -L "$posh_download_url" -o "$posh_install_script" -w "%{http_code}")
    chmod +x "$posh_install_script"

    if [ $http_response != "200" ] || [ ! -f $posh_install_script ]; then
        printf "Unable to download executable from ${posh_download_url}\nPlease validate your curl, connection and/or proxy settings"
    fi

    # make sure the install folder is set up
    if [ ! -d "${posh_install_dir}" ]; then
        install -d -o "${USERNAME}" -g "${group_name}" -m 0755 "$posh_install_dir"
    fi

    if [ ! -d "$posh_themes_dir" ]; then
        install -d -o "${USERNAME}" -g "${group_name}" -m 0755 "$posh_themes_dir"
    fi

    # install oh-my-posh using the provided install script
    TMP_HOME="$HOME"
    HOME="${user_home}"
    $posh_install_script -d "$posh_install_dir" -t "$posh_themes_dir" -v "${POSH_VERSION}"

    HOME="$TMP_HOME"

    if [ ! -f "${posh_install_dir}/oh-my-posh" ]; then
        printf "Something went wrong while installing oh-my-posh. Retry or report to the maintainer of the zsh-posh-vi feature repo!"
        exit 1
    fi

    # add default zen theme
    cp -f "${FEATURE_DIR}/config/zen.toml" "$posh_themes_dir"
    chown ${USERNAME}:${group_name} "${posh_themes_dir}/zen.toml"

    # configure oh my posh prompt in zshrc if not already present
    eval_string='eval "$(oh-my-posh init zsh --config $HOME/.config/zsh/ohmyposh/zen.toml)"'
    if [ -z "$(grep -F "$eval_string" "${user_home}/.config/zsh/.zshrc")" ]; then
        echo "$eval_string" >> "${user_home}/.config/zsh/.zshrc"
    fi

    echo 'export PATH=$HOME/.local/bin:${PATH:+:${PATH}}' >> "${user_home}/.profile"

    # Copy to root user if atleast one non-root user is present
    if [ "${USERNAME}" != "root" ]; then
        user_files=("${posh_install_dir}" "${posh_themes_dir}")

        # remove the first two components of the path
        root_files=("${user_files[@]#/*/*/}")

        # prepend /root/ on those elements
        root_files=("${root_files[@]/#//root/}")

        # remove the last part to make sure files are correctly copied
        root_files=("$(dirname ${root_files[@]})")

        for (( i=0; i<${#root_files[*]}; ++i)); do
            if [ -d "${user_files[$i]}" ]; then
                mkdir -p "${root_files[$i]}"
            else
                mkdir -p "$(dirname ${root_files[$i]})"
            fi
            cp -rf "${user_files[$i]}" "${root_files[$i]}"
        done
        chown -R root:root "${root_files[@]}"
    fi
    OHMYPOSH_ALREADY_CONFIGURED="true"
fi

# ****************************
# ** Utilities and commands **
# ****************************

# Write marker file
if [ ! -d "/usr/local/etc/dev-containers" ]; then
    mkdir -p "$(dirname "${MARKER_FILE}")"
fi

echo -e "\
    OHMYPOSH_ALREADY_CONFIGURED=${OHMYPOSH_ALREADY_CONFIGURED}\n
    ZSH_ALREADY_INSTALLED=${ZSH_ALREADY_INSTALLED}\n
    ZSH_BASE_ALREADY_CONFIGURED=${ZSH_BASE_ALREADY_CONFIGURED}" > "${MARKER_FILE}"

echo "Done!"
