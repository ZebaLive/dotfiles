#!/bin/bash

# Dotfiles Installation Script for Arch Linux
# This script installs all required packages for the Hyprland + Catppuccin setup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
check_arch() {
    if ! command -v pacman &> /dev/null; then
        print_error "This script is designed for Arch Linux. pacman not found."
        exit 1
    fi
    print_success "Arch Linux detected"
}

# Check if AUR helper is installed
check_aur_helper() {
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
        print_success "yay found as AUR helper"
        elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
        print_success "paru found as AUR helper"
    else
        print_warning "No AUR helper found. Installing yay..."
        install_yay
    fi
}

# Install yay AUR helper
install_yay() {
    if ! command -v git &> /dev/null; then
        print_info "Installing git..."
        sudo pacman -S --noconfirm git
    fi
    
    print_info "Installing yay AUR helper..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    AUR_HELPER="yay"
    print_success "yay installed successfully"
}

# Update system
update_system() {
    print_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
    print_success "System updated"
}

# Install official packages
install_official_packages() {
    print_info "Installing official repository packages..."
    
    # Core Hyprland and Wayland packages
    HYPRLAND_PACKAGES=(
        "hyprland"
        "hyprland-protocols"
        "xdg-desktop-portal-hyprland"
    )
    
    # Terminal and shell
    TERMINAL_PACKAGES=(
        "kitty"
        "zsh"
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
    )
    
    # System utilities
    SYSTEM_PACKAGES=(
        "waybar"
        "rofi-wayland"
        "mako"
        "swww"
        "hypridle"
        "hyprlock"
        "gammastep"
        "brightnessctl"
        "wireplumber"
        "pipewire"
        "pipewire-alsa"
        "pipewire-pulse"
        "pipewire-jack"
        "polkit-gnome"
        "udiskie"
        "wl-clipboard"
        "cliphist"
        "playerctl"
        "grim"
        "slurp"
        "qt6-svg"
        "qt6-declarative"
        "qt5-quickcontrols2"
        "sddm"
    )
    
    # File management and utilities
    UTILITY_PACKAGES=(
        "lsd"
        "bat"
        "btop"
        "fastfetch"
        "zoxide"
        "stow"
    )
    
    # Fonts and themes
    FONT_PACKAGES=(
        "ttf-jetbrains-mono-nerd"
        "noto-fonts"
        "noto-fonts-emoji"
    )
    
    # Development tools
    DEV_PACKAGES=(
        "git"
        "base-devel"
    )
    
    OTHER_PACKAGES=(
        "curl"
        "wget"
        "unzip"
        "discord"
    )
    
    # Combine all official packages
    ALL_OFFICIAL_PACKAGES=(
        "${HYPRLAND_PACKAGES[@]}"
        "${TERMINAL_PACKAGES[@]}"
        "${SYSTEM_PACKAGES[@]}"
        "${UTILITY_PACKAGES[@]}"
        "${FONT_PACKAGES[@]}"
        "${DEV_PACKAGES[@]}"
        "${OTHER_PACKAGES[@]}"
    )
    
    # Install official packages
    for package in "${ALL_OFFICIAL_PACKAGES[@]}"; do
        if ! pacman -Qi "$package" &> /dev/null; then
            print_info "Installing $package..."
            sudo pacman -S --noconfirm "$package" || print_warning "Failed to install $package"
        else
            print_success "$package is already installed"
        fi
    done
}

# Install AUR packages
install_aur_packages() {
    print_info "Installing AUR packages..."
    
    AUR_PACKAGES=(
        "catppuccin-cursors-frappe"
        "pfetch-rs"
        "cbonsai"
        "brave-bin"
        "rofi-emoji"
        "hyprshot"
        "peaclock"
        "wofi"
        "ags-hyprpanel-git"
        "visual-studio-code-bin"
    )
    
    for package in "${AUR_PACKAGES[@]}"; do
        if ! pacman -Qi "$package" &> /dev/null; then
            print_info "Installing $package from AUR..."
            $AUR_HELPER -S --noconfirm "$package" || print_warning "Failed to install $package"
        else
            print_success "$package is already installed"
        fi
    done
}

