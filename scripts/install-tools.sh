#!/usr/bin/env bash
# Installe kubectl, kind et helm dans ~/.local/bin (sans sudo). Idempotent : ne réinstalle pas l'existant.
set -euo pipefail
BIN="${HOME}/.local/bin"; mkdir -p "$BIN"
export PATH="$BIN:$PATH"
KIND_VERSION="${KIND_VERSION:-v0.27.0}"
case "$(uname -m)" in x86_64) ARCH=amd64;; aarch64|arm64) ARCH=arm64;; *) echo "arch inconnue"; exit 1;; esac
have() { command -v "$1" >/dev/null 2>&1; }

if ! have kubectl; then
  echo ">> kubectl"; V=$(curl -sL https://dl.k8s.io/release/stable.txt)
  curl -sLo "$BIN/kubectl" "https://dl.k8s.io/release/${V}/bin/linux/${ARCH}/kubectl"; chmod +x "$BIN/kubectl"
fi
if ! have kind; then
  echo ">> kind ${KIND_VERSION}"
  curl -sLo "$BIN/kind" "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"; chmod +x "$BIN/kind"
fi
if ! have helm; then
  echo ">> helm"
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | USE_SUDO=false HELM_INSTALL_DIR="$BIN" bash
fi
for t in make jq envsubst curl git python3; do
  have "$t" || echo "!! manquant : $t  ->  sudo apt update && sudo apt install -y make jq gettext-base curl git python3"
done
echo; echo "Versions :"; kubectl version --client 2>/dev/null | head -1; kind version; helm version --short
case ":$PATH:" in *":$BIN:"*) ;; *) echo "Ajoutez à ~/.bashrc :  export PATH=\"\$HOME/.local/bin:\$PATH\"";; esac
