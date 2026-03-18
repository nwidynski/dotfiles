# Copyright (C) 2023-2026 vdrip® GmbH. All rights reserved.
#
# This source code is protected under international copyright law. All rights
# reserved and protected by the copyright holders.
#
# This file is confidential and only available to authorized individuals with the
# permission of the copyright holders. If you encounter this file and do not have
# permission, please contact the copyright holders and delete this file.‌‍‍‌

__mise_setup() {
  # Configure mise-en-place
  export MISE_AUTO_ACTIVATE=0
  export MISE_BIN_DIR="$XDG_DATA_HOME/mise/bin"
  export MISE_CACHE_DIR="$XDG_CACHE_HOME/mise"
  export MISE_CONFIG_DIR="$XDG_CODESPACE_HOME/mise"
  export MISE_DATA_DIR="$XDG_DATA_HOME/mise"
  export MISE_GLOBAL_CONFIG_FILE="$MISE_CONFIG_DIR/mise.toml"
  export MISE_INSTALLS_DIR="$XDG_DATA_HOME/mise/installs"
  export MISE_INSTALL_PATH="$XDG_DATA_HOME/mise/mise"
  export MISE_LOG_FILE="$TMPDIR/mise/mise.log"
  export MISE_PLUGINS_DIR="$XDG_DATA_HOME/mise/plugins"
  export MISE_STATE_DIR="$XDG_STATE_HOME/mise"
  export MISE_TMP_DIR="$TMPDIR/mise"
  export MISE_TRUSTED_CONFIG_PATHS="$MISE_CONFIG_DIR"

  # Install mise-en-place
  if [ ! -f "$MISE_INSTALL_PATH" ]; then
    local version=${MISE_VERSION}

    if [ -f "$MISE_GLOBAL_CONFIG_FILE" ]; then
      version=$(sed -n 's/^min_version *= *"\([^"]*\)".*/\1/p' "$MISE_GLOBAL_CONFIG_FILE")
    fi

    curl -fsSL https://mise.run | MISE_VERSION="$version" MISE_INSTALL_HELP=0 sh
  fi

  # Clean orphaned aliases, since we re-create them
  if [ -d "$MISE_BIN_DIR" ]; then
    rm -rf "$MISE_BIN_DIR"
  fi

  # Configure mise-en-place directories
  mkdir -p "$MISE_BIN_DIR" "$MISE_PLUGINS_DIR"

  # Symlink mise-en-place itself
  if [ ! -f "$MISE_BIN_DIR/mise" ]; then
    ln -sf "$MISE_INSTALL_PATH" "$MISE_BIN_DIR/mise"
  fi

  # Install plugins
  "$MISE_INSTALL_PATH" plugins ls | while IFS= read -r plugin; do
    if [ ! -d "$MISE_PLUGINS_DIR/$plugin" ]; then 
      "$MISE_INSTALL_PATH" plugins install "$plugin"
    fi
  done

  # Install environment toolchain
  if [ -n "$("$MISE_INSTALL_PATH" ls fnox --missing)" ]; then
    "$MISE_INSTALL_PATH" install fnox
  fi

  # Activate environment
  eval "$("$MISE_INSTALL_PATH" env ${ZSH_VERSION:+zsh}${BASH_VERSION:+bash})"

  # Install toolchain
  if [ -n "$("$MISE_INSTALL_PATH" ls --missing)" ]; then
    "$MISE_INSTALL_PATH" install
  fi

  # Activate toolchain
  if [ "$MISE_AUTO_ACTIVATE" = "1" ]; then
    eval "$("$MISE_INSTALL_PATH" activate ${ZSH_VERSION:+zsh}${BASH_VERSION:+bash})"
  fi

  # Configure docker compose plugin
  # See: https://github.com/jdx/mise/discussions/5950
  if command -v docker-cli-plugin-docker-compose &> /dev/null; then
    DOCKER_COMPOSE_PATH=$( command -v docker-cli-plugin-docker-compose )
    DOCKER_COMPOSE_PLUGINS_DIR="${DOCKER_CONFIG:-$HOME/.docker}/cli-plugins"

    mkdir -p "$DOCKER_COMPOSE_PLUGINS_DIR"
    ln -sf "$DOCKER_COMPOSE_PATH" "$DOCKER_COMPOSE_PLUGINS_DIR/docker-compose"
  fi

  # Configure mise-en-place shell aliases
  "$MISE_INSTALL_PATH" shell-alias ls | while IFS= read -r alias; do
    local bin=$(echo "$alias" | awk '{print $1}')
    local command=$(echo "$alias" | awk '{$1=""; sub(/^ /, ""); print}')

    [ -z "$bin" ] && continue
    [ -z "$command" ] && continue

    echo "$command \"\$@\"" > "$MISE_BIN_DIR/$bin"
    chmod +x "$MISE_BIN_DIR/$bin"
  done

  # Add custom executables to PATH
  export PATH="$MISE_BIN_DIR:$PATH"
}

__global_setup
__mise_setup