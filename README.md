# devops-lab : Laboratoire DevOps réutilisable

Un cluster Kubernetes local (**kind**) + **Prometheus + Grafana**, reproductible en une commande sur n'importe quelle machine
(Windows + Docker Desktop + WSL2 Ubuntu, ou Linux natif). Chaque TP/projet vient *se brancher* sur ce lab au lieu de réinstaller sa propre stack.

## Démarrage rapide
```bash
git clone git@github.com:ReemaZa/devops-lab.git ~/dev/devops-lab && cd ~/dev/devops-lab
make tools     # une fois par machine : kubectl, kind, helm
make check     # vérifie Docker, WSL2, BTF/eBPF
make up        # cluster + Prometheus + Grafana (3-5 min)
```
- Grafana    : http://localhost:3000 (admin / admin)
- Prometheus : http://localhost:9090

`make down` détruit tout. `make up` le recrée à l'identique : **l'infrastructure est du code, jetable et reproductible**.

## Contenu
| Fichier | Rôle |
|---|---|
| `kind/kind-config.yaml` | définition du cluster + ports exposés vers Windows |
| `helm/kube-prometheus-stack-values.yaml` | Prometheus + Grafana en configuration minimale |
| `scripts/install-tools.sh` | installe kubectl / kind / helm dans `~/.local/bin` |
| `scripts/check-prereqs.sh` | diagnostic de la machine (WSL2, Docker, eBPF) |
| `Makefile` | `make help` liste les commandes |

## Brancher un projet
Un projet fournit ses manifestes (Deployments, ServiceMonitor, dashboards en ConfigMap labellisée `grafana_dashboard=1`) et les applique
sur le contexte `kind-lab`. Voir `tp-ebpf-microservices` pour un exemple complet.

## Idées d'extensions (addons)
Loki (logs), Tempo (traces), ingress-nginx, Argo CD, Chaos Mesh, Trivy... : ajouter un dossier `addons/<nom>/` + une cible `make addon-<nom>`.
