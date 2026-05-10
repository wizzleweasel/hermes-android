#!/bin/bash

# Hermes Agent - Termux Optimized Installer
# Repository: https://github.com/AbuZar-Ansarii/Hermes-Agent-On-Android

set -e

# Colors
GRN='\033[0;32m'
CYN='\033[0;36m'
RED='\033[0;31m'
YEL='\033[0;33m'
RST='\033[0m'

echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}         HERMES AGENT - TERMUX OPTIMIZED${RST}"
echo -e "${CYN}=====================================================${RST}"

# Fix 1: Handle apt config prompts
export DEBIAN_FRONTEND=noninteractive
yes 'Y' | pkg upgrade -y 2>/dev/null || true

# Update packages
echo -e "${GRN}📦 Updating packages...${RST}"
pkg update -y -o Dpkg::Options::="--force-confnew" 2>/dev/null || true
pkg upgrade -y -o Dpkg::Options::="--force-confnew" 2>/dev/null || yes 'Y' | pkg upgrade -y

# Install dependencies
echo -e "${GRN}📦 Installing dependencies...${RST}"
pkg install -y git python clang rust make pkg-config libffi openssl nodejs ripgrep ffmpeg

# Clone repository
echo -e "${GRN}📥 Cloning Hermes Agent...${RST}"
rm -rf hermes-agent 2>/dev/null
git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git
cd hermes-agent

# Setup Python virtual environment
echo -e "${GRN}🐍 Setting up Python environment...${RST}"
python -m venv venv
source venv/bin/activate

# Set Android API level
export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk 2>/dev/null || echo 24)"

# Upgrade pip
python -m pip install --upgrade pip setuptools wheel

# ============================================================
# CRITICAL FIX: Manually install psutil on Android
# ============================================================
echo -e "${GRN}🔧 Installing psutil for Android...${RST}"

# Create a temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download psutil source
pip download --no-deps psutil
tar -xzf psutil-*.tar.gz
cd psutil-*/

# Patch setup.py to recognize Android as Linux
sed -i "s/'linux'/'android'/g" setup.py
sed -i "s/platform.system() == 'Linux'/platform.system() in ['Linux', 'Android']/g" setup.py

# Install the patched psutil
python setup.py install

# Clean up
cd - > /dev/null
rm -rf "$TMP_DIR"

# Verify psutil works
if python -c "import psutil; print('psutil version:', psutil.__version__)" 2>/dev/null; then
    echo -e "${GRN}✅ psutil installed successfully${RST}"
else
    echo -e "${YEL}⚠️ psutil manual install failed, trying pip with Android patch...${RST}"
    # Alternative: Use pip with environment variable to force Linux compatibility
    export SETUPTOOLS_USE_DISTUTILS=stdlib
    pip install psutil --no-binary psutil
fi

# Return to hermes directory
cd "$HOME/hermes-agent"

# Install Hermes with Termux extra (not full all)
echo -e "${GRN}🔧 Installing Hermes Agent...${RST}"
pip install -e '.[termux]' -c constraints-termux.txt

# Create global symlink
ln -sf "$PWD/venv/bin/hermes" "$PREFIX/bin/hermes"

echo -e "${GRN}=====================================================${RST}"
echo -e "${GRN}✅ Hermes Agent installed successfully!${RST}"
echo -e "${GRN}=====================================================${RST}"
echo ""
echo -e "${CYN}🔥 Run 'hermes' to start using it${RST}"
echo -e "${CYN}🔧 Run 'hermes setup' for configuration${RST}"
echo -e "${CYN}📖 Type 'hermes --help' for more options${RST}"
echo ""
echo -e "${GRN}💡 Need help? Visit:${RST} https://github.com/AbuZar-Ansarii/Hermes-Agent-On-Android"
