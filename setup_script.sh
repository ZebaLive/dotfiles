# Install packages
if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y stow git zsh curl zsh-syntax-highlighting zsh-autosuggestions
elif [  -f /etc/arch-release  ]; then
    sudo pacman -Syu --noconfirm stow git zsh curl
    yay -Syu --noconfirm zsh-syntax-highlighting zsh-autosuggestions
else
    echo "Unsupported Linux distribution."
    exit 1
fi


curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

curl -s https://ohmyposh.dev/install.sh | bash -s

git clone https://github.com/ZebaLive/dotfiles.git
cd dotfiles
stow .
cd ..

# Set zsh as the default shell for the current user
if command -v zsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)"
    echo "zsh has been set as your default shell. Please log out and log back in for changes to take effect."
else
    echo "Installation failed."
    exit 1
fi
