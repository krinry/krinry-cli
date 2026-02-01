# Contributing to krinry

Thank you for your interest in contributing to krinry! 🎉

## How to Contribute

### Reporting Bugs

1. Check if the issue already exists
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected vs actual behavior
   - Termux version and device info

### Suggesting Features

1. Open an issue with `[Feature]` prefix
2. Describe the feature and use case
3. Explain why it would be useful

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Test on Termux if possible
5. Commit with clear messages
6. Push and open a PR

### Code Style

- Use 4-space indentation in shell scripts
- Add comments for complex logic
- Follow existing naming conventions
- Test your changes before submitting

### Areas to Contribute

- 🐛 Bug fixes
- 📚 Documentation improvements
- 🌍 New features
- 🧪 Testing on different devices
- 🎨 UI/UX improvements

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/krinry-cli.git
cd krinry-cli

# Create symlink for testing
ln -sf $(pwd)/bin/krinry ~/.local/bin/krinry

# Test your changes
krinry --help
```

## Questions?

Open an issue or reach out on GitHub!

Thanks for contributing! 🚀
