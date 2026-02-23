#!/bin/bash
# krinry installer: shell-tools bundle
# Usage: krinry install shell-tools

cmd_install() {
    print_header "Installing Shell Tools Bundle"
    echo -e "${DIM}Auto-suggestions, command correction, fuzzy finder${NC}"
    echo ""
    
    require_termux
    
    local tools=("fish" "fzf" "zsh")
    local installed=0
    
    for tool in "${tools[@]}"; do
        print_step "Installing ${tool}..."
        if pkg install "$tool" -y >/dev/null 2>&1; then
            print_success "${tool} installed"
            ((installed++))
        else
            print_warning "Could not install ${tool}"
        fi
    done
    
    # Install thefuck via pip
    print_step "Installing thefuck..."
    if pkg install python -y >/dev/null 2>&1; then
        pip install thefuck >/dev/null 2>&1 && print_success "thefuck installed" || print_warning "thefuck failed"
    fi
    
    echo ""
    print_success "Shell tools installed! (${installed}/${#tools[@]})"
    echo ""
    echo -e "${BOLD}Recommended: Switch to Fish shell${NC}"
    echo "  Run: chsh -s fish"
    echo "  Then restart Termux"
    echo ""
    echo -e "${BOLD}TheFuck Usage:${NC}"
    echo "  Add to ~/.bashrc: eval \$(thefuck --alias)"
    echo ""
    echo -e "${DIM}Powered by krinry${NC}"
    echo ""
}
