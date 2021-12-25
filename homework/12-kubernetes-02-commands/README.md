# Домашняя работа к занятию "12.2 Команды для работы с Kubernetes"

Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте

Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2).

Требования:

* пример из hello world запущен в качестве deployment
* количество реплик в deployment установлено в 2
* наличие deployment можно проверить командой kubectl get deployment
* наличие подов можно проверить командой kubectl get pods  

**ОТВЕТ:**  

```bash
wizard:~/ $ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas=2
deployment.apps/hello-node created

wizard:~/ $ kubectl get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           22s

wizard:~/ $ kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-cjbpt   1/1     Running   0          37s
hello-node-7567d9fdc9-dwlw8   1/1     Running   0          37s
```

## Задание 2: Просмотр логов для разработки

Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе.
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования:

* создан новый токен доступа для пользователя
* пользователь прописан в локальный конфиг (~/.kube/config, блок users)
* пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

**ОТВЕТ:**

* Создаем неймспейс `app-namespace`

    ```bash
    wizard:~/ $ kubectl create namespace app-namespace
    namespace/app-namespace created
    ```

* Создаем пользователя (serviceaccount) `testuser` внутри minikube в неймспейсе `app-namespace`

    ```bash
    wizard:~/ $ kubectl -n app-namespace create serviceaccount testuser
    wizard:serviceaccount/testuser created
    ```

* Задаем контекст для пользователя

    ```bash
    wizard:~/ $ kubectl config set-context testuser --cluster=minikube --user=testuser
    ```

* Получаем название секрета созданного пользователя
  
    ```bash
    wizard:~/ $ kubectl -n app-namespace get serviceaccounts testuser -o jsonpath='{.secrets[].name}'
    testuser-token-pm2cc
    ```

* Получаем токен созданного пользователя из секрета

    ```bash
    wizard:~/ $ kubectl -n app-namespace get secret testuser-token-pm2cc -o jsonpath='{.data.token}' | base64 --decode
    eyJhbGciOiJSUzI1NiIsImtpZCI6Ikx1engwRDg0Ul8yZ2ZHNTZDYTZqX1lWNEpaV3pqSm1BV0RienppSVB4VVkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHAtbmFtZXNwYWNlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRlc3R1c2VyLXRva2VuLXBtMmNjIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRlc3R1c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNmM1ZDAyODEtYzhmNS00Yzk5LThkYmMtMWMzYjcwODI4ODQ2Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmFwcC1uYW1lc3BhY2U6dGVzdHVzZXIifQ.lWCJK2duaKNUFeVbojYi7haPjKtHiHd6HcjQkHD4Ju6rfd67fJW-sS4b1XNZ3jdoHVl2PA6YDcWLls34ET_nJCv0fV2xvigwSf1l_Cw7ireiNFSL3w4HIq_X2R0EuQm5ozFfe6H9e-KxvL1iu0XMsxmy9QBFOJnhvoGSBhfclEg4sBQjlITEA4irVDAM2RlzEbsath8JCGQW6cvMX9zMEUojDaGmulpzlpu6wKW-BETcFx23CQIao9bpVOGnxmMEzsGdH6DbMf9fkFcQyslpH9d9XZ0G77mI8T8jwQPFhW6yxZDT4hh04IGgmixDtB1OPZP4ktue9VawaPstxm3S8g
    ```

* Создаем роль для пользователя `kubectl create -f ./role_testuser.yml` из файла следующего содержания:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
    name: role-testuser
    namespace: app-namespace
    rules:
    - apiGroups: [""]
        resources: ["pods"]
        verbs: ["get", "describe"]
    - apiGroups: [""]
        resources: ["pods/log"]
        verbs: ["get"]
    ```

* Привязываем роль к пользователю `kubectl apply -f ./roleBinding_testuser.yml`

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
    name: role-testuser
    namespace: app-namespace
    subjects:
    - kind: User
    name: testuser
    apiGroup: rbac.authorization.k8s.io
    roleRef:
    kind: Role
    name: role-testuser
    apiGroup: rbac.authorization.k8s.io 
    ```

* Создаем пользователя в системе

    ```bash
    root:/home/ # useradd testuser -m
    ```

