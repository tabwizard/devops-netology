# Домашняя работа к занятию "14.4 Сервис-аккаунты"

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

**Как создать сервис-аккаунт?**

```bash
kubectl create serviceaccount netology
```

**Как просмотреть список сервис-акаунтов?**

```bash
kubectl get serviceaccounts
kubectl get serviceaccount
```

**Как получить информацию в формате YAML и/или JSON?**

```bash
kubectl get serviceaccount netology -o yaml
kubectl get serviceaccount default -o json
```

**Как выгрузить сервис-акаунты и сохранить его в файл?**

```bash
kubectl get serviceaccounts -o json > serviceaccounts.json
kubectl get serviceaccount netology -o yaml > netology.yml
```

**Как удалить сервис-акаунт?**

```bash
kubectl delete serviceaccount netology
```

**Как загрузить сервис-акаунт из файла?**

```bash
kubectl apply -f netology.yml
```

**ОТВЕТ:**  
Создаем сервис-аккаунт:

```bash
wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl create serviceaccount netology
serviceaccount/netology created
```

Смотрим список сервис-акаунтов:

```bash
wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl get serviceaccounts
NAME       SECRETS   AGE
default    1         10d
netology   1         57s

wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl get serviceaccount
NAME       SECRETS   AGE
default    1         10d
netology   1         59s
```

Получаем информацию в формате YAML и/или JSON:

```bash
wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl get serviceaccount netology -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-03-23T02:03:14Z"
  name: netology
  namespace: default
  resourceVersion: "218371"
  uid: b27f3ed9-2985-4cba-8303-e6e7601b55cb
secrets:
- name: netology-token-rlrzk

wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl get serviceaccount default -o json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2022-03-12T03:52:35Z",
        "name": "default",
        "namespace": "default",
        "resourceVersion": "134871",
        "uid": "a0531384-4f28-41f4-8510-290d8c8db88b"
    },
    "secrets": [
        {
            "name": "default-token-q9xr7"
        }
    ]
}
```

Выгружаем сервис-акаунты и сохраняем его в файл:

```bash
wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl get serviceaccounts -o json > serviceaccounts.json

wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ cat serviceaccounts.json
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "kind": "ServiceAccount",
            "metadata": {
                "creationTimestamp": "2022-03-12T03:52:35Z",
                "name": "default",
                "namespace": "default",
                "resourceVersion": "134871",
                "uid": "a0531384-4f28-41f4-8510-290d8c8db88b"
            },
            "secrets": [
                {
                    "name": "default-token-q9xr7"
                }
            ]
        },
        {
            "apiVersion": "v1",
            "kind": "ServiceAccount",
            "metadata": {
                "creationTimestamp": "2022-03-23T02:03:14Z",
                "name": "netology",
                "namespace": "default",
                "resourceVersion": "218371",
                "uid": "b27f3ed9-2985-4cba-8303-e6e7601b55cb"
            },
            "secrets": [
                {
                    "name": "netology-token-rlrzk"
                }
            ]
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}

wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl get serviceaccount netology -o yaml > netology.yml

wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ cat netology.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-03-23T02:03:14Z"
  name: netology
  namespace: default
  resourceVersion: "218371"
  uid: b27f3ed9-2985-4cba-8303-e6e7601b55cb
secrets:
- name: netology-token-rlrzk

```

Удаляем сервис-акаунт:

```bash
wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl delete serviceaccount netology
serviceaccount "netology" deleted

wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl get serviceaccount
NAME      SECRETS   AGE
default   1         10d
```

Загружаем сервис-акаунт из файла:

```bash
wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl apply -f netology.yml
serviceaccount/netology created

wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl get serviceaccount
NAME       SECRETS   AGE
default    1         10d
netology   2         2s

```

## Задача 2 (*): Работа с сервис-акаунтами внутри модуля

Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить
доступность API Kubernetes

```bash
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Просмотреть переменные среды

```bash
env | grep KUBE
```

Получить значения переменных

```bash
K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
SADIR=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat $SADIR/token)
CACERT=$SADIR/ca.crt
NAMESPACE=$(cat $SADIR/namespace)
```

Подключаемся к API

```bash
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
```

В случае с minikube может быть другой адрес и порт, который можно взять здесь

```bash
cat ~/.kube/config
```

или здесь

```bash
kubectl cluster-info
```

**ОТВЕТ:**  
Запускаем образ контейнера, смотрим переменные среды:

```bash
wizard:14-kubernetes-net-sec-04-service-accounts/ (main✗) $ kubectl run -i --tty fedora --image=fedora --serviceaccount=netology --restart=Never -- sh
Flag --serviceaccount has been deprecated, has no effect and will be removed in 1.24.
If you don't see a command prompt, try pressing enter.

