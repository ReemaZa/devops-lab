#!/usr/bin/env bash
# Vérifie que la machine peut faire tourner le lab (et eBPF).
ok(){ echo "  [OK]   $*"; }; ko(){ echo "  [FAIL] $*"; }
echo "== Environnement"
grep -qi microsoft /proc/version && ok "WSL2 détecté" || echo "  [info] pas WSL (Linux natif ?)"
echo "  noyau : $(uname -r)"
echo "== Docker"
docker info >/dev/null 2>&1 && ok "docker accessible depuis cette distro" || ko "docker inaccessible (Docker Desktop > Settings > Resources > WSL Integration)"
echo "== eBPF"
[ -e /sys/kernel/btf/vmlinux ] && ok "BTF présent dans le noyau (/sys/kernel/btf/vmlinux)" || ko "BTF absent -> PowerShell : wsl --update puis wsl --shutdown"
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^lab-control-plane$'; then
  docker exec lab-control-plane test -e /sys/kernel/btf/vmlinux && ok "BTF visible DANS le noeud kind" || ko "BTF absent dans le noeud kind"
fi
echo "== Outils"
for t in docker kubectl kind helm make jq envsubst git; do command -v $t >/dev/null && ok "$t" || ko "$t manquant"; done
echo "== Ressources"
echo "  CPU : $(nproc) | RAM : $(free -g | awk '/Mem/{print $2}') Go (recommandé : >= 4 CPU, >= 8 Go)"
