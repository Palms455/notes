# Основные команды
	- ansible
	
	
# Инвентарь
	- указываются адреса доманы
	- типы файлов .ini .yml
Команда с использованием файла инвентаря:
	- ansible all -i inventory.ini -a 'uptime'
	где all указывает - что команда для всех серверов в файле инвентаря

```
[webservers] - группы серверов
www.some.ru
192.168.2.1
www[01:45].some.ru - можно указывать скобки

[dbservers]
17.4.5.6

[db]
mydb.com env=production replicas=2  -использование переменных

coolhost ansible_port=2222 ansible_host=192.168.2.1 -- алиасы для порта и адреса

192.168.2.1 ansible_user=palms - указание пользователя

localhost ansible_connection=local -- команда выполняется на хостовой машине

[servers:children] -- объединение в одну группу подгруппы
dbservers
webservers 
```

###При задании алиаса к машине

```
# Выбираем удобное имя 
jumper ansible_host=123.25.26.35 ansible_port=5555

...
  hosts:
    jumper:
      ansible_port: 5555
      ansible_host: 192.0.2.50
```

Такое имя можно использовать в командах Ansible. Это позволит, например, с помощью специального флага --limit выполнять запросы на конкретном сервере:

```
ansible all --limit jumper -i inventory.ini -m ping
```

Переменные
```
[atlanta]
host1
host2

[atlanta:vars]
ntp_server=ntp.atlanta.example.com
proxy=proxy.atlanta.example.com

atlanta:
  hosts:
    host1:
    host2:
  vars:
    ntp_server: ntp.atlanta.example.com
    proxy: proxy.atlanta.example.com

```

###ример конфигурации yaml файла

```
all:
  hosts:
    mail.example.com:
  children:
    webservers:
      hosts:
        foo.example.com:
        bar.example.com:
    dbservers:
      hosts:
        one.example.com:
        two.example.com:
        three.example.com:
    east:
      hosts:
        foo.example.com:
        one.example.com:
        two.example.com:
    west:
      hosts:
        bar.example.com:
        three.example.com:
    prod:
      children:
        east:
    test:
      children:
        west:

[webservers]
www[01:50:2].example.com

webservers:
    hosts:
      www[01:50:2].example.com:
	  

[atlanta]
host1 http_port=80 maxRequestsPerChild=808
host2 http_port=303 maxRequestsPerChild=909

atlanta:
  hosts:
    host1:
      http_port: 80
      maxRequestsPerChild: 808
    host2:
      http_port: 303
      maxRequestsPerChild: 909

```
### Использование нескольких файлов iventory

```
ansible-playbook get_logs.yml -i staging -i production
```

##Модули
	-https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html
	
	
## Плейбуки

```

# На какой группе серверов
- hosts: webservers

  tasks:
    - name: install redis server
      # apt-get update && apt-get install redis-server
      ansible.builtin.apt: # имя модуля Ansible
        name: redis-server
        state: present
        update_cache: yes

    - name: remove redis server
      # apt-get remove redis-server
      ansible.builtin.apt:
        name: redis-server
        state: absent
```

В этом плейбуке на группе хостов webservers выполняются две задачи (таски). Первая — это установка redis-server, и вторая — его удаление. Структура любой задачи такая:

имя задачи — необязательный параметр, в котором описывается задача. Нужна только для вывода во время выполнения плейбука.
модуль и его параметры – определяет команду, которая будет выполнена на указанной группе серверов. В примере выше это модуль apt, который запускает пакетный менеджер apt входящий в стандартную поставку Ubuntu. С его помощью устанавливаются и удаляются программы.

Имя модуля в задачах задается с префиксом ansible.builtin. Ansible позволяет создавать свои модули у которых имена могут совпадать со встроенными модулями. Поэтому разработчики ввели пространства имен, позволяющие избежать неоднозначностей (какой модуль имелся ввиду?).
	
### Запуск плейбуков

```
# В отличие от ad-hoc режима, группа хостов указывается внутри плейбука
ansible-playbook playbook.yml -i inventory.ini
```

### Команды с правами админа
Необходимо прописывать в таски параметр become: yes  - sudo

```
- hosts: webservers

  tasks:
    - name: install redis server
      ansible.builtin.apt:
        name: redis-server
        state: present
        update_cache: yes
      become: yes # <---

    - name: remove redis server
      ansible.builtin.apt:
        name: redis-server
        state: absent
      become: yes # <---

```

По умолчанию become использует sudo и переключает в root, поэтому у вашего пользователя должны быть необходимые права. Если понадобится другой пользователь, то его можно указать в параметре become_user. Естественно необходимо чтобы у вашего пользователя было sudo.

Если нужно передать пароль - то лучше прописать флаг -K в команду 
```
ansible-playbook playbook.yml -i inventory.ini -K --спросит пароль
```

