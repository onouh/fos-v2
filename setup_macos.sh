#!/bin/bash

# FOS macOS Environment Setup Script
# This script installs the necessary 32-bit cross-compiler and QEMU.

echo "🚀 Starting FOS Environment Setup for macOS..."

# 1. Check for Homebrew (required for QEMU)
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install it from https://brew.sh/"
    exit 1
fi

# 2. Check for MacPorts (required for i386-elf-gcc)
if ! command -v port &> /dev/null; then
    echo "❌ MacPorts not found. Please install it from https://www.macports.org/install.php"
    echo "   Ensure you download the version matching your macOS (e.g., Sequoia)."
    exit 1
fi

echo "📦 Installing QEMU via Homebrew..."
brew install qemu

echo "🛠️ Installing i386-elf toolchain via MacPorts..."
echo "   (This may require your sudo password)"
sudo port install i386-elf-gcc i386-elf-binutils

echo "✅ Setup Complete!"
echo "----------------------------------------------------"
echo "Next Steps:"
echo "1. Ensure your Makefile TOOLPREFIX is set to: /opt/local/bin/i386-elf-"
echo "2. Run 'make clean && make all' to build FOS."
echo "3. Run 'make qemu' to launch the OS."
echo "----------------------------------------------------"
