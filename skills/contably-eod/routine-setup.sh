#!/usr/bin/env bash
# routine-setup.sh — paste this into the Claude Code Routine "Setup script" field
# Runs once per Routine invocation, before /contably-eod fires. Cached across runs.
set -euo pipefail

echo "▶ contably-eod routine setup — $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# 1. System packages
sudo apt-get update -qq
sudo apt-get install -y -qq curl jq git unzip

# 2. pnpm (matches Contably packageManager field)
curl -fsSL https://get.pnpm.io/install.sh | bash -
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# 3. uv (Contably Python toolchain)
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# 4. GitHub CLI (for PR / run inspection by /contably-ci-rescue)
if ! command -v gh >/dev/null 2>&1; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -qq && sudo apt-get install -y -qq gh
fi

# 5. kubectl + OCI CLI (only if CI-rescue-to-prod scenarios are desired; heavy)
if [[ "${ENABLE_KUBECTL:-false}" == "true" ]]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults
  # Decode kubeconfig from env var
  if [[ -n "${KUBECONFIG_B64:-}" ]]; then
    mkdir -p ~/.kube
    echo "$KUBECONFIG_B64" | base64 -d > ~/.kube/config
    chmod 600 ~/.kube/config
  fi
fi

# 6. Resend CLI (for agenda email)
curl -fsSL https://github.com/resend/resend-cli/releases/latest/download/resend-linux-amd64 -o /tmp/resend
chmod +x /tmp/resend
sudo mv /tmp/resend /usr/local/bin/resend

# 7. Install Contably API deps (cached across runs)
cd apps/api && uv sync --frozen 2>/dev/null || uv sync
cd ../..

# 8. Install Contably frontend deps
pnpm install --frozen-lockfile 2>/dev/null || pnpm install

# 9. Sanity check
echo "▶ Versions:"
node --version
pnpm --version
uv --version
gh --version | head -1
resend --version || echo "resend: installed"

echo "✓ contably-eod routine setup complete"
