# MIT Copyright (C) 2026 Nikolas Schröter. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the “Software”), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

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
  # Configure ZSH shell
  # https://github.com/orgs/community/discussions/148958
  export SHELL="/bin/zsh"
  export ZSH="$HOME/.oh-my-zsh"
  export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  export ZSH_THEME="powerlevel10k/powerlevel10k"

  # Install Oh My Zsh
  if [ ! -f "$ZSH/oh-my-zsh.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
  fi

  # Install Powerlevel10k theme
  if [ ! -d "$ZSH_CUSTOM/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/powerlevel10k"
  fi
  
  # Activate Oh My Zsh
  if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
  fi

  if [ -f "$HOME/.p10k.zsh" ]; then
    source "$HOME/.p10k.zsh"
  fi

  # Activate codespace profile
  if [ -f "$XDG_CODESPACE_HOME/shell/install.sh" ]; then
    source "$XDG_CODESPACE_HOME/shell/install.sh"
  fi
}

__global_setup
__shell_setup
