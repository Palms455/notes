#Kubernetes #k8 #Метки #annotations

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
