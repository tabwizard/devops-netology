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

    Копируем созданные сертификаты и ключ в файлы.

    ```bash
    vagrant@vagrant:~$ vim intermediate.ca.cert.crt
    vagrant@vagrant:~$ vim netology.example.com.crt
    vagrant@vagrant:~$ vim netology.example.com.key
    ```

1. Поднимите на localhost nginx, сконфигурируйте default vhost для использования подписанного Vault Intermediate CA сертификата и выбранного вами домена. Сертификат из Vault подложить в nginx руками.  

    __ОТВЕТ:__ Устанавливаем `nginx` и настраиваем сертификат домена `netology.example.com`  

    ```bash
    vagrant@vagrant:~$ sudo apt-get install nginx
    vagrant@vagrant:~$ sudo vim /etc/nginx/sites-enabled/default
    vagrant@vagrant:~$ cat /etc/nginx/sites-enabled/default | grep ssl
            listen 443 ssl default_server;
            listen [::]:443 ssl default_server;
            # Read up on ssl_ciphers to ensure a secure configuration.
            # Self signed certs generated by the ssl-cert package
            ssl_certificate /home/vagrant/netology.example.com.crt;
            ssl_certificate_key /home/vagrant/netology.example.com.key;
    vagrant@vagrant:~$ sudo nginx -t
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful
    vagrant@vagrant:~$ sudo systemctl reload nginx
    vagrant@vagrant:~$ sudo systemctl status nginx
    ● nginx.service - A high performance web server and a reverse proxy server
        Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
        Active: active (running) since Thu 2021-05-13 05:43:41 UTC; 14min ago
        Docs: man:nginx(8)
        Process: 1655 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
    Main PID: 1475 (nginx)
        Tasks: 2 (limit: 470)
        Memory: 5.6M
        CGroup: /system.slice/nginx.service
                ├─1475 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
                └─1656 nginx: worker process

    May 13 05:43:40 vagrant systemd[1]: Starting A high performance web server and a reverse proxy server...
    May 13 05:43:41 vagrant systemd[1]: Started A high performance web server and a reverse proxy server.
    May 13 05:57:38 vagrant systemd[1]: Reloading A high performance web server and a reverse proxy server.
    May 13 05:57:38 vagrant systemd[1]: Reloaded A high performance web server and a reverse proxy server.
    ```

1. Модифицировав `/etc/hosts` и [системный trust-store](http://manpages.ubuntu.com/manpages/focal/en/man8/update-ca-certificates.8.html), добейтесь безошибочной с точки зрения HTTPS работы curl на ваш тестовый домен (отдающийся с localhost). Рекомендуется добавлять в доверенные сертификаты Intermediate CA. Root CA добавить было бы правильнее, но тогда при конфигурации nginx потребуется включить в цепочку Intermediate, что выходит за рамки лекции. Так же, пожалуйста, не добавляйте в доверенные сам сертификат хоста.  

    __ОТВЕТ:__ Правим `/etc/hosts`, добавляем в доверенные сертификаты Intermediate CA. И проверяем работу `netology.example.com` по HTTPS.  

    ```bash
    vagrant@vagrant:~$ sudo -i
    root@vagrant:~# echo 127.0.0.1 netology.example.com >> /etc/hosts
    root@vagrant:~# ln -s /home/vagrant/intermediate.ca.cert.crt /usr/share/ca-certificates/mozilla/intermediate.ca.cert.crt
    root@vagrant:~# echo mozilla/intermediate.ca.cert.crt >> /etc/ca-certificates.conf
    root@vagrant:~# update-ca-certificates
    Updating certificates in /etc/ssl/certs...
    1 added, 0 removed; done.
    Running hooks in /etc/ca-certificates/update.d...
    done.
    root@vagrant:~# curl -I -s https://netology.example.com |head -1
    HTTP/1.1 200 OK

    root@vagrant:~# curl -v https://netology.example.com 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
    * Server certificate:
    *  subject: CN=netology.example.com
    *  start date: May 13 04:37:22 2021 GMT
    *  expire date: May 14 04:37:52 2021 GMT
    *  subjectAltName: host "netology.example.com" matched cert's "netology.example.com"
    *  issuer: CN=example.com Intermediate Authority
    *  SSL certificate verify ok.
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * old SSL session ID is stale, removing
    * Mark bundle as not supporting multiuse
    * Connection #0 to host netology.example.com left intact

    ```

1. [Ознакомьтесь](https://letsencrypt.org/ru/docs/client-options/) с протоколом ACME и CA Let's encrypt. Если у вас есть во владении доменное имя с платным TLS-сертификатом, который возможно заменить на LE, или же без HTTPS вообще, попробуйте воспользоваться одним из предложенных клиентов, чтобы сделать веб-сайт безопасным (или перестать платить за коммерческий сертификат).  

    __ОТВЕТ:__ Есть рабочий домен `eddsmgo.ru`, с помощью панели управления `ispmanager` сгенерирован сертификат Let's Encrypt и настроена автоматическое продление каждые 82 дня.  

    ```bash
    root@vagrant:/etc# curl -v https://eddsmgo.ru 2>&1 | awk 'BEGIN { cert=0 } /^\* Server certificate:/ { cert=1 } /^\*/ { if (cert) print }'
    * Server certificate:
    *  subject: CN=eddsmgo.ru
    *  start date: Apr  9 23:12:39 2021 GMT
    *  expire date: Jul  8 23:12:39 2021 GMT
    *  subjectAltName: host "eddsmgo.ru" matched cert's "eddsmgo.ru"
    *  issuer: C=US; O=Let's Encrypt; CN=R3
    *  SSL certificate verify ok.
    * Using HTTP2, server supports multi-use
    * Connection state changed (HTTP/2 confirmed)
    * Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
    * Using Stream ID: 1 (easy handle 0x555a90fd6c60)
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * old SSL session ID is stale, removing
    * Connection state changed (MAX_CONCURRENT_STREAMS == 128)!
    * Connection #0 to host eddsmgo.ru left intact
    ```

**Дополнительное задание вне зачета.** Вместо ручного подкладывания сертификата в nginx, воспользуйтесь [consul-template](https://medium.com/hashicorp-engineering/pki-as-a-service-with-hashicorp-vault-a8d075ece9a) для автоматического подтягивания сертификата из Vault.

>Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на ваш репозиторий.
>
>Также вы можете выполнить задание в [Google Docs](https://docs.google.com/document/u/0/?tgif=d) и отправить в личном кабинете на проверку ссылку на ваш документ.
>Название файла Google Docs должно содержать номер лекции и фамилию студента. Пример названия: "1.1. Введение в DevOps — Сусанна Алиева"
>Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на комментирование всем, у кого есть ссылка).
>Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.
>
>Любые вопросы по решению задач задавайте в чате Slack.
