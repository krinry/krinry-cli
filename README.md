<p align="center">
  <img src="https://img.shields.io/badge/krinry-CLI-blueviolet?style=for-the-badge&logo=terminal" alt="krinry CLI">
</p>

<h1 align="center">🚀 krinry</h1>

<p align="center">
  <strong>The Ultimate CLI for Mobile Developers on Termux</strong>
</p>

<p align="center">
  <a href="#installation"><img src="https://img.shields.io/badge/Install-One%20Line-success?style=flat-square" alt="Install"></a>
  <a href="#features"><img src="https://img.shields.io/badge/Features-Cloud%20Builds-blue?style=flat-square" alt="Features"></a>
  <a href="https://github.com/krinry/krinry-cli/releases"><img src="https://img.shields.io/github/v/release/krinry/krinry-cli?style=flat-square&color=orange" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"></a>
</p>

<p align="center">
  <a href="#flutter-commands">Flutter</a> •
  <a href="#installation">Install</a> •
  <a href="#usage">Usage</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## ✨ What is krinry?

**krinry** is a powerful CLI tool designed for mobile developers using **Termux** on Android. Build Flutter APKs in the cloud, install packages with one command, and develop apps right from your phone!

### 🎯 Key Features

| Feature | Description |
|---------|-------------|
| ☁️ **Cloud Builds** | Build Flutter APKs/AABs using GitHub Actions |
| 📦 **Package Manager** | Install Flutter, editors, and tools with one command |
| 🔄 **Auto Updates** | Keep krinry up-to-date automatically |
| 📱 **Termux Native** | Built specifically for Termux on Android |
| 🎨 **Beautiful UI** | Colorful, informative terminal output |

---

## 📥 Installation

```bash
curl -fsSL https://raw.githubusercontent.com/krinry/krinry-cli/dev/install.sh | bash
```

After installation, restart your terminal or run:
```bash
source ~/.bashrc
```

### Requirements
- [Termux](https://f-droid.org/packages/com.termux/) (from F-Droid)
- Internet connection
- GitHub account (for cloud builds)

---

## 🚀 Quick Start

### Install Flutter
```bash
krinry install flutter
```

### Build APK in Cloud
```bash
# Initialize your project
cd your-flutter-project
krinry flutter init

# Build release APK
krinry flutter build apk --release
```

---

## 📖 Usage

### Global Commands

| Command | Description |
|---------|-------------|
| `krinry --help` | Show help |
| `krinry --version` | Show version |
| `krinry update` | Update krinry to latest |

### Install Commands

```bash
# Install Flutter SDK
krinry install flutter

# Install AI Tools
krinry install qwen

# Install Shell enhancements
krinry install oh-my-zsh
krinry install shell-tools

# Install editors
krinry install neovim
krinry install micro

# Install any Termux package as fallback
krinry install <package-name>
```

### Flutter Commands

```bash
# Initialize cloud builds in your project
krinry flutter init

# Check system setup
krinry flutter doctor

# Build APK (cloud)
krinry flutter build apk --release
krinry flutter build apk --debug
krinry flutter build apk --split-per-abi

# Build App Bundle
krinry flutter build appbundle --release

# Run web server locally
krinry flutter run web
```

### Build Options

| Flag | Description |
|------|-------------|
| `--release` | Release build (optimized) |
| `--debug` | Debug build (default) |
| `--split-per-abi` | Split APK by architecture |
| `--target-platform` | Build for specific ABI |
| `--install` | Install APK after download |

---

## 🔧 How Cloud Builds Work

1. **Initialize** - `krinry flutter init` creates a GitHub Actions workflow
2. **Commit** - Push your code to GitHub
3. **Build** - `krinry flutter build apk` triggers the workflow
4. **Download** - APK is automatically downloaded when ready

```
Your Phone (Termux)          GitHub Actions
      │                            │
      ├── krinry flutter init ────►│ Creates workflow
      │                            │
      ├── git push ───────────────►│ Code uploaded
      │                            │
      ├── krinry flutter build ───►│ Triggers build
      │                            │
      │◄── APK downloaded ─────────┤ Build complete
      │                            │
```

---

## 📁 Project Structure

```
~/.krinry/
├── bin/
│   └── krinry           # Main CLI entry point
├── lib/
│   ├── core.sh          # Core utilities
│   ├── update.sh        # Auto-update
│   ├── install.sh       # Auto-discovery plugin dispatcher
│   ├── installers/      # 📦 PLUGINS: Drop a .sh file here to add a tool!
│   │   ├── qwen.sh
│   │   ├── flutter.sh
│   │   └── ...
│   └── flutter/         # Dedicated flutter core logic
│       ├── init.sh
│       └── build.sh
└── workflows/
    └── krinry-flutter-build.yml
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

- **[Flutter](https://flutter.dev)** - UI toolkit
- **[GitHub Actions](https://github.com/features/actions)** - Cloud CI/CD

---

<p align="center">
  <strong>Made with ❤️ by <a href="https://github.com/krinry">krinry</a></strong>
</p>

<p align="center">
  <a href="https://github.com/krinry/krinry-cli/stargazers">⭐ Star this repo</a> •
  <a href="https://github.com/krinry/krinry-cli/issues">🐛 Report Bug</a> •
  <a href="https://github.com/krinry/krinry-cli/issues">💡 Request Feature</a>
</p>
