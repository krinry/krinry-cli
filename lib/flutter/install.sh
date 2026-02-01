#!/bin/bash
# krinry flutter - Install Flutter Command
# Uses tur-repo (Termux User Repository) for pre-built Flutter

cmd_install_flutter() {
    print_header "Install Flutter SDK"
    
    # Check if Flutter is already installed
    if is_flutter_installed; then
        local current_version
        current_version=$(get_flutter_version)
        print_success "Flutter is already installed!"
        echo "  Version: ${current_version}"
        echo ""
        
        if ask_yes_no "Do you want to reinstall/update Flutter?"; then
            print_info "Proceeding with reinstall..."
        else
            print_info "Keeping existing installation"
            echo ""
            echo "Run 'flutter doctor' to check your setup"
            exit 0
        fi
    fi
    
    # Check internet connection
    print_step "Checking internet connection..."
    if ! check_internet; then
        die "No internet connection. Please check your network."
    fi
    print_success "Internet connection OK"
    
    # Detect platform
    if is_termux; then
        print_info "Detected Termux environment"
        install_flutter_termux
    else
        # Detect OS for non-Termux
        case "$(uname -s)" in
            Linux*)  
                print_info "Detected Linux"
                install_flutter_linux
                ;;
            Darwin*) 
                print_info "Detected macOS"
                install_flutter_macos
                ;;
            *)
                die "Unsupported platform: $(uname -s)"
                ;;
        esac
    fi
}

install_flutter_termux() {
    print_header "Installing Flutter for Termux"
    
    # Update packages first
    print_step "Updating Termux packages..."
    pkg update -y 2>/dev/null || apt update -y 2>/dev/null || true
    pkg upgrade -y 2>/dev/null || apt upgrade -y 2>/dev/null || true
    
    # Install required dependencies
    print_step "Installing dependencies..."
    pkg install -y git curl wget 2>/dev/null || true
    
    # METHOD 1: Add TermuxVoid repository (has Flutter pre-built)
    print_step "Adding TermuxVoid repository..."
    if curl -sL https://termuxvoid.github.io/repo/install.sh | bash 2>/dev/null; then
        print_success "TermuxVoid repo added"
        
        # Update after adding repo
        pkg update -y 2>/dev/null || true
        
        # Install Flutter
        print_step "Installing Flutter from TermuxVoid..."
        if pkg install flutter -y 2>/dev/null; then
            verify_flutter_termux
            return 0
        fi
    fi
    
    # METHOD 2: Try tur-repo (Termux User Repository)
    print_step "Trying tur-repo..."
    if pkg install tur-repo -y 2>/dev/null; then
        pkg update -y 2>/dev/null || true
        if pkg install flutter -y 2>/dev/null; then
            verify_flutter_termux
            return 0
        fi
    fi
    
    # METHOD 3: Install via one-line script from community
    print_step "Trying community install script..."
    
    # Download and run the install script
    local install_script="${PREFIX}/tmp/flutter-install.sh"
    
    # Try multiple sources
    local scripts=(
        "https://raw.githubusercontent.com/nicko130/Flutter-For-Termux/main/install.sh"
        "https://raw.githubusercontent.com/nicko3130/termux-flutter/main/install.sh"
    )
    
    for script_url in "${scripts[@]}"; do
        if curl -fsSL "$script_url" -o "$install_script" 2>/dev/null; then
            chmod +x "$install_script"
            if bash "$install_script" 2>/dev/null; then
                rm -f "$install_script"
                verify_flutter_termux
                return 0
            fi
        fi
    done
    
    # METHOD 4: Manual steps with clear instructions
    print_warning "Automatic installation couldn't complete"
    echo ""
    print_header "Running Manual Installation Steps"
    echo ""
    
    # Actually run the manual steps automatically
    print_step "Step 1: Installing proot-distro..."
    pkg install proot-distro -y 2>/dev/null || true
    
    print_step "Step 2: Installing Ubuntu in proot..."
    if proot-distro install ubuntu 2>/dev/null; then
        print_success "Ubuntu installed in proot"
        
        print_step "Step 3: Installing Flutter in Ubuntu proot..."
        # Create install script for proot
        cat > "${PREFIX}/tmp/proot-flutter-install.sh" << 'PROOTSCRIPT'
#!/bin/bash
apt update && apt upgrade -y
apt install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev
cd ~
git clone https://github.com/nicko130/Flutter-For-Termux.git 2>/dev/null || true
if [ -d "Flutter-For-Termux" ]; then
    cd Flutter-For-Termux
    bash install.sh
else
    curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.3-stable.tar.xz -o flutter.tar.xz
    tar -xf flutter.tar.xz
    mv flutter /opt/
    echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
    export PATH="/opt/flutter/bin:$PATH"
    flutter --version
fi
PROOTSCRIPT
        
        proot-distro login ubuntu -- bash "${PREFIX}/tmp/proot-flutter-install.sh" 2>/dev/null
        
        if proot-distro login ubuntu -- flutter --version 2>/dev/null; then
            print_success "Flutter installed in Ubuntu proot!"
            echo ""
            echo "To use Flutter, run:"
            echo "  proot-distro login ubuntu"
            echo "  flutter doctor"
            return 0
        fi
    fi
    
    # If all fails, provide clear manual instructions
    print_error "Automatic installation failed"
    echo ""
    echo "Please try these manual steps:"
    echo ""
    echo "${CYAN}Option 1: tur-repo (recommended)${NC}"
    echo "  pkg install tur-repo"
    echo "  pkg update"
    echo "  pkg install flutter"
    echo ""
    echo "${CYAN}Option 2: proot with Ubuntu${NC}"
    echo "  pkg install proot-distro"
    echo "  proot-distro install ubuntu"
    echo "  proot-distro login ubuntu"
    echo "  # Inside Ubuntu:"
    echo "  apt update && apt install snapd"
    echo "  snap install flutter --classic"
    echo ""
    exit 1
}

