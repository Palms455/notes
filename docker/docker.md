|**docker pull <image>**|скачивает образ с регистра |
| :- | :- |
|**docker images**|список образов в системе|
|**docker run busybox**|запуск образа по имени|
|**docker ps**|вывод всех запущенных контейнеров|
|**docker ps -a**|все конт которые запускались|
|**docker run -it**|подключает интерактивный tty в контейнер. Теперь можно запускать сколько угодно много команд внутри|
|**docker rm <ID or name>**|удаление контейнеров|
|**docker rm $(docker ps -a -q -f status=exited)**|комбинирование команд. Удаление всех отработанных контейнеров|
|**-d  (detached mode)**|отвязка терминала от контейнера|
|**-P** |все открытые порты будут публичными|
|**--name** |присвоение имени контейнеру|
|docker run -d -P --name static-site prakhar1989/static-site|
|**docker port <name container>**|порты открытые для контейнера|
|**-p 8888:80**|назначение порта|
|**docker stop <id or name container >**||
|` `**образ ONBUILD**|` `триггер для быстрого разворачивания приложения и установки доп зависимостей|
|**python : 3-onbuild**||
|FROM python:3-onbuild|указание базового образа|
|EXPOSE 5000|открыть порт|
|**WORKDIR /usr/src/app**|создает рабочую директорию|
|**COPY . .**|копирует содержимое текущей папки  в рабочую|
|**RUN pip install –no-cache-dir –r requirements.txt**|установка зависимотей|
|ПРИ установке базовго образа onbuild – не нужны команды WORKDIR COPY PIP|
|**CMD [“python”, “./app.py”]**|запуск приложения|
|||
|**docker build –t name .**|создание образа –t присвоение имени|
|**docker push <name>**|отправка образа  в регистр|
|||
|**RUN apt-get -yqq install python-pip python-dev**|-yqq  для автоматического выбора Yesv|
|<p>После установки, Докер автоматически создает три сети:</p><p>$ docker network ls</p><p>NETWORK ID          NAME                DRIVER</p><p>075b9f628ccc        none                null</p><p>be0f7178486c        host                host</p><p>8022115322ec        bridge              bridge</p><p></p>|
|**docker network inspect bridge**|проверка сетей|
|**docker network create <name >**|network create создает новую сеть *bridge*. |
|Можно запустить наши контейнеры внутри сети с помощью флага --net|
|network ls|список сетей|
|network connect <network name> <cont name>|присоединение конт к сети|
|docker container run -it --name one --network=custom\_network nginx|запуск и присоед конт к сети|
|disconnect <netw name><cont name>|отсоединить от сети контейнер|
|network prune|удаление всех етей|
|--net-alias|dns имя|
|||
|**pip install docker-compose**|установка |
|<p>version: "2" </p><p>services: </p><p>`   `es: - название неймспейсов</p><p>`      `image: elasticsearch – образ в регистре</p><p>`   `web: </p><p>`      `image: prakhar1989/foodtrucks-web </p><p>`      `command: python app.py </p><p>`      `ports: - "5000:5000" </p><p>`      `volumes: - .:/code</p><p>№ синтаксис конфигурационного yml файла</p><p>для запуска docker compose нужно находится в той же директории.</p>|
|**docker-compose up**|` `запуск|
|**FROM**|` `задаёт базовый (родительский) образ.|
|**LABEL**|описывает метаданные. Например — сведения о том, кто создал и поддерживает образ|
|**ENV**|устанавливает постоянные переменные среды|
|**RUN**|выполняет команду и создаёт слой образа. Используется для установки в контейнер пакетов|
|**COPY**|копирует в контейнер файлы и папки|
|**ADD**|копирует файлы и папки в контейнер, может распаковывать локальные .tar-файлы.|
|**CMD**|описывает команду с аргументами, которую нужно выполнить когда контейнер будет запущен. Аргументы могут быть переопределены при запуске контейнера. В файле может присутствовать лишь одна инструкция CMD|
|**WORKDIR**|задаёт рабочую директорию для следующей инструкции|
|**ARG**|задаёт переменные для передачи Docker во время сборки образа|
|**ENTRYPOINT**|предоставляет команду с аргументами для вызова во время выполнения контейнера. Аргументы не переопределяются.|
|**EXPOSE**|указывает на необходимость открыть порт|
|**VOLUME**|`	`создаёт точку монтирования для работы с постоянным хранилищем|
|<p>FROM python:3.7.2-alpine3.8 </p><p>LABEL maintainer="jeffmshale@gmail.com" </p><p># Устанавливаем зависимости </p><p>RUN apk add --update git </p><p># Задаём текущую рабочую директорию </p><p>WORKDIR /usr/src/my\_app\_directory </p><p># Копируем код из локального контекста в рабочую директорию образа </p><p>COPY . . </p><p># Задаём значение по умолчанию для переменной </p><p>ARG my\_var=my\_default\_value </p><p># Настраиваем команду, которая должна быть запущена в контейнере во время его выполнения ENTRYPOINT ["python", "./app/my\_script.py", "my\_var"] </p><p># Открываем порты </p><p>EXPOSE 8000 </p><p># Создаём том для хранения данных </p><p>VOLUME /my\_volume</p><p></p><p>RUN apk update && apk upgrade && apk add bash<br>Кстати нюанс писать несколько команд через && крайне полезен. Он означает что вместо трех отдельных слоев будет создан лишь один, что заметно уменьшает и размер образа и скорость его разворачивания.</p><p>Кэширование можно отключить, передав ключ --no-cache=True команде docker build.</p><p>Объединяйте команды RUN apt-get update и apt-get install в цепочки для того, чтобы исключить проблемы, связанные с неправильным использованием кэша.</p><p>Если вы используете менеджеры пакетов, наподобие pip, с файлом requirements.txt, тогда придерживайтесь нижеприведённой схемы работы для того, чтобы исключить использование устаревших промежуточных образов из кэша, содержащих набор пакетов, перечисленных в старой версии файла requirements.txt. Вот как это выглядит:</p><p>COPY requirements.txt /tmp/</p><p>RUN pip install -r /tmp/requirements.txt</p><p>COPY . /tmp/</p><p></p>|
|**dockerignore**|аналог .gitignore|
|**container ls -s**|примерный размер образов|
|**image inspect my\_image:tag**|подробные сведения об образе, в том ч — размер каждого его слоя|
|<p>Если вы пользуетесь apt, комбинируйте в одной инструкции RUN команды apt-get update и apt-get install. Кроме того, объединяйте в одну инструкцию команды установки пакетов. Перечисляйте пакеты в алфавитном порядке на нескольких строках, разделяя список символами \. Например, это может выглядеть так:</p><p></p><p>Включайте конструкцию вида && rm -rf /var/lib/apt/lists/\* в конец инструкции RUN, используемой для установки пакетов. Это позволит очистить кэш apt и приведёт к тому, что он не будет сохраняться в слое, сформированном командой RUN.</p><p></p>|
|**docker container run my\_app**|создает(скачивает) и запускает контейнер	|
|**docker container stop**||
|**docker container <command>**||
|**create**|создание конт из образа|
|**start**|запуск конт|
|**run**|создание и запуск|
|**ls**|список работ контейнеров|
|**inspsect**|подробная инфа о конт|
|**logs**|вывод логов|
|**stop**|остановка работающ контейнера|
|**kill**|остановка работ конт|
|**rm**|удаление остановл контейнера|
|**docker image <command> <name>**||
|**build**|сборка образа|
|**push**|отправка образа в удал реестр|
|**ls**|список образов|
|**history**|сведения о слоях образа|
|**inspect**|подробная инфа о образе в т.ч. о слоях|
|**docker version**|вывод сведений о версиях клиента|
|**docker login**|вход в реестр docker|
|**docker system prune**|удаление неиспользуемых контейнеров сетей и образов которым не назначено имя и тег|
|**docker container create my\_image**|создание контейнера из образа|
|**-a (--attach)**|поключение конт к STDN STDOUT STDERR|
|**docker container start my\_container**|запуск контейнера|
|**-I (--interactive)**|STDN в открытом состоянии|
|**-t (--tty)**|псевдотерминал с потоками STDIN и STDNOUT|
|**-it**|воздействие на конт через терминал|
|rm <options> <cont name> or <hash>|автоматическое удаление контейнера при его завершении|
|rm -f|удаление запущенного конейнера|
|pause <cont name> or <hash>|"замораживает" кон|
|unpause<cont name> or <hash>|возобновляет контейнер|
|--memory-reservation <bytes>|soft limit|
|--restart <params>|параметры перезагрузки|
|--restart always|всегда перезагружается за искл команды остановки|
|--restart on-failure|перезагр при ошибках внутри конт|
|` `restart no |по дефолту рестарт|
|--rm|после остановки контейнер удаляется|
|attach <cont name>|присоединение к контейнеру|
|<p>docker container inspect proxy --format "IP: {{ .NetworkSettings.IPAddress }} | Gateway: {{.NetworkSettings.Networks.bridge.Gateway}}"</p><p>получение нужных параметров</p>|
|<p>for VARIABLE in 1 2 3</p><p>do</p><p>`	`docker container create --name proxy-$VARIABLE nginx</p><p>done</p>|<p>создание неск контейнеров</p><p></p>|
|docker exec -it <cont name> bash - подключение к запущенному контейнеру|
|<p>docker container cp ./data/\*.html proxy:/usr/share/nginx/html</p><p>docker container cp ./data/css proxy:/usr/share/nginx/html/css</p><p>скопировать файлы и папки внутрь контейнера</p>|
|diff <name cont>|Изменения в контейнере|
|top <cont name> or <hash>|показ запущ процессы в конт|
|stats <cont name> or <hash>|показывает потреб ресурсы конт|
|**-sh**|создает сессию в терминале|
|**-d (--detach)**|запуск в фоновом режиме|
|**-s**|размер контейнера|
|**-a**|свед обо всех конт|
|**docker container kill $(docker ps -q)** |быстрая остановка всех работающих конт|
|**docker container rm $(docker ps -a -q)**|удаление всех конт которые не выполняются|
|**docker image build –t image**|создание образа|
|**-t (--tag)**|предост образу тег|
|<p>**Хранение файлов:**</p><p>1\.файлы можно хранить в контейнере без указания места хранения – инфа будет жить сколько живет контейнер</p><p>2\.big mount  монтирование tmpfs в контейнер</p><p>3\. тома в docker</p><p>Том — это файловая система, которая расположена на хост-машине за пределами контейнеров.</p><p>Docker [никогда не удаляет](_blank) data volumes, даже если контейнеры, которые их создали, удалены. </p><p>docker volume ls -qf dangling=true  - тома без контейнеров примонтированных к ним</p><p>docker volume rm $(docker volume ls -qf dangling=true)  - удаление таких томов</p><p></p>|
|**VOLUME /my\_volume**|в Dockerfile создание тома при его запуске|
|**docker volume create —-name my\_volume**|` `создание тома самостоятельно|
|**docker volume ls**|список томов|
|**docker volume rm my\_volume**|удаление тома|
|**docker volume prune**|удалить все тома не используемые в конт|
|<p>Если том связан с каким-либо контейнером, такой том нельзя удалить до тех пор, пока не удалён соответствующий контейнер. При этом, даже если контейнер удалён, Docker не всегда это понимает. Если это случилось — можете воспользоваться следующей командой:</p><p>docker system prune</p>|
|**docker container run --mount source=my\_volume, target=/container/path/for/volume my\_image**|создание тома во время создания котейнера|
|**type**|тип монтирования(bind volume tmpfs)|
|**source**|источник монтирования. Имя тома |
|**destination**|путь, к которому файл или папка монтируется в контейнере. Этот ключ может быть сокращён до dst или target.|
|**readonly**|монтирует том, который предназначен только для чтения.|
|<p>`	`Вот пример использования --mount с множеством параметров:</p><p>docker run --mount type=volume,source=volume\_name,destination=/path/in/container,readonly my\_image</p>|
|<p>-v path:/home <imagename></p><p>$(pwd) - текущ директория</p>|монтирование директории хоста(до двоеточия) к директории контейнера: после двоеточия|
|**docker run -ti --rm -v c:\your\path\:/home ubuntu** |
|**$(pwd) - путь текущей директории Linux, монтировать можно не только папки но и файлы**|
|docker volume ls|список доступных томов|
|<p>-- volume при монтировании директории создает каталоги и подкаталоги, если мы указали их при монтировании, и они не существовалаи до монтирования!!! </p><p>При монтировании несуществующего файла --volume  создаст пустой каталог(не файл) с таким же именем, которое мы указали в качетсве названия файла</p><p>--mount  выдаст ошибку при монтировании несуществующего каталога</p><p>Если внутри контейнер каталог был не пустой, то он затрется содержимым примонтированного каталога </p>|
|**REGISTRY IMAGES**|
|**docker registry**|локальный репозиторий|
|<p>**docker container run -d -p 5000:5000 --restart always --name registry registry**</p><p>**запуск контейнера с локальным репозиторием**</p>|
|**docker push localhost:5000/ubuntu**|запушить образ в репозиторий|
|**в GitLab есть образы**||
|**docker login**|вход в docker hub|
|**docker image tag <image name> palms450/<image name>**|Присваивание тега образу по умолчанию (latest)|
|**Webhook позволяет отправлять запрос при выполнении push в репозиторий**|
|**docker system prune -a -f**|УДАЛИТЬ ВСЁ|
|**docker pull localhost:5000 <image name>**|скачать образ с локального репозитория|
|**docker image pull <options><image\_name:tag>**|скачать образ|
|||
|**docker compose - запуск нескольких образов одной командой**|
|<p>version: "2.4"                   </p><p></p><p>services:                                                                    сущность верхнего уровня</p><p>`  `webhost:                                                                 название сервиса</p><p>`    `image: nginx:alpine                                             образ для сервиса</p><p>`    `container\_name: webhost                                задать имя контейнера</p><p>`    `build: ./webapp                                                   при запуске compose соберет образ из dockerfile</p><p>`    `ports:</p><p>`      `- 80:80                                                                 примапить порты</p><p>`    `depends\_on:                                                        определяет зависимости</p><p>`      `- db                                                                      webhost не стартует пока не запустится севис db</p><p>`         `db:</p><p>`           `condition: service\_started                        опционально указывать когда будет стартовать зависимые сервисы</p><p>`    `volumes:</p><p>`      `- ./html:/usr/share/nginx/html                      монтир каталога bind (позволяет указывать относительный путь)</p><p>`      `- /usr/share/nginx/html                                   монтирование анонимного каталога</p><p>`    `networks:                                                              подключение к сети db, back</p><p>`      `- db</p><p>`      `- back</p><p>`  `db:</p><p>`    `image: mongo:4</p><p>`    `container\_name: storage</p><p>`    `volumes:</p><p>`      `- ./data:/data/db</p><p>`    `networks:</p><p>`      `- db</p><p></p><p>`  `networks:</p><p>`      `back:</p><p>`        `driver : bridge</p><p>`      `db:</p><p>`        `driver : bridge</p>|
|**docker-compose up -d**|поднимает сервис|
|**docker-compose.yml**|название файла по умолчанию|
|**docker compose -f <custom yame.yml>**|задать на выполнение если название файла другое|
|**docker-compose logs <service\_name>**|посмотреть логи сервиса|
|**docker-compose down**|остановить |
|<p>version: "2.4"</p><p>services:</p><p>`  `webhost:</p><p>`    `image: nginx:alpine</p><p>`    `container\_name: webhost</p><p>`    `ports:</p><p>`      `- 80:80</p><p>`    `restart: always                    - переазгружаться всегда</p><p>`    `environment:                      - перменные среды окружения (можно передавать ссылку на бд)</p><p>`      `- MODE=dev</p><p>`    `volumes:</p><p>`      `- ./html:/usr/share/nginx/html</p>|
|**command: <com name>**|команда внутри контейнера|
|||
|||
|||
|||
|||
|||
|||
|||
|||
|||
|||
|||
|||
|||
|||

