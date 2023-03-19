dokku# Пример для ОС Linux Debian 10.3 amd64 netinst
## Ветка репозитория - web-release
### Предварительно необходимо установить Dokku на сервере 

1\. Создаём контейнер для приложения в dokku:
```
sudo -iu dokku
dokku apps:create sign-service
```
2\. Создаём каталоги static, uploads, cprocsp, cprocsp/keys, cprocsp/users в /home/dokku/sign-service:
```
mkdir -p /home/dokku/sign-service/static
mkdir -p /home/dokku/sign-service/uploads
mkdir -p /home/dokku/sign-service/cprocsp
mkdir -p /home/dokku/sign-service/cprocsp/keys
mkdir -p /home/dokku/sign-service/cprocsp/users
chmod -R 775 /home/dokku/sign-service/static
chmod -R 775 /home/dokku/sign-service/uploads
```
3\. Прикручиваем созданные каталоги к контейнеру приложения:
```
dokku storage:mount sign-service /home/dokku/sign-service/static:/app/static
dokku storage:mount sign-service /home/dokku/sign-service/uploads:/app/uploads
dokku storage:mount sign-service /home/dokku/sign-service/cprocsp:/var/opt/cprocsp/keys
dokku storage:mount sign-service /home/dokku/sign-service/cprocsp:/var/opt/cprocsp/users
```
4\. Создаём и привязываем базу данных:
```
dokku postgres:create sign_db
dokku postgres:link sign_db sign-service
```
5\. Отключаем домен для приложения:
```
dokku domains:disable sign-service
```
6\. Задаём порт для приложения:
```
dokku proxy:ports-set sign-service http:8005:5000
```
7\. Разворачиваем ветку web-release проекта sign-service в созданный контейнер, для этого можно скачать готовый скрипт:

https://gitlab.com/Komtek-ru/sign-service/-/blob/web-release/conf/deploy-sign-service.sh

Скрипт работает без правок, только если в настройках Dokku добавлен ваш RSA public key. Если это не так, то его необходимо добавить:
```
exit
sudo dokku ssh-keys:add name /path/to/key/rsa_file.pub
```
name - имя ключа, например admin, petrov и т.д.

/path/to/key/rsa_file.pub - путь до файла открытого ключа.

8\. Создаём superuser для добавления подписей в сервис:
```
sudo dokku enter sign-service web
python manage.py createsuperuser
```
При запросах задаём логин, e-mail, пароль.

9\. Находясь внутри контейнера копируем конфигурационные файлы nginx.static.conf и nginx.uploads.conf в каталог /app/uploads c помощью mc:
```
mc
```
Выходим из mc, (F-10)

10\. Выходим из контейнера:
```
exit
```
11\. Запускаем mc, создаём каталог nginx.conf.d в /home/dokku/sign-service:
```
sudo -iu dokku
mc
```
12\. Перемещаем файлы nginx.static.conf и nginx.uploads.conf из /home/dokku/sign-service/static в /home/dokku/sign-service/nginx.conf.d и завершаем работу с mc (F-10)

13\. Завершаем сеанс пользователя dokku:
```
exit
```
14\. Перезапускаем сервис nginx:
```
sudo service nginx restart
```
15\. Открываем в браузере адрес созданного сервиса, ip_адрес_вашего_сервера:ваш_порт

16\. Вводим логин и пароль, которые задали при создании суперпользователя

17\. В верхнем правом углу административного интерфейса жмём ссылку 'ОТКРЫТЬ САЙТ', откроется форма для добавления сертификатов в формате pfx. Для загрузки в сервис ЭП сперва необходимо экспортировать в данном формате.

18\. Выбираем файл сертификата pfx, задаём пароль для контейнера pfx (если он отличается от того что задан в форме по умолчанию), и нажимаем кнопку 'Загрузить'. Если ошибок нет, форма уведомит, что сертификат и контейнер успешно загружены. При возникновении ошибок - уведомит об ошибках.

19\. Проверяем работоспособность сервиса с помощью curl:
```
curl http://ip_адрес_вашего_сервера:ваш_порт/about
```
В ответ получаем:
```
{
    "version": 0.2,
    "msg": "API для подписи данных в кодировке Base64. Принимает запрос POST в формате JSON",
    "expires": "93 day(s)"
}
```

Для POST запроса используется RAW. В качестве обозначения подписанта необходим серийный номер сертификата "cert_serial_number" в десятичном виде.
Список подписантов "signatories" может содержать несколько (количество не ограничено) элементов для подписи данных в "unsigned_data".
Данные unsigned_data должны быть закодированы в base64. Подпись в ответе "signature" на данный момент откреплённая. В ответе на запрос содержится "checksum" (контрольная сумма) электронной подписи "signature".