* Создаем конфиг для пользователя с использованием полученного токена, в файл `/home/testuser/.kube/config`

    ```yaml
    apiVersion: v1
    clusters:
    - cluster:
        insecure-skip-tls-verify: true
        server: https://192.168.178.25:8443
    name: minicube
    contexts:
    - context:
        cluster: minicube
        namespace: app-namespace
        user: testuser
    name: testuser
    current-context: testuser
    kind: Config
    preferences: {}
    users:
    - name: testuser
    user:
        token: eyJhbGciOiJSUzI1NiIsImtpZCI6Ikx1engwRDg0Ul8yZ2ZHNTZDYTZqX1lWNEpaV3pqSm1BV0RienppSVB4VVkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHAtbmFtZXNwYWNlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRlc3R1c2VyLXRva2VuLXBtMmNjIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRlc3R1c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNmM1ZDAyODEtYzhmNS00Yzk5LThkYmMtMWMzYjcwODI4ODQ2Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmFwcC1uYW1lc3BhY2U6dGVzdHVzZXIifQ.lWCJK2duaKNUFeVbojYi7haPjKtHiHd6HcjQkHD4Ju6rfd67fJW-sS4b1XNZ3jdoHVl2PA6YDcWLls34ET_nJCv0fV2xvigwSf1l_Cw7ireiNFSL3w4HIq_X2R0EuQm5ozFfe6H9e-KxvL1iu0XMsxmy9QBFOJnhvoGSBhfclEg4sBQjlITEA4irVDAM2RlzEbsath8JCGQW6cvMX9zMEUojDaGmulpzlpu6wKW-BETcFx23CQIao9bpVOGnxmMEzsGdH6DbMf9fkFcQyslpH9d9XZ0G77mI8T8jwQPFhW6yxZDT4hh04IGgmixDtB1OPZP4ktue9VawaPstxm3S8g

    ```

    ##### Проверяем пользователя

    ```bash
    wizard:~/ $ su testuser
    Пароль: 

    [testuser@wizard-pc ~]$ kubectl get po -A
    Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:app-namespace:testuser" cannot list resource "pods" in API group "" at the cluster scope

    [testuser@wizard-pc ~]$ kubectl get po
    Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:app-namespace:testuser" cannot list resource "pods" in API group "" in the namespace "app-namespace"

    [testuser@wizard-pc ~]$ kubectl get po hello-node-7567d9fdc9-qw9f6
    NAME                          READY   STATUS    RESTARTS   AGE
    hello-node-7567d9fdc9-qw9f6   1/1     Running   0          65m

    [testuser@wizard-pc ~]$ kubectl describe po hello-node-7567d9fdc9-qw9f6
    Name:         hello-node-7567d9fdc9-qw9f6
    Namespace:    app-namespace
    Priority:     0
    Node:         wizard-pc/192.168.178.25
    Start Time:   Fri, 24 Dec 2021 21:32:28 +0700
    Labels:       app=hello-node
                pod-template-hash=7567d9fdc9
    Annotations:  <none>
    Status:       Running
    IP:           172.17.0.3
    IPs:
    IP:           172.17.0.3
    Controlled By:  ReplicaSet/hello-node-7567d9fdc9
    Containers:
    echoserver:
        Container ID:   docker://ba3a05e8918ccc63323499d93cdef97db2af9b2849c1975b3f27bb1918d7a1a5
        Image:          k8s.gcr.io/echoserver:1.4
        Image ID:       docker-pullable://k8s.gcr.io/echoserver@sha256:5d99aa1120524c801bc8c1a7077e8f5ec122ba16b6dda1a5d3826057f67b9bcb
        Port:           <none>
        Host Port:      <none>
        State:          Running
        Started:      Fri, 24 Dec 2021 21:32:29 +0700
        Ready:          True
        Restart Count:  0
        Environment:    <none>
        Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9t2m4 (ro)
    Conditions:
    Type              Status
    Initialized       True 
    Ready             True 
    ContainersReady   True 
    PodScheduled      True 
    Volumes:
    kube-api-access-9t2m4:
        Type:                    Projected (a volume that contains injected data from multiple sources)
        TokenExpirationSeconds:  3607
        ConfigMapName:           kube-root-ca.crt
        ConfigMapOptional:       <nil>
        DownwardAPI:             true
    QoS Class:                   BestEffort
    Node-Selectors:              <none>
    Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                                node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
    Events:                      <none>
    [testuser@wizard-pc ~]$ kubectl logs hello-node-7567d9fdc9-qw9f6
    [testuser@wizard-pc ~]$ 
    ```

## Задание 3: Изменение количества реплик

Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик.

Требования:

* в deployment из задания 1 изменено количество реплик на 5
* проверить что все поды перешли в статус running (kubectl get pods)  

**ОТВЕТ:**  

```bash
wizard:~/ $ kubectl scale --replicas=5 deployment/hello-node
deployment.apps/hello-node scaled

wizard:~/ $ kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-8vq4c   1/1     Running   0          20s
hello-node-7567d9fdc9-cjbpt   1/1     Running   0          5m2s
hello-node-7567d9fdc9-dwlw8   1/1     Running   0          5m2s
hello-node-7567d9fdc9-h99gk   1/1     Running   0          20s
hello-node-7567d9fdc9-j78kq   1/1     Running   0          20s
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
