# Домашняя работа к занятию "5.3. Контейнеризация на примере Docker"

## Задача 1

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование докера? Или лучше подойдет виртуальная машина, физическая машина? Или возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение; __ОТВЕТ:__  возможны любые варианты, не вижу препятствий для запуска как в докере, так и в виртуалке или на хосте.
- Go-микросервис для генерации отчетов; __ОТВЕТ:__ однозначно докер, само название "микросервис" как бы уже предполагает контейнеризацию
- Nodejs веб-приложение; __ОТВЕТ:__  тоже докер, для веб-приложений нормально
- Мобильное приложение c версиями для Android и iOS; __ОТВЕТ:__ бэкенд нормально живет в докере
- База данных postgresql используемая, как кэш; __ОТВЕТ:__ с одной стороны хорошей практикой считается на пихать базы в докер, с другой, вроде бы кеш и потеря данных нестрашна, поэтому возможны варианты
- Шина данных на базе Apache Kafka; __ОТВЕТ:__ в докер, будет хорошо масштабироваться
- Очередь для Logstash на базе Redis; __ОТВЕТ:__ в докер, не страшно
- Elastic stack для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana; __ОТВЕТ:__ в докер всю эту кучу но распихать по контейнерам
- Мониторинг-стек на базе prometheus и grafana; __ОТВЕТ:__ в докер, им в контейнерах будет неплохо
- Mongodb, как основное хранилище данных для java-приложения; __ОТВЕТ:__ как уже писал, базы лучше не пихать в докер, поэтому или виртуалка или хост
- Jenkins-сервер. __ОТВЕТ:__ в докер

## Задача 2

Сценарий выполения задачи:

- создайте свой репозиторий на докерхаб;
- выберете любой образ, который содержит апачи веб-сервер;
- создайте свой форк образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:

    ```
    <html>
    <head>
    Hey, Netology
    </head>
    <body>
    <h1>I’m kinda DevOps now</h1>
    </body>
    </html>
    ```

Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на докерхаб-репо.  

__ОТВЕТ:__  

```bash
wizard:05-virt-03-docker-usage/ (main✗) $ cat > index.html <<_EOF_
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m kinda DevOps now</h1>
</body>
</html>
_EOF_

wizard:05-virt-03-docker-usage/ (main✗) $ cat > Dockerfile <<_EOF_
FROM httpd
COPY index.html /usr/local/apache2/htdocs/
EXPOSE 8080 80
_EOF_

wizard:05-virt-03-docker-usage/ (main?) $ docker build -t 05-virt-03-docker-usage .
Sending build context to Docker daemon  9.728kB
Step 1/3 : FROM httpd
 ---> 39c2d1c93266
Step 2/3 : COPY index.html /usr/local/apache2/htdocs/
 ---> a637c155408f
Step 3/3 : EXPOSE 8080 80
 ---> Running in 14c63105bc49
Removing intermediate container 14c63105bc49
 ---> 431f4d993a07
Successfully built 431f4d993a07
Successfully tagged 05-virt-03-docker-usage:latest

wizard:05-virt-03-docker-usage/ (main?) $ docker run -d -p 8080:80 05-virt-03-docker-usage:latest
006cdc4b977eb2a400f511544e2bf1f73045de5397f5096c6a5a21ad8205cb03

wizard:05-virt-03-docker-usage/ (main?) $ curl http://127.0.0.1:8080
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m kinda DevOps now</h1>
</body>
</html>

wizard:05-virt-03-docker-usage/ (main✗) $ docker login
Authenticating with existing credentials...
WARNING! Your password will be stored unencrypted in /home/wizard/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

wizard:05-virt-03-docker-usage/ (main✗) $ docker tag 05-virt-03-docker-usage tabwizard/05-virt-03-docker-usage

wizard:05-virt-03-docker-usage/ (main✗) $ docker push tabwizard/05-virt-03-docker-usage
Using default tag: latest
The push refers to repository [docker.io/tabwizard/05-virt-03-docker-usage]
2adc85d94f3f: Pushed
98d580c48609: Pushed
33de34a890b7: Pushed
33c6c92714e0: Pushed
15fd28211cd0: Pushed
02c055ef67f5: Pushed
latest: digest: sha256:a4b878910df32fd6423fd95de7a0c0ebffbc7162407db7b9d23e396c3e6cdd75 size: 1573
```  

Для проверки запускать docker: `docker run -d -p 8080:80 tabwizard/05-virt-03-docker-usage` Образ [tabwizard/05-virt-03-docker-usage](https://hub.docker.com/repository/docker/tabwizard/05-virt-03-docker-usage)

## Задача 3

- Запустите первый контейнер из образа centos c любым тэгом в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /share/info контейнера;
- Запустите второй контейнер из образа debian:latest в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /info контейнера;
- Подключитесь к первому контейнеру с помощью exec и создайте текстовый файл любого содержания в /share/info ;
- Добавьте еще один файл в папку info на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /info контейнера.  

__ОТВЕТ:__  

```bash
wizard:05-virt-03-docker-usage/ (main✗) $ mkdir ./info

wizard:05-virt-03-docker-usage/ (main✗) $ docker run --name centos8 -d -v "$(pwd)"/info:/share/info centos:8 sleep 1200
Unable to find image 'centos:8' locally
8: Pulling from library/centos
7a0437f04f83: Already exists
Digest: sha256:5528e8b1b1719d34604c87e11dcd1c0a20bedf46e83b5632cdeac91b8c04efc1
Status: Downloaded newer image for centos:8
7a520134e2b97a4ef9e759fafa155274ec78b36ff8a53aebdb0f78b1517a3dcc


wizard:05-virt-03-docker-usage/ (main✗) $ docker run --name debian -d -v "$(pwd)"/info:/info debian:latest sleep 1200
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
d960726af2be: Already exists
Digest: sha256:acf7795dc91df17e10effee064bd229580a9c34213b4dba578d64768af5d8c51
Status: Downloaded newer image for debian:latest
c7c6742076cd01a0e0b8882d28c43a2375a32903bf39782f6226099cd0f09b7b

wizard:05-virt-03-docker-usage/ (main✗) $ docker exec -it centos8 bash

[root@7a520134e2b9 /]# echo "from docker centos:8" > /share/info/centos.txt
[root@7a520134e2b9 /]# exit
exit

wizard:05-virt-03-docker-usage/ (main✗) $ echo "from host" > ./info/host.txt

wizard:05-virt-03-docker-usage/ (main✗) $ docker exec -it debian bash

root@c7c6742076cd:/# ls -la /info
total 16
drwxr-xr-x 2 1000 1000 4096 Jun 18 07:04 .
drwxr-xr-x 1 root root 4096 Jun 18 07:03 ..
-rw-r--r-- 1 root root   21 Jun 18 07:04 centos.txt
-rw-r--r-- 1 1000 1000   10 Jun 18 07:04 host.txt

root@c7c6742076cd:/# cat /info/centos.txt
from docker centos:8
root@c7c6742076cd:/# cat /info/host.txt
from host
root@c7c6742076cd:/# exit
exit

```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
