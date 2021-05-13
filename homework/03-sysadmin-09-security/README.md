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
    ...
    2021-05-13T03:06:33.979Z [INFO]  secrets.kv.kv_be0f68fd: upgrading keys finished
    2021-05-13T03:06:33.980Z [INFO]  rollback: starting rollback manager
    WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
    and starts unsealed with a single unseal key. The root token is already
    authenticated to the CLI, so you can immediately begin using Vault.

    You may need to set the following environment variable:

        $ export VAULT_ADDR='http://0.0.0.0:8200'

    The unseal key and root token are displayed below in case you want to
    seal/unseal the Vault or re-authenticate.

    Unseal Key: miBjfaq4hIa4EnjXh3N2Xc3G5dK9VYMcYAM/u8o8xkk=
    Root Token: s.mV4e2Exb9nbguE6OXelWmzx4


    Development mode should NOT be used in production installations!
    vagrant@vagrant:~$
    vagrant@vagrant:~$ export VAULT_ADDR='http://127.0.0.1:8200'
    vagrant@vagrant:~$ export VAULT_TOKEN=s.mV4e2Exb9nbguE6OXelWmzx4
    ```

1. Используя [PKI Secrets Engine](https://www.vaultproject.io/docs/secrets/pki), создайте Root CA и Intermediate CA.
Обратите внимание на [дополнительные материалы](https://learn.hashicorp.com/tutorials/vault/pki-engine) по созданию CA в Vault, если с изначальной инструкцией возникнут сложности.  

    __ОТВЕТ:__ Создаём Root CA:  

    ```bash
    vagrant@vagrant:~$ vault secrets enable pki
    2021-05-13T03:32:19.278Z [INFO]  core: successful mount: namespace= path=pki/ type=pki
    Success! Enabled the pki secrets engine at: pki/
    vagrant@vagrant:~$ vault secrets tune -max-lease-ttl=87600h pki
    2021-05-13T03:32:31.207Z [INFO]  core: mount tuning of leases successful: path=pki/
    Success! Tuned the secrets engine at: pki/
    vagrant@vagrant:~$ vault write -field=certificate pki/root/generate/internal common_name="example.com" ttl=87600h > CA_cert.crt
    vagrant@vagrant:~$ vault write pki/config/urls issuing_certificates="$VAULT_ADDR/v1/pki/ca" crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
    Success! Data written to: pki/config/urls
    ```

    и Intermediate CA:  

    ```bash
    vagrant@vagrant:~$ vault secrets enable -path=pki_int pki
    2021-05-13T03:38:58.326Z [INFO]  core: successful mount: namespace= path=pki_int/ type=pki
    Success! Enabled the pki secrets engine at: pki_int/
    vagrant@vagrant:~$ vault secrets tune -max-lease-ttl=43800h pki_int
    2021-05-13T03:39:10.664Z [INFO]  core: mount tuning of leases successful: path=pki_int/
    Success! Tuned the secrets engine at: pki_int/
    vagrant@vagrant:~$ sudo apt install jq
    vagrant@vagrant:~$ vault write -format=json pki_int/intermediate/generate/internal common_name="example.com Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr
    vagrant@vagrant:~$ vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > intermediate.cert.pem
    vagrant@vagrant:~$ vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
    Success! Data written to: pki_int/intermediate/set-signed
    ```

1. Согласно этой же инструкции, подпишите Intermediate CA csr на сертификат для тестового домена (например, `netology.example.com` если действовали согласно инструкции).  

    __ОТВЕТ:__ Подписываем Intermediate CA csr на сертификат для тестового домена `netology.example.com`  

    ```bash
    vagrant@vagrant:~$ vault write pki_int/roles/example-dot-com allowed_domains="example.com" allow_subdomains=true max_ttl="720h"
    Success! Data written to: pki_int/roles/example-dot-com
    vagrant@vagrant:~$ vault write pki_int/issue/example-dot-com common_name="netology.example.com" ttl="24h"
    Key                 Value
    ---                 -----
    ca_chain            [-----BEGIN CERTIFICATE-----
    MIIDpjCCAo6gAwIBAgIUc/2+bGiwhIXWQKYtXkb3xeHQpw4wDQYJKoZIhvcNAQEL
    BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjEwNTEzMDQzNTMwWhcNMjYw
    ...
    -----END CERTIFICATE-----]
    certificate         -----BEGIN CERTIFICATE-----
    MIIDbjCCAlagAwIBAgIUUS0EEYGQ93WBzTKE9niMZieq2IEwDQYJKoZIhvcNAQEL
    BQAwLTErMCkGA1UEAxMiZXhhbXBsZS5jb20gSW50ZXJtZWRpYXRlIEF1dGhvcml0
    ...
    -----END CERTIFICATE-----
    expiration          1620967072
    issuing_ca          -----BEGIN CERTIFICATE-----
    MIIDpjCCAo6gAwIBAgIUc/2+bGiwhIXWQKYtXkb3xeHQpw4wDQYJKoZIhvcNAQEL
    BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjEwNTEzMDQzNTMwWhcNMjYw
    ...
    -----END CERTIFICATE-----
    private_key         -----BEGIN RSA PRIVATE KEY-----
    MIIEogIBAAKCAQEAxyx+JZ+CnLxITxdV0uPt2ji6SQyZHP0kwc/rnohQh18J8NV9
    5qZrKKJpseu4LZYGHcZ3fYGO4SIWDxKCQ7MWnnh48NnVZhu9lfJBOaghdZjW1jw6
    ...
    -----END RSA PRIVATE KEY-----
    private_key_type    rsa
    serial_number       51:2d:04:11:81:90:f7:75:81:cd:32:84:f6:78:8c:66:27:aa:d8:81
    ```

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
