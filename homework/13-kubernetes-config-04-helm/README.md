# Домашняя работа к занятию "13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet"

В работе часто приходится применять системы автоматической генерации конфигураций. Для изучения нюансов использования разных инструментов нужно попробовать упаковать приложение каждым из них.

## Задание 1: подготовить helm чарт для приложения

Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:

* каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;
* в переменных чарта измените образ приложения для изменения версии.

**ОТВЕТ:** Создадим чарт **[mytestapp](./mytestapp)** и проверим с помощью lint:

```bash
wizard:13-kubernetes-config-04-helm/ (main?) $ helm lint ./mytestapp 
==> Linting ./mytestapp
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

## Задание 2: запустить 2 версии в разных неймспейсах

Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:

* одну версию в namespace=app1;
* вторую версию в том же неймспейсе;
* третью версию в namespace=app2.

**ОТВЕТ:** Версию менять будем в `Chart.yaml - appVersion` перед каждой установкой. Устанавливать будем с флагом `--create-namespace` чтобы не создавать неймспейсы в ручную. Номер версии будем проверять в имени пода.

```bash
wizard:13-kubernetes-config-04-helm/ (main?) $ helm install mytestapp ./mytestapp --create-namespace -n app1
NAME: mytestapp
LAST DEPLOYED: Wed Feb  9 14:46:37 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app1 -l "app.kubernetes.io/name=mytestapp,app.kubernetes.io/instance=mytestapp" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app1 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app1 port-forward $POD_NAME 8080:$CONTAINER_PORT


wizard:13-kubernetes-config-04-helm/ (main?) $ kg po -n app1
NAME                                READY   STATUS    RESTARTS   AGE
mytestapp-1.16.0-789f96c98f-5bg5v   1/1     Running   0          6s


wizard:13-kubernetes-config-04-helm/ (main?) $ helm upgrade mytestapp ./mytestapp --create-namespace -n app1
Release "mytestapp" has been upgraded. Happy Helming!
NAME: mytestapp
LAST DEPLOYED: Wed Feb  9 14:49:11 2022
NAMESPACE: app1
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app1 -l "app.kubernetes.io/name=mytestapp,app.kubernetes.io/instance=mytestapp" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app1 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app1 port-forward $POD_NAME 8080:$CONTAINER_PORT


wizard:13-kubernetes-config-04-helm/ (main?) $ kg po -n app1
NAME                               READY   STATUS    RESTARTS   AGE
mytestapp-1.20.0-f5dd94cc6-mr8kl   1/1     Running   0          52s


wizard:13-kubernetes-config-04-helm/ (main?) $ helm install mytestapp ./mytestapp --create-namespace -n app2
NAME: mytestapp
LAST DEPLOYED: Wed Feb  9 14:54:23 2022
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app2 -l "app.kubernetes.io/name=mytestapp,app.kubernetes.io/instance=mytestapp" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app2 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app2 port-forward $POD_NAME 8080:$CONTAINER_PORT


wizard:13-kubernetes-config-04-helm/ (main?) $ kg po -n app2
NAME                                READY   STATUS             RESTARTS   AGE
mytestapp-1.30.0-868df45589-2tvjc   1/1     Running   0          22s

```

## Задание 3 (*): повторить упаковку на jsonnet

Для изучения другого инструмента стоит попробовать повторить опыт упаковки из задания 1, только теперь с помощью инструмента jsonnet.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
