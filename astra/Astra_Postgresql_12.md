## Установка PostgreSQL server v12 на Astra Linux релиз Орел

Обновляемся

```bash
apt update && apt upgrade
```

Ставим postgres

```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt install postgresql-12 postgresql-client-12
```

Если в этом месте начнет ругаться на postgresql-common не той версии, надо либо пподнять приоритет репозитария pgdg, 
либо настоять на конкретной версии postgresql-common

Второй вариант:

```bash
apt-cache policy postgresql-common
# смотрим pgdg версию и ставим ее
sudo apt install postgresql-common=216.pgdg90+1
sudo apt install postgresql-client-common=216.pgdg90+1
# то же с libpq
apt-cache policy libpq-dev
sudo apt install libpq-dev=12.4-1.pgdg90+1
# и тогда уже
sudo apt install postgresql-12 postgresql-client-12
```

Редактируем настройки и запускаем
```bash
sudo nano /etc/postgresql/12/main/postgresql.conf 
sudo nano /etc/postgresql/12/main/pg_hba.conf 
sudo systemctl start postgresql
sudo systemctl enable postgresql
```
