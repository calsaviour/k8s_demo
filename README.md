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

## Delete K8S
```
./k8s_setup/setup_cluster1.sh -o cleanup
./k8s_setup/setup_cluster2.sh -o cleanup
```