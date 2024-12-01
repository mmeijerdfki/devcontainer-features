
# Neovim (from appimage releases) (neovim-appimage)

A feature to install Neovim from appimage

## Example Usage

```json
"features": {
    "ghcr.io/mmeijerdfki/devcontainer-features/neovim-appimage:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | The version of Neovim to be installed (stable, nightly or a specific version in the format 'MAJOR.MINOR.PATCH' e.g. '0.9.5) | string | stable |
| neovimReleaseRepo | The repo to pull the release appimage from. The name has to be nvim.appimage! | string | neovim/neovim |

## Docker permissions

This Feature needs atleast `--cap-add SYS_ADMIN --device /dev/fuse` as a capability, otherwise fuse
cannot be used to the needed extend.
A `--privileged` container does work as well.

## OS Support

This Feature should work on recent versions of Debian/Ubuntu with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/mmeijerdfki/devcontainer-features/blob/main/src/neovim-appimage/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
