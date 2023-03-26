#Kubernetes #k8 

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

