#Kubernetes

### Плолучить список pod
```
kubectl get pod
```

### Ad hoc запуск pod
```
 kubectl create deployment some-app  --image=hexletcomponents/devops-example-app --port=5000
 
 kubectl run nginx --image=nginx:latest --port=80
```

Описание pod - модуля
```
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


### Создание SERVICE
```
kubectl expose deployment some-app --type=LoadBalancer --name=new-balancer --port=80 --target_port=5000 
```
данная команда создать loadbalancer и будет прослушивать 80 порт и перенаправлять к подам на 5000 порт

### локальный проброс
 minikube service new-balancer --url
 
### изменение масштабирования 

	kubectl scale deployment some-app --scale=3
	
команда установит кол-во подов данного deployment сервиса some-app в 3 штуки


##Deployment
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

#Метки
```
 kubectl get po --show-labels
 отображение меток
```

## Селектор меток
```
Отобразят те поды с меткой creation_method=manual
kubectl get po -l creation_method=manual

Отобразят те поды с наименованием метки env
kubectl get pod -l env

-L -отображение меток
-l -селектор меток

Отобразят те поды, которые не имеют ветку !env
kubectl get po -l !env

creation_method!=manual, чтобы выбрать модули с меткой creation_method с любым значением, кроме manual;

env in (prod,devel), чтобы выбрать модули с меткой env, установленной в prod или development;

env notin (prod,devel), чтобы выбрать модули с меткой env, установленной в любое значение, кроме prod или devel.
Возвращаясь к модулям в примере микросервисно-ориентированной архитектуры, все модули, входящие в состав микросервиса каталога продукции, можно выбрать с помощью селектора меток

```

### Метки можно добавлять к люому объекту К8

```
kubectl label node gke-kubia-85f6-node-0rrx gpu=tru
```



### Приписывание моулей к узлам

Хоть к8 сам располагает поды по нодам, с помощью селекторов меток можно повлиять выбор ноды для соответствующего пода. Например для контейнера, требующего вычислительных мощностей приписать к ноде н более мощном серваке.

Для этого приписываем к ноде определенную метку 
в манифесте описния пода указываем nodeSelector
```yaml
apiVersion: V1
kind: Pod
metadata:
	name: some-app
spec:
	nodeSelector:
		gpu: True
	containers:
		- image: image_name
		  name: some_app

```

## Аннотация модулей
Аннотации это такие же пары ключ значение как и метки, но они не для идентификации
По ним нельзя делать группировкую
Они предназначены для утилит.

### Добавление аннтоации
```
kubectl annotate pod  name_pod key="some value"
```

### Просмотр аннотации

```
kubectl describe pod pod_name
```


## Простанства имен Namespaces

NS позволяеют сгруппировать ресурсы на отдельные группы. Разные группы, разделенные по NS могут внтури использовать одни и те же имена.

Это бывает полезно для определения разных групп, например, prod. devel

NODE - ноды всегда являеются глобальным и не привязан ни к какому NS

### Вывести все NS

```
kubectl get ns
```

### Вывести все поды для NS

```
kubectl get po -n <NS>

kubectl get po --namespace=NS
```

### Создание NS

```
apiVersion: v1
kind: nameSpace
metadata:
  name: my-cutom-ns


kubectl create -f custom-ns.yaml
```


для создание подов в конкретном NS необходимо прописывать NS в metadata или командой

```
kubectl create -f yaml_manifest_pod -n namespace_name
```

### Пространства имен не обеспцивают изоляции между NS

## Удаление модулей 
```
kubectl delete po name_pod

kebectl delete pod -llabel_name=lbel_value - удаление с помощью селекторов меток

kubectl deleet ns name_ns - удаление ns

kubectl delete po --all - удаление все модулей в текущем ns

kubectl delete all --all -удаление всех ресурсов. Эта команда удаляет не только поды но и service и replicas 
```







 

 