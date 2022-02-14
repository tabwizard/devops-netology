# Домашняя работа к занятию "13.5 поддержка нескольких окружений на примере Qbec"

Приложение обычно существует в нескольких окружениях. Для удобства работы следует использовать соответствующие инструменты, например, Qbec.

## Задание 1: подготовить приложение для работы через qbec

Приложение следует упаковать в qbec. Окружения должно быть 2: stage и production.

Требования:

* stage окружение должно поднимать каждый компонент приложения в одном экземпляре;
* production окружение — каждый компонент в трёх экземплярах;
* для production окружения нужно добавить endpoint на внешний адрес.

**ОТВЕТ:** Инициализируем каталог приложения с помощью `qbec init`

```bash
wizard:13-kubernetes-config-05-qbec/ (main✗) $ qbec init mytestapp
using server URL "https://10.0.0.10:6443" and default namespace "default" for the default environment
wrote mytestapp/params.libsonnet
wrote mytestapp/environments/base.libsonnet
wrote mytestapp/environments/default.libsonnet
wrote mytestapp/qbec.yaml
```

Изменим содержимое каталога **[mytestapp](./mytestapp)** в соответствии со своими задачами.  
Проверим что получилось с помощью `qbec validate`:  

```bash
wizard:mytestapp/ (main✗) $ qbec validate stage
setting cluster to kubernetes
setting context to kubernetes-admin@kubernetes
cluster metadata load took 35ms
1 components evaluated in 8ms
✔ deployments backend -n stage (source mysiteapp) is valid
✔ services backend -n stage (source mysiteapp) is valid
---
stats:
  valid: 2

command took 190ms

wizard:mytestapp/ (main✗) $ qbec validate prod
setting cluster to kubernetes
setting context to kubernetes-admin@kubernetes
cluster metadata load took 31ms
2 components evaluated in 5ms
✔ endpoints backend -n prod (source endpoint) is valid
✔ deployments backend -n prod (source mysiteapp) is valid
✔ services backend -n prod (source mysiteapp) is valid
---
stats:
  valid: 3

command took 170ms
```

Попробуем всё задеплоить и посмотреть, что получится:

```bash
wizard:mytestapp/ (main✗) $ k create namespace stage
namespace/stage created

wizard:mytestapp/ (main✗) $ k create namespace prod
namespace/prod created


wizard:mytestapp/ (main✗) $ qbec apply stage
setting cluster to kubernetes
setting context to kubernetes-admin@kubernetes
cluster metadata load took 39ms
1 components evaluated in 4ms

will synchronize 2 object(s)

Do you want to continue [y/n]: y
1 components evaluated in 5ms
create deployments backend -n stage (source mysiteapp)
create services backend -n stage (source mysiteapp)
waiting for deletion list to be returned
server objects load took 605ms
---
stats:
  created:
  - deployments backend -n stage (source mysiteapp)
  - services backend -n stage (source mysiteapp)

waiting for readiness of 1 objects
  - deployments backend -n stage

  0s    : deployments backend -n stage :: 0 of 1 updated replicas are available
✓ 7s    : deployments backend -n stage :: successfully rolled out (0 remaining)

✓ 7s: rollout complete
command took 9.24s


wizard:mytestapp/ (main✗) $ qbec apply prod
setting cluster to kubernetes
setting context to kubernetes-admin@kubernetes
cluster metadata load took 26ms
2 components evaluated in 4ms

will synchronize 3 object(s)

Do you want to continue [y/n]: y
2 components evaluated in 6ms
create endpoints backend -n prod (source endpoint)
create deployments backend -n prod (source mysiteapp)
create services backend -n prod (source mysiteapp)
server objects load took 805ms
---
stats:
  created:
  - endpoints backend -n prod (source endpoint)
  - deployments backend -n prod (source mysiteapp)
  - services backend -n prod (source mysiteapp)

waiting for readiness of 1 objects
  - deployments backend -n prod

  0s    : deployments backend -n prod :: 0 of 3 updated replicas are available
  5s    : deployments backend -n prod :: 1 of 3 updated replicas are available
  9s    : deployments backend -n prod :: 2 of 3 updated replicas are available
✓ 11s   : deployments backend -n prod :: successfully rolled out (0 remaining)

✓ 11s: rollout complete
command took 13.96s

wizard:mytestapp/ (main✗) $ kg po,service,endpoints -n stage -o wide
NAME                           READY   STATUS    RESTARTS   AGE     IP               NODE            NOMINATED NODE   READINESS GATES
pod/backend-7f655b767b-tml58   1/1     Running   0          3m21s   192.168.158.15   worker-node02   <none>           <none>

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/backend   ClusterIP   10.104.79.190   <none>        80/TCP    3m21s   app=backend

NAME                ENDPOINTS           AGE
endpoints/backend   192.168.158.15:80   3m21s


wizard:mytestapp/ (main✗) $ kg po,service,endpoints -n prod -o wide
NAME                           READY   STATUS    RESTARTS   AGE     IP               NODE            NOMINATED NODE   READINESS GATES
pod/backend-7f655b767b-2pkvd   1/1     Running   0          3m18s   192.168.158.16   worker-node02   <none>           <none>
pod/backend-7f655b767b-b2v8c   1/1     Running   0          3m18s   192.168.87.203   worker-node01   <none>           <none>
pod/backend-7f655b767b-hkfg6   1/1     Running   0          3m18s   192.168.87.202   worker-node01   <none>           <none>

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/backend   ClusterIP   10.101.74.147   <none>        80/TCP    3m17s   app=backend

NAME                ENDPOINTS                                               AGE
endpoints/backend   192.168.158.16:80,192.168.87.202:80,192.168.87.203:80   3m18s

```

