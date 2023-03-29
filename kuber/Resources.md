#Kubernetes #k8 #Deployment 

### Limits
- Количество ресурсов, которые [[pod]] может использовать
- Верхняя граница ресурсов

### Requests
- Количество ресурсов, которые резервируются на [[pod]]
- Не делятся с другими [[pod]]
- Не имеуют никакого отношения, сколько реально использует  pod. Это влияет только на резервирование

### Пример конфига с резерированием ресурсов
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
            cpu: 10m         # 0.01 CPU
            memory: 100Mi    # 100 
          limits:  
            cpu: 100m  
            memory: 100Mi  
...

```

В описании пода появится параметр `QoS Class: Burstable` - указывается тип лимитов
Бывают:
 - Best effort - не указываются лимиты и реквесты. Используются все ресурсы. При эвакуации с ноды будут удалены в первую очередь
 - Burstable - когда указаны реквесты но не указан лимиты. Или если реквесты меньше запрашиваемых лимитов. Удаляются с ноды во вторую очередь
 - Guaranteed - когда limits == requests. Удаляются с ноды в последнюю очередь

