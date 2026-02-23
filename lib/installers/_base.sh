#!/bin/bash
# krinry - Base helpers for all installers
# Source this in every lib/installers/*.sh file

# Require Termux environment
require_termux() {
    if ! is_termux; then
        die "This installer is designed for Termux only"
    fi
}

# Require a specific pkg to be installed
require_pkg() {
    local pkg="$1"
    if ! is_command_available "$pkg"; then
        print_step "Installing dependency: ${pkg}..."
        if pkg install "$pkg" -y 2>/dev/null; then
            print_success "${pkg} ready"
        else
            die "Could not install dependency: ${pkg}"
        fi
    fi
}

# Install from TermuxVoid repo (sets up repo first silently)
install_from_void_repo() {
    local pkg="$1"
    setup_void_repo_silent
    print_step "Installing ${pkg}..."
    if pkg install "$pkg" -y 2>/dev/null; then
        print_success "${pkg} installed"
        return 0
    else
        die "Failed to install ${pkg} from repository"
    fi
}

# Setup TermuxVoid repo silently (only if not present)
setup_void_repo_silent() {
    if [[ -f "${PREFIX}/etc/apt/sources.list.d/termuxvoid.list" ]]; then
        return 0
    fi
    print_step "Setting up package repository..."
    curl -sL https://termuxvoid.github.io/repo/install.sh 2>/dev/null | bash >/dev/null 2>&1
    pkg update -y >/dev/null 2>&1 || true
    print_success "Repository configured"
}

# Print a branded done message
print_done() {
    local tool="$1"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓${NC} ${BOLD}${tool} installed successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${DIM}Powered by krinry • https://github.com/krinry/krinry-cli${NC}"
    echo ""
}