sh-5.1# env | grep KUBE
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
```

Получаем значения переменных:

```bash
sh-5.1# K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT

sh-5.1# SADIR=/var/run/secrets/kubernetes.io/serviceaccount

sh-5.1# TOKEN=$(cat $SADIR/token)

sh-5.1# CACERT=$SADIR/ca.crt

sh-5.1# NAMESPACE=$(cat $SADIR/namespace)


sh-5.1# echo $K8S
https://10.96.0.1:443

sh-5.1# echo $SADIR
/var/run/secrets/kubernetes.io/serviceaccount

sh-5.1# echo $TOKEN
eyJhbGciOiJSUzI1NiIsImtpZCI6ImJaRWhQOHRlWTg2OENsdFVNTnpaQTZBZGFKR3U4OHJIdGx1RG5JUG1Nb2cifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjc5NTM3OTEzLCJpYXQiOjE2NDgwMDE5MTMsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0IiwicG9kIjp7Im5hbWUiOiJmZWRvcmEiLCJ1aWQiOiI0MzYxMTI4Zi04OGM2LTRiNjUtODVkOC1kZTViZTAxMTA0NmYifSwic2VydmljZWFjY291bnQiOnsibmFtZSI6ImRlZmF1bHQiLCJ1aWQiOiJhMDUzMTM4NC00ZjI4LTQxZjQtODUxMC0yOTBkOGM4ZGI4OGIifSwid2FybmFmdGVyIjoxNjQ4MDA1NTIwfSwibmJmIjoxNjQ4MDAxOTEzLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpkZWZhdWx0In0.t5-gmzETSnUYCH573K5FTKMHiq_fQPXan4f6DKtj1Ai233ZUAn1ZxluL905Kk26K0AkqHt2WD89wH0yGaj24uO-930LtxDZfBHZsCEgZ2xaJQj9pKFMPp8yOZGnkfKpLqjeUMc70SvVArY3IpChAlzN0niam8XUU1lPqRMe7lBJWVE3bhiA8ZLz9DeyVN7QaMmGOV1FQl-p3tA-3BfxTYiBZCo61SiX6MkWvrrS3tlPdKnf3yL6Nn4pUsg4CQ6h1mvBuyxEwphOy_I7JgpbP6JWwQjl18wbYtbXQOrQlurP8I5VQfqA1QFymsLPY1O6qQKh-z2ds4ySTkovk_KB0LQ

sh-5.1# echo $CACERT
/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

