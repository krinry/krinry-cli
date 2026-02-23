# Changelog

All notable changes to krinry are documented here.

## [3.0.2] - 2026-02-23

### Added
- **Plugin-based Installer Architecture**: `lib/installers/` directory introduced. Any `.sh` file added here automatically becomes a `krinry install <name>` command.
- `krinry install qwen`: Installs Qwen Code CLI via npm automatically.
- Generic fallback installer: `krinry install <pkg>` will attempt to install via Termux `pkg` if a dedicated script doesn't exist.
- 12 standard plugins added to the `krinry install oh-my-zsh` configuration.

### Changed
- Removed all dependencies on the TermuxVoid repository.
- Flutter installation now uses a dedicated `packages/flutter.deb` file hosted directly in the krinry-cli repository for enhanced reliability and custom branding.
- Global installation script (`install.sh`) now only installs absolute minimum dependencies (`git`, `curl`). Other dependencies like `gh`, `jq`, `npm` are installed lazily only when requested by a specific command.
- Switched all main repository references from the `main` branch to the `dev` branch.

## [2.7.1] - 2025-02-01

### Added
- Complete Zsh setup with one command: `krinry install oh-my-zsh`
  - Zsh shell
  - Oh My Zsh framework
  - Powerlevel10k theme
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - zsh-completions
- Automatic .zshrc configuration from the current shell

## [2.7.0] - 2025-02-01

### Added
- `krinry install shell-tools` - Bundle with Fish, Zsh, TheFuck, Fzf
- `krinry install fish` - Fish shell with auto-suggestions
- `krinry install zsh` - Z Shell
- `krinry install oh-my-zsh` - Complete Zsh setup
- `krinry install thefuck` - Command correction tool
- Post-install prompt asking to install shell-tools

### Changed
- Installer now asks if you want shell-tools after CLI install

## [2.6.0] - 2025-02-01

### Added
- `krinry install` command for installing packages
- `krinry install flutter` - Install Flutter SDK
- `krinry install neovim/micro/vim` - Install editors
- Automatic TermuxVoid repository setup
- krinry branding throughout CLI
- TermuxVoid credit in install messages
- Professional README with badges
- CONTRIBUTING.md guide
- CHANGELOG.md

### Changed
- Completely rewrote `krinry update` for automatic updates
- Auto-download latest version with backup
- Shows changelog during updates
- Silenced TermuxVoid output during install

### Fixed
- Update command now actually auto-updates
- Flutter install uses correct TermuxVoid repo

## [2.5.0] - 2025-02-01

### Added
- TermuxVoid integration for Flutter install

### Fixed
- Flutter SDK installation on Termux

## [2.4.0] - 2025-01-31

### Added
- Live build progress with elapsed time
- Step-by-step build status display
- Auto-detect artifact names for download

### Fixed
- "Artifact not found" download errors
- APK file overwrite issues

## [2.3.0] - 2025-01-31

### Added
- `--split-per-abi` flag for split APKs
- `--target-platform` for specific architectures
- `--install` to install APK after download
- Pro tips displayed after `krinry flutter init`

### Changed
- Workflow template copied from file instead of hardcoded
- Auto-overwrite existing workflow files

## [2.0.0] - 2025-01-31

### Added
- Complete CLI rewrite as `krinry`
- Multi-tool architecture
- `krinry flutter` subcommands
- Cloud build support via GitHub Actions
- `krinry update` command

### Changed
- Renamed from krinry-flutter to krinry
- Modular script structure

## [1.0.0] - 2025-01-30

### Added
- Initial release
- Flutter cloud build support
- APK generation via GitHub Actions
