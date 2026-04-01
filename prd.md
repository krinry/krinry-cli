# krinry - Product Requirements Document

## 1. Product Name
**krinry** (multi-tool CLI, with `flutter` as first tool)

## 2. One-line Vision
A mobile-first CLI that lets users build Flutter apps on Android phones using Termux and cloud builds — without a PC.

## 3. Target Users
- Students with no PC access
- Low-end PC or no-PC developers
- Android + Termux users
- Flutter beginners

## 4. Core Philosophy
- **Don't replace Flutter** — wrap it with mobile-friendly automation
- **Cloud-first builds** — offload heavy builds to GitHub Actions
- **Same commands as Flutter** — familiar interface

## 5. Installation

```bash
curl -fsSL https://raw.githubusercontent.com/krinry/krinry-cli/dev/install.sh | bash
```

## 6. Command Structure

### Global Commands
```bash
krinry --help           # Show help
krinry --version        # Show version  
krinry update           # Update CLI
```

### Overview
The objective is to expand the capabilities of the `krinry-cli` tool to support comprehensive cloud-based project creation and building for **Android (Gradle/Kotlin/Java)** and **Flutter** via **GitHub Actions**. This implementation enables fully cloud-native workflows on environments like Termux, eliminating local hardware constraints for compiling large projects like Android apps.

## Target Audience
Mobile app developers, specifically Android and Flutter developers leveraging low-power or terminal-based environments (like Termux on Android) and favoring cloud CI/CD logic instead of local compilation.

## Key Features Added

1.  **Gradle Cloud Builds (Android/Java/Kotlin):**
    *   `krinry gradle assembleDebug` / `krinry gradle test` / etc.: Invokes corresponding gradle tasks on GitHub Actions, downloading outputs seamlessly.
    *   `krinry gradle init`: Initializes a `.github/workflows/krinry-gradle-build.yml` file to handle gradle tasks.
    *   `krinry gradle doctor`: Checks GitHub CLI authentication and repo configuration.
    
2.  **Cloud-Based Project Scaffolding `create`:**
    *   **Gradle**: `krinry gradle create <name>` dynamically scaffolds a new Android (Kotlin + Jetpack Compose) or pure Kotlin/Java repository directly on GitHub and pulls the fresh repository back locally.
    *   **Flutter**: `krinry flutter create <name>` generates a new Flutter application purely via GitHub Actions, bypassing the need for an installed local SDK to orchestrate the structure.

3.  **Preserved existing local configurations:**
    *   Keeps Flutter installation scripts intact for users who want to run `flutter run web` locally.

## Architecture

*   **Language:** Bash (for the CLI), GitHub Actions (YAML for cloud compute).
*   **Infrastructure:** Depends on the `gh` (GitHub CLI) for creating repositories, triggering workflows, and downloading artifacts.
*   **Structure Update:** 
    *   `bin/krinry`: The entry point router passes parameters to `run_gradle_tool`.
    *   `lib/gradle/*.sh`: Houses the logic for init, doctor, build, and create.
    *   `workflows/krinry-gradle-build.yml` & `krinry-gradle-create.yml`: Remote runner configuration.

## Deployment & Verification
To test the tool:
1. `krinry gradle create test_android_app`
   Expected: Requests creation of github repo, pushes a create workflow, GitHub runner generates a new Compose Android app and pushes it to main, CLI pulls down the codebase.
2. `cd test_android_app && krinry gradle assembleDebug`
   Expected: Triggers Krinry Gradle build workflow, waits for completion, downloads `.apk` file into `app/build/outputs/apk/debug/`.
3. `krinry flutter create test_flutter_app`
   Expected: Scaffolds a flutter app in the cloud, pulls code down.
4. `cd test_flutter_app && krinry flutter build apk`
   Expected: Builds the Flutter apk via cloud. CLI → Plugin Dispatcher (lib/installers/*.sh)
                                 │
                                 ├──> Flutter Tool → GitHub Action → APK
                                 ├──> Qwen Install
                                 └──> Shell Tools Install

### Flutter Tool Commands
```bash
krinry flutter install       # Install Flutter SDK
krinry flutter doctor        # Check requirements
krinry flutter init          # Initialize cloud build
krinry flutter run web       # Run local web server
```

### Build Commands (matching `flutter build`)
```bash
# APK builds
krinry flutter build apk --debug
krinry flutter build apk --profile
krinry flutter build apk --release

# Split APK (smaller per-device files)
krinry flutter build apk --release --split-per-abi

# Target platform
krinry flutter build apk --release --target-platform android-arm64
krinry flutter build apk --release --target-platform android-arm
krinry flutter build apk --release --target-platform android-x64

# App Bundle
krinry flutter build appbundle --debug
krinry flutter build appbundle --release

# Auto-install on device
krinry flutter build apk --release --install
```

## 7. Architecture

```
User (Termux) → krinry CLI → Plugin Dispatcher (lib/installers/*.sh)
                                 │
                                 ├──> Flutter Tool → GitHub Action → APK
                                 ├──> Qwen Install
                                 └──> Shell Tools Install
```

## 8. Files Generated

### `.github/workflows/krinry-build.yml`
GitHub Actions workflow with inputs:
- `build_type`: debug, profile, release
- `output_type`: apk, appbundle, apk-split
- `target_platform`: all, android-arm64, android-arm, android-x64

### `.krinry.yaml`
Project configuration file.

## 9. Technical Stack
- **CLI**: Pure Bash (native Termux, fast startup)
- **Cloud**: GitHub Actions
- **Auth**: GitHub CLI (`gh auth login`)

## 10. Non-Goals (v1)
- iOS builds
- Emulator management
- Desktop OS support
- GUI interface

## 11. Success Criteria
A user can:
1. Install krinry on phone
2. Create/open Flutter project
3. Run one build command
4. Get working APK downloaded
5. Optionally auto-install to device

**All without touching a PC.**

## 12. Roadmap

### v1 (Current)
- ✅ Install Flutter SDK
- ✅ Doctor command
- ✅ Init cloud build
- ✅ Build APK (debug/profile/release)
- ✅ Build App Bundle
- ✅ Split APK by ABI
- ✅ Target platform
- ✅ Auto-install on device

### v2 (Planned)
- Log streaming
- Build caching
- Run web locally
- Template workflows

### v3 (Current)
- ✅ Auto-discovery Plugin system (`lib/installers/`)
- ✅ 100% krinry branding (No TermuxVoid dependency)
- ✅ AI Tools Integration (Qwen)

### v4 (Future)
- Multiple cloud backends
- Custom workflows