20\. Пример запроса к сервису:
```
{
	"uuid": "c4661a97-3de0-4935-87dd-996c488a3cd5",
	"unsigned_data": "0KLQtdGB0YLQvtCy0L7QtSDRgdC+0L7QsdGJ0LXQvdC40LUg0LTQu9GPINC/0L7QtNC/0LjRgdC4",
	"signatories": [
    	    {"cert_serial_number": "401436239789537192650289056661676378181276809"}
	]
}
```
21\. Пример ответа на POST запрос:
```
{
    "uuid": "c4661a97-3de0-4935-87dd-996c488a3cd5",
    "errors": null,
    "signatures": [
        {
            "signer": "401436239789537192650289056661676378181276809",
            "owner": {
                "E": "ivanov@mail.ru",
                "G": "ИВАН ИВАНОВИЧ",
                "SN": "ИВАНОВ",
                "CN": "ИВАНОВ ИВАН ИВАНОВИЧ",
                "OU": "Home",
                "O": "Home",
                "L": "Москва",
                "S": "Московская область",
                "C": "RU",
                "notValidBefore": "2020-04-07T18:12:31",
                "notValidAfter": "2020-07-07T18:22:31"
            },
            "signature":
    			"MIIGQwYJKoZIhvcNAQcCoIIGNDCCBjACAQExDjAMBggqhQMHAQECAgUAMAsGCSqG\n
    			SIb3DQEHAaCCA7QwggOwMIIDX6ADAgECAhMSAEMUiUnXeqEoM34sAAEAQxSJMAgG\n
    			BiqFAwICAzB/MSMwIQYJKoZIhvcNAQkBFhRzdXBwb3J0QGNyeXB0b3Byby5ydTEL\n
    			MAkGA1UEBhMCUlUxDzANBgNVBAcTBk1vc2NvdzEXMBUGA1UEChMOQ1JZUFRPLVBS\n
    			TyBMTEMxITAfBgNVBAMTGENSWVBUTy1QUk8gVGVzdCBDZW50ZXIgMjAeFw0yMDA0\n
    			MDcxODEyMzFaFw0yMDA3MDcxODIyMzFaMIG1MR0wGwYJKoZIhvcNAQkBFg5lZnJl\n
    			bW9mZkB5YS5ydTEXMBUGA1UEAwwO0JLQuNGC0LDQu9C40LkxDTALBgNVBAsMBEhv\n
    			bWUxDTALBgNVBAoMBEhvbWUxJDAiBgNVBAcMG9Cl0LDQvdGC0Yst0JzQsNC90YHQ\n
    			uNC50YHQujEqMCgGA1UECAwh0KLRjtC80LXQvdGB0LrQsNGPINC+0LHQu9Cw0YHR\n
    			gtGMMQswCQYDVQQGEwJSVTBmMB8GCCqFAwcBAQEBMBMGByqFAwICJAAGCCqFAwcB\n
    			AQICA0MABECjpusu4PB8sOv5Wk1qwDCpXgBi+p9n46nt2QYAbFhP2qWIr4LiSy7a\n
    			ElTqA9XK1DLahh+Aebz6kPtvxOjaAO4do4IBdjCCAXIwDgYDVR0PAQH/BAQDAgTw\n
    			MBMGA1UdJQQMMAoGCCsGAQUFBwMCMB0GA1UdDgQWBBS3tsMW46s+Lor1d3VByTLq\n
    			wv4vvTAfBgNVHSMEGDAWgBROgz4Uae/sXXqVK18R/jcyFklVKzBcBgNVHR8EVTBT\n
    			MFGgT6BNhktodHRwOi8vdGVzdGNhLmNyeXB0b3Byby5ydS9DZXJ0RW5yb2xsL0NS\n
    			WVBUTy1QUk8lMjBUZXN0JTIwQ2VudGVyJTIwMigxKS5jcmwwgawGCCsGAQUFBwEB\n
    			BIGfMIGcMGQGCCsGAQUFBzAChlhodHRwOi8vdGVzdGNhLmNyeXB0b3Byby5ydS9D\n
    			ZXJ0RW5yb2xsL3Rlc3QtY2EtMjAxNF9DUllQVE8tUFJPJTIwVGVzdCUyMENlbnRl\n
    			ciUyMDIoMSkuY3J0MDQGCCsGAQUFBzABhihodHRwOi8vdGVzdGNhLmNyeXB0b3By\n
    			by5ydS9vY3NwL29jc3Auc3JmMAgGBiqFAwICAwNBADrnZ0dFfRG3qZenZX1eVFcJ\n
    			beYghmx6hGWNjigAEzim7Rfbe5JF+RLuVEQXkebXpOFUrZMectfOPSE0nE+ZolMx\n
    			ggJUMIICUAIBATCBljB/MSMwIQYJKoZIhvcNAQkBFhRzdXBwb3J0QGNyeXB0b3By\n
    			by5ydTELMAkGA1UEBhMCUlUxDzANBgNVBAcTBk1vc2NvdzEXMBUGA1UEChMOQ1JZ\n
    			UFRPLVBSTyBMTEMxITAfBgNVBAMTGENSWVBUTy1QUk8gVGVzdCBDZW50ZXIgMgIT\n
    			EgBDFIlJ13qhKDN+LAABAEMUiTAMBggqhQMHAQECAgUAoIIBUjAYBgkqhkiG9w0B\n
    			CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMDA0MjEwOTEyMTlaMC8G\n
    			CSqGSIb3DQEJBDEiBCCUckp4cDHfppz6DnIet51BvNY5pRGa7JuIIeOkQQi6KTCB\n
    			5gYLKoZIhvcNAQkQAi8xgdYwgdMwgdAwgc0wCgYIKoUDBwEBAgIEIKyO5fHNT/ht\n
    			AOhf4LAqbq+cjezTax4/dOfnp/gBgKl6MIGcMIGEpIGBMH8xIzAhBgkqhkiG9w0B\n
    			CQEWFHN1cHBvcnRAY3J5cHRvcHJvLnJ1MQswCQYDVQQGEwJSVTEPMA0GA1UEBxMG\n
    			TW9zY293MRcwFQYDVQQKEw5DUllQVE8tUFJPIExMQzEhMB8GA1UEAxMYQ1JZUFRP\n
    			LVBSTyBUZXN0IENlbnRlciAyAhMSAEMUiUnXeqEoM34sAAEAQxSJMAwGCCqFAwcB\n
    			AQEBBQAEQHZmMIRFnYt2RZ46OB9lv+ykCGsyJRYovezMjYQMLgt+ItR7nqp10cBP\n
    			U+GHYqzvIGKcLcOp2Oz1aNfMi4EpwIM=\n",
    		"checksum": 3159080262
		}
	]
}
```