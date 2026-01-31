#!/bin/bash
# krinry flutter - Init Command

cmd_init() {
    print_header "Initialize krinry flutter"
    
    # Check if in Flutter project
    if ! is_flutter_project; then
        die "Not a Flutter project. Please run this in a Flutter project directory."
    fi
    print_success "Flutter project detected"
    
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
    print_step "Creating GitHub Actions workflow..."
    ensure_dir ".github/workflows"
    
    # Get project name from pubspec
    local app_name
    app_name=$(grep "^name:" pubspec.yaml 2>/dev/null | sed 's/name:[[:space:]]*//' | tr -d '"' | tr -d "'")
    if [[ -z "$app_name" ]]; then
        app_name="app"
    fi
    
    # Create the complete workflow file with all options
    cat > ".github/workflows/krinry-build.yml" << 'WORKFLOW_EOF'
name: krinry Build

on:
  workflow_dispatch:
    inputs:
      build_type:
        description: 'Build type'
        required: true
        default: 'debug'
        type: choice
        options:
          - debug
          - profile
          - release
      
      output_type:
        description: 'Output type'
        required: true
        default: 'apk'
        type: choice
        options:
          - apk
          - appbundle
          - apk-split
      
      target_platform:
        description: 'Target platform (APK only)'
        required: false
        default: 'all'
        type: choice
        options:
          - all
          - android-arm64
          - android-arm
          - android-x64

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
          cache: 'gradle'
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version-file: pubspec.yaml
          cache: true
          cache-key: 'flutter-:os:-:channel:-:version:-:arch:'
          cache-path: '${{ runner.tool_cache }}/flutter/:channel:-:version:-:arch:'
      
      - name: Flutter version
        run: flutter --version
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build
        run: |
          BUILD_TYPE="${{ github.event.inputs.build_type }}"
          OUTPUT_TYPE="${{ github.event.inputs.output_type }}"
          TARGET_PLATFORM="${{ github.event.inputs.target_platform }}"
          
          echo "🔨 Build Configuration:"
          echo "  Type: $BUILD_TYPE"
          echo "  Output: $OUTPUT_TYPE"
          echo "  Platform: $TARGET_PLATFORM"
          echo ""
          
          # Build APK
          if [ "$OUTPUT_TYPE" = "apk" ]; then
            if [ "$TARGET_PLATFORM" != "all" ]; then
              echo "Building APK ($BUILD_TYPE) for $TARGET_PLATFORM..."
              flutter build apk --$BUILD_TYPE --target-platform $TARGET_PLATFORM
            else
              echo "Building APK ($BUILD_TYPE)..."
              flutter build apk --$BUILD_TYPE
            fi
          
          # Build APK split per ABI
          elif [ "$OUTPUT_TYPE" = "apk-split" ]; then
            echo "Building split APKs ($BUILD_TYPE)..."
            flutter build apk --$BUILD_TYPE --split-per-abi
          
          # Build App Bundle
          elif [ "$OUTPUT_TYPE" = "appbundle" ]; then
            echo "Building App Bundle ($BUILD_TYPE)..."
            flutter build appbundle --$BUILD_TYPE
          fi
      
      - name: Upload APK
        if: ${{ github.event.inputs.output_type == 'apk' || github.event.inputs.output_type == 'apk-split' }}
        uses: actions/upload-artifact@v4
        with:
          name: build-${{ github.event.inputs.build_type }}-${{ github.event.inputs.output_type }}
          path: build/app/outputs/flutter-apk/*.apk
          retention-days: 7
      
      - name: Upload App Bundle
        if: ${{ github.event.inputs.output_type == 'appbundle' }}
        uses: actions/upload-artifact@v4
        with:
          name: build-${{ github.event.inputs.build_type }}-${{ github.event.inputs.output_type }}
          path: build/app/outputs/bundle/*/*.aab
          retention-days: 7
WORKFLOW_EOF
    
    print_success "Created .github/workflows/krinry-build.yml"
    
    # Create config file
    print_step "Creating configuration file..."
    
    cat > ".krinry.yaml" << CONFIG_EOF
# krinry configuration
project:
  name: ${app_name}
  type: flutter

build:
  apk:
    artifact: app-release.apk
    output_path: build/app/outputs/flutter-apk

cloud:
  provider: github
  workflow: krinry-build.yml
  poll_interval: 8
CONFIG_EOF
    
    print_success "Created .krinry.yaml"
    
    # Summary
    echo ""
    print_header "Initialization Complete"
    echo ""
    echo "Created files:"
    echo "  • .github/workflows/krinry-build.yml"
    echo "  • .krinry.yaml"
    echo ""
    echo "Next steps:"
    echo "  1. Commit these files:"
    echo "     git add ."
    echo "     git commit -m 'Add krinry cloud build'"
    echo ""
    echo "  2. Push to GitHub:"
    echo "     git push"
    echo ""
    echo "  3. Build your APK:"
    echo "     krinry flutter build apk"
    echo "     krinry flutter build apk --release"
    echo "     krinry flutter build apk --release --split-per-abi"
    echo "     krinry flutter build appbundle --release"
    echo ""
}
