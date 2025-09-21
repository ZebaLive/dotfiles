#!/bin/bash
# Usage  curl -fsSL https://raw.githubusercontent.com/ZebaLive/dotfiles/refs/heads/arch/setup.sh | bash

# Clone the repo into ~
git clone https://github.com/ZebaLive/dotfiles.git ~/dotfiles

# Change to the repo directory
cd ~/dotfiles

# Run the arch install script
bash install-arch.sh