verify_flutter_termux() {
    print_step "Verifying installation..."
    
    if command -v flutter &>/dev/null; then
        print_success "Flutter installed successfully!"
        echo ""
        flutter --version
        echo ""
        echo "Next steps:"
        echo "  1. Run: flutter doctor"
        echo "  2. Create app: flutter create myapp"
        echo "  3. Build: krinry flutter build apk --release"
        return 0
    else
        print_warning "Flutter command not found. Try restarting terminal."
        return 1
    fi
}

install_flutter_linux() {
    print_header "Installing Flutter SDK"
    
    ensure_dir "${KRINRY_HOME}"
    
    local flutter_tar="${KRINRY_HOME}/flutter.tar.xz"
    local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.3-stable.tar.xz"
    
    rm -rf "${FLUTTER_HOME}" 2>/dev/null || true
    
    print_step "Downloading Flutter SDK..."
    if ! download_file "$flutter_url" "$flutter_tar"; then
        die "Failed to download Flutter SDK"
    fi
    
    print_step "Extracting Flutter SDK..."
    cd "${KRINRY_HOME}"
    tar -xf "$flutter_tar"
    rm -f "$flutter_tar" 2>/dev/null || true
    
    setup_flutter_path
    verify_flutter_install
}

install_flutter_macos() {
    print_header "Installing Flutter SDK"
    
    ensure_dir "${KRINRY_HOME}"
    
    local flutter_zip="${KRINRY_HOME}/flutter.zip"
    local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.27.3-stable.zip"
    
    rm -rf "${FLUTTER_HOME}" 2>/dev/null || true
    
    print_step "Downloading Flutter SDK..."
    if ! download_file "$flutter_url" "$flutter_zip"; then
        die "Failed to download Flutter SDK"
    fi
    
    print_step "Extracting Flutter SDK..."
    cd "${KRINRY_HOME}"
    unzip -q "$flutter_zip"
    rm -f "$flutter_zip" 2>/dev/null || true
    
    setup_flutter_path
    verify_flutter_install
}

setup_flutter_path() {
    print_step "Configuring PATH..."
    
    local flutter_bin="${FLUTTER_HOME}/bin"
    local shell_rc=""
    
    if [[ -n "$BASH_VERSION" ]]; then
        shell_rc="${HOME}/.bashrc"
    elif [[ -n "$ZSH_VERSION" ]]; then
        shell_rc="${HOME}/.zshrc"
    else
        shell_rc="${HOME}/.profile"
    fi
    
    if grep -q "flutter/bin" "$shell_rc" 2>/dev/null; then
        print_info "PATH already configured"
        return
    fi
    
    echo "" >> "$shell_rc"
    echo "# Flutter SDK (krinry)" >> "$shell_rc"
    echo "export PATH=\"${flutter_bin}:\$PATH\"" >> "$shell_rc"
    
    export PATH="${flutter_bin}:$PATH"
    
    print_success "PATH configured in ${shell_rc}"
    print_warning "Run 'source ${shell_rc}' or restart terminal"
}

verify_flutter_install() {
    print_step "Verifying installation..."
    
    if command -v flutter &>/dev/null || [[ -f "${FLUTTER_HOME}/bin/flutter" ]]; then
        print_success "Flutter installed successfully!"
        echo ""
        flutter --version 2>/dev/null || "${FLUTTER_HOME}/bin/flutter" --version
        echo ""
        print_info "Run 'flutter doctor' to check your setup"
    else
        die "Flutter installation failed. Please try again."
    fi
}
