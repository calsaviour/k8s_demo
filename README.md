## Build docker image and push to docker hub
```
docker build -t calsaviour/simple-node:v1 .
docker push calsaviour/simple-node:v1
```

## Setup K8S
```
./k8s_setup/setup_cluster1.sh -o install
./k8s_setup/setup_cluster2.sh -o install
```

## App setup
```
kubectl create -f app/backend.yml 
kubectl create -f app/frontend.yml 
```

## Optional (Kubernetes Dashboard)
```
kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f cluster-role-binding.yaml
kubectl apply -f recommended.yaml

tmux new -s calvin
kubectl proxy

Detach from tmux

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')\n


http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/



```

## Delete K8S
```
./k8s_setup/setup_cluster1.sh -o cleanup
./k8s_setup/setup_cluster2.sh -o cleanup
```