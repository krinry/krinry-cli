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
curl -fsSL https://raw.githubusercontent.com/krinry/krinry-cli/main/install.sh | bash
```

## 6. Command Structure

### Global Commands
```bash
krinry --help           # Show help
krinry --version        # Show version  
krinry update           # Update CLI
```

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
User (Termux) → krinry CLI → GitHub API → Actions Runner → APK → Download
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

### v3 (Future)
- Plugin system
- Multiple cloud backends
- Custom workflows