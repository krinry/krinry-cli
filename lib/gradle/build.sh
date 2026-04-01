#!/bin/bash
# krinry gradle - Build Command

cmd_build() {
    local gradle_task="${1:-assembleDebug}"
    
    # Help flag check
    if [[ "$gradle_task" == "--help" || "$gradle_task" == "-h" ]]; then
        show_build_help
        exit 0
    fi
    
    print_header "krinry Gradle"
    echo "Task: ${gradle_task}"
    echo ""
    
    # Validate environment
    validate_build_environment
    
    # Check for uncommitted changes
    if has_uncommitted_changes; then
        print_warning "You have uncommitted changes"
        echo ""
        git status --short
        echo ""
        if ask_yes_no "Commit changes before building?" "y"; then
            read -r -p "Commit message: " commit_msg
            git add .
            git commit -m "${commit_msg:-'Build commit'}"
            print_success "Changes committed"
        else
            print_warning "Building with uncommitted changes (they won't be in the build)"
        fi
    fi
    
    # Push latest changes
    print_step "Pushing to GitHub..."
    local push_output
    push_output=$(git push 2>&1)
    if [[ $? -ne 0 ]]; then
        print_warning "Failed to push changes"
        echo "$push_output"
        echo ""
        echo "Please resolve this and try again."
        exit 1
    else
        print_success "Pushed to GitHub"
    fi
    
    # Trigger workflow
    print_step "Triggering cloud build..."
    
    local repo_owner=$(get_repo_owner)
    local repo_name=$(get_repo_name)
    
    if [[ -z "$repo_owner" || -z "$repo_name" ]]; then
        print_error "Could not determine repository owner/name from remote URL"
        exit 1
    fi
    
    local trigger_output
    trigger_output=$(gh workflow run krinry-gradle-build.yml -f gradle_task="${gradle_task}" 2>&1)
    
    if [[ $? -ne 0 ]]; then
        print_error "Failed to trigger workflow"
        echo "$trigger_output"
        exit 1
    fi
    
    print_success "Build triggered!"
    echo ""
    sleep 3
    
    print_step "Getting build status..."
    local run_id
    run_id=$(gh run list --workflow=krinry-gradle-build.yml --limit=1 --json databaseId -q '.[0].databaseId' 2>/dev/null)
    
    if [[ -z "$run_id" ]]; then
        print_error "Could not find the triggered workflow run"
        exit 1
    fi
    
    echo "Run ID: ${run_id}"
    echo "View online: https://github.com/${repo_owner}/${repo_name}/actions/runs/${run_id}"
    echo ""
    
    local artifact_pattern="build-${gradle_task}-*"
    
    # For test reports, checking test word in task name
    if [[ "$gradle_task" == *"test"* || "$gradle_task" == *"Test"* ]]; then
        artifact_pattern="test-reports"
    fi
    
    poll_build_status "$run_id" "$repo_owner" "$repo_name" "$artifact_pattern"
}

show_build_help() {
    echo ""
    echo "Usage: krinry gradle <task>"
    echo ""
    echo "Run any Gradle task using GitHub Actions cloud build."
    echo ""
    echo "COMMON TASKS:"
    echo "  assembleDebug       Build Android Debug APK"
    echo "  assembleRelease     Build Android Release APK"
    echo "  bundleRelease       Build Android App Bundle (.aab)"
    echo "  build               Run standard build and tests"
    echo "  test                Run unit tests"
    echo "  clean               Clean build directories"
    echo ""
    echo "EXAMPLES:"
    echo "  krinry gradle assembleDebug"
    echo "  krinry gradle myCustomTask"
    echo "  krinry gradle build"
    echo ""
}

