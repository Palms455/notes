## Удаление модулей 
```
kubectl delete po name_pod

kebectl delete pod -llabel_name=lbel_value - удаление с помощью селекторов меток

kubectl deleet ns name_ns - удаление ns

kubectl delete po --all - удаление все модулей в текущем ns

kubectl delete all --all -удаление всех ресурсов. Эта команда удаляет не только поды но и service и replicas 
```
