#!/bin/bash
# krinry gradle - Doctor Command

cmd_doctor() {
    print_header "krinry gradle Doctor"
    
    local all_ok=true
    
    # Check 1: Git
    echo ""
    echo -e "${BOLD}Git${NC}"
    if is_command_available git; then
        local git_version
        git_version=$(git --version 2>/dev/null | head -1)
        print_success "Git installed: ${git_version}"
    else
        print_error "Git not installed"
        if is_termux; then
            echo "       Run: pkg install git"
        else
            echo "       Please install Git"
        fi
        all_ok=false
    fi
    
    # Check 2: GitHub CLI
    echo ""
    echo -e "${BOLD}GitHub CLI${NC}"
    if is_command_available gh; then
        local gh_version
        gh_version=$(gh --version 2>/dev/null | head -1)
        print_success "GitHub CLI installed: ${gh_version}"
        
        # Check auth status
        if gh auth status &>/dev/null; then
            local gh_user
            gh_user=$(gh api user -q '.login' 2>/dev/null || echo "authenticated")
            print_success "GitHub authenticated as: ${gh_user}"
        else
            print_warning "GitHub CLI not authenticated"
            echo "       Run: gh auth login"
            all_ok=false
        fi
    else
        print_error "GitHub CLI not installed"
        if is_termux; then
            echo "       Run: pkg install gh"
        else
            echo "       Visit: https://cli.github.com"
        fi
        all_ok=false
    fi
    
    # Check 3: curl
    echo ""
    echo -e "${BOLD}curl${NC}"
    if is_command_available curl; then
        print_success "curl installed"
    else
        print_error "curl not installed"
        all_ok=false
    fi
    
    # Check 4: jq (for JSON parsing)
    echo ""
    echo -e "${BOLD}jq${NC}"
    if is_command_available jq; then
        print_success "jq installed"
    else
        print_warning "jq not installed (optional, but recommended)"
        if is_termux; then
            echo "       Run: pkg install jq"
        fi
    fi
    
    # Check 5: Current directory checks
    echo ""
    echo -e "${BOLD}Project Checks${NC}"
    
    if is_git_repo; then
        print_success "Git repository detected"
        
        local remote
        remote=$(get_remote_url)
        if [[ -n "$remote" ]]; then
            print_success "Remote: ${remote}"
        else
            print_warning "No remote configured"
            echo "       Run: git remote add origin <url>"
        fi
    else
        print_info "Not in a git repository (OK if not in a project)"
    fi
    
    if is_gradle_project; then
        print_success "Gradle project detected"
        
        if is_android_project; then
            print_success "Android project markers detected"
        fi
        
        if has_gradle_workflow_file; then
            print_success "krinry-gradle workflow found"
        else
            print_warning "No krinry-gradle workflow"
            echo "       Run: krinry gradle init"
        fi
        
        if config_exists; then
            print_success "Config file found: .krinry.yaml"
        else
            print_warning "No config file"
            echo "       Run: krinry gradle init"
        fi
    else
        print_info "Not in a Gradle project (OK if creating a new one)"
    fi
    
    # Internet check
    echo ""
    echo -e "${BOLD}Network${NC}"
    if check_internet; then
        print_success "Internet connection OK"
    else
        print_error "No internet connection"
        all_ok=false
    fi
    
    # Summary
    echo ""
    echo "─────────────────────────────────────"
    if $all_ok; then
        print_success "All checks passed! You're ready to build."
    else
        print_warning "Some issues found. Please fix them before building."
    fi
    echo ""
}
