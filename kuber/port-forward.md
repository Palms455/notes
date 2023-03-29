#Kubernetes #k8 #Pod 

Для проброса из pod в локальную сеть команда:
```bash
kubectl port-forward my-deployment-5b47d48b58-l4t67 8080:80
```
где: 
`8080` - local port
`80` - pod port