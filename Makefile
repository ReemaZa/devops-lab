CLUSTER := lab
KPS_VERSION ?=            # optionnel : make up KPS_VERSION=xx.y.z (épingler après la 1re install : helm list -n monitoring)

.PHONY: help tools check up down status urls grafana-password

help: ## Liste les commandes
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

tools: ## Installe kubectl / kind / helm (une seule fois par machine)
	./scripts/install-tools.sh

check: ## Vérifie WSL2, Docker, BTF/eBPF, outils
	./scripts/check-prereqs.sh

up: ## Crée le cluster kind + Prometheus + Grafana (≈ 3-5 min)
	@kind get clusters | grep -qx $(CLUSTER) || kind create cluster --config kind/kind-config.yaml
	kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm upgrade --install kps prometheus-community/kube-prometheus-stack -n monitoring \
	    -f helm/kube-prometheus-stack-values.yaml $(if $(KPS_VERSION),--version $(KPS_VERSION)) --wait --timeout 10m
	@$(MAKE) --no-print-directory urls

down: ## Détruit le cluster (tout est recréable avec `make up`)
	kind delete cluster --name $(CLUSTER)

status: ## État du lab
	kubectl get nodes
	kubectl get pods -n monitoring

urls: ## Adresses utiles
	@echo "Grafana    : http://localhost:3000   (admin / admin)"
	@echo "Prometheus : http://localhost:9090"
