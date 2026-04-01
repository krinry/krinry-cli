#!/bin/bash
# krinry gradle - Create Command

cmd_create_help() {
    echo ""
    echo "Usage: krinry gradle create <project_name> [--type <type>] [--package <package>]"
    echo ""
    echo "Create a new Gradle/Android project via cloud."
    echo ""
    echo "OPTIONS:"
    echo "  --type <type>        android, java-application, java-library,"
    echo "                       kotlin-application, kotlin-library"
    echo "                       (default: android)"
    echo "  --package <package>  Package name (default: com.example.app)"
    echo "  --help               Show this help"
    echo ""
    echo "EXAMPLES:"
    echo "  krinry gradle create myapp"
    echo "  krinry gradle create myapp --type android"
    echo "  krinry gradle create mycli --type kotlin-application"
    echo ""
}

cmd_create() {
    # Check for empty args
    if [[ $# -eq 0 ]]; then
        cmd_create_help
        exit 1
    fi
    
    local project_name=""
    local project_type="android"
    local package_name="com.example.app"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type)
                project_type="$2"
                shift 2
                ;;
            --type=*)
                project_type="${1#*=}"
                shift
                ;;
            --package)
                package_name="$2"
                shift 2
                ;;
            --package=*)
                package_name="${1#*=}"
                shift
                ;;
            --help|-h)
                cmd_create_help
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                cmd_create_help
                exit 1
                ;;
            *)
                if [[ -z "$project_name" ]]; then
                    project_name="$1"
                else
                    print_error "Too many arguments. Expected project name."
                    exit 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$project_name" ]]; then
        print_error "Project name is required"
        cmd_create_help
        exit 1
    fi

    # Check GH CLI
    if ! is_command_available gh || ! gh auth status &>/dev/null; then
        print_error "GitHub CLI not installed or not authenticated. Run: gh auth login"
        exit 1
    fi
    
    # Check if dir exists
    if [[ -d "$project_name" ]]; then
        print_error "Directory '$project_name' already exists."
        exit 1
    fi

    print_header "Creating Gradle Project (${project_type})"
    echo "Name: ${project_name}"
    echo "Package: ${package_name}"
    echo ""

    if ! ask_yes_no "Create this project and a GitHub repository for it?" "y"; then
        exit 0
    fi

    print_step "Creating GitHub repository..."
    
    local repo_info
    repo_info=$(gh repo create "$project_name" --private --clone 2>&1)
    
    if [[ $? -ne 0 ]]; then
        print_error "Failed to create repository"
        echo "$repo_info"
        exit 1
    fi
    print_success "Repository created and cloned"
    
    cd "$project_name" || exit 1
    
    # Create the workflow file locally
    print_step "Setting up temporary scaffolding workflow..."
    ensure_dir ".github/workflows"
    
    local template_file="${KRINRY_HOME}/workflows/krinry-gradle-create.yml"
    local workflow_file=".github/workflows/krinry-gradle-create.yml"
    
    if [[ -f "$template_file" ]]; then
        cp "$template_file" "$workflow_file"
    else
        curl -fsSL "https://raw.githubusercontent.com/krinry/krinry-cli/dev/workflows/krinry-gradle-create.yml" -o "$workflow_file" 2>/dev/null
    fi
    
    # Create initial commit to have a base branch
    echo "# $project_name" > README.md
    git add .
    git commit -m "Initial commit with scaffolding workflow"
    git push -u origin HEAD
    print_success "Workflow pushed to GitHub"
    
    print_step "Triggering scaffolding action..."
    gh workflow run krinry-gradle-create.yml -f project_name="$project_name" -f project_type="$project_type" -f package_name="$package_name"
    
    sleep 3
    local run_id=$(gh run list --workflow=krinry-gradle-create.yml --limit=1 --json databaseId -q '.[0].databaseId' 2>/dev/null)
    
    if [[ -n "$run_id" ]]; then
        echo "Wait while cloud runner creates the project..."
        
        while true; do
            local status=$(gh run view "$run_id" --json status -q '.status' 2>/dev/null)
            if [[ "$status" == "completed" ]]; then
                local conclusion=$(gh run view "$run_id" --json conclusion -q '.conclusion' 2>/dev/null)
                if [[ "$conclusion" == "success" ]]; then
                    print_success "Cloud scaffolding completed!"
                    break
                else
                    print_error "Cloud scaffolding failed!"
                    exit 1
                fi
            fi
            echo -ne "\r${CYAN}🔄${NC} Working... "
            sleep 5
        done
        
        # Pull the changes
        print_step "Pulling scaffolded files..."
        git pull --rebase
        
        print_success "Project created successfully!"
        echo ""
        echo "Run:"
        echo "  cd $project_name"
        echo "  krinry gradle init"
    else
        print_error "Failed to start workflow"
    fi
}
