#Kubernetes #Deployment #k8

## Deployment
```
kubectl create deployment <name> --image <image>

```

Команды
```
kubectl get deployments -- список 

kubectl describe deployments <name> --описание
```

Scaling 
```
kubectl scale deployment <name deployment> --replicas=4
```

Вывод описания полей манифеста yaml
```
kubectl explain pod.metadata
```

Получение логов пода
```
 kubectl logs kubia-manual
 
 получение логов конкретного контейнера 
  kubectl logs kubia-manual -c kubi
```