# Install Oh My Zsh
install_oh_my_posh() {
    if [ ! -d "$HOME/.oh-my-posh" ]; then
        print_info "Installing Oh My Posh..."
        curl -s https://ohmyposh.dev/install.sh | bash -s
        print_success "Oh My Posh installed"
    else
        print_success "Oh My Posh is already installed"
    fi
}

install_sddm_theme() {
    print_info "Installing Catppuccin SDDM theme..."
    
    # Create themes directory if it doesn't exist
    sudo mkdir -p /usr/share/sddm/themes
    
    if [ ! -d "/usr/share/sddm/themes/catppuccin-frappe-mauve" ]; then
        # Copy theme to system directory
        cd ./sddm
        sudo cp -r catppuccin-frappe-mauve /usr/share/sddm/themes/
        cd ..
        print_success "Catppuccin theme files copied to /usr/share/sddm/themes/"
    else
        print_success "Catppuccin theme is already installed"
    fi
    
    # Configure SDDM to use the theme
    if [ ! -f "/etc/sddm.conf" ]; then
        print_info "Creating /etc/sddm.conf..."
        sudo tee /etc/sddm.conf > /dev/null << 'EOF'
[Theme]
Current=catppuccin-frappe-mauve
EOF
        print_success "Created /etc/sddm.conf with Catppuccin theme"
    else
        # Check if Theme section exists
        if grep -q "^\[Theme\]" /etc/sddm.conf; then
            # Update existing Theme section
            if grep -q "^Current=" /etc/sddm.conf; then
                sudo sed -i 's/^Current=.*/Current=catppuccin-frappe-mauve/' /etc/sddm.conf
            else
                # Add Current line to existing Theme section
                sudo sed -i '/^\[Theme\]/a Current=catppuccin-frappe-mauve' /etc/sddm.conf
            fi
        else
            # Add Theme section to the file
            echo -e "\n[Theme]\nCurrent=catppuccin-frappe-mauve" | sudo tee -a /etc/sddm.conf > /dev/null
        fi
        print_success "Updated /etc/sddm.conf to use Catppuccin theme"
    fi
    
    # Enable SDDM service
    if ! systemctl is-enabled sddm &> /dev/null; then
        print_info "Enabling SDDM service..."
        sudo systemctl enable sddm
        print_success "SDDM service enabled"
    else
        print_success "SDDM service is already enabled"
    fi
}

# Enable services
enable_services() {
    print_info "Enabling system services..."
    
    # Enable pipewire services for current user
    systemctl --user enable --now pipewire
    systemctl --user enable --now pipewire-pulse
    systemctl --user enable --now wireplumber
    
    print_success "Services enabled"
}

# Set up user directories
setup_directories() {
    print_info "Setting up user directories..."
    
    # Create wallpaper directory
    mkdir -p "$HOME/Wallpapers"
    
    cp "./wallpaper/default.png" "$HOME/Wallpapers/default.png"
    
    # Create other useful directories
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share/applications"
    
    print_success "Directories created"
}

# Post-installation configuration
post_install_config() {
    print_info "Performing post-installation configuration..."
    
    # Change default shell to zsh if not already
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        print_info "Changing default shell to zsh..."
        chsh -s /usr/bin/zsh
        print_success "Default shell changed to zsh (will take effect on next login)"
    fi
    
    # Configure Git if not already configured
    if [ -z "$(git config --global user.name)" ]; then
        print_warning "Git user.name not configured. Please run:"
        echo "git config --global user.name 'Your Name'"
        echo "git config --global user.email 'your.email@example.com'"
    fi
}

# Main installation process
main() {
    print_info "Starting Arch Linux dotfiles setup..."
    print_info "This script will install packages for Hyprland + Catppuccin rice"
    
    echo
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    check_arch
    update_system
    check_aur_helper
    install_official_packages
    install_aur_packages
    install_oh_my_posh
    install_sddm_theme
    enable_services
    setup_directories
    post_install_config
    
    echo
    print_success "Installation completed successfully!"
    print_info "Next steps:"
    echo "  1. Reboot your system"
    echo "  2. Use GNU Stow to deploy your dotfiles: stow ."
    echo "  3. Log out and select Hyprland from your display manager"
    
    print_warning "Note: Some applications may require additional configuration"
    print_warning "Check the README.md for any additional setup steps"
}

# Run main function
main "$@"
