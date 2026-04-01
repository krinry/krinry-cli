#!/bin/bash
# krinry flutter - Create Command

cmd_create_help() {
    echo ""
    echo "Usage: krinry flutter create <project_name> [OPTIONS]"
    echo ""
    echo "Create a new Flutter project via cloud (no local Flutter needed)."
    echo ""
    echo "OPTIONS:"
    echo "  --org <org>          Organization (default: com.example)"
    echo "  --template <type>    app, package, plugin, skeleton (default: app)"
    echo "  --platforms <list>   Comma-separated: android,ios,web,linux,macos,windows"
    echo "                       (default: android,ios,web)"
    echo "  --help               Show this help"
    echo ""
    echo "EXAMPLES:"
    echo "  krinry flutter create myapp"
    echo "  krinry flutter create myapp --org com.mycompany"
    echo "  krinry flutter create myplugin --template plugin"
    echo "  krinry flutter create myapp --platforms android,web"
    echo ""
}

cmd_create() {
    if [[ $# -eq 0 ]]; then
        cmd_create_help
        exit 1
    fi

    local project_name=""
    local org="com.example"
    local template="app"
    local platforms="android,ios,web"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --org)
                org="$2"; shift 2 ;;
            --org=*)
                org="${1#*=}"; shift ;;
            --template)
                template="$2"; shift 2 ;;
            --template=*)
                template="${1#*=}"; shift ;;
            --platforms)
                platforms="$2"; shift 2 ;;
            --platforms=*)
                platforms="${1#*=}"; shift ;;
            --help|-h)
                cmd_create_help; exit 0 ;;
            -*)
                print_error "Unknown option: $1"
                cmd_create_help; exit 1 ;;
            *)
                if [[ -z "$project_name" ]]; then
                    project_name="$1"
                else
                    print_error "Too many arguments."
                    exit 1
                fi
                shift ;;
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

    if [[ -d "$project_name" ]]; then
        print_error "Directory '$project_name' already exists."
        exit 1
    fi

    print_header "Creating Flutter Project"
    echo "Name:      ${project_name}"
    echo "Org:       ${org}"
    echo "Template:  ${template}"
    echo "Platforms: ${platforms}"
    echo ""

    if ! ask_yes_no "Create this project and a new GitHub repository?" "y"; then
        exit 0
    fi

    # Create GitHub repo and clone
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

    # Install create workflow
    print_step "Setting up scaffolding workflow..."
    ensure_dir ".github/workflows"

    local template_file="${KRINRY_HOME}/workflows/krinry-flutter-create.yml"
    local workflow_file=".github/workflows/krinry-flutter-create.yml"

    if [[ -f "$template_file" ]]; then
        cp "$template_file" "$workflow_file"
    else
        print_step "Downloading workflow template..."
        curl -fsSL "https://raw.githubusercontent.com/krinry/krinry-cli/dev/workflows/krinry-flutter-create.yml" -o "$workflow_file" 2>/dev/null
    fi

    # Initial commit
    echo "# ${project_name}" > README.md
    git add .
    git commit -m "chore: add scaffolding workflow"
    git push -u origin HEAD
    print_success "Workflow pushed to GitHub"

    # Trigger workflow
    print_step "Triggering Flutter create in cloud..."
    gh workflow run krinry-flutter-create.yml \
        -f project_name="$project_name" \
        -f org="$org" \
        -f template="$template" \
        -f platforms="$platforms"

    sleep 3
    local run_id
    run_id=$(gh run list --workflow=krinry-flutter-create.yml --limit=1 --json databaseId -q '.[0].databaseId' 2>/dev/null)

    if [[ -n "$run_id" ]]; then
        local start_time=$(date +%s)
        while true; do
            local now=$(date +%s)
            local elapsed=$((now - start_time))
            local status
            status=$(gh run view "$run_id" --json status -q '.status' 2>/dev/null)
            echo -ne "\r${CYAN}🔄${NC} Creating Flutter project... (${elapsed}s)   "
            if [[ "$status" == "completed" ]]; then
                echo ""
                local conclusion
                conclusion=$(gh run view "$run_id" --json conclusion -q '.conclusion' 2>/dev/null)
                if [[ "$conclusion" == "success" ]]; then
                    print_success "Cloud scaffolding completed!"
                else
                    print_error "Cloud scaffolding failed!"
                    exit 1
                fi
                break
            fi
            sleep 5
        done

        # Pull scaffolded files
        print_step "Pulling scaffolded files..."
        git pull --rebase
    else
        print_error "Failed to get workflow run ID"
        exit 1
    fi

    print_success "Flutter project created successfully!"
    echo ""
    echo "Next steps:"
    echo "  cd ${project_name}"
    echo "  krinry flutter init      # Setup cloud build workflow"
    echo "  krinry flutter build apk --debug"
    echo ""
}