## Теги
В примере две задачи, которые отвечают за работу с докером. Одна из них копирует файл конфигурации, вторая перезапускает докер. Мы их пометили тегом nginx, указав ключ и значение. При этом в любой задаче можно указать несколько тегов. Например, вот так tags: [nginx, config]:
```
- hosts: webservers
  tasks:
    - name: install nginx
      ansible.builtin.apt:
        name: nginx
        state: latest
      become: yes
      tags: nginx

    - name: install redis server
      ansible.builtin.apt:
        name: redis-server
        state: present
        update_cache: yes
      become: yes

    - name: update cron
      ansible.builtin.cron:
        name: "check dirs"
        minute: "0"
        hour: "5,2"
        job: "ls -alh > /dev/null"

    - name: update nginx config
      ansible.builtin.copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
      become: yes
      tags: [nginx, config]

    - name: restart nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded
      become: yes
      tags: nginx

```
Нужные задачи запускаются с помощью опции -t, которой передаётся название тега. Если мы ошибёмся и укажем несуществующий тег, то Ansible выдаст подсказку со списком тегов, которые можно использовать:
```
ansible-playbook --check playbook.yml -i inventory.ini -t nginx
```
Обратите внимание, что используется параметр --check. Так мы проверяем возможность изменений, не выполняя непосредственно сами задачи. После ввода команды мы увидим, что выполнились только три задачи с тегом nginx
```
TASK [install nginx] ****************************************
ok: [ec2-18-216-178-214.us-east-2.compute.amazonaws.com]

TASK [update nginx config] **********************************
ok: [ec2-18-216-178-214.us-east-2.compute.amazonaws.com]

TASK [restart nginx] ****************************************
changed: [ec2-18-216-178-214.us-east-2.compute.amazonaws.com]
```

## Переменные
Существует несколько способов задать переменные.
Шаблонизатор Jinja2 подставляет переменные вида {{ vars }} 

### Переменные в playbooks

1\. В общем блоке

```
- hosts: webservers
  vars:
    root_dir: /var/tmp/www
  tasks:
    - name: update nginix config
      ansible.builtin.template:
        src: templates/nginix.conf.j2
        dest: "{{root_dir}}/nginx.conf"

    - name: update index.html
      ansible.builtin.copy:
        src: files/index.html
        dest: "{{root_dir}}/index.html"
```

2\. На уровне task 

```
- hosts: webservers
  tasks:
    - name: update nginix config
      vars:
		root_dir: /var/tmp/www
      ansible.builtin.template:
        src: templates/nginix.conf.j2
        dest: "{{root_dir}}/nginx.conf"

```
2\. В отдельном файле для переменных
Создадим файл для переменных .yml

```
user: some_user
```
В плейбуке подключаем файл через параметр vars_files

```
- name: user
  hosts: all
  vars_files:
    - ./my_vars.ml
  tasks:
    name: Create user
	user:
	  name {{ user }}
	  state: present
	become: yes
```
3\. Использование зарезервированной структуры папок/файллов
На уровне плейбука можно созать папку group_vars, затем дочернюю папку с наименованием группы для которой применяется переменная.
Далее в этой папке создается файл с vars.yml, где прописываются переменные для данной группы

```
|
|-playbook.yml
|
|-group_vars
	|
	|
	|-webservers -название файла как группы или all для всех групп хостов
		|
		|-vars.yml
	
```
4\. Задание переменной для конкретного хоста

```
|
|-playbook.yml
|
|-host_vars
	|
	|
	|-namehost.yml - имя хоста[ip адрес] для которой действуют данные переменные
```
5.\ Задание переменных в инвентаре

```
[webservers]
192.168.1.2 user=someuser some_vars=12345

```

Можно выделить переменные в отдельный файл инвентаря
файл inventory можно разбить на несколко файлов, сгруппировав их по папкам.
Таким образом в команде можно указывать только саму папку вмесо файла инвентаря. Все переменные автоматически смержаться
```
|
|-inventory_folder
	|
	|-vars.ini
	|
	|-hosts.ini
	|
	|-other_hosts.yaml


ansible -i inventory_folder -m Ping
```

6.\ Использование --extra-vars "name_vars=value"

```
ansible -i inventory.ini --extra-vars "name_vars=value"
```

