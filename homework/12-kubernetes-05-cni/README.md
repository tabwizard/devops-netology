# Домашняя работа к занятию "12.5 Сетевые решения CNI"

После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.

## Задание 1: установить в кластер CNI плагин Calico

Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования:

* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

**ОТВЕТ:** Воспользуемся наработками предыдущего урока и установим кластер на AWS через kubespray. В kubespray по-умолчанию установлен CNI плагин Calico (в файле `mycluster/group_vars/k8s_cluster/k8s-kluster.yml` параметр `kube_network_plugin: calico`).  
Скопируем конфиг для доступа к ластеру с Control plane на локальную машину, заменим адрес сервера. Проверим:  

```bash
wizard:.kube/ $ kubectl get node -o wide
NAME    STATUS   ROLES                  AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
cp      Ready    control-plane,master   29m   v1.23.1   10.0.101.199   <none>        Ubuntu 20.04.3 LTS   5.11.0-1025-aws   containerd://1.5.9
node1   Ready    <none>                 24m   v1.23.1   10.0.101.12    <none>        Ubuntu 20.04.3 LTS   5.11.0-1025-aws   containerd://1.5.9
```

Запустим тестовый под из файла [echoserver_deployment.yml](./echoserver_deployment.yml) и под для проверки [multitool_deployment.yml](./multitool_deployment.yml).  
Проверим, что тестовый под пингуется и отвечает по порту 8080.

```bash
wizard:12-kubernetes-05-cni/ (main✗) $ kubectl apply -f ./echoserver_deployment.yml -f ./multitool_deployment.yml
deployment.apps/echoserver-deployment created
deployment.apps/multitool-deployment created


wizard:12-kubernetes-05-cni/ (main✗) $ kubectl get pods -o wide
NAME                                     READY   STATUS    RESTARTS   AGE     IP            NODE    NOMINATED NODE   READINESS GATES
echoserver-deployment-69db45c5c7-7s789   1/1     Running   0          3m22s   10.233.90.2   node1   <none>           <none>
multitool-deployment-64c67d498c-ngxxd    1/1     Running   0          3m22s   10.233.90.3   node1   <none>           <none>

wizard:12-kubernetes-05-cni/ (main✗) $ kubectl exec -it multitool-deployment-64c67d498c-ngxxd -- /bin/bash

bash-5.1# ping 10.233.90.2
PING 10.233.90.2 (10.233.90.2) 56(84) bytes of data.
64 bytes from 10.233.90.2: icmp_seq=1 ttl=63 time=0.094 ms
64 bytes from 10.233.90.2: icmp_seq=2 ttl=63 time=0.059 ms
64 bytes from 10.233.90.2: icmp_seq=3 ttl=63 time=0.058 ms
64 bytes from 10.233.90.2: icmp_seq=4 ttl=63 time=0.065 ms
^C
--- 10.233.90.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3056ms
rtt min/avg/max/mdev = 0.058/0.069/0.094/0.014 ms

bash-5.1# curl http://10.233.90.2:8080
CLIENT VALUES:
client_address=10.233.90.3
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.233.90.2:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.233.90.2:8080
user-agent=curl/7.79.1
BODY:
-no body in request-
bash-5.1#
```

Применим сетевые политики из файла [NetworkPolicy.yml](./NetworkPolicy.yml) (разрешаем только порт 8080):

```bash
wizard:12-kubernetes-05-cni/ (main✗) $ kubectl apply -f ./NetworkPolicy.yml
networkpolicy.networking.k8s.io/test-network-policy created

wizard:12-kubernetes-05-cni/ (main✗) $ kubectl get networkpolicies
NAME                  POD-SELECTOR     AGE
test-network-policy   app=echoserver   4s

wizard:12-kubernetes-05-cni/ (main✗) $ kubectl exec -it multitool-deployment-64c67d498c-ngxxd -- /bin/bash

bash-5.1# ping 10.233.90.2
PING 10.233.90.2 (10.233.90.2) 56(84) bytes of data.
^C
--- 10.233.90.2 ping statistics ---
8 packets transmitted, 0 received, 100% packet loss, time 7150ms

bash-5.1# curl http://10.233.90.2:8080
CLIENT VALUES:
client_address=10.233.90.3
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.233.90.2:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.233.90.2:8080
user-agent=curl/7.79.1
BODY:
-no body in request-
```

