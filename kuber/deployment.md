#Kubernetes #Deployment #k8

[[#Пример конфиг файла]]
[[#Создание]]
[[#Scaling]]
[[#Обновить версию image]]
[[#Редактирование файла Deployment в kubernetes]]



### Пример конфиг файла
```yaml
---  
apiVersion: apps/v1  
kind: Deployment  
metadata:  
  name: my-deployment  
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

## Deployment
```
kubectl create deployment <name> --image <image>

kubectl apply  -f file

```

#### Создание
```
kubectl get deployments -- список 

kubectl describe deployments <name> --описание
```

#### Scaling 
```
kubectl scale deployment <name deployment> --replicas=4
```

Вывод описания полей манифеста yaml
```
kubectl explain pod.metadata
```


#### Обновить версию image  
  
Обновляем версию image для container в deployment my-deployment.  
Для этого выполним команду:  
  
```bash  
kubectl set image deployment my-deployment nginx=nginx:1.13

```
После выполенения данной команды deployment поднимет контейнеры с новой версией и выключит со старой


#### Редактирование файла Deployment в kubernetes
```bash
kubectl edit deployment my-deployment
```

Производит редактирование файла непосредственно в k8s. Удобно для дебаггинга

```bash
kubectl patch deployment my-deployment --patch '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"requests":{"cpu":"10"},"limits":{"cpu":"10"}}}]}}}}'
```
Редактирование через patch. Принимает на вход json

### Ресурсы 
```yaml
---  
apiVersion: apps/v1  
kind: Deployment  
metadata:  
  name: my-deployment  
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
        resources:  
          requests:  
            cpu: 10m  
            memory: 100Mi  
          limits:  
            cpu: 100m  
            memory: 100Mi  
...
```
Ресурсы прописываются в spec/containers/resources

### Strategy
При обновлении/переприменении нового конфига в k8s существуют стратегии выкатки pod
```bash
kubectl explain deployment.spec.strategy
```
2 статегии
	Recreate - удалить все старые поды и накатить новой
	RollingUpdate - накатывать новые и удалять старые, обеспечивая постепенную замену
	
```bash
	kubectl explain deployment.spec.strategy.rollingUpdate
```
эта команда покажет опциональные поля
*maxSurge* - в % показывает % подов которые можно поднять перед тем как удалить старые
*maxUnavailable* - в % показывает кол-во подов, которые можно загасить перед созданием новых

```bash
---  
apiVersion: apps/v1  
kind: Deployment  
metadata:  
  name: my-deployment  
spec:  
  replicas: 1
  strategy:
      rollingUpdate:
        maxSurge: 10
        maxUnavailable 0	    
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