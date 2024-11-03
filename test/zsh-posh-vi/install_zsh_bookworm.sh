#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "version-zsh" zsh --version
check "version-posh" oh-my-posh --version

# Report results
reportResults
