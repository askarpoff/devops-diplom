#!/bin/bash
cd terraform
terraform apply --auto-approve
cd ..


yc managed-kubernetes cluster get-credentials diplomregionalcluster --external --force
#yc container registry get diplom-registry

# create namespace and CRDs
kubectl create -f kube-prometheus/manifests/setup

# wait for CRD creation to complete
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done

# create monitoring components
kubectl create -f kube-prometheus/manifests/

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo add gitlab https://charts.gitlab.io && \
helm repo update && \

kubectl create namespace gitlab

helm install --namespace gitlab gitlab-runner gitlab/gitlab-runner \
  --set rbac.create=true \
  --set gitlabUrl=https://git.askarpoff.site/ \
  --set ${runnertoken} \
  -f ./gitlab/config.toml



#kubectl get all -n monitoring

kubectl create namespace stage
kubectl create secret docker-registry regcred --docker-username=askarpoff --docker-password={$dockertoken} --docker-email=askarpoff@gmail.com -n stage

helm install --namespace stage ingress-nginx ingress-nginx/ingress-nginx


sleep 30


kubectl apply -f ./app/ingress.yaml
kubectl apply -f ./app/simpleapp.yaml


kubectl get all --all-namespaces



yc managed-kubernetes cluster get "diplomregionalcluster" --format=json    | jq -r .master.endpoints.external_v4_endpoint
echo
kubectl apply -f ./gitlab/sa.yaml
kubectl -n kube-system get secrets -o json | jq -r '.items[0] | select(.metadata.name | startswith("admin-user-token")) | .data.token' | base64 --decode
echo

