#Kubernetes/replicaSet #k8 #replicaSet

[[#Описание файла]]
[[#1. Создание Replicaset]]
[[#2. Scaling Replicaset]]
[[#3 Нюанс Обновления pod в replicaSet .]]
[[#4. Удаление replicaSet]]


# ReplicaSet  
ReplicaSet предоставляет абстракцию над [[pod]]


## Описание файла
```yaml
---  
apiVersion: apps/v1  
kind: ReplicaSet  
metadata:  
  name: my-replicaset  
spec:  
  replicas: 2
  selector:  
    matchLabels:  
      app: my-app  
  template:  
    metadata:  
      labels:  
        app: my-app  
    spec:  
      containers:  
      - image: quay.io/testing-farm/nginx:1.12  
        name: nginx  
        ports:  
        - containerPort: 80  
...

```
  
## 1. Создание Replicaset  
  
```bash  
kubectl apply -f replicaset.yaml
```  
  
## 2. Scaling Replicaset  
Изменение кол-ва подов
  
```bash  
kubectl scale replicaset my-replicaset --replicas 3
```  
   
### 3 Нюанс Обновления pod в replicaSet .
Допустим мы обновили версию Image  
  
Для этого выполним команду:  
  
```bash  
kubectl set image replicaset my-replicaset nginx=nginx:1.13
```  
  
И проверяем сам Replicaset, для чего выполним команду:  
  
```bash  
kubectl describe replicaset my-replicaset
```  
  
В результате находим строку Image и видим:  
  
```bash  
  Containers:   nginx:    Image:        nginx:1.13  
```  
  
Проверяем версию image в pod. Для этого выполним команду, подставив имя своего Pod  
  
```bash  
kubectl describe pod my-replicaset-55qdj
```  
  
Видим что версия имаджа в поде не изменилась:  
  
```bash  
  Containers:   nginx:    Image:        nginx:1.12  
```  
  
Помогаем поду обновиться - для этого выполним команду, подставив имя своего Pod  
  
```bash  
kubectl delete po my-replicaset-55qdj
```  
  
Проверяем результат, для этого выполним команду:  
  
```bash  
kubectl get pod
```  
  
Результат должен быть примерно следующим:  
  
```bash  
NAME                  READY     STATUS              RESTARTS   AGEmy-replicaset-55qdj   0/1       Terminating         0          11mmy-replicaset-cwjlf   0/1       ContainerCreating   0          1smy-replicaset-pbtdm   1/1       Running             0          16mmy-replicaset-szqgz   1/1       Running             0          14m
```  
  
Проверяем версию Image в новом Pod. Для этого выполним команду,  
подставив имя своего Pod  
  
```bash  
kubectl describe pod my-replicaset-cwjlf
```  
  
Результат должен быть примерно следующим:  
  
```bash  
    Image:          nginx:1.13  
```  
  
### 4. Удаление replicaSet 
  
Для этого выполним команду:  
  
```bash  
kubectl delete replicaset --all
```