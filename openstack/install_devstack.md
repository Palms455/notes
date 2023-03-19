

#### Для включения влож виртуализации
```bash
VBoxManage modifyvm "название виртуальной системы" --nested-hw-virt on
```
#### Установка
после создания виртуалки перезапуск с клавишей shift, выибраем recovery
```bash
mount –o rw,remount /
passwd
```

- устанавливаем пароль
- перезапуск

#### Через Gparted Live CD грузимся и расширяем диск

	Посмотреть сколько места `df -h`

#### Настройка
1. настраиваем dhcp
```bash
nano /etc/netplan/dhcp.yaml
```

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
```

2. Применить настройки сети:
``` bash
netplan apply  
```


3. проверка сети  `ping 8.8.8.8`

4. настриваем sshd_config
```bash
nano /etc/ssh/sshd_config

PermitRootLogin yes
PasswordAuthetication yes
```


5. Генерируем host ключи для sshd:
```bash
ssh-keygen -A  
```

 
6. Запуск sshd: 
```bash
service sshd start
```

7. Посмотреть ip-address `ip a`

#### Установка devstack
1. Заходим по ssh
2. Установка devstack:
```bash
apt-get update && apt-get upgrade -y

#sudo apt-get install git  (если git не установлен) 

```


3. Проверяем аппаратную виртуализацию:
```bash
cat /sys/module/kvm_intel/parameters/nested
(выводит Y)
```

4. Создаем пользователя stack:

```bash 
useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
su - stack
```

5. Клонируем репозиторий:

```bash
git clone https://opendev.org/openstack/devstack
cd devstack
```

6. Создаем файл конфигурации: 
```bash
nano local.conf
```

```conf
[[local|localrc]]
ADMIN_PASSWORD=secret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
HOST_IP=192.168.0.109  (ip машины devstack) -по команде ip a
```


7. Удаляем пакеты, которые будут мешать:

```bash
sudo apt-get --purge remove python3-simplejson python3-pyasn1-modules -y
```

8. Запускаем установку:

```bash
./stack.sh
```

9. Далее openstack доступен по адресу:

https://xxx.xxx.xxx.xxx/dashboard  admin или demo


10. Делаем инстанс доступным из компьютера локальной сети. Создаем маршрут на машине или роутере

```bash
route add 172.24.4.0 mask 255.255.255.0 x.x.x.x (devstack ip)
```


Если не заработало, то на машине devstack включаем ip forward:

```bash
sudo bash
echo 1 (угловая скобка) /proc/sys/net/ipv4/ip_forward
```

или для сохранения после перезагрузки:

```bash
nano /etc/sysctl.conf

правим net.ipv4.ip_forward = 1

или

sysctl -w net.ipv4.ip_forward=1
```


11. Для решения проблемы выхода в интернет с инстансов. 
- Создаем правило iptables на машине devstack:
	
	 ```bash
	 iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
	```


12. Стандартный пароль для Cirros образа: gocubsgo
