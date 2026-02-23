#!/bin/bash
# krinry - Install Command Dispatcher
# Auto-discovers installers from lib/installers/*.sh
# To add a new tool: just create lib/installers/<name>.sh with cmd_install()

cmd_install_package() {
    local package="$1"

    if [[ -z "$package" ]]; then
        print_error "No package specified"
        echo "Usage: krinry install <package>"
        exit 1
    fi

    # Alias mappings (alternate names -> canonical name)
    case "$package" in
        ohmyzsh|oh-my-zsh) package="oh-my-zsh" ;;
        fuck|tf)            package="thefuck" ;;
        shell|shell-tools)  package="shell-tools" ;;
        nvim)               package="neovim" ;;
    esac

    # Auto-discover: does lib/installers/<package>.sh exist?
    local installer_file="${LIB_DIR}/installers/${package}.sh"

    if [[ -f "$installer_file" ]]; then
        # Source base helpers first, then the installer
        source "${LIB_DIR}/installers/_base.sh"
        source "$installer_file"
        cmd_install
        return
    fi

    # Fallback: generic pkg install for unknown packages (Termux only)
    print_header "Installing ${package}"

    if ! is_termux; then
        print_warning "This command is designed for Termux"
        echo "On other systems, use your package manager directly"
        exit 1
    fi

    print_step "Installing ${package}..."
    if pkg install "$package" -y 2>/dev/null; then
        echo ""
        print_success "${package} installed successfully!"
        echo ""
        echo -e "${DIM}Powered by krinry${NC}"
        echo ""
    else
        print_error "Failed to install ${package}"
        echo ""
        echo "Try updating packages first:"
        echo "  pkg update && pkg upgrade"
        echo ""
        echo "Or check available packages:"
        echo "  pkg search ${package}"
        exit 1
    fi
}
