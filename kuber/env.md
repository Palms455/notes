#Kubernetes #k8 #Deployment 
[[#Переменные окуржения в манифесте]]
[[#ConfigMap]]
[[#Обновление env в pod]]
[[#Secrets]]
[[#Применение только выбранных ключей]]
[[#Монтирование configMap, Secret в качестве файлов]]


### Переменные окуржения в манифесте 
Можно указать env параметры 
```yaml
---  
apiVersion: apps/v1  
kind: Deployment  
metadata:  
  name: my-deployment  
spec:  
  replicas: 1  
  selector:  
    matchLabels:  
      app: my-app  
  strategy:  
    rollingUpdate:  
      maxSurge: 1  
      maxUnavailable: 1  
    type: RollingUpdate  
  template:  
    metadata:  
      labels:  
        app: my-app  
    spec:  
      containers:  
      - image: quay.io/testing-farm/nginx:1.12  
        name: nginx  
        env:  
        - name: TEST  
          value: foo  
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
После применения манифеста в описании пода появляется запись
```bash
Environment:
      TEST:  foo

```
### ConfigMap
Использование отдельного файла для хранения конифгураций
```yaml
---  
apiVersion: v1  
kind: ConfigMap  
metadata:  
  name: my-configmap-env  
data:  
  dbhost: postgresql  
  DEBUG: "false"  
...
```
#### Применение configMap
Для использования env из configMap его необходимо применить
```bash
kubectl apply -f configmap.yaml
```
Просмотр всех configMap
```bash
kubectl get cm
```

### Вывод содержимого configMap из кластера
```

kubectl get cm my-configmap-env -o yaml 
```
Для использования configMap необходимо добавить в [[deployment]] манифест параметр в template.spec.conatiners указание для нужного контейнера использование cm

```yaml
envFrom:  
- configMapRef:  
    name: my-configmap-env
```

Если применить манифест с указанием cm до применения самого cm возникнет ошибка `CreateContainerConfigError`

Применение configMap не отобразит параметры env в команде `describe pod`
```bash
Environment Variables from:
      my-configmap-env  ConfigMap  Optional: false

```

Для просмотра env необходимо вызвать [[#Вывод содержимого configMap из кластера]] или выполнить команду [[pod#Зайти в pod | Зайти в консоль pod]] 

### Обновление env в pod
Если  env обновилось в манифесте или cm, то для обновления на непосредственно pod необходимо его пересоздать заново

### Secrets
 - generic - пароли/токены для приложении
 - docker-registry - данные для авторизации в docker registry
 - tls - TLS сертификаты для ingress

#### Создание secret
```bash
kubectl create secret generic test --from-literal=test1=asdf --from-literal=dbpassword=1q2w3e  --save-config
```
`--from-literal=test1=asdf` - добавление переменной `test1` со значением `asdf` 
`--save-config` - добавление аннотации для сохранения конфигов
или с применением файла
```yaml
---  
apiVersion: v1  
kind: Secret  
metadata:  
  name: test  
stringData:  
  test1: asdf
  dbpassword: 1q2w3e 
...
```

Команда для применения файла конфига
```bash
kubectl apply -f secrets.yml
```

Получение secret
```bash
kubectl get secret

kubectl get secret test -o yaml
```

! Secret не хранит информацию в зашифрованном виде. Только в закодированном

#### Применение  secret
```yaml
envFrom:  
- secretRef:  
    name: test
```

### Применение только выбранных ключей
для configMap и secret можно применять не целиком сущность, а только выбранные ключи.

```yaml
env:  
- name: TEST  
  value: foo  
- name: TEST_1  
  valueFrom:  
    secretKeyRef:  
      name: test  
      key: test1
```

Здесь произошло добавление env параметра TEST_1 со значением ключа test из secret test

### Монтирование configMap, Secret в качестве файлов

В качестве примера возьмем следующий configMap:
```yaml
---  
apiVersion: v1  
kind: ConfigMap  
metadata:  
  name: my-configmap  
data:  
  default.conf: |  
    server {  
        listen       80 default_server;  
        server_name  _;  
  
        default_type text/plain;  
  
        location / {  
            return 200 '$hostname\n';  
        }  
    }  
...
```
После его применения, добавим в манифест формирование файла из cm
```yaml
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
      volumeMounts:  
      - name: config  
        mountPath: /etc/nginx/conf.d/  
    volumes:  
    - name: config  
      configMap:  
        name: my-configmap
```
Таким образом внутри контейнера примонтируются файлы, сгенерированные из переменных cm и будут находится в каталоге /etc/nginx/conf.d/

После изменения и применении файла автоматически произойдет перемонтирование файлов без перезагрузки  pod. Однако надо иметь ввиду что приложения должны отслеживать изменившееся состояние файла.
На самом деле используется symlink. 

## Downward API
В некоторых случаях необходимо прокидывать в контейнер метаданные самого pod. Его namespace, ip-адрес, метки.

Метадату можно прокинуть в env в манифесте:
```yaml
env:  
- name: TEST  
  value: foo  
- name: TEST_1  
  valueFrom:  
    secretKeyRef:  
      name: test  
      key: test1  
- name: __NODE_NAME  
  valueFrom:  
    fieldRef:  
      fieldPath: spec.nodeName  
- name: __POD_NAME  
  valueFrom:  
    fieldRef:  
      fieldPath: metadata.name  
- name: __POD_NAMESPACE  
  valueFrom:  
    fieldRef:  
      fieldPath: metadata.namespace  
- name: __POD_IP  
  valueFrom:  
    fieldRef:  
      fieldPath: status.podIP  
- name: __NODE_IP  
  valueFrom:  
    fieldRef:  
      fieldPath: status.hostIP  
- name: __POD_SERVICE_ACCOUNT  
  valueFrom:  
    fieldRef:  
      fieldPath: spec.serviceAccountName
```
А можно в виде файлов
```yaml
  volumeMounts:  
  - name: config  
    mountPath: /etc/nginx/conf.d/  
  - name: podinfo  
    mountPath: /etc/podinfo  
volumes:  
- name: config  
  configMap:  
    name: my-configmap  
- name: podinfo  
  downwardAPI:  
    items:  
      - path: "labels"  
        fieldRef:  
          fieldPath: metadata.labels  
      - path: "annotations"  
        fieldRef:  
          fieldPath: metadata.annotations
```