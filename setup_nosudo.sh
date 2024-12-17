#!/bin/bash
# Created by: Leandro Balico
# Date: 2024-06-17
# License: MIT (https://opensource.org/licenses/MIT)
# Initial configuration
REQUIRED_PIP_PACKAGES=("PyGObject" "gitpython" "manimpango")
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
print_header() { printf "${BLUE}\n========== $1 ==========${RESET}\n"; }

# Function to print success message
print_success() { printf "${GREEN}✔ $1${RESET}\n"; }

# Function to print warning message
print_warning() { printf "${YELLOW}⚠ $1${RESET}\n"; }

# Function to print error message
print_error() { printf "${RED}✖ $1${RESET}\n"; }

# Function to check for Python3
check_python3() {
    if command -v python3 &>/dev/null; then
        PYTHON_VERSION=$(python3 --version | awk '{print $2}')
        print_success "Python3 found: Version $PYTHON_VERSION"
    else
        print_error "Python3 is not installed. Install it manually and rerun the script."
        exit 1
    fi
}

# Function to check and install pip locally
check_and_install_pip() {
    if ! command -v pip3 &>/dev/null; then
        print_warning "pip3 is not installed. Installing locally..."
        curl -sS https://bootstrap.pypa.io/get-pip.py | python3 --user >/dev/null 2>&1
        export PATH="$HOME/.local/bin:$PATH"
        print_success "pip3 installed locally in $HOME/.local/bin"
    else
        print_success "pip3 is already installed."
    fi
}

# Function to install Python packages locally via pip
install_pip_packages() {
    print_header "Installing Required Python Packages Locally"
    for package in "${REQUIRED_PIP_PACKAGES[@]}"; do
        if ! python3 -m pip show --user "$package" &>/dev/null; then
            print_warning "$package is missing. Installing locally..."
            python3 -m pip install --user "$package" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                print_success "$package installed successfully."
            else
                print_error "Failed to install $package. Exiting..."
                exit 1
            fi
        else
            print_success "$package is already installed."
        fi
    done
}

# Function to download and extract the launcher
download_and_extract_launcher() {
    print_header "Downloading and Extracting Launcher"
    wget -q --show-progress -O "$ARCHIVE_NAME" "$LAUNCHER_URL"
    print_success "Download complete."

    tar -xzf "$ARCHIVE_NAME" >/dev/null 2>&1
    rm -f "$ARCHIVE_NAME"
    print_success "Launcher extracted successfully."
}

# Function to create a desktop launcher
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

    # Copy to Desktop if xdg-user-dir is available
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

    # Check for Python3 and pip
    check_python3
    check_and_install_pip

    # Install Python dependencies locally
    install_pip_packages

    # Download and extract the launcher
    download_and_extract_launcher

    # Create a desktop launcher
    create_launcher

    print_header "Setup Completed Successfully!"
    print_success "To launch the game, run:"
    echo "  python3 LotSClient.py"
    print_success "Or use the launcher created in the Desktop directory or current folder."
}

# Run the main function
main
