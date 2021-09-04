# Домашняя работа к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению

1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соответствии с группами из предподготовленного playbook.
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`.  

**ОТВЕТ:** Подготовил [Vagrantfile](./Vagrantfile) для ВМ в соответствии с `playbook`, скачал в каталог `playbook/files/` дистрибутив [java](./playbook/files/jdk-11.0.12_linux-x64_bin.tar.gz)

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.  

    **ОТВЕТ:** Подготовил [prod.yml](./playbook/inventory/prod.yml) в соответствии с [Vagrantfile](./Vagrantfile)

    ```yaml
    ---
    elasticsearch:
    hosts:
        elastic-vm:
        ansible_host: 192.168.178.91
        ansible_port: 22
        ansible_connection: ssh
        ansible_user: root
        ansible_ssh_private_key_file: ~/.ssh/id_rsa
    kibana:
    hosts:
        kibana-vm:
        ansible_host: 192.168.178.92
        ansible_port: 22
        ansible_connection: ssh
        ansible_user: root
        ansible_ssh_private_key_file: ~/.ssh/id_rsa
    ```

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.  

    **ОТВЕТ:** Дополнил playbook для установки и настройки kibana

    ```yaml
    - name: Install Kibana
      hosts: kibana
      tasks:
        - name: Upload tar.gz Kibana from remote URL
          get_url:
            url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
            dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
            mode: 0644
            timeout: 60
            force: true
            validate_certs: false
          register: get_kibana
          until: get_kibana is succeeded
          tags: kibana
        - name: Create directory for Kibana
          file:
            state: directory
            path: "{{ kibana_home }}"
            mode: 0755
          tags: kibana
        - name: Extract Kibana in the installation directory
          become: true
          unarchive:
            copy: false
            src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
            dest: "{{ kibana_home }}"
            extra_opts: [--strip-components=1]
            creates: "{{ kibana_home }}/bin/kibana"
          tags:
            - kibana
        - name: Set environment Kibana
          become: true
          template:
            src: templates/kbn.sh.j2
            dest: /etc/profile.d/kbn.sh  
            mode: 0755
          tags: kibana
    ```

3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

    **ОТВЕТ:** Запустил `ansible-lint site.yml` и исправил ошибки с правами

    ```bash
    wizard:playbook/ (main✗) $ ansible-lint site.yml
    WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml 
    ```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.  

    **ОТВЕТ:** Запустил playbook на этом окружении с флагом `--check`

    ```bash
    wizard:playbook/ (main✗) $ ansible-playbook -i ./inventory/prod.yml site.yml --check

    PLAY [Install Java] **********************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [kibana-vm]
    ok: [elastic-vm]

    TASK [Set facts for Java 11 vars] ********************************************************************************
    ok: [elastic-vm]
    ok: [kibana-vm]

    TASK [Upload .tar.gz file containing binaries from local storage] ************************************************
    changed: [kibana-vm]
    changed: [elastic-vm]

    TASK [Ensure installation dir exists] ****************************************************************************
    changed: [kibana-vm]
    changed: [elastic-vm]

    TASK [Extract java in the installation directory] ****************************************************************
    An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
    fatal: [elastic-vm]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.12' must be an existing dir"}
    An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
    fatal: [kibana-vm]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.12' must be an existing dir"}

    PLAY RECAP *******************************************************************************************************
    elastic-vm                 : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
    kibana-vm                  : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
    ```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.  

    **ОТВЕТ:** Запустил playbook на `prod.yml` окружении с флагом `--diff`

    ```bash
    wizard:playbook/ (main✗) $ ansible-playbook -i ./inventory/prod.yml site.yml --diff

    PLAY [Install Java] **********************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [kibana-vm]
    ok: [elastic-vm]

    TASK [Set facts for Java 11 vars] ********************************************************************************
    ok: [elastic-vm]
    ok: [kibana-vm]

    TASK [Upload .tar.gz file containing binaries from local storage] ************************************************
    diff skipped: source file size is greater than 104448
    changed: [elastic-vm]
    diff skipped: source file size is greater than 104448
    changed: [kibana-vm]

    TASK [Ensure installation dir exists] ****************************************************************************
    --- before
    +++ after
    @@ -1,4 +1,4 @@
    {
        "path": "/opt/jdk/11.0.12",
    -    "state": "absent"
    +    "state": "directory"
    }

    changed: [kibana-vm]
    --- before
    +++ after
    @@ -1,4 +1,4 @@
    {
        "path": "/opt/jdk/11.0.12",
    -    "state": "absent"
    +    "state": "directory"
    }

    changed: [elastic-vm]

    TASK [Extract java in the installation directory] ****************************************************************
    changed: [kibana-vm]
    changed: [elastic-vm]

    TASK [Export environment variables] ******************************************************************************
    --- before
    +++ after: /home/wizard/.ansible/tmp/ansible-local-2081386krn1qz8/tmpqre0wafq/jdk.sh.j2
    @@ -0,0 +1,5 @@
    +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
    +#!/usr/bin/env bash
    +
    +export JAVA_HOME=/opt/jdk/11.0.12
    +export PATH=$PATH:$JAVA_HOME/bin
    \ No newline at end of file

    changed: [kibana-vm]
    --- before
    +++ after: /home/wizard/.ansible/tmp/ansible-local-2081386krn1qz8/tmpcdbun3ov/jdk.sh.j2
    @@ -0,0 +1,5 @@
    +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
    +#!/usr/bin/env bash
    +
    +export JAVA_HOME=/opt/jdk/11.0.12
    +export PATH=$PATH:$JAVA_HOME/bin
    \ No newline at end of file

    changed: [elastic-vm]

    PLAY [Install Elasticsearch] *************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [elastic-vm]

    TASK [Upload tar.gz Elasticsearch from remote URL] ***************************************************************
    changed: [elastic-vm]

    TASK [Create directory for Elasticsearch] ************************************************************************
    --- before
    +++ after
    @@ -1,4 +1,4 @@
    {
        "path": "/opt/elastic/7.10.1",
    -    "state": "absent"
    +    "state": "directory"
    }

    changed: [elastic-vm]

    TASK [Extract Elasticsearch in the installation directory] *******************************************************
    changed: [elastic-vm]

    TASK [Set environment Elastic] ***********************************************************************************
    --- before
    +++ after: /home/wizard/.ansible/tmp/ansible-local-2081386krn1qz8/tmpegozyvkd/elk.sh.j2
    @@ -0,0 +1,5 @@
    +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
    +#!/usr/bin/env bash
    +
    +export ES_HOME=/opt/elastic/7.10.1
    +export PATH=$PATH:$ES_HOME/bin
    \ No newline at end of file

    changed: [elastic-vm]

    PLAY [Install Kibana] ********************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [kibana-vm]

    TASK [Upload tar.gz Kibana from remote URL] **********************************************************************
    changed: [kibana-vm]

    TASK [Create directory for Kibana] *******************************************************************************
    --- before
    +++ after
    @@ -1,4 +1,4 @@
    {
        "path": "/opt/kibana/7.14.1",
    -    "state": "absent"
    +    "state": "directory"
    }

    changed: [kibana-vm]

    TASK [Extract Kibana in the installation directory] **************************************************************
    changed: [kibana-vm]

    TASK [Set environment Kibana] ************************************************************************************
    --- before
    +++ after: /home/wizard/.ansible/tmp/ansible-local-2081386krn1qz8/tmpgyldsul3/kbn.sh.j2
    @@ -0,0 +1,5 @@
    +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
    +#!/usr/bin/env bash
    +
    +export KBN_HOME=/opt/kibana/7.14.1
    +export PATH=$PATH:$KBN_HOME/bin

    changed: [kibana-vm]

    PLAY RECAP *******************************************************************************************************
    elastic-vm                 : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    kibana-vm                  : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
    ```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.  

    **ОТВЕТ:** Повторно запустил playbook с флагом `--diff`

    ```bash
    wizard:playbook/ (main✗) $ ansible-playbook -i ./inventory/prod.yml site.yml --diff

    PLAY [Install Java] **********************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [elastic-vm]
    ok: [kibana-vm]

    TASK [Set facts for Java 11 vars] ********************************************************************************
    ok: [elastic-vm]
    ok: [kibana-vm]

    TASK [Upload .tar.gz file containing binaries from local storage] ************************************************
    ok: [kibana-vm]
    ok: [elastic-vm]

    TASK [Ensure installation dir exists] ****************************************************************************
    ok: [elastic-vm]
    ok: [kibana-vm]

    TASK [Extract java in the installation directory] ****************************************************************
    skipping: [elastic-vm]
    skipping: [kibana-vm]

    TASK [Export environment variables] ******************************************************************************
    ok: [elastic-vm]
    ok: [kibana-vm]

    PLAY [Install Elasticsearch] *************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [elastic-vm]

    TASK [Upload tar.gz Elasticsearch from remote URL] ***************************************************************
    ok: [elastic-vm]

    TASK [Create directory for Elasticsearch] ************************************************************************
    ok: [elastic-vm]

    TASK [Extract Elasticsearch in the installation directory] *******************************************************
    skipping: [elastic-vm]

    TASK [Set environment Elastic] ***********************************************************************************
    ok: [elastic-vm]

    PLAY [Install Kibana] ********************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [kibana-vm]

    TASK [Upload tar.gz Kibana from remote URL] **********************************************************************
    ok: [kibana-vm]

    TASK [Create directory for Kibana] *******************************************************************************
    ok: [kibana-vm]

    TASK [Extract Kibana in the installation directory] **************************************************************
    skipping: [kibana-vm]

    TASK [Set environment Kibana] ************************************************************************************
    ok: [kibana-vm]

    PLAY RECAP *******************************************************************************************************
    elastic-vm                 : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
    kibana-vm                  : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
    ```

    Проверил изменения внутри виртуальных машин

    ```bash
    wizard:mnt-homeworks/ (MNT-7) $ ssh root@192.168.178.91 -p 22 
    Last login: Sat Sep  4 03:37:04 2021 from 192.168.178.25
    [root@elastic-vm ~]# ll /opt
    total 0
    drwxr-xr-x. 3 root root 20 Sep  4 03:32 elastic
    drwxr-xr-x. 3 root root 21 Sep  4 03:31 jdk

    wizard:mnt-homeworks/ (MNT-7) $ ssh root@192.168.178.92 -p 22
    Last login: Sat Sep  4 03:37:43 2021 from 192.168.178.25
    [root@kibana-vm ~]# ll /opt
    total 0
    drwxr-xr-x. 3 root root 21 Sep  4 03:31 jdk
    drwxr-xr-x. 3 root root 20 Sep  4 03:33 kibana
    [root@kibana-vm ~]# cat /etc/profile.d/kbn.sh
        # Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
        #!/usr/bin/env bash

        export KBN_HOME=/opt/kibana/7.14.1
        export PATH=$PATH:$KBN_HOME/bin
    ```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.  

    **ОТВЕТ:** Подготовил [README.md](./playbook/README.md) c описанием своего playbook.
10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
