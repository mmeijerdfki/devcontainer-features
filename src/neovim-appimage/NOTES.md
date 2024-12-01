## Docker permissions

This Feature needs atleast `--cap-add SYS_ADMIN --device /dev/fuse` as a capability, otherwise fuse
cannot be used to the needed extend.
A `--privileged` container does work as well.

## OS Support

This Feature should work on recent versions of Debian/Ubuntu with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.
