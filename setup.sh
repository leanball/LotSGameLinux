#!/bin/bash
# Created by: Leandro Balico
# Date: 2024-06-18
# License: MIT (https://opensource.org/licenses/MIT)

# Initial configuration
REQUIRED_PIP_PACKAGES=("PyGObject" "gitpython" "manimpango")
REQUIRED_SYSTEM_PACKAGES=("python3-gi" "git" "xdg-utils" "desktop-file-utils")
LAUNCHER_URL="https://github.com/leanball/LotSGameLinux/raw/refs/heads/main/lotslauncherlinux.tar.gz"
ARCHIVE_NAME="lotslauncherlinux.tar.gz"
LAUNCHER_NAME="LotSLauncher.desktop"
USE_NO_SUDO=false

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# Utility functions
print_header() { printf "${BLUE}\n========== $1 ==========${RESET}\n"; }
print_success() { printf "${GREEN}✔ $1${RESET}\n"; }
print_warning() { printf "${YELLOW}⚠ $1${RESET}\n"; }
print_error() { printf "${RED}✖ $1${RESET}\n"; }

# Parse arguments
parse_arguments() {
    if [[ "$1" == "--no-sudo" ]]; then
        USE_NO_SUDO=true
        print_warning "Running in no-sudo mode. Installing Python packages locally via pip."
    fi
}

# Check for Python3
check_python3() {
    if command -v python3 &>/dev/null; then
        PYTHON_VERSION=$(python3 --version | awk '{print $2}')
        print_success "Python3 found: Version $PYTHON_VERSION"
    else
        print_error "Python3 is not installed. Please install it manually."
        exit 1
    fi
}

# Install pip locally
check_and_install_pip() {
    if ! command -v pip3 &>/dev/null; then
        print_warning "pip3 not found. Installing locally..."
        curl -sS https://bootstrap.pypa.io/get-pip.py | python3 --user >/dev/null 2>&1
        export PATH="$HOME/.local/bin:$PATH"
        print_success "pip3 installed locally in $HOME/.local/bin"
    else
        print_success "pip3 is already installed."
    fi
}

# Install system packages (multi-distro support)
install_system_packages() {
    print_header "Installing System Dependencies"
    if command -v apt &>/dev/null; then
        print_success "Detected APT (Debian/Ubuntu)"
        sudo apt update -qq
        for package in "${REQUIRED_SYSTEM_PACKAGES[@]}"; do
            sudo apt install -y "$package" >/dev/null 2>&1 && print_success "$package installed."
        done
    elif command -v dnf &>/dev/null; then
        print_success "Detected DNF (Fedora)"
        for package in "${REQUIRED_SYSTEM_PACKAGES[@]}"; do
            sudo dnf install -y "$package" >/dev/null 2>&1 && print_success "$package installed."
        done
    elif command -v yum &>/dev/null; then
        print_success "Detected YUM (RedHat/CentOS)"
        for package in "${REQUIRED_SYSTEM_PACKAGES[@]}"; do
            sudo yum install -y "$package" >/dev/null 2>&1 && print_success "$package installed."
        done
    elif command -v zypper &>/dev/null; then
        print_success "Detected ZYPPER (openSUSE)"
        for package in "${REQUIRED_SYSTEM_PACKAGES[@]}"; do
            sudo zypper install -y "$package" >/dev/null 2>&1 && print_success "$package installed."
        done
    else
        print_error "No compatible package manager found. Install the required packages manually."
        exit 1
    fi
}

# Install Python packages locally
install_pip_packages() {
    print_header "Installing Python Packages Locally"
    for package in "${REQUIRED_PIP_PACKAGES[@]}"; do
        python3 -m pip install --user "$package" >/dev/null 2>&1 && print_success "$package installed."
    done
}

# Download and extract the launcher
download_and_extract_launcher() {
    print_header "Downloading and Extracting Launcher"
    wget -q --show-progress -O "$ARCHIVE_NAME" "$LAUNCHER_URL"
    tar -xzf "$ARCHIVE_NAME" >/dev/null 2>&1
    rm -f "$ARCHIVE_NAME"
    print_success "Launcher extracted successfully."
}

# Install fonts locally
install_fonts() {
    FONT_DIR="Resources"
    LOCAL_FONT_DIR="$HOME/.local/share/fonts"

    print_header "Installing Fonts"
    if [ -d "$FONT_DIR" ]; then
        mkdir -p "$LOCAL_FONT_DIR"
        cp "$FONT_DIR"/*.ttf "$LOCAL_FONT_DIR/"
        fc-cache -f -v >/dev/null 2>&1
        print_success "Fonts installed successfully."
    else
        print_warning "Font directory not found. Skipping font installation."
    fi
}

# Create launcher
create_launcher() {
    CURRENT_DIR=$(pwd)
    ICON_PATH="$CURRENT_DIR/Resources/icon.ico"
    EXEC_COMMAND="python3 $CURRENT_DIR/LotSClient.py"

    print_header "Creating Desktop Launcher"
    cat <<EOF > "$LAUNCHER_NAME"
[Desktop Entry]
Name=LotS Launcher
Comment=Launch LotS Game
Exec=$EXEC_COMMAND
Path=$CURRENT_DIR
Icon=$ICON_PATH
Type=Application
Terminal=false
StartupNotify=true
EOF

    chmod +x "$LAUNCHER_NAME"
    DESKTOP_DIR=$(xdg-user-dir DESKTOP)
    cp "$LAUNCHER_NAME" "$DESKTOP_DIR" >/dev/null 2>&1 && print_success "Launcher copied to Desktop."
}

# Main execution
main() {
    print_header "Starting LotS Launcher Setup"
    parse_arguments "$1"

    check_python3
    check_and_install_pip

    if [ "$USE_NO_SUDO" = true ]; then
        install_pip_packages
    else
        install_system_packages
        install_pip_packages
    fi

    download_and_extract_launcher
    install_fonts
    create_launcher

    print_header "Setup Completed Successfully!"
    print_success "Run the game with:"
    echo "  python3 LotSClient.py"
}

main "$1"
