# Домашнее задание к занятию "13.3 работа с kubectl"

## Задание 1: проверить работоспособность каждого компонента

Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:

* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

**ОТВЕТ:** Для проверки будем использовать **[исправленное приложение](./13-kubernetes-config)** которое теперь нормально работает при открытии наружу только фронтенда (бекенд и база остаются внутри кластера) и **[манифест test_apps.yml](ю.test_apps.yml)**.  

```bash
wizard:13-kubernetes-config-03-kubectl/ (main✗) $ kg po -o wide
NAME                                  READY   STATUS    RESTARTS   AGE    IP             NODE                        NOMINATED NODE   READINESS GATES
backend-app-5567d89778-zvrzz          1/1     Running   1          15h    10.233.98.23   cl1enbofe9mh4irbkim9-omep   <none>           <none>
db-app-0                              1/1     Running   0          15h    10.233.96.38   cl1enbofe9mh4irbkim9-idep   <none>           <none>
frontend-app-6d99d687b8-fwqfg         1/1     Running   0          15h    10.233.97.51   cl1enbofe9mh4irbkim9-egav   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          3d2h   10.233.97.39   cl1enbofe9mh4irbkim9-egav   <none>           <none>
```

Проверяем бекенд:

```bash
wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k port-forward backend-app-5567d89778-zvrzz 9000:9000 &
[1] 190351
wizard:13-kubernetes-config-03-kubectl/ (main✗) $ Forwarding from 127.0.0.1:9000 -> 9000
Forwarding from [::1]:9000 -> 9000

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ curl http://127.0.0.1:9000/api/news/1
Handling connection for 9000
{"id":1,"title":"title 0","short_description":"small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0small text 0","description":"0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, ","preview":"/static/image.png"}%

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k exec -it backend-app-5567d89778-zvrzz -- sh  

# curl http://127.0.0.1:9000/api/news/2
{"id":2,"title":"title 1","short_description":"small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1small text 1","description":"1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, 1 some more text, ","preview":"/static/image.png"}
# exit

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ kill -9 190351
[1]  + 190351 killed     kubectl port-forward backend-app-5567d89778-zvrzz 9000:9000
```

Проверяем фронтенд:

```bash
wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k port-forward frontend-app-6d99d687b8-fwqfg 8000:80 &
[1] 191951
wizard:13-kubernetes-config-03-kubectl/ (main✗) $ Forwarding from 127.0.0.1:8000 -> 80
Forwarding from [::1]:8000 -> 80

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ curl http://127.0.0.1:8000/
Handling connection for 8000
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>%

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k exec -it frontend-app-6d99d687b8-fwqfg -- sh

# curl http://127.0.0.1
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
# exit

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ kill -9 191951
[1]  + 191951 killed     kubectl port-forward frontend-app-6d99d687b8-fwqfg 8000:80
```

Проверяем базу:

```bash
wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k port-forward db-app-0 5432:5432 &                                                        [15:26:27]
[1] 192691
wizard:13-kubernetes-config-03-kubectl/ (main✗) $ Forwarding from 127.0.0.1:5432 -> 5432                                                     [15:26:57]
Forwarding from [::1]:5432 -> 5432

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ psql -h localhost -Upostgres -b news                                                       [15:27:00]
Handling connection for 5432
psql (13.4, сервер 13.5)
Введите "help", чтобы получить справку.

news=# \dt
          Список отношений
 Схема  | Имя  |   Тип   | Владелец 
--------+------+---------+----------
 public | news | таблица | postgres
(1 строка)

news=# exit

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k exec -it db-app-0 -- sh

/ # netstat -tulpn | grep 5432
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN      -
tcp        0      0 :::5432                 :::*                    LISTEN      -
/ # exit

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ kill -9 192691
[1]  + 192691 killed     kubectl port-forward db-app-0 5432:5432
```

## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. После уменьшите количество копий до 1. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe).

**ОТВЕТ:** Выполним действия из задания, а на каких нодах оказались поды проще посмотреть в `kubectl get pod -o wide` чем открывать `describe` для каждого пода.