Endpoint при деплое в `prod` был создан первым и был перекрыт `endpoint`-ами `deploymenta`, попробуем еще раз:

```bash
wizard:mytestapp/ (main✗) $ qbec apply prod
setting cluster to kubernetes
setting context to kubernetes-admin@kubernetes
cluster metadata load took 28ms
2 components evaluated in 5ms

will synchronize 3 object(s)

Do you want to continue [y/n]: y
2 components evaluated in 5ms
update endpoints backend -n prod (source endpoint)
server objects load took 405ms
---
stats:
  same: 2
  updated:
  - endpoints backend -n prod (source endpoint)

waiting for readiness of 1 objects
  - deployments backend -n prod

✓ 0s    : deployments backend -n prod :: successfully rolled out (0 remaining)

✓ 0s: rollout complete
command took 7s


wizard:mytestapp/ (main✗) $ kg po,service,endpoints -n prod -o wide
NAME                           READY   STATUS    RESTARTS   AGE     IP               NODE            NOMINATED NODE   READINESS GATES
pod/backend-7f655b767b-2pkvd   1/1     Running   0          4m36s   192.168.158.16   worker-node02   <none>           <none>
pod/backend-7f655b767b-b2v8c   1/1     Running   0          4m36s   192.168.87.203   worker-node01   <none>           <none>
pod/backend-7f655b767b-hkfg6   1/1     Running   0          4m36s   192.168.87.202   worker-node01   <none>           <none>

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/backend   ClusterIP   10.101.74.147   <none>        80/TCP    4m35s   app=backend

NAME                ENDPOINTS           AGE
endpoints/backend   87.250.250.242:80   4m36s
```

Приберемся за собой:

```bash
wizard:mytestapp/ (main✗) $ qbec delete stage
setting cluster to kubernetes
setting context to kubernetes-admin@kubernetes
cluster metadata load took 30ms
1 components evaluated in 5ms
waiting for deletion list to be returned
server objects load took 205ms

will delete 2 object(s)

Do you want to continue [y/n]: y
delete services backend -n stage
delete deployments backend -n stage
---
stats:
  deleted:
  - services backend -n stage
  - deployments backend -n stage

command took 1.8s


wizard:mytestapp/ (main✗) $ qbec delete prod
setting cluster to kubernetes
setting context to kubernetes-admin@kubernetes
cluster metadata load took 31ms
2 components evaluated in 4ms
waiting for deletion list to be returned
server objects load took 206ms

will delete 2 object(s)

Do you want to continue [y/n]: y
delete services backend -n prod
delete deployments backend -n prod
---
stats:
  deleted:
  - services backend -n prod
  - deployments backend -n prod

command took 1.35s

wizard:mytestapp/ (main✗) $ kg po,service,endpoints -n prod -o wide
No resources found in prod namespace.

wizard:mytestapp/ (main✗) $ kg po,service,endpoints -n stage -o wide
No resources found in stage namespace.

wizard:mytestapp/ (main✗) $ k delete ns stage prod
namespace "stage" deleted
namespace "prod" deleted

```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