sh-5.1# echo $NAMESPACE
default
```

Подключаемся к API:
<details>
  <summary>Нажмите чтобы раскрыть</summary>

```bash
sh-5.1# curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "componentstatuses",
      "singularName": "",
      "namespaced": false,
      "kind": "ComponentStatus",
      "verbs": [
        "get",
        "list"
      ],
      "shortNames": [
        "cs"
      ]
    },
    {
      "name": "configmaps",
      "singularName": "",
      "namespaced": true,
      "kind": "ConfigMap",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "cm"
      ],
      "storageVersionHash": "qFsyl6wFWjQ="
    },
    {
      "name": "endpoints",
      "singularName": "",
      "namespaced": true,
      "kind": "Endpoints",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "ep"
      ],
      "storageVersionHash": "fWeeMqaN/OA="
    },
    {
      "name": "events",
      "singularName": "",
      "namespaced": true,
      "kind": "Event",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "ev"
      ],
      "storageVersionHash": "r2yiGXH7wu8="
    },
    {
      "name": "limitranges",
      "singularName": "",
      "namespaced": true,
      "kind": "LimitRange",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "limits"
      ],
      "storageVersionHash": "EBKMFVe6cwo="
    },
    {
      "name": "namespaces",
      "singularName": "",
      "namespaced": false,
      "kind": "Namespace",
      "verbs": [
        "create",
        "delete",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "ns"
      ],
      "storageVersionHash": "Q3oi5N2YM8M="
    },
    {
      "name": "namespaces/finalize",
      "singularName": "",
      "namespaced": false,
      "kind": "Namespace",
      "verbs": [
        "update"
      ]
    },
    {
      "name": "namespaces/status",
      "singularName": "",
      "namespaced": false,
      "kind": "Namespace",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "nodes",
      "singularName": "",
      "namespaced": false,
      "kind": "Node",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "no"
      ],
      "storageVersionHash": "XwShjMxG9Fs="
    },
    {
      "name": "nodes/proxy",
      "singularName": "",
      "namespaced": false,
      "kind": "NodeProxyOptions",
      "verbs": [
        "create",
        "delete",
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "nodes/status",
      "singularName": "",
      "namespaced": false,
      "kind": "Node",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "persistentvolumeclaims",
      "singularName": "",
      "namespaced": true,
      "kind": "PersistentVolumeClaim",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "pvc"
      ],
      "storageVersionHash": "QWTyNDq0dC4="
    },
    {
      "name": "persistentvolumeclaims/status",
      "singularName": "",
      "namespaced": true,
      "kind": "PersistentVolumeClaim",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "persistentvolumes",
      "singularName": "",
      "namespaced": false,
      "kind": "PersistentVolume",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "pv"
      ],
      "storageVersionHash": "HN/zwEC+JgM="
    },
    {
      "name": "persistentvolumes/status",
      "singularName": "",
      "namespaced": false,
      "kind": "PersistentVolume",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "pods",
      "singularName": "",
      "namespaced": true,
      "kind": "Pod",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "po"
      ],
      "categories": [
        "all"
      ],
      "storageVersionHash": "xPOwRZ+Yhw8="
    },
    {
      "name": "pods/attach",
      "singularName": "",
      "namespaced": true,
      "kind": "PodAttachOptions",
      "verbs": [
        "create",
        "get"
      ]
    },
    {
      "name": "pods/binding",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "pods/ephemeralcontainers",
      "singularName": "",
      "namespaced": true,
      "kind": "Pod",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "pods/eviction",
      "singularName": "",
      "namespaced": true,
      "group": "policy",
      "version": "v1",
      "kind": "Eviction",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "pods/exec",
      "singularName": "",
      "namespaced": true,
      "kind": "PodExecOptions",
      "verbs": [
        "create",
        "get"
      ]
    },
    {
      "name": "pods/log",
      "singularName": "",
      "namespaced": true,
      "kind": "Pod",
      "verbs": [
        "get"
      ]
    },
    {
      "name": "pods/portforward",
      "singularName": "",
      "namespaced": true,
      "kind": "PodPortForwardOptions",
      "verbs": [
        "create",
        "get"
      ]
    },
    {
      "name": "pods/proxy",
      "singularName": "",
      "namespaced": true,
      "kind": "PodProxyOptions",
      "verbs": [
        "create",
        "delete",
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "pods/status",
      "singularName": "",
      "namespaced": true,
      "kind": "Pod",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "podtemplates",
      "singularName": "",
      "namespaced": true,
      "kind": "PodTemplate",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "storageVersionHash": "LIXB2x4IFpk="
    },
    {
      "name": "replicationcontrollers",
      "singularName": "",
      "namespaced": true,
      "kind": "ReplicationController",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "rc"
      ],
      "categories": [
        "all"
      ],
      "storageVersionHash": "Jond2If31h0="
    },
    {
      "name": "replicationcontrollers/scale",
      "singularName": "",
      "namespaced": true,
      "group": "autoscaling",
      "version": "v1",
      "kind": "Scale",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "replicationcontrollers/status",
      "singularName": "",
      "namespaced": true,
      "kind": "ReplicationController",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "resourcequotas",
      "singularName": "",
      "namespaced": true,
      "kind": "ResourceQuota",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "quota"
      ],
      "storageVersionHash": "8uhSgffRX6w="
    },
    {
      "name": "resourcequotas/status",
      "singularName": "",
      "namespaced": true,
      "kind": "ResourceQuota",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "secrets",
      "singularName": "",
      "namespaced": true,
      "kind": "Secret",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "storageVersionHash": "S6u1pOWzb84="
    },
    {
      "name": "serviceaccounts",
      "singularName": "",
      "namespaced": true,
      "kind": "ServiceAccount",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "sa"
      ],
      "storageVersionHash": "pbx9ZvyFpBE="
    },
    {
      "name": "serviceaccounts/token",
      "singularName": "",
      "namespaced": true,
      "group": "authentication.k8s.io",
      "version": "v1",
      "kind": "TokenRequest",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "services",
      "singularName": "",
      "namespaced": true,
      "kind": "Service",
      "verbs": [
        "create",
        "delete",
        "deletecollection",
        "get",
        "list",
        "patch",
        "update",
        "watch"
      ],
      "shortNames": [
        "svc"
      ],
      "categories": [
        "all"
      ],
      "storageVersionHash": "0/CO1lhkEBI="
    },
    {
      "name": "services/proxy",
      "singularName": "",
      "namespaced": true,
      "kind": "ServiceProxyOptions",
      "verbs": [
        "create",
        "delete",
        "get",
        "patch",
        "update"
      ]
    },
    {
      "name": "services/status",
      "singularName": "",
      "namespaced": true,
      "kind": "Service",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    }
  ]
}
```
</details>

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, serviceaccounts) или скриншот из самого Kubernetes, что сервисы подняты и работают, а также вывод из CLI.

---
