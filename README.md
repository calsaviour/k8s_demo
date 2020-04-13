## Setup K8S
- Create two Kubernetes clusters using EC2 on AWS
- Cluster 1: 1 master, 3 worker nodes
- Cluster 2: 3 master, 1 worker node

```
./k8s_setup/setup_cluster1.sh -o install
./k8s_setup/setup_cluster2.sh -o install
```

## Create a simple application with a frontend that interacts with Redis in the backend. The application should have a simple index page that displays.
```
Refer to app/server.js
```

## Containerize  the frontend and backend.
```
cd app/
docker build -t <DOCKER_REPO>/simple-node:v2 .
docker push <DOCKER_REPO>/simple-node:v2
```


## Deploy the frontend in cluster 1 in namespace “frontend”
```
kubectl config use-context devpoc.calsaviour.one.k8s.local
kubectl apply -f app/backend_namespace.yml
kubectl apply -f app/frontend_namespace.yml
kubectl apply -f app/backend.yml
kubectl apply -f app/frontend.yml
```


## (Was not able to figure out the inter communication and connecting with different namespace)


## Optional (Kubernetes Dashboard)
```
kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f cluster-role-binding.yaml
kubectl apply -f recommended.yaml

tmux new -s <SESSION_NAME>
kubectl proxy

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')\n


http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/



```

## Delete K8S
```
./k8s_setup/setup_cluster1.sh -o cleanup
./k8s_setup/setup_cluster2.sh -o cleanup
```