## Установка docker и docker-compose на Astra Linux релиз Орел

Обновляемся

```bash
apt update && apt upgrade
```

Ставим docker

```bash
sudo apt-get install apt-transport-https ca-certificates curl gnupg2 
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" | sudo tee -a /etc/apt/sources.list
sudo apt update
sudo apt install docker-ce
```

Проверяем

```bash
sudo systemctl status docker
docker --version
```

Разрешаем себе пользовать docker без sudo, проверяем

```bash
sudo usermod -aG docker ${USER}
sudo su - ${USER}
docker run hello-world
```

Ставим docker-compose.

Имеет смысл проверить версию последнего релиза (https://github.com/docker/compose/releases) и заменить "1.23.2" в команде ниже

```bash
sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
Проверяем

```bash
docker-compose --version
```
