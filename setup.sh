#!/bin/bash
# Created by: Leandro Balico
# Date: 2024-06-17
# License: MIT (https://opensource.org/licenses/MIT)

# Initial configuration
REQUIRED_PYTHON="3.6"
REQUIRED_PACKAGES=("python3-gi" "git" "python3-git"  "xdg-utils" "desktop-file-utils")
LAUNCHER_URL="https://github.com/leanball/LotSGameLinux/raw/refs/heads/main/lotslauncherlinux.tar.gz"
ARCHIVE_NAME="lotslauncherlinux.tar.gz"
LAUNCHER_NAME="LotSLauncher.desktop"

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# Function to print headers
print_header() {
    printf "${BLUE}\n========== $1 ==========${RESET}\n"
}

# Function to print success message
print_success() {
    printf "${GREEN}✔ $1${RESET}\n"
}

# Function to print warning message
print_warning() {
    printf "${YELLOW}⚠ $1${RESET}\n"
}

# Function to print error message
print_error() {
    printf "${RED}✖ $1${RESET}\n"
}

# Function to check for Python3
check_python3() {
    if command -v python3 &>/dev/null; then
        PYTHON_VERSION=$(python3 --version | awk '{print $2}')
        print_success "Python3 found: Version $PYTHON_VERSION"
    else
        print_error "Python3 is not installed."
        install_package "python3"
    fi
}

# Function to install packages
install_package() {
    PACKAGE=$1
    if command -v apt &>/dev/null; then
        sudo apt update -qq && sudo apt install -y "$PACKAGE" >/dev/null 2>&1
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$PACKAGE" >/dev/null 2>&1
    elif command -v yum &>/dev/null; then
        sudo yum install -y "$PACKAGE" >/dev/null 2>&1
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y "$PACKAGE" >/dev/null 2>&1
    else
        print_error "No compatible package manager found. Install $PACKAGE manually."
        exit 1
    fi
}

# Function to verify and install required system packages
check_and_install_system_packages() {
    print_header "Checking for Required Packages"
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "$package" 2>/dev/null && ! rpm -q "$package" 2>/dev/null; then
            print_warning "$package is missing. Installing..."
            install_package "$package"
            print_success "$package installed successfully."
        else
            print_success "$package is already installed."
        fi
    done
}

# Function to download and extract the launcher
download_and_extract_launcher() {
    print_header "Downloading and Extracting Launcher"
    printf "Downloading launcher... "
    wget -q --show-progress -O "$ARCHIVE_NAME" "$LAUNCHER_URL"
    print_success "Download complete."

    printf "Extracting launcher... "
    tar -xzf "$ARCHIVE_NAME" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        print_error "Error extracting launcher. Exiting..."
        exit 1
    fi
    rm -f "$ARCHIVE_NAME"
    print_success "Launcher extracted successfully."
}
# Function to install fonts
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
        print_warning "Font directory not found: $FONT_DIR. Skipping font installation."
    fi
}
# Function to create a universal launcher
create_launcher() {
    CURRENT_DIR=$(pwd)
    ICON_PATH="$CURRENT_DIR/Resources/icon.ico"
    EXEC_COMMAND="python3 LotSClient.py"

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

    DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null)
    if [ -n "$DESKTOP_DIR" ] && [ -d "$DESKTOP_DIR" ]; then
        cp "$LAUNCHER_NAME" "$DESKTOP_DIR/"
        print_success "Launcher copied to: $DESKTOP_DIR/$LAUNCHER_NAME"
    else
        print_warning "Unable to determine Desktop directory. Copy manually:"
        echo "  cp $LAUNCHER_NAME ~/Área\ de\ Trabalho/"
    fi
    print_success "Launcher created: $CURRENT_DIR/$LAUNCHER_NAME"
}

# Main function
main() {
    print_header "Starting LotS Launcher Setup"

    # Check for Python3
    check_python3

    # Verify and install system dependencies
    check_and_install_system_packages

    # Download and extract the launcher
    download_and_extract_launcher

    # Install fonts
    install_fonts

    # Create universal desktop launcher
    create_launcher

    print_header "Setup Completed Successfully!"
    print_success "To launch the game, run:"
    echo "  python3 LotSClient.py"
    print_success "Or use the launcher created in the Desktop directory or current folder."
}

# Run the main function
main
