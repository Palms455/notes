#Kubernetes #Pod

[[#Получить список pod]]
[[#Ad hoc запуск pod]]
[[#Выполнить команду внтури pod]]
[[#Выполнить команду внтури pod]]
[[#Проброс из pod к внешнему порту]]
[[#Создание pod через файл]]


### Получить список pod
```cli
kubectl get pod
```

### Ad hoc запуск pod
```cli
 kubectl create deployment some-app  --image=hexletcomponents/devops-example-app --port=5000
 
 kubectl run nginx --image=nginx:latest --port=80
```

Описание pod - модуля
```cli
kubectl <podname> describe

```

pod - минимально возможная единица kuber. На ней крутится контейнер с приложением. 

### Выполнить команду внтури pod
```
kubectl exec [POD] -- [COMMAND]
```

Pod крутится на Node(узел). В одном узле может быть несколько pod
Доступ к pod через службу service

### Проброс из pod к внешнему порту
```
kubectl port-forward hello 80:80

справа порт пода
``` 

### Создание pod через файл
```
пример example.yaml
apiVersion: v1
kind: Pod
metadata:
    name: some-web
spec:
  containers:
    - name: container-nginx
      image: nginx-latest
      ports:
        - containerPort: 80
	  
Вызов команды:

	kubectl apply -f example.yaml
Удаление:
	kubectl delete -f example.yaml

```


