# Common base

A feature to install basic utilities for a dev container.
This is essentially a stripped down variant of
[common-utils](https://github.com/devcontainers/features/tree/main/src/common-utils).

## Example Usage

```json
"features": {
    "ghcr.io/mmeijerdfki/devcontainer-features/common-base:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| upgradePackages | Upgrade OS packages? | boolean | true |
| username | Enter name of a non-root user to configure or none to skip | string | automatic |
| userUid | Enter UID for non-root user | string | automatic |
| userGid | Enter GID for non-root user | string | automatic |
| nonFreePackages | Add packages from non-free Debian repository? (Debian only) | boolean | false |

## OS Support

This Feature should work on recent versions of Debian/Ubuntu, RedHat Enterprise Linux, Fedora, RockyLinux, and Alpine Linux.

## Using with dev container images

The **common-utils** Feature is used in many of the [dev container images](https://github.com/search?q=repo%3Adevcontainers%2Fimages+%22ghcr.io%2Fdevcontainers%2Ffeatures%2Fcommon-utils%22&type=code), as a result
these images have already allocated UID & GID 1000. Attempting to add this Feature with  UID 1000 and/or GID 1000 on top of such a dev container image will result in an error when building the dev container.

_Note: This file is based on the auto-generated [README.md](https://github.com/devcontainers/features/blob/main/src/common-utils/README.md).  Add additional notes to a `NOTES.md`._
