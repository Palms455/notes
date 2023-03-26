#Kubernetes #k8 
## Простанства имен Namespaces

NS позволяеют сгруппировать ресурсы на отдельные группы. Разные группы, разделенные по NS могут внтури использовать одни и те же имена.

Это бывает полезно для определения разных групп, например, prod. devel

*NODE* - ноды всегда являеются глобальным и не привязан ни к какому NS

Пример конфигурации
```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: my-cutom-ns
...
```

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


Для создания подов в конкретном NS необходимо прописывать NS в metadata или командой

```
kubectl create -f yaml_manifest_pod -n namespace_name
```

!!! Пространства имен не обеспцивают изоляции между NS