# Виртуалзация

##  Проверка на загруженность модулей KVM
    lsmod | grep kvm

## Автозагрузка  libvirtd
    systemctl start libvirtd
    systemctl enable libvirtd
    systemctl status libvirtd

## virsh - клиент libvirt

## Подключиться к VM QEMU по ssh
    virt-manager -c qemu+ssh://root@192.168.0.109/system

###  Вывести сети 
    virsh net-list --all
    
### Создание сети
    virsh net-define
### Вывести xml дамп сети
    virsh net-dumpxml default

```xml
<network>
  <name>network1</name>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <ip address='10.0.1.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.0.1.200' end='10.0.1.254'/>
    </dhcp>
  </ip>
</network>
```

Применить сетевые настройки
    virsh define ./example/network1.xml

Редактирование конфига
    virsh net-edit network1

Активация сети
    virsh net-start network1

Autostart
    vitsh net-autostart network1

### Создать внешний диск
```bash
sudo qemu-img create -f qcow2 /var/lib/libvirt/qemu/cent-os.qcow2 10G
```

### Работа с дисками virsh pool

#### Вывести список дисков
	virsh vol-list --pool pool1

### Вид конфигурации пула (в примере объявлени тип-директория)
```xml
<pool type="dir" >
    <name>pool1</name>
    <target>
        <path>/QEMU/pool1</path>
    </target>
</pool>
```

virsh pool-define example/pool1.xml
virsh pool-autostart pool1
virsh pool-start pool1

Теперь при создание виртуальных машин образы будут падать в pool1

### Установка VM `virt-install`


```bash
virt-install --name Cent --ram 1024 --disk path=/var/lib/libvirt/qemu/cent-os.qcow2 --vcpus 1 --os-variant centos7 --network=network:default --graphics vnc,port=5999 --console pty,target_type=serial --cdrom /home/rustam/Загрузки/CentOS-7-x86_64-Minimal-2207-02.iso
```
```


```bash
virt-install --name test-deb --memory 2048 --vcpus=2 --cpu host --cdrom /QEMU/images/debian-11.6.0-amd64-netinst.iso --disk pool=pool1,size=6,bus=virtio,sparse=true,cache=none,io=native --network=bridge:virbr0 --virt-type kvm --graphics=vnc
```

### Список вирт машин
```bash
virsh list --all
```
### Редактирование конфигурации вирт машины
```bash
virsh edit template1
```

###  Запуск вирт машины
    virsh start test-deb

### Остановка вирт машины 
    virsh destroy test-deb

### Удаление вирт машины 
    virsh undefine test-deb

### Посмотреть о диске инфу
    virsh vol-list pool1
    virsh vol-info --pool pool1 test-deb.qcow2

### Удаление внешнего диска
    virsh vol-delete --pool pool1 test-deb.qcow2


### [Виртуализация часть 2](https://www.youtube.com/watch?v=PjZLCLOZJeY&t=185s)

[Подключиться к VM QEMU по ssh]

### Отредактировать конфиг
	virsh edit test-deb
	
### Склонировать домен
	virt-clone --original test-deb --name new-deb --auto-clone
-- auto-clone - флаг, который перегенерирует конфликтующие идентификаторы

### Автозагрузка домена
	virsh autostart server2

### Установка домена
virsh net-edit network1
```
<domain name='some.we' localOnly='yes' />
```
Это необходимо для автогенерирования dnsmasq