Теперь удалим политику test-network-policy и применим файл [NetworkPolicy2.yml](./NetworkPolicy2.yml) с полным запретом сетевого взаимодействия

```bash
wizard:12-kubernetes-05-cni/ (main✗) $ kubectl delete networkpolicies test-network-policy
networkpolicy.networking.k8s.io "test-network-policy" deleted

wizard:12-kubernetes-05-cni/ (main✗) $ kubectl apply -f ./NetworkPolicy2.yml
networkpolicy.networking.k8s.io/default-deny-all created

wizard:12-kubernetes-05-cni/ (main✗) $ kubectl exec -it multitool-deployment-64c67d498c-hvghg -- /bin/bash

bash-5.1# curl http://10.233.90.2:8080
^C

bash-5.1# ping 10.233.90.2
PING 10.233.90.2 (10.233.90.2) 56(84) bytes of data.
^C
--- 10.233.90.2 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2083ms

```

Что и требовалось доказать - никакие пакеты не ходят.

## Задание 2: изучить, что запущено по умолчанию

Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования:

* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.

**ОТВЕТ:**  Установим на локальную машину `calicoctl`: `wizard:~/ $ sudo pacman -Syu calicoctl-bin`. Проверим список нод, ipPool и profile:

```bash
wizard:12-kubernetes-05-cni/ (main✗) $ calicoctl get node --allow-version-mismatch -o wide
NAME    ASN       IPV4              IPV6
cp      (64512)   10.0.101.199/24
node1   (64512)   10.0.101.12/24

wizard:12-kubernetes-05-cni/ (main✗) $ calicoctl get ipPool --allow-version-mismatch
NAME           CIDR             SELECTOR
default-pool   10.233.64.0/18   all()

wizard:12-kubernetes-05-cni/ (main✗) $ calicoctl get profile --allow-version-mismatch
NAME
projectcalico-default-allow
kns.default
kns.kube-node-lease
kns.kube-public
kns.kube-system
ksa.default.default
ksa.kube-node-lease.default
ksa.kube-public.default
ksa.kube-system.attachdetach-controller
ksa.kube-system.bootstrap-signer
ksa.kube-system.calico-kube-controllers
ksa.kube-system.calico-node
ksa.kube-system.certificate-controller
ksa.kube-system.clusterrole-aggregation-controller
ksa.kube-system.coredns
ksa.kube-system.cronjob-controller
ksa.kube-system.daemon-set-controller
ksa.kube-system.default
ksa.kube-system.deployment-controller
ksa.kube-system.disruption-controller
ksa.kube-system.dns-autoscaler
ksa.kube-system.endpoint-controller
ksa.kube-system.endpointslice-controller
ksa.kube-system.endpointslicemirroring-controller
ksa.kube-system.ephemeral-volume-controller
ksa.kube-system.expand-controller
ksa.kube-system.generic-garbage-collector
ksa.kube-system.horizontal-pod-autoscaler
ksa.kube-system.job-controller
ksa.kube-system.kube-proxy
ksa.kube-system.namespace-controller
ksa.kube-system.node-controller
ksa.kube-system.nodelocaldns
ksa.kube-system.persistent-volume-binder
ksa.kube-system.pod-garbage-collector
ksa.kube-system.pv-protection-controller
ksa.kube-system.pvc-protection-controller
ksa.kube-system.replicaset-controller
ksa.kube-system.replication-controller
ksa.kube-system.resourcequota-controller
ksa.kube-system.root-ca-cert-publisher
ksa.kube-system.service-account-controller
ksa.kube-system.service-controller
ksa.kube-system.statefulset-controller
ksa.kube-system.token-cleaner
ksa.kube-system.ttl-after-finished-controller
ksa.kube-system.ttl-controller
```

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
