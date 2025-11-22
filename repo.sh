#!/bin/bash
set -e

# --- Skapa cluster-struktur ---
for env in dev test prod; do
  for app in myservice otherservice; do
    mkdir -p clusters/$env/apps/$app
    touch clusters/$env/apps/$app/kustomization.yaml
    touch clusters/$env/apps/$app/helmfile.yaml
    touch clusters/$env/apps/$app/values-$env.yaml
  done
  mkdir -p clusters/$env/infra
done

# --- Skapa apps med chart, base och overlays ---
for app in myservice otherservice; do
  mkdir -p apps/$app/chart
  mkdir -p apps/$app/base
  mkdir -p apps/$app/overlays
done

# --- Skapa gemensamma kataloger ---
mkdir -p platform
mkdir -p infra

echo "Strukturen skapad!"
