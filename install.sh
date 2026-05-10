#!/bin/bash

# Hermes Agent - One-line installer for Termux (Android)
# Repository: https://github.com/AbuZar-Ansarii/Hermes-Agent-On-Android

set -e

# Colors for output
CYN='\033[0;36m'
GRN='\033[0;32m'
RED='\033[0;31m'
RST='\033[0m'

echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}                   THEVOIDKERNEL"
echo -e "${CYN}=====================================================${RST}"

echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}              HERMES AGENT INSTALLER"
echo -e "${CYN}=====================================================${RST}"

echo -e "${GRN}🚀 Installing Hermes Agent on Termux...${RST}"
echo "📦 Repository: https://github.com/AbuZar-Ansarii/Hermes-Agent-On-Android"
echo ""

# Fix: Handle apt prompts automatically by setting DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND=noninteractive

# Update packages without prompts - use --yes and handle config prompts
pkg update -y 2>/dev/null || true

# Fix for sources.list prompt - force overwrite with 'Y' answer
yes 'Y' | pkg upgrade -y 2>/dev/null || true

# Alternative: Force overwrite config files
yes | pkg upgrade -y 2>/dev/null || true

# Now do a clean update/upgrade
pkg update -y -o Dpkg::Options::="--force-confnew" 2>/dev/null || pkg update -y
pkg upgrade -y -o Dpkg::Options::="--force-confnew" 2>/dev/null || yes 'Y' | pkg upgrade -y

echo -e "${GRN}✅ System packages updated!${RST}"

# Install dependencies
echo -e "${GRN}📦 Installing dependencies...${RST}"
pkg install -y git python clang rust make pkg-config libffi openssl nodejs ripgrep ffmpeg

# Clone repository
echo -e "${GRN}📥 Cloning Hermes Agent...${RST}"
if [ -d "hermes-agent" ]; then
    rm -rf hermes-agent
fi
git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git

# Navigate to directory
cd hermes-agent

# Setup Python virtual environment
echo -e "${GRN}🐍 Setting up Python environment...${RST}"
python -m venv venv
source venv/bin/activate

# Set Android API level
export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk)"

# Upgrade pip tools
python -m pip install --upgrade pip setuptools wheel

# Install Hermes with Termux support
echo -e "${GRN}🔧 Installing Hermes Agent...${RST}"
python -m pip install -e '.[termux]' -c constraints-termux.txt

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
echo -e "${CYN}🌐 Run 'hermes gateway' to deploy it${RST}"
echo ""