### Порядок переменных

	- command line							 -u  аргументы в ком строке	
	- role defaults
	- inventory file or script group vars
	- inventory group_vars/all
	- playbook group_vars/all
	- inventory group_vars/*
	- playbook group_vars/*
	- inventory file or script host vars
	- inventory host_vars/*
	- host facts/ cached set facts/
	- play vars
	- play vars_promt
	- play vars_files
	- role vars
	- task vars
	- include vars
	- set facts
	- role
	- include params
	- extra vars

7.\ Comand promt переменные 
При вызове команды ansible попросить ввести значение указвапемой преемнной

```
playbook.yml

- name: user
  hosts: all
  vars_promt:
	- name: user
	  promt: "Введите пользователя"
	  private: no
  tasks:
    - name: Some name
	  user:
		name: "{{ user }}"
		state: present
	  become: yes


```

## Отладка

1.\ Для отладки плейбуков можно перехватывать и выводить output tsks

```
playbook.yml

---
- name: Some playbook
  hosts: all
  tasks:
    - name: Add new user
      vars:
        username: "Palms"
      user:
        name: "{{ username }}"
        state: present
      become: yes
	  # регистрируем переменную
      register: debug_var -
    - debug:
		# использование переменной в debug
        var: debug_var
	 
```

Вывод debug:

```
TASK [debug] ***********************************************************************************************************
ok: [34.88.11.35] => {
    "debug_var": {
        "changed": true,
        "comment": "",
        "create_home": true,
        "failed": false,
        "group": 1004,
        "home": "/home/Palms",
        "name": "Palms",
        "shell": "/bin/sh",
        "state": "present",
        "system": false,
        "uid": 1003
    }
}
```

2.\ Использование debugger
Включет в себя несколько режимов

	- always - всегда отображает информацию для отладки
	- never - никогда не включается
	- on_failed - при ошибке в task
	- on_unreachable - при невозможности подключиться
	- on_skipped - при прерывании task
	
```
---
- name: Some playbook
  hosts: all
  tasks:
    - name: Add new user
      vars:
        username: "Palms"
      user:
        name: "{{ username }}"
        state: present
      become: yes
      register: debug_var
      debugger: always
```

При входе в debug режим можно вводить команды:

```
	p  переменные
	p task.name - отобразит наименование таски
	p task args - аргументы
	
	Посмотреть какие перемнные мы подставили:
	p tasks.vars
	
	посмотреть вообще все пременные:
	выведет массив словарей с переменными
	p tasks_vars
	
```
Можем поменять текущие переменные:

```
	task.args["name"] = "New_name"
```
Перезапустить task в режиме debugger: r


## Блоки
Блоки позволяют группирвоать таски в один блок и выполнять в рамках этого блока
```
---
- name: Some playbook
  hosts: all
  any_error_fatal: True - необязательный флаг, который фаталит таски при люой ошибке
  tasks:
    - name: Preconfig block
      block:
        - name: Add new user
          vars:
            username: "Palms"
          user:
            name: "{{ username }}"
            state: present
          register: error
		  ignore_errors: yes - игнорирование ошибки (не сваливается в блок rescue)
        - name: Install curl
          apt:
            name: curl
            update_cache: yes
          register: error
      become: yes
      rescue:
        - name: Some err
          debug:
            var: error
      always:
        - name: Reboot
          debug:
            msg: "Reboot now!"
```
Команда failed_when используется, когда нужно пометить таск как заваленный при выполнении какого лбо условия
Пример:

```
-hame: plabook
 hosts: all
 tasks:
	- name: some block
	  block:
		- name failded task
		  command: echo "fail"
		  register: command_result - переменая куда записывается оутпут
		  failed_when: "'fail' in command_result.stdout"
	  rescue:
        - name: Some err
          debug:
            var: error
      always:
        - name: Reboot
          debug:
            msg: "Reboot now!"
		  

```
### Условия в блоках
Позволяет понять когда блок должен быть выполнен

```
---
- name: Some playbook
  hosts: all
  tasks:
    - name: Preconfig block
      block:
        - name: Add new user
          vars:
            username: "Palms"
          user:
            name: "{{ username }}"
            state: present
          register: error
        - name: Install curl
          apt:
            name: curl
            update_cache: yes
          register: error
      become: yes
	  # Условие
      when: ansible_facts['distribution'] == 'Ubuntu' 
      rescue:
        - name: Some err
          debug:
            var: error
      always:
        - name: Reboot
          debug:
            msg: "Reboot now!"

```
## Асинхронные таски

```
- hosts: webservers
  tasks:
    - name: install nginx
      block:
        - name: install nginx
          ansible.builtin.apt:
            name: nginx
            state: latest
          async: 1000 -- указываем время, в течение которого может выполняться таска
          poll: 5	-- указывается промежуток времени через которое опрашивается статус выполнения задачи
```

Если poll: 0 то это значит что мы не будем опрашивать статус таски, а сразу приступаем к другой таске. Первая таска будет выполняться асинхронно.
Для паралелльного выполнения задачи используется async_status. 
Для этого нужно узнать job id  первой асинхронной таски. нужно указать в первой таске register: variable
Тогда таски примут вид:
```
	- hosts: webservers
  tasks:
    - name: install nginx
      block:
        - name: install nginx
          ansible.builtin.apt:
            name: nginx
            state: latest
          async: 1000
          poll: 5
          register: result # для того чтобы забрать job_id
        - name: Check sleep
          async_status: 
            jid: "{{ result.ansible_job_id }}" 
          register: job_result
          until: job_result.finished 
		  retries: 100
		  delay: 1
		  become: True
		  # если не нужно знать о завершении таски, то не нужно описывать блок async/register/until - просто указываем poll: 0
```