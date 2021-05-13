# Домашняя работа к занятию "3.9. Элементы безопасности информационных систем"

1. Установите [Hashicorp Vault](https://learn.hashicorp.com/vault) в виртуальной машине Vagrant/VirtualBox. Это не является обязательным для выполнения задания, но для лучшего понимания что происходит при выполнении команд (посмотреть результат в UI), можно по аналогии с netdata из прошлых лекций пробросить порт Vault на localhost:

    ```bash
    config.vm.network "forwarded_port", guest: 8200, host: 8200
    ```

    Однако, обратите внимание, что только-лишь проброса порта не будет достаточно – по-умолчанию Vault слушает на 127.0.0.1; добавьте к опциям запуска `-dev-listen-address="0.0.0.0:8200"`.  

    __ОТВЕТ:__ Ставим Vault  

    ```bash
    vagrant@vagrant:~$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    OK
    vagrant@vagrant:~$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    Get:1 http://security.ubuntu.com/ubuntu focal-security InRelease [109 kB]
    Get:2 https://apt.releases.hashicorp.com focal InRelease [4,419 B]
    ...
    Get:32 http://archive.ubuntu.com/ubuntu focal-backports/universe i386 Packages [2,932 B]
    Fetched 6,238 kB in 3s (2,029 kB/s)
    Reading package lists... Done
    vagrant@vagrant:~$ sudo apt-get update && sudo apt-get install vault
    Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
    Hit:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease
    Hit:3 http://security.ubuntu.com/ubuntu focal-security InRelease
    Hit:4 http://archive.ubuntu.com/ubuntu focal-backports InRelease
    Hit:5 https://apt.releases.hashicorp.com focal InRelease
    Reading package lists... Done
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    The following NEW packages will be installed:
    vault
    0 upgraded, 1 newly installed, 0 to remove and 117 not upgraded.
    Need to get 68.8 MB of archives.
    After this operation, 197 MB of additional disk space will be used.
    Get:1 https://apt.releases.hashicorp.com focal/main amd64 vault amd64 1.7.1 [68.8 MB]
    Fetched 68.8 MB in 7s (9,613 kB/s)
    Selecting previously unselected package vault.
    (Reading database ... 41397 files and directories currently installed.)
    Preparing to unpack .../archives/vault_1.7.1_amd64.deb ...
    Unpacking vault (1.7.1) ...
    Setting up vault (1.7.1) ...
    Generating Vault TLS key and self-signed certificate...
    Generating a RSA private key
    .........................................................................++++
    ..........................++++
    writing new private key to 'tls.key'
    -----
    Vault TLS key and self-signed certificate have been generated in '/opt/vault/tls'.

    ```

1. Запустить Vault-сервер в dev-режиме (дополнив ключ `-dev` упомянутым выше `-dev-listen-address`, если хотите увидеть UI).  

    __ОТВЕТ:__ Запускаем Vault-сервер в dev-режиме  

    ```bash
    vagrant@vagrant:~$ vault server -dev -dev-listen-address="0.0.0.0:8200" &
    [1] 14028
    vagrant@vagrant:~$ ==> Vault server configuration:

                Api Address: http://0.0.0.0:8200
                        Cgo: disabled
            Cluster Address: https://0.0.0.0:8201
                Go Version: go1.15.11
                Listener 1: tcp (addr: "0.0.0.0:8200", cluster address: "0.0.0.0:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
                Log Level: info
                    Mlock: supported: true, enabled: false
            Recovery Mode: false
                    Storage: inmem
                    Version: Vault v1.7.1
                Version Sha: 917142287996a005cb1ed9d96d00d06a0590e44e

    ==> Vault server started! Log data will stream in below:

    2021-05-13T03:06:33.914Z [INFO]  proxy environment: http_proxy= https_proxy= no_proxy=
    2021-05-13T03:06:33.914Z [WARN]  no `api_addr` value specified in config or in VAULT_API_ADDR; falling back to detection if possible, but this value should be manually set
    2021-05-13T03:06:33.925Z [INFO]  core: security barrier not initialized
    2021-05-13T03:06:33.925Z [INFO]  core: security barrier initialized: stored=1 shares=1 threshold=1
    2021-05-13T03:06:33.926Z [INFO]  core: post-unseal setup starting
    2021-05-13T03:06:33.949Z [INFO]  core: loaded wrapping token key
    2021-05-13T03:06:33.949Z [INFO]  core: successfully setup plugin catalog: plugin-directory=
    2021-05-13T03:06:33.949Z [INFO]  core: no mounts; adding default mount table
    2021-05-13T03:06:33.951Z [INFO]  core: successfully mounted backend: type=cubbyhole path=cubbyhole/
    2021-05-13T03:06:33.951Z [INFO]  core: successfully mounted backend: type=system path=sys/
    2021-05-13T03:06:33.951Z [INFO]  core: successfully mounted backend: type=identity path=identity/
    2021-05-13T03:06:33.953Z [INFO]  core: successfully enabled credential backend: type=token path=token/
    2021-05-13T03:06:33.954Z [INFO]  core: restoring leases
    2021-05-13T03:06:33.956Z [INFO]  rollback: starting rollback manager
    2021-05-13T03:06:33.957Z [INFO]  expiration: lease restore complete
    2021-05-13T03:06:33.957Z [INFO]  identity: entities restored
    2021-05-13T03:06:33.957Z [INFO]  identity: groups restored
    2021-05-13T03:06:33.957Z [INFO]  core: post-unseal setup complete
    2021-05-13T03:06:33.958Z [INFO]  core: root token generated
    2021-05-13T03:06:33.958Z [INFO]  core: pre-seal teardown starting
    2021-05-13T03:06:33.959Z [INFO]  rollback: stopping rollback manager
    2021-05-13T03:06:33.959Z [INFO]  core: pre-seal teardown complete
    2021-05-13T03:06:33.959Z [INFO]  core.cluster-listener.tcp: starting listener: listener_address=0.0.0.0:8201
    2021-05-13T03:06:33.959Z [INFO]  core.cluster-listener: serving cluster requests: cluster_listen_address=[::]:8201
    2021-05-13T03:06:33.959Z [INFO]  core: post-unseal setup starting
    2021-05-13T03:06:33.960Z [INFO]  core: loaded wrapping token key
    2021-05-13T03:06:33.960Z [INFO]  core: successfully setup plugin catalog: plugin-directory=
    2021-05-13T03:06:33.960Z [INFO]  core: successfully mounted backend: type=system path=sys/
    2021-05-13T03:06:33.961Z [INFO]  core: successfully mounted backend: type=identity path=identity/
    2021-05-13T03:06:33.961Z [INFO]  core: successfully mounted backend: type=cubbyhole path=cubbyhole/
    2021-05-13T03:06:33.963Z [INFO]  core: successfully enabled credential backend: type=token path=token/
    2021-05-13T03:06:33.964Z [INFO]  core: restoring leases
    2021-05-13T03:06:33.967Z [INFO]  identity: entities restored
    2021-05-13T03:06:33.967Z [INFO]  identity: groups restored
    2021-05-13T03:06:33.967Z [INFO]  core: post-unseal setup complete
    2021-05-13T03:06:33.967Z [INFO]  core: vault is unsealed
    2021-05-13T03:06:33.971Z [INFO]  core: successful mount: namespace= path=secret/ type=kv
    2021-05-13T03:06:33.978Z [INFO]  expiration: lease restore complete
    2021-05-13T03:06:33.979Z [INFO]  secrets.kv.kv_be0f68fd: collecting keys to upgrade
    2021-05-13T03:06:33.979Z [INFO]  secrets.kv.kv_be0f68fd: done collecting keys: num_keys=1
    2021-05-13T03:06:33.979Z [INFO]  secrets.kv.kv_be0f68fd: upgrading keys finished
    2021-05-13T03:06:33.980Z [INFO]  rollback: starting rollback manager
    WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
    and starts unsealed with a single unseal key. The root token is already
    authenticated to the CLI, so you can immediately begin using Vault.

    You may need to set the following environment variable:

        $ export VAULT_ADDR='http://0.0.0.0:8200'

    The unseal key and root token are displayed below in case you want to
    seal/unseal the Vault or re-authenticate.

    Unseal Key: xXuCyJXHCeV3A5kOYXZtGYdi1CTC3d+YA+IeribAUvI=
    Root Token: s.8b0Btcqq7E1k4dRUhZdELWBd

    Development mode should NOT be used in production installations!
    vagrant@vagrant:~$
    ```

1. Используя [PKI Secrets Engine](https://www.vaultproject.io/docs/secrets/pki), создайте Root CA и Intermediate CA.
Обратите внимание на [дополнительные материалы](https://learn.hashicorp.com/tutorials/vault/pki-engine) по созданию CA в Vault, если с изначальной инструкцией возникнут сложности.
1. Согласно этой же инструкции, подпишите Intermediate CA csr на сертификат для тестового домена (например, `netology.example.com` если действовали согласно инструкции).
1. Поднимите на localhost nginx, сконфигурируйте default vhost для использования подписанного Vault Intermediate CA сертификата и выбранного вами домена. Сертификат из Vault подложить в nginx руками.
1. Модифицировав `/etc/hosts` и [системный trust-store](http://manpages.ubuntu.com/manpages/focal/en/man8/update-ca-certificates.8.html), добейтесь безошибочной с точки зрения HTTPS работы curl на ваш тестовый домен (отдающийся с localhost). Рекомендуется добавлять в доверенные сертификаты Intermediate CA. Root CA добавить было бы правильнее, но тогда при конфигурации nginx потребуется включить в цепочку Intermediate, что выходит за рамки лекции. Так же, пожалуйста, не добавляйте в доверенные сам сертификат хоста.
1. [Ознакомьтесь](https://letsencrypt.org/ru/docs/client-options/) с протоколом ACME и CA Let's encrypt. Если у вас есть во владении доменное имя с платным TLS-сертификатом, который возможно заменить на LE, или же без HTTPS вообще, попробуйте воспользоваться одним из предложенных клиентов, чтобы сделать веб-сайт безопасным (или перестать платить за коммерческий сертификат).

**Дополнительное задание вне зачета.** Вместо ручного подкладывания сертификата в nginx, воспользуйтесь [consul-template](https://medium.com/hashicorp-engineering/pki-as-a-service-with-hashicorp-vault-a8d075ece9a) для автоматического подтягивания сертификата из Vault.

>Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на ваш репозиторий.
>
>Также вы можете выполнить задание в [Google Docs](https://docs.google.com/document/u/0/?tgif=d) и отправить в личном кабинете на проверку ссылку на ваш документ.
>Название файла Google Docs должно содержать номер лекции и фамилию студента. Пример названия: "1.1. Введение в DevOps — Сусанна Алиева"
>Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на комментирование всем, у кого есть ссылка).
>Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.
>
>Любые вопросы по решению задач задавайте в чате Slack.