validate_build_environment() {
    print_step "Validating environment..."
    local has_error=false
    
    if ! is_gradle_project; then
        print_error "Not a Gradle project"
        has_error=true
    fi
    
    if ! is_git_repo; then
        print_error "Not a git repository"
        has_error=true
    fi
    
    if [[ -z "$(get_remote_url)" ]]; then
        print_error "No GitHub remote configured"
        has_error=true
    fi
    
    if ! has_gradle_workflow_file; then
        print_error "No workflow file found (Run: krinry gradle init)"
        has_error=true
    fi
    
    if ! is_command_available gh || ! gh auth status &>/dev/null; then
        print_error "GitHub CLI not installed or not authenticated"
        has_error=true
    fi
    
    if ! check_internet; then
        print_error "No internet connection"
        has_error=true
    fi
    
    if [[ "$has_error" == "true" ]]; then
        print_error "Environment validation failed"
        exit 1
    fi
    print_success "Environment valid"
    echo ""
}

poll_build_status() {
    local run_id="$1"
    local repo_owner="$2"
    local repo_name="$3"
    local artifact_pattern="$4"
    
    local poll_interval=5
    local status=""
    local conclusion=""
    local start_time=$(date +%s)
    local current_step=""
    
    print_header "Build Progress"
    echo ""
    
    while true; do
        local run_info
        run_info=$(gh run view "$run_id" --json status,conclusion,jobs 2>/dev/null)
        
        status=$(echo "$run_info" | grep -o '"status":"[^"]*"' | head -1 | sed 's/"status":"\([^"]*\)"/\1/')
        conclusion=$(echo "$run_info" | grep -o '"conclusion":"[^"]*"' | head -1 | sed 's/"conclusion":"\([^"]*\)"/\1/')
        
        local step_name
        step_name=$(echo "$run_info" | grep -o '"name":"[^"]*"' | tail -1 | sed 's/"name":"\([^"]*\)"/\1/')
        
        local now=$(date +%s)
        local elapsed=$((now - start_time))
        local time_str="${elapsed}s"
        if [[ $((elapsed / 60)) -gt 0 ]]; then
            time_str="$((elapsed / 60))m $((elapsed % 60))s"
        fi
        
        case "$status" in
            queued)
                echo -ne "\r${YELLOW}⏳${NC} Queued... (${time_str})                              "
                ;;
            in_progress)
                if [[ -n "$step_name" && "$step_name" != "$current_step" ]]; then
                    current_step="$step_name"
                    echo ""
                    echo -e "${CYAN}→${NC} ${step_name}"
                fi
                echo -ne "\r${CYAN}🔄${NC} Building... (${time_str})                             "
                ;;
            completed)
                echo ""
                break
                ;;
            *)
                echo -ne "\r${BLUE}⏳${NC} ${status}... (${time_str})                            "
                ;;
        esac
        
        sleep "$poll_interval"
    done
    
    case "$conclusion" in
        success)
            print_success "Build completed successfully!"
            echo ""
            download_artifacts "$run_id" "$artifact_pattern"
            ;;
        failure)
            print_error "Build failed!"
            echo ""
            print_step "Fetching build logs..."
            gh run view "$run_id" --log-failed 2>/dev/null | tail -50
            exit 1
            ;;
        *)
            print_error "Build ended with: ${conclusion}"
            exit 1
            ;;
    esac
}

download_artifacts() {
    local run_id="$1"
    local artifact_pattern="$2"
    
    print_header "Downloading Outputs"
    
    ensure_dir "build/krinry-outputs"
    
    local available_artifacts
    available_artifacts=$(gh run view "$run_id" --json artifacts -q '.artifacts[].name' 2>/dev/null)
    
    if [[ -z "$available_artifacts" ]]; then
        print_info "No artifacts produced by this build."
        return 0
    fi
    
    local downloaded=false
    while IFS= read -r avail_artifact; do
        if [[ -n "$avail_artifact" ]]; then
            # Simple wildcard matching
            if [[ "$avail_artifact" == ${artifact_pattern} ]]; then
                print_step "Downloading artifact: ${avail_artifact}"
                if gh run download "$run_id" -n "${avail_artifact}" -D "build/krinry-outputs" 2>/dev/null; then
                    downloaded=true
                fi
            fi
        fi
    done <<< "$available_artifacts"
    
    if [[ "$downloaded" == "true" ]]; then
        print_success "Outputs saved to build/krinry-outputs/"
        ls -la build/krinry-outputs/
    else
        print_info "No matching artifacts found to download."
        echo "Available artifacts on GitHub:"
        echo "$available_artifacts"
    fi
}
