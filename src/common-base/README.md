
# Common Base (common-base)

Installs a set of common command line utilities and sets up a non-root user on devcontainer.

## Example Usage

```json
"features": {
    "ghcr.io/mmeijerdfki/devcontainer-features/common-base:0": {}
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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/mmeijerdfki/devcontainer-features/blob/main/src/common-base/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
