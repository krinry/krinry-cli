#!/bin/bash
# krinry - Generic Package Install Command
# Installs packages with krinry branding

cmd_install_package() {
    local package="$1"
    
    if [[ -z "$package" ]]; then
        print_error "No package specified"
        echo "Usage: krinry install <package>"
        exit 1
    fi
    
    print_header "Installing ${package}"
    
    # Check if Termux
    if ! is_termux; then
        print_warning "This command is designed for Termux"
        echo "On other systems, use your package manager directly"
        exit 1
    fi
    
    # Setup TermuxVoid repo silently if not already added
    setup_termuxvoid_repo
    
    # Install the package
    print_step "Installing ${package}..."
    
    if pkg install "$package" -y 2>/dev/null; then
        print_success "${package} installed successfully!"
        echo ""
        
        # Show post-install tips for common packages
        case "$package" in
            neovim|nvim)
                echo "Run: nvim <filename>"
                echo "Press 'i' to insert, ':wq' to save & quit"
                ;;
            micro)
                echo "Run: micro <filename>"
                echo "Ctrl+S to save, Ctrl+Q to quit"
                ;;
            vim)
                echo "Run: vim <filename>"
                echo "Press 'i' to insert, ':wq' to save & quit"
                ;;
            nano)
                echo "Run: nano <filename>"
                echo "Ctrl+O to save, Ctrl+X to quit"
                ;;
        esac
        
        echo ""
        echo -e "${DIM}Powered by krinry • Package from TermuxVoid${NC}"
    else
        print_error "Failed to install ${package}"
        echo ""
        echo "Try updating packages first:"
        echo "  pkg update && pkg upgrade"
        exit 1
    fi
}

setup_termuxvoid_repo() {
    # Check if repo already added
    if [[ -f "${PREFIX}/etc/apt/sources.list.d/termuxvoid.list" ]]; then
        return 0
    fi
    
    print_step "Setting up package repository..."
    
    # Silently add TermuxVoid repo
    curl -sL https://termuxvoid.github.io/repo/install.sh 2>/dev/null | bash >/dev/null 2>&1
    
    # Update package lists
    pkg update -y >/dev/null 2>&1 || true
    
    print_success "Repository configured"
}
