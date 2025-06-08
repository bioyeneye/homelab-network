#!/bin/bash

set -e

BASE_DIR="internal-traefik/base"
mkdir -p $BASE_DIR/{helm,middleware,dashboard}

echo "[+] Creating Helm values.yaml..."
cat > $BASE_DIR/helm/values.yaml <<EOF
dashboard:
  enabled: true
  ingressRoute:
    dashboard:
      enabled: true

ingressClass:
  enabled: true
  name: internal-traefik
  isDefaultClass: false

service:
  type: LoadBalancer

ports:
  web:
    expose: true
    exposedPort: 80
  websecure:
    expose: false

logs:
  general:
    level: INFO
EOF

echo "[+] Creating helm/kustomization.yaml..."
cat > $BASE_DIR/helm/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

helmCharts:
  - name: traefik
    repo: https://helm.traefik.io/traefik
    version: 24.0.0
    releaseName: internal-traefik
    namespace: kube-system
    valuesFile: values.yaml
EOF

echo "[+] Creating middleware/auth-secret.yaml..."
cat > $BASE_DIR/middleware/auth-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: traefik-dashboard-auth
  namespace: kube-system
type: Opaque
data:
  users: YWRtaW46JDJ5JFc0R3RzaEZUYzF6SGxCeHc2MFgvWU81dmM0eVZ6Cg==  # admin:\$2y\$...
EOF

echo "[+] Creating middleware/auth-middleware.yaml..."
cat > $BASE_DIR/middleware/auth-middleware.yaml <<EOF
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: traefik-dashboard-auth
  namespace: kube-system
spec:
  basicAuth:
    secret: traefik-dashboard-auth
    realm: "Traefik Dashboard"
EOF

echo "[+] Creating middleware/kustomization.yaml..."
cat > $BASE_DIR/middleware/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - auth-secret.yaml
  - auth-middleware.yaml
EOF

echo "[+] Creating dashboard/ingressroute.yaml..."
cat > $BASE_DIR/dashboard/ingressroute.yaml <<EOF
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard
  namespace: kube-system
spec:
  entryPoints:
    - web
  routes:
    - match: Host(\`traefik.local\`) && (PathPrefix(\`/dashboard\`) || PathPrefix(\`/api\`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
      middlewares:
        - name: traefik-dashboard-auth
EOF

echo "[+] Creating dashboard/kustomization.yaml..."
cat > $BASE_DIR/dashboard/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ingressroute.yaml
EOF

echo "[+] Creating base/kustomization.yaml..."
cat > $BASE_DIR/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - helm
  - middleware
  - dashboard
EOF

echo "[✅] All files created under: internal-traefik/base"
