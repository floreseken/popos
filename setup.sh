#!/bin/bash

# ==============================================================================
# Pop!_OS Developer Setup Script
# ==============================================================================

set -e # Exit immediately if a command exits with a non-zero status

echo "Starting setup..."

# 1. Update and Upgrade System
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# 2. Install Basic Development Tools
echo "Installing git, curl, and wget..."
sudo apt install -y git curl wget gnupg2 gpg software-properties-common apt-transport-https

# 3. Install VS Code (via .deb for stability)
echo "Installing VS Code..."
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor  | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null

# 4. Add the VS Code repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update
sudo apt install code -y



# 4. Install Node.js (via NVM)
echo "Installing NVM and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
sudo ln -s $(which node) /usr/local/bin/node

# 5. Install Docker
echo "Installing Docker..."
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker $USER

# 6. Install ohmyposh
echo "Installing Oh my posh..."
sudo sh -c "curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin"
oh-my-posh init bash --config ~/.cache/oh-my-posh/themes/quick-term.omp.json
oh-my-posh font install meslo
PROFILE="$HOME/.bashrc"
SNIPPET='eval "$(oh-my-posh init bash --config ~/.cache/oh-my-posh/themes/quick-term.omp.json)"'

if grep -qF "$SNIPPET" "$PROFILE"; then
    echo "oh-my-posh init already present in $PROFILE — skipping."
else
    echo "" >> "$PROFILE"
    echo "$SNIPPET" >> "$PROFILE"
    echo "Added oh-my-posh init to $PROFILE"
fi
exec bash



# 6. Install .NET framework
echo "Installing .NET 10 SDK..."
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 10.0
echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools' >> ~/.bashrc
source ~/.bashrc


# 9. Cleanup
echo "Cleaning up..."
sudo apt autoremove -y

echo "Setup Complete! Please restart your computer."
