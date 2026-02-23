#!/bin/bash
# krinry installer: flutter
# Usage: krinry install flutter
# Installs Flutter SDK via krinry's .deb package (krinry branding)

cmd_install() {
    # Delegate to the flutter tool's install command
    # This keeps all flutter logic in lib/flutter/
    source "${LIB_DIR}/flutter/install.sh"
    cmd_install_flutter
}
