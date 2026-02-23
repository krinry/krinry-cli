#!/bin/bash
# krinry installer: zsh
# Usage: krinry install zsh

cmd_install() {
    print_header "Installing Zsh Shell"
    echo -e "${DIM}Z Shell with powerful features${NC}"
    echo ""
    
    require_termux
    
    print_step "Installing zsh..."
    if pkg install zsh -y 2>/dev/null; then
        print_done "Zsh"
        echo -e "${BOLD}Next Step:${NC}"
        echo "  Install Oh My Zsh for themes & plugins:"
        echo "  krinry install oh-my-zsh"
        echo ""
    else
        print_error "Failed to install zsh"
        exit 1
    fi
}
