## Создание процесса непрерывной поставки для приложения с применением Практик CI/CD и быстрой обратной связью

### Выполнено:

## 1. Создан makefile для сборки образов
cd ./docker
make

## 2. Создан docker-compose.yml для сборки приложения
docker git:(main) docker-compose up -d

## 3. Деплой приложения в k8s
cd terraform-k8s/  
terraform init
terraform apply --auto-approve

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --version v1.8.0 \
  --set prometheus.enabled=false \
  --set webhook.timeoutSeconds=4

kubectl --namespace default get services -o wide -w ingress-nginx-controller

## 4. Настройка CI/CD

cd gitlab-ci/terraform
terraform apply --auto-approve

helm repo add gitlab https://charts.gitlab.io
helm install --namespace default gitlab-runner -f values.yaml gitlab/gitlab-runner

## 5. Мониторинг

### Установка 
cd k8s/monitoring/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack -f values.yml
