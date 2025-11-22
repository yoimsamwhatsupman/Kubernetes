📁 Repositorystruktur

1️⃣  clusters/ – Miljöspecifika resurser

Varje miljö (dev, test, prod) har egna resurser:

clusters/
 ├─ <env>/
 │  ├─ apps/           # Miljöspecifika anpassningar för applikationer
 │  ├─ infra/          # Infrastrukturresurser (ingress, logging, monitoring, cert-manager)
 │  ├─ cluster-config/ # Namespaces, resource quotas etc.
 │  └─ kustomization.yaml

Syfte:

    Patcha applikationer per miljö (t.ex. replicas, image-tag, namespace)

    Hantera miljöspecifik infrastruktur och konfiguration

2️⃣  apps/ – Applikationer

Struktur per applikation:

apps/
 ├─ <app>/
 │  ├─ base/       # Grundläggande manifests eller Helm-values
 │  ├─ chart/      # Helm chart (Chart.yaml, templates, values)
 │  └─ overlays/   # Specifika variationer, t.ex. high-throughput eller read-only

Syfte:

    Återanvändbara applikationer

    Separera basdefinition från miljöspecifika patchar

3️⃣  platform/ – ArgoCD & plattformskonfiguration

platform/
 ├─ root-app.yaml                 # Root ArgoCD-applikation
 ├─ argocd/projects/              # ArgoCD-projekt (developers, ops, security)
 ├─ argocd/rbac/                  # RBAC-konfigurationer
 ├─ argocd/repo-credentials.yaml  # Repo credentials
 └─ README.md

Syfte:

    Hantera ArgoCD-synkronisering och accesskontroller

    Samordna alla miljöer och applikationer

4️⃣  infra/ – Delad infrastruktur

infra/
 ├─ networking/
 ├─ policies/
 ├─ observability/
 └─ storage/

Syfte:

    Infrastruktur som kan delas mellan alla miljöer

    Exempel: nätverkspolicies, monitoring, lagring

💡 Principer

    Separation: Applikation (apps/) vs miljöspecifik konfiguration (clusters/)

    Deployment: ArgoCD synkar clusters/<env>/kustomization.yaml mot respektive miljö

    Flexibilitet: Nya applikationer kan läggas till i apps/ och patchas per miljö

