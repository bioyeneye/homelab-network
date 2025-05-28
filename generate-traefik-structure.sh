#!/bin/bash

# Base path for the structure
BASE_DIR=internal-traefik

# Create folder structure
mkdir -p $BASE_DIR/base
mkdir -p $BASE_DIR/base/traefik
mkdir -p $BASE_DIR/base/dashboard

# Create empty files for Traefik Helm release
touch $BASE_DIR/base/traefik/traefik-values.yaml
touch $BASE_DIR/base/traefik/kustomization.yaml

# Create empty files for Dashboard config (IngressRoute + Middleware)
touch $BASE_DIR/base/dashboard/ingressroute-dashboard.yaml
touch $BASE_DIR/base/dashboard/middleware-dashboard.yaml
touch $BASE_DIR/base/dashboard/kustomization.yaml

# Create top-level kustomization.yaml to reference subfolders
touch $BASE_DIR/base/kustomization.yaml

# Argo CD application manifests
mkdir -p $BASE_DIR/app
touch $BASE_DIR/app/traefik-install-app.yaml

echo "✅ Traefik folder structure and empty config files created successfully."