```bash
wizard:13-kubernetes-config-03-kubectl/ (main✗) $ kg deploy
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
backend-app    1/1     1            1           16h
frontend-app   1/1     1            1           16h

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k scale --replicas=3 deployment/backend-app
deployment.apps/backend-app scaled

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k scale --replicas=3 deployment/frontend-app
deployment.apps/frontend-app scaled

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ kg po -o wide
NAME                                  READY   STATUS    RESTARTS   AGE    IP             NODE                        NOMINATED NODE   READINESS GATES
backend-app-5567d89778-lptwx          1/1     Running   0          58s    10.233.98.24   cl1enbofe9mh4irbkim9-omep   <none>           <none>
backend-app-5567d89778-sdcb8          1/1     Running   0          58s    10.233.97.52   cl1enbofe9mh4irbkim9-egav   <none>           <none>
backend-app-5567d89778-zvrzz          1/1     Running   1          16h    10.233.98.23   cl1enbofe9mh4irbkim9-omep   <none>           <none>
db-app-0                              1/1     Running   0          16h    10.233.96.38   cl1enbofe9mh4irbkim9-idep   <none>           <none>
frontend-app-6d99d687b8-7qtnh         1/1     Running   0          16s    10.233.96.39   cl1enbofe9mh4irbkim9-idep   <none>           <none>
frontend-app-6d99d687b8-fwqfg         1/1     Running   0          16h    10.233.97.51   cl1enbofe9mh4irbkim9-egav   <none>           <none>
frontend-app-6d99d687b8-j7ld7         1/1     Running   0          16s    10.233.98.25   cl1enbofe9mh4irbkim9-omep   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          3d3h   10.233.97.39   cl1enbofe9mh4irbkim9-egav   <none>           <none>

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k scale --replicas=1 deployment/frontend-app
deployment.apps/frontend-app scaled

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k scale --replicas=1 deployment/backend-app
deployment.apps/backend-app scaled

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ kg po -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE                        NOMINATED NODE   READINESS GATES
backend-app-5567d89778-sdcb8          1/1     Running   0          3m51s   10.233.97.52   cl1enbofe9mh4irbkim9-egav   <none>           <none>
db-app-0                              1/1     Running   0          16h     10.233.96.38   cl1enbofe9mh4irbkim9-idep   <none>           <none>
frontend-app-6d99d687b8-fwqfg         1/1     Running   0          16h     10.233.97.51   cl1enbofe9mh4irbkim9-egav   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          3d3h    10.233.97.39   cl1enbofe9mh4irbkim9-egav   <none>           <none>

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k describe deployment/backend-app
Name:                   backend-app
Namespace:              default
CreationTimestamp:      Fri, 04 Feb 2022 23:30:27 +0700
Labels:                 app=backend-app
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=backend-app
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=backend-app
  Containers:
   backend-app:
    Image:      tabwizard/backend
    Port:       9000/TCP
    Host Port:  0/TCP
    Liveness:   tcp-socket :9000 delay=15s timeout=1s period=60s #success=1 #failure=3
    Environment:
      DATABASE_URL:  postgres://postgres:postgres@db:5432/news
    Mounts:          <none>
  Volumes:           <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   backend-app-5567d89778 (1/1 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  3m57s  deployment-controller  Scaled up replica set backend-app-5567d89778 to 3
  Normal  ScalingReplicaSet  45s    deployment-controller  Scaled down replica set backend-app-5567d89778 to 1

wizard:13-kubernetes-config-03-kubectl/ (main✗) $ k describe deployment/frontend-app
Name:                   frontend-app
Namespace:              default
CreationTimestamp:      Fri, 04 Feb 2022 23:30:26 +0700
Labels:                 app=frontend-app
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=frontend-app
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=frontend-app
  Containers:
   frontend-app:
    Image:        tabwizard/frontend:correct
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   frontend-app-6d99d687b8 (1/1 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  3m25s  deployment-controller  Scaled up replica set frontend-app-6d99d687b8 to 3
  Normal  ScalingReplicaSet  67s    deployment-controller  Scaled down replica set frontend-app-6d99d687b8 to 1
```
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
