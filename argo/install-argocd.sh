#!/bin/bash
# abort early if any script fails
set -e

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl port-forward svc/argocd-server -n argocd 8001:443 &

export ARGOCD_SERVER=localhost:8001
echo "export ARGOCD_SERVER=https://localhost:8001"

export TEMP_PASSWORD=`argocd admin initial-password -n argocd | head -n 1`

argocd login localhost:8001 --insecure --username admin --password ${TEMP_PASSWORD}

# Generate a url safe password.
password() {
  local length=${1:-"20"}
  cat /dev/urandom | tr -dc A-Za-z0-9~_- | head -c $length && echo
}

export ARGO_PASSWORD=$(password)
echo "export ARGO_PASSWORD=$(password)"

argocd account update-password --current-password ${TEMP_PASSWORD} --new-password ${ARGO_PASSWORD}

kubectl config set-context --current --namespace=argocd

# # TODO: this is just a sample app for testing. remove when testing completed.
# argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
# argocd app get guestbook
# argocd app sync guestbook


# kubectl port-forward deployment.apps/nginx-deployment 8002:8080

