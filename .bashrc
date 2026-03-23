# Copyright (C) 2023-2026 vdrip® GmbH. All rights reserved.
#
# This source code is protected under international copyright law. All rights
# reserved and protected by the copyright holders.
#
# This file is confidential and only available to authorized individuals with the
# permission of the copyright holders. If you encounter this file and do not have
# permission, please contact the copyright holders and delete this file.‌‍‍‌

__global_setup() {
  # Configure global directories
  export TMPDIR="$HOME/.tmp"
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
  export XDG_RUNTIME_DIR="$HOME/.run"
  export XDG_STATE_HOME="$HOME/.local/state"
  export XDG_CODESPACE_HOME="$HOME/.codespace"
  
  mkdir -p "$TMPDIR" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_RUNTIME_DIR" "$XDG_STATE_HOME" "$XDG_CODESPACE_HOME"

  # Check for required dependencies
  if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl to continue." >&2
    return 1
  fi

  if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git to continue." >&2
    return 1
  fi
}

__shell_setup() {
  # Activate codespace profile
  if [ -f "$XDG_CODESPACE_HOME/shell/install.sh" ]; then
    source "$XDG_CODESPACE_HOME/shell/install.sh"
  fi
}

__global_setup
__shell_setup
