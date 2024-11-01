## OS Support

This Feature should work on recent versions of Debian/Ubuntu, RedHat Enterprise Linux, Fedora, RockyLinux, and Alpine Linux.

## Using with dev container images

The **common-utils** Feature is used in many of the [dev container images](https://github.com/search?q=repo%3Adevcontainers%2Fimages+%22ghcr.io%2Fdevcontainers%2Ffeatures%2Fcommon-utils%22&type=code), as a result
these images have already allocated UID & GID 1000. Attempting to add this Feature with  UID 1000 and/or GID 1000 on top of such a dev container image will result in an error when building the dev container.
