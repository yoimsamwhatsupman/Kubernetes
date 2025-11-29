#!/bin/bash
# ============================================
# GitOps Bootstrap Script med .gitkeep
# Skapar mappstruktur och filer för:
# - environment-entrypoints
# - environments (dev/test/prod)
# - applications (hello-api, frontend-web)
# - infrastructure (argocd bootstrap)
# ============================================

set -e

# 1️⃣ Skapa mappstruktur
mkdir -p environment-entrypoints
mkdir -p environments/dev/applications
mkdir -p environments/test/applications
mkdir -p environments/prod/applications
mkdir -p applications/hello-api/base/templates
mkdir -p applications/frontend-web/base/templates
mkdir -p infrastructure/argocd
mkdir -p infrastructure/cert-manager
mkdir -p infrastructure/ingress-controller
mkdir -p infrastructure/sealed-secrets
mkdir -p .github/workflows

# 2️⃣ Lägg till .gitkeep i tomma mappar
find environments infrastructure -type d -empty -exec touch {}/.gitkeep \;

# 3️⃣ Skapa minimal Chart.yaml och deployment/service.yaml för hello-api
cat <<EOF > applications/hello-api/base/Chart.yaml
apiVersion: v2
name: hello-api
version: 0.1.0
EOF

cat <<EOF > applications/hello-api/base/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-api
spec:
  selector:
    matchLabels:
      app: hello-api
  template:
    metadata:
      labels:
        app: hello-api
    spec:
      containers:
        - name: hello-api
          image: ghcr.io/example/hello-api:stable
          ports:
            - containerPort: 8080
EOF

cat <<EOF > applications/hello-api/base/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-api
spec:
  ports:
    - port: 8080
  selector:
    app: hello-api
EOF

# 4️⃣ Skapa helmfile och values för hello-api
cat <<EOF > applications/hello-api/helmfile.yaml.gotmpl
releases:
  - name: hello-api
    chart: ./base
    namespace: default
    values:
      - values-base.yaml.gotmpl
EOF

cat <<EOF > applications/hello-api/values-base.yaml.gotmpl
replicaCount: 1
EOF

# 5️⃣ Kopiera samma för frontend-web
cat <<EOF > applications/frontend-web/base/Chart.yaml
apiVersion: v2
name: frontend-web
version: 0.1.0
EOF

cat <<EOF > applications/frontend-web/base/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-web
spec:
  selector:
    matchLabels:
      app: frontend-web
  template:
    metadata:
      labels:
        app: frontend-web
    spec:
      containers:
        - name: frontend-web
          image: ghcr.io/example/frontend-web:stable
          ports:
            - containerPort: 80
EOF

cat <<EOF > applications/frontend-web/base/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-web
spec:
  ports:
    - port: 80
  selector:
    app: frontend-web
EOF

cat <<EOF > applications/frontend-web/helmfile.yaml.gotmpl
releases:
  - name: frontend-web
    chart: ./base
    namespace: default
    values:
      - values-base.yaml.gotmpl
EOF

cat <<EOF > applications/frontend-web/values-base.yaml.gotmpl
replicaCount: 1
EOF

# 6️⃣ Skapa infrastruktur bootstrap fil
cat <<EOF > infrastructure/argocd/install.yaml
# ArgoCD standardinstall manifest (fyll på med https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)
EOF

# 7️⃣ Skapa environment-entrypoints
cat <<EOF > environment-entrypoints/infrastructure-root.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: infrastructure-root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<your-org>/gitops-platform.git
    targetRevision: main
    path: infrastructure
  destination:
    server: https://kubernetes.default.svc
    namespace: kube-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

for env in dev test prod; do
  cat <<EOF > environment-entrypoints/$env.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${env}-root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<your-org>/gitops-platform.git
    targetRevision: main
    path: environments/$env
  destination:
    server: https://kubernetes.default.svc
    namespace: $env
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

done

echo "Bootstrap repo-struktur skapad med .gitkeep i tomma mappar!"

