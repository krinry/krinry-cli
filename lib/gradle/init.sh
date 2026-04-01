#!/bin/bash
# krinry gradle - Init Command

cmd_init() {
    print_header "Initialize krinry gradle"
    
    # Check if in Gradle project
    if ! is_gradle_project; then
        print_warning "No build.gradle or settings.gradle found."
        if ! ask_yes_no "Initialize anyway?"; then
            die "Gradle project required for cloud builds"
        fi
    else
        print_success "Gradle project detected"
    fi
    
    # Check if git repo
    if ! is_git_repo; then
        print_warning "Not a git repository"
        if ask_yes_no "Initialize git repository?"; then
            git init
            print_success "Git repository initialized"
        else
            die "Git repository required for cloud builds"
        fi
    fi
    print_success "Git repository detected"
    
    # Check remote
    local remote_url
    remote_url=$(get_remote_url)
    if [[ -z "$remote_url" ]]; then
        print_warning "No GitHub remote configured"
        echo ""
        echo "Please add a GitHub remote:"
        echo "  git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
        echo ""
        die "GitHub remote required for cloud builds"
    fi
    
    # Verify it's a GitHub URL
    if [[ "$remote_url" != *"github.com"* ]]; then
        print_warning "Remote doesn't appear to be GitHub: ${remote_url}"
        echo "krinry currently only supports GitHub for cloud builds"
        if ! ask_yes_no "Continue anyway?"; then
            exit 1
        fi
    fi
    print_success "GitHub remote: ${remote_url}"
    
    # Create workflow directory
    print_step "Setting up GitHub Actions workflow..."
    ensure_dir ".github/workflows"
    
    local app_name=$(basename "$PWD")
    
    # Copy workflow from krinry template directory
    local workflow_file=".github/workflows/krinry-gradle-build.yml"
    local template_file="${KRINRY_HOME}/workflows/krinry-gradle-build.yml"
    
    if [[ -f "$template_file" ]]; then
        cp "$template_file" "$workflow_file"
        print_success "Copied workflow from template"
    else
        # Fallback: download latest from GitHub
        print_step "Downloading latest workflow..."
        curl -fsSL "https://raw.githubusercontent.com/krinry/krinry-cli/dev/workflows/krinry-gradle-build.yml" -o "$workflow_file" 2>/dev/null
        
        if [[ ! -f "$workflow_file" || ! -s "$workflow_file" ]]; then
            print_error "Failed to download workflow template"
            echo "Please check your internet connection and try again"
            exit 1
        fi
        print_success "Downloaded latest workflow"
    fi
    
    if [[ -f "$workflow_file" ]]; then
        print_success "Created .github/workflows/krinry-gradle-build.yml"
    fi
    
    # Create/update config file
    print_step "Creating configuration file..."
    
    cat > ".krinry.yaml" << CONFIG_EOF
# krinry configuration v${VERSION}
project:
  name: ${app_name}
  type: gradle

cloud:
  provider: github
  workflow: krinry-gradle-build.yml
CONFIG_EOF
    
    print_success "Created .krinry.yaml"
    
    # Add to .gitignore if not present
    if [[ -f ".gitignore" ]]; then
        if ! grep -q "# krinry" .gitignore 2>/dev/null; then
            echo "" >> .gitignore
            echo "# krinry" >> .gitignore
            echo ".krinry-cache/" >> .gitignore
        fi
    fi
    
    # Summary
    echo ""
    print_header "Initialization Complete"
    echo ""
    echo "Created/Updated files:"
    echo "  • .github/workflows/krinry-gradle-build.yml"
    echo "  • .krinry.yaml"
    echo ""
    echo "Next steps:"
    echo "  1. Commit and push:"
    echo "     git add . && git commit -m 'Add krinry cloud build' && git push"
    echo ""
    echo "  2. Build commands:"
    echo ""
    echo -e "${CYAN}# Android APK build${NC}"
    echo "     krinry gradle assembleDebug"
    echo "     krinry gradle assembleRelease"
    echo ""
    echo -e "${CYAN}# Custom tasks${NC}"
    echo "     krinry gradle build"
    echo "     krinry gradle test"
    echo "     krinry gradle clean"
    echo ""
}
