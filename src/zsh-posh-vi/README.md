
# Zsh Posh Vi (zsh-posh-vi)

Installs zsh in vi mode with or without oh-my-posh as the prompt

## Example Usage

```json
"features": {
    "ghcr.io/mmeijerdfki/devcontainer-features/zsh-posh-vi:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| configureZshAsDefaultShell | Should zsh be the default? | boolean | false |
| configureOhMyPosh | When using zsh, configure oh my posh as the prompt? | boolean | true |
| poshInstallShCommitHash | From which commit should the oh my posh install.sh get retrieved | string | 5937cf8e3b76b58a9df890869a1c83f1538e448d |
| poshVersion | Tag oh my posh to specific version. Leaving this empty defaults to latest | string | - |

## OS Support

This Feature should work on recent versions of Debian/Ubuntu with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/mmeijerdfki/devcontainer-features/blob/main/src/zsh-posh-vi/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
