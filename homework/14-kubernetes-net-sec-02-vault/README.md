# Домашняя работа к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

## Задача 1: Работа с модулем Vault

Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube

```bash
kubectl apply -f 14.2/vault-pod.yml
```

Получить значение внутреннего IP пода

```bash
kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
```

Примечание: jq - утилита для работы с JSON в командной строке

Запустить второй модуль для использования в качестве клиента

```bash
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Установить дополнительные пакеты

```bash
dnf -y install pip
pip install hvac
```

Запустить интепретатор Python и выполнить следующий код, предварительно
поменяв IP и токен

```python
import hvac
client = hvac.Client(
    url='http://10.10.133.71:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

**ОТВЕТ:**  
Сгенерируем свой токен:  

```bash
wizard:14-kubernetes-net-sec-02-vault/ (main✗) $ openssl rand -base64 12
CkXFg+wY7phUK5NH
```

и запишем его в **[vault-pod.yml](./vault-pod.yml)**:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: 14.2-netology-vault
spec:
  containers:
  - name: vault
    image: vault
    ports:
    - containerPort: 8200
      protocol: TCP
    env:
    - name: VAULT_DEV_ROOT_TOKEN_ID
      value: "CkXFg+wY7phUK5NH"
    - name: VAULT_DEV_LISTEN_ADDRESS
      value: 0.0.0.0:8200
```  

Запустим под и получим его внутренний IP-адрес:  

```bash
wizard:14-kubernetes-net-sec-02-vault/ (main✗) $ kubectl apply -f vault-pod.yml
pod/14.2-netology-vault created

wizard:14-kubernetes-net-sec-02-vault/ (main✗) $ kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
[{"ip":"172.17.0.3"}]

```

Запустим второй модуль и установим дополнительные пакеты:  

```bash
wizard:14-kubernetes-net-sec-02-vault/ (main✗) $ kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
If you don't see a command prompt, try pressing enter.

sh-5.1# dnf -y install pip
Fedora 35 - x86_64                                                                                                               6.1 MB/s |  79 MB     00:12
Fedora 35 openh264 (From Cisco) - x86_64                                                                                         1.9 kB/s | 2.5 kB     00:01
Fedora Modular 35 - x86_64                                                                                                       1.6 MB/s | 3.3 MB     00:02
Fedora 35 - x86_64 - Updates                                                                                                     937 kB/s |  28 MB     00:30
Fedora Modular 35 - x86_64 - Updates                                                                                             634 kB/s | 2.3 MB     00:03
Errors during downloading metadata for repository 'updates-modular':
  - Curl error (23): Failed writing received data to disk/application for http://mirror.yandex.ru/fedora/linux/updates/35/Modular/x86_64/repodata/8270597c1230c7d9992bc5adacb91714516b8362a19d5134c0eedae5d10f1542-primary.xml.zck [Failure writing output to destination]
  - Status code: 404 for http://mirror.yandex.ru/fedora/linux/updates/35/Modular/x86_64/repodata/f3b72701154f5fe754d0af444eca2a2cda271d2e46a608187d53b33ca399a885-filelists.xml.zck (IP: 213.180.204.183)
Error: Failed to download metadata for repo 'updates-modular': Yum repo downloading error: Downloading error(s): repodata/8270597c1230c7d9992bc5adacb91714516b8362a19d5134c0eedae5d10f1542-primary.xml.zck - Download failed: Curl error (23): Failed writing received data to disk/application for http://mirror.yandex.ru/fedora/linux/updates/35/Modular/x86_64/repodata/8270597c1230c7d9992bc5adacb91714516b8362a19d5134c0eedae5d10f1542-primary.xml.zck [Failure writing output to destination]

sh-5.1# dnf update
Fedora Modular 35 - x86_64 - Updates                                                                                             864 kB/s | 2.8 MB     00:03
Last metadata expiration check: 0:00:02 ago on Mon Mar 14 08:44:43 2022.
Dependencies resolved.
=================================================================================================================================================================
 Package                                                Architecture                Version                                   Repository                    Size
=================================================================================================================================================================
Upgrading:
 audit-libs                                             x86_64                      3.0.7-2.fc35                              updates                      116 k
 ca-certificates                                        noarch                      2021.2.52-1.0.fc35                        updates                      364 k
 coreutils                                              x86_64                      8.32-32.fc35                              updates                      1.1 M
 coreutils-common                                       x86_64                      8.32-32.fc35                              updates                      2.0 M
 cyrus-sasl-lib                                         x86_64                      2.1.27-14.fc35                            updates                      774 k
 . . .
 . . .
 . . .
 Installed:
  acl-2.3.1-2.fc35.x86_64                                  cryptsetup-libs-2.4.3-1.fc35.x86_64           dbus-1:1.12.22-1.fc35.x86_64
  dbus-broker-29-4.fc35.x86_64                             dbus-common-1:1.12.22-1.fc35.noarch           device-mapper-1.02.175-6.fc35.x86_64
  device-mapper-libs-1.02.175-6.fc35.x86_64                diffutils-3.8-1.fc35.x86_64                   elfutils-debuginfod-client-0.186-1.fc35.x86_64
  glibc-gconv-extra-2.34-28.fc35.x86_64                    gnupg2-smime-2.3.4-1.fc35.x86_64              iptables-legacy-libs-1.8.7-13.fc35.x86_64
  kmod-libs-29-4.fc35.x86_64                               libargon2-20171227-7.fc35.x86_64              libbpf-2:0.4.0-2.fc35.x86_64
  libfdisk-2.37.4-1.fc35.x86_64                            libibverbs-39.0-1.fc35.x86_64                 libnl3-3.5.0-8.fc35.x86_64
  libpcap-14:1.10.1-2.fc35.x86_64                          libseccomp-2.5.3-1.fc35.x86_64                libsecret-0.20.4-3.fc35.x86_64
  libusb1-1.0.24-4.fc35.x86_64                             libutempter-1.2.1-5.fc35.x86_64               libxkbcommon-1.3.1-1.fc35.x86_64
  mkpasswd-5.5.12-1.fc35.x86_64                            mozjs78-78.15.0-1.fc35.x86_64                 pcsc-lite-1.9.5-1.fc35.x86_64
  pcsc-lite-ccid-1.5.0-1.fc35.x86_64                       pcsc-lite-libs-1.9.5-1.fc35.x86_64            pinentry-1.2.0-1.fc35.x86_64
  polkit-0.120-1.fc35.2.x86_64                             polkit-libs-0.120-1.fc35.2.x86_64             polkit-pkla-compat-0.1-20.fc35.x86_64
  python-unversioned-command-3.10.2-1.fc35.noarch          qrencode-libs-4.1.1-1.fc35.x86_64             systemd-249.9-1.fc35.x86_64
  systemd-libs-249.9-1.fc35.x86_64                         systemd-networkd-249.9-1.fc35.x86_64          systemd-pam-249.9-1.fc35.x86_64
  systemd-resolved-249.9-1.fc35.x86_64                     trousers-0.3.15-4.fc35.x86_64                 trousers-lib-0.3.15-4.fc35.x86_64
  util-linux-2.37.4-1.fc35.x86_64                          util-linux-core-2.37.4-1.fc35.x86_64          vim-data-2:8.2.4529-1.fc35.noarch
  whois-nls-5.5.12-1.fc35.noarch                           xkeyboard-config-2.33-2.fc35.noarch

Complete!

sh-5.1# dnf -y install pip
Last metadata expiration check: 0:00:39 ago on Mon Mar 14 08:44:43 2022.
Dependencies resolved.
=================================================================================================================================================================
 Package                                      Architecture                     Version                                   Repository                         Size
=================================================================================================================================================================
Installing:
 python3-pip                                  noarch                           21.2.3-4.fc35                             updates                           1.8 M
Installing weak dependencies:
 libxcrypt-compat                             x86_64                           4.4.28-1.fc35                             updates                            89 k
 python3-setuptools                           noarch                           57.4.0-1.fc35                             fedora                            928 k

Transaction Summary
=================================================================================================================================================================
Install  3 Packages

Total download size: 2.8 M
Installed size: 14 M
Downloading Packages:
(1/3): libxcrypt-compat-4.4.28-1.fc35.x86_64.rpm                                                                                 239 kB/s |  89 kB     00:00
(2/3): python3-setuptools-57.4.0-1.fc35.noarch.rpm                                                                               1.4 MB/s | 928 kB     00:00
(3/3): python3-pip-21.2.3-4.fc35.noarch.rpm                                                                                      2.3 MB/s | 1.8 MB     00:00
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                            1.2 MB/s | 2.8 MB     00:02
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                         1/1
  Installing       : libxcrypt-compat-4.4.28-1.fc35.x86_64                                                                                                   1/3
  Installing       : python3-setuptools-57.4.0-1.fc35.noarch                                                                                                 2/3
  Installing       : python3-pip-21.2.3-4.fc35.noarch                                                                                                        3/3
  Running scriptlet: python3-pip-21.2.3-4.fc35.noarch                                                                                                        3/3
  Verifying        : python3-setuptools-57.4.0-1.fc35.noarch                                                                                                 1/3
  Verifying        : libxcrypt-compat-4.4.28-1.fc35.x86_64                                                                                                   2/3
  Verifying        : python3-pip-21.2.3-4.fc35.noarch                                                                                                        3/3

Installed:
  libxcrypt-compat-4.4.28-1.fc35.x86_64                 python3-pip-21.2.3-4.fc35.noarch                 python3-setuptools-57.4.0-1.fc35.noarch

Complete!

sh-5.1# pip install hvac
Collecting hvac
  Downloading hvac-0.11.2-py2.py3-none-any.whl (148 kB)
     |████████████████████████████████| 148 kB 551 kB/s
Collecting requests>=2.21.0
  Downloading requests-2.27.1-py2.py3-none-any.whl (63 kB)
     |████████████████████████████████| 63 kB 1.5 MB/s
Collecting six>=1.5.0
  Downloading six-1.16.0-py2.py3-none-any.whl (11 kB)
Collecting urllib3<1.27,>=1.21.1
  Downloading urllib3-1.26.8-py2.py3-none-any.whl (138 kB)
     |████████████████████████████████| 138 kB 3.5 MB/s
Collecting charset-normalizer~=2.0.0
  Downloading charset_normalizer-2.0.12-py3-none-any.whl (39 kB)
Collecting certifi>=2017.4.17
  Downloading certifi-2021.10.8-py2.py3-none-any.whl (149 kB)
     |████████████████████████████████| 149 kB 6.3 MB/s
Collecting idna<4,>=2.5
  Downloading idna-3.3-py3-none-any.whl (61 kB)
     |████████████████████████████████| 61 kB 5.7 MB/s
Installing collected packages: urllib3, idna, charset-normalizer, certifi, six, requests, hvac
Successfully installed certifi-2021.10.8 charset-normalizer-2.0.12 hvac-0.11.2 idna-3.3 requests-2.27.1 six-1.16.0 urllib3-1.26.8
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
```  

Выполним **[скрипт](./check-vault.py)** для проверки со своим токеном и IP-адресом:

```python
import hvac
client = hvac.Client(
    url='http://172.17.0.3:8200',
    token='CkXFg+wY7phUK5NH'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big netology secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

```bash
sh-5.1# python
Python 3.10.2 (main, Jan 17 2022, 00:00:00) [GCC 11.2.1 20211203 (Red Hat 11.2.1-7)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import hvac

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big netology secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)>>> client = hvac.Client(
...     url='http://172.17.0.3:8200',
...     token='CkXFg+wY7phUK5NH'
... )
>>> client.is_authenticated()
True
>>>
>>> # Пишем секрет
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac',
...     secret=dict(netology='Big netology secret!!!'),
... )
{'request_id': '8ca2ff28-94f4-1a0a-6d9b-fefa7fadd5f9', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2022-03-14T08:53:54.803851093Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 3}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>>
>>> # Читаем секрет
>>> client.secrets.kv.v2.read_secret_version(
...     path='hvac',
... )
{'request_id': 'b3c00da8-c756-a191-a8ac-4332f410794a', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big netology secret!!!'}, 'metadata': {'created_time': '2022-03-14T08:53:54.803851093Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 3}}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>>
```

## Задача 2 (*): Работа с секретами внутри модуля

* На основе образа fedora создать модуль;
* Создать секрет, в котором будет указан токен;
* Подключить секрет к модулю;
* Запустить модуль и проверить доступность сервиса Vault.

**ОТВЕТ:**  
Создадим секрет с нашим токеном:

```bash
wizard:14-kubernetes-net-sec-02-vault/ (main✗) $ kubectl create secret generic vault-token --from-literal=token=CkXFg+wY7phUK5NH
secret/vault-token created
```

Создадим **[манифест](./vault-fedora.yml)** для проверки:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vault-fedora
spec:
  containers:
  - name: vault-fedora
    image: fedora:latest
    command: ['/bin/bash', '-c']
    args: ["sleep 60000"]
    env:
      - name: VAULT_TOKEN
        valueFrom:
          secretKeyRef:
            name: vault-token
            key: token
  restartPolicy: Never
```

И немного изменим проверочный **[скрипт](./check-vault2.py)**:

```python
import os
import hvac
client = hvac.Client(
    url='http://172.17.0.3:8200',
    token=os.environ['VAULT_TOKEN']
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big netology secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

Запустим наш под с fedor-ой и установим пакеты:

```bash
wizard:14-kubernetes-net-sec-02-vault/ (main✗) $ kubectl apply -f vault-fedora.yml
pod/vault-fedora created

wizard:14-kubernetes-net-sec-02-vault/ (main✗) $ kubectl exec -it pod/vault-fedora -- /bin/bash

[root@vault-fedora /]# dnf -y install pip
Fedora 35 - x86_64                                                                                                               6.8 MB/s |  79 MB     00:11
Fedora 35 openh264 (From Cisco) - x86_64                                                                                         1.2 kB/s | 2.5 kB     00:02
Fedora Modular 35 - x86_64                                                                                                       1.8 MB/s | 3.3 MB     00:01
Fedora 35 - x86_64 - Updates                                                                                                     3.7 MB/s |  28 MB     00:07
Fedora Modular 35 - x86_64 - Updates                                                                                             923 kB/s | 2.8 MB     00:03
Dependencies resolved.
=================================================================================================================================================================
 Package                                      Architecture                     Version                                   Repository                         Size
=================================================================================================================================================================
Installing:
 python3-pip                                  noarch                           21.2.3-4.fc35                             updates                           1.8 M
Installing weak dependencies:
 libxcrypt-compat                             x86_64                           4.4.26-4.fc35                             fedora                             89 k
 python3-setuptools                           noarch                           57.4.0-1.fc35                             fedora                            928 k

Transaction Summary
=================================================================================================================================================================
Install  3 Packages

Total download size: 2.8 M
Installed size: 14 M
Downloading Packages:
(1/3): libxcrypt-compat-4.4.26-4.fc35.x86_64.rpm                                                                                 296 kB/s |  89 kB     00:00
(2/3): python3-pip-21.2.3-4.fc35.noarch.rpm                                                                                      2.0 MB/s | 1.8 MB     00:00
(3/3): python3-setuptools-57.4.0-1.fc35.noarch.rpm                                                                               1.0 MB/s | 928 kB     00:00
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                            1.6 MB/s | 2.8 MB     00:01
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                         1/1
  Installing       : python3-setuptools-57.4.0-1.fc35.noarch                                                                                                 1/3
  Installing       : libxcrypt-compat-4.4.26-4.fc35.x86_64                                                                                                   2/3
  Installing       : python3-pip-21.2.3-4.fc35.noarch                                                                                                        3/3
  Running scriptlet: python3-pip-21.2.3-4.fc35.noarch                                                                                                        3/3
  Verifying        : libxcrypt-compat-4.4.26-4.fc35.x86_64                                                                                                   1/3
  Verifying        : python3-setuptools-57.4.0-1.fc35.noarch                                                                                                 2/3
  Verifying        : python3-pip-21.2.3-4.fc35.noarch                                                                                                        3/3

Installed:
  libxcrypt-compat-4.4.26-4.fc35.x86_64                 python3-pip-21.2.3-4.fc35.noarch                 python3-setuptools-57.4.0-1.fc35.noarch

Complete!

[root@vault-fedora /]# pip install hvac
Collecting hvac
  Downloading hvac-0.11.2-py2.py3-none-any.whl (148 kB)
     |████████████████████████████████| 148 kB 553 kB/s
Collecting six>=1.5.0
  Downloading six-1.16.0-py2.py3-none-any.whl (11 kB)
Collecting requests>=2.21.0
  Downloading requests-2.27.1-py2.py3-none-any.whl (63 kB)
     |████████████████████████████████| 63 kB 986 kB/s
Collecting charset-normalizer~=2.0.0
  Downloading charset_normalizer-2.0.12-py3-none-any.whl (39 kB)
Collecting certifi>=2017.4.17
  Downloading certifi-2021.10.8-py2.py3-none-any.whl (149 kB)
     |████████████████████████████████| 149 kB 3.6 MB/s
Collecting urllib3<1.27,>=1.21.1
  Downloading urllib3-1.26.8-py2.py3-none-any.whl (138 kB)
     |████████████████████████████████| 138 kB 6.9 MB/s
Collecting idna<4,>=2.5
  Downloading idna-3.3-py3-none-any.whl (61 kB)
     |████████████████████████████████| 61 kB 4.6 MB/s
Installing collected packages: urllib3, idna, charset-normalizer, certifi, six, requests, hvac
Successfully installed certifi-2021.10.8 charset-normalizer-2.0.12 hvac-0.11.2 idna-3.3 requests-2.27.1 six-1.16.0 urllib3-1.26.8
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
```

Запустим тестовый скрипт:

```bash
[root@vault-fedora /]# python3
Python 3.10.0 (default, Oct  4 2021, 00:00:00) [GCC 11.2.1 20210728 (Red Hat 11.2.1-1)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import os
import hvac
>>> import hvac
client = hvac.Client(
    url='http://172.17.0.3:8200',
    token=os.environ['VAULT_TOKEN']
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big netology secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)>>> client = hvac.Client(
...     url='http://172.17.0.3:8200',
...     token=os.environ['VAULT_TOKEN']
... )
>>> client.is_authenticated()
True
>>>
>>> # Пишем секрет
>>> client.secrets.kv.v2.create_or_update_secret(
...     path='hvac',
...     secret=dict(netology='Big netology secret!!!'),
... )
{'request_id': '20b026ea-9c35-7d9d-ab8a-ab0bb85718c7', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'created_time': '2022-03-14T09:29:54.202010468Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 4}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>>
>>> # Читаем секрет
>>> client.secrets.kv.v2.read_secret_version(
...     path='hvac',
... )
{'request_id': 'b825f125-4e7e-a119-b3c6-b914afb6216a', 'lease_id': '', 'renewable': False, 'lease_duration': 0, 'data': {'data': {'netology': 'Big netology secret!!!'}, 'metadata': {'created_time': '2022-03-14T09:29:54.202010468Z', 'custom_metadata': None, 'deletion_time': '', 'destroyed': False, 'version': 4}}, 'wrap_info': None, 'warnings': None, 'auth': None}
>>>
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, statefulset, service) или скриншот из самого Kubernetes, что сервисы подняты и работают, а также вывод из CLI.

---
