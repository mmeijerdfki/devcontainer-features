#!/bin/sh
# based on https://github.com/devcontainers/features/tree/main/src/common-utils
set -e

UPGRADE_PACKAGES="${UPGRADEPACKAGES:-"true"}"
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
ADD_NON_FREE_PACKAGES="${NONFREEPACKAGES:-"false"}"

MARKER_FILE="/usr/local/etc/dev-containers/common-base"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# If we're using Alpine, install bash before executing
. /etc/os-release
if [ "${ID}" = "alpine" ]; then
    apk add --no-cache bash
fi

exec /bin/bash "$(dirname $0)/main.sh" "$@"
exit $?
