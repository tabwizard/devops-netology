# Домашняя работа к занятию "08.03 Использование Yandex Cloud"

## Подготовка к выполнению

1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.  

    **ОТВЕТ:** Для подготовки к выполнению домашнего задания в Yandex.Cloud было создано 3 ВМ, внешние IP-адреса которых были прописаны в `playbook\inventory\prod\prod.yml`

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.  

    **ОТВЕТ 1 - 3:** Дописал создание kibana

    ```yaml
    - name: Install Kibana
    hosts: kibana
    handlers:
        - name: restart Kibana
        become: true
        systemd:
            name: kibana
            state: restarted
            enabled: true
    tasks:
        - name: "Download Kibana's rpm"
        get_url:
            url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ elk_stack_version }}-x86_64.rpm"
            dest: "/tmp/kibana-{{ elk_stack_version }}-x86_64.rpm"
        register: download_kibana
        until: download_kibana is succeeded
        - name: Install Kibana
        become: true
        yum:
            name: "/tmp/kibana-{{ elk_stack_version }}-x86_64.rpm"
            state: present
        notify: restart Kibana
        - name: Configure Kibana
        become: true
        template:
            src: kibana.yml.j2
            dest: /etc/kibana/kibana.yml
        notify: restart Kibana
    ```

4. Приготовьте свой собственный inventory файл `prod.yml`.  

    **ОТВЕТ:** Подготовил inventory файл `prod.yml`

    ```yaml
    all:
      hosts:
        el-instance:
          ansible_host: 178.154.193.149
        k-instance:
          ansible_host: 178.154.197.120
        app-instance:
          ansible_host: 84.252.143.138
      vars:
        ansible_connection: ssh
        ansible_port: 22
        ansible_user: wizard
    elasticsearch:
      hosts:
        el-instance:
    kibana:
      hosts:
        k-instance:
    application:
      hosts:
        app-instance:
    ```

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.  

    **ОТВЕТ:** Запустил `ansible-lint site.yml`, получил сообщения об ошибках прав доступа, исправил их, получил чистый вывод.

    ```bash
    wizard:playbook/ (main✗) $ ansible-lint site.yml
    WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
    WARNING  Listing 3 violation(s) that are fatal
    risky-file-permissions: File permissions unset or incorrect
    site.yml:24 Task/Handler: Configure Elasticsearch

    risky-file-permissions: File permissions unset or incorrect
    site.yml:53 Task/Handler: Configure Kibana

    risky-file-permissions: File permissions unset or incorrect
    site.yml:82 Task/Handler: Configure Filebeat

    You can skip specific rules or tags by adding them to your configuration file:
    # .ansible-lint
    warn_list:  # or 'skip_list' to silence them completely
      - experimental  # all rules tagged as experimental

    Finished with 0 failure(s), 3 warning(s) on 1 files.



    wizard:playbook/ (main✗) $ ansible-lint site.yml
    WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
    ```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.  

    **ОТВЕТ:** Запустил playbook с флагом `--check`, получил ошибки установки нескачанного rpm-файла

    ```bash
    wizard:playbook/ (main✗) $ ansible-playbook -i inventory/prod site.yml --check  

    PLAY [Install Elasticsearch] *************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [el-instance]

    TASK [Download Elasticsearch's rpm] ******************************************************************************
    changed: [el-instance]

    TASK [Install Elasticsearch] *************************************************************************************
    fatal: [el-instance]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/elasticsearch-7.14.1-x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/elasticsearch-7.14.1-x86_64.rpm' found on system"]}

    PLAY RECAP *******************************************************************************************************
    el-instance                : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
    ```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.  

    **ОТВЕТ:** Запустил playbook с флагом `--diff`, получил ошибки конфигурирования filebeat, исправил их, запустил еще раз, убедился, что изменения были произведены

    ```bash
    wizard:playbook/ (main✗) $ ansible-playbook -i inventory/prod site.yml --diff

    PLAY [Install Elasticsearch] *************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [el-instance]

    * * *
    * * *
    * * *

    PLAY RECAP *******************************************************************************************************
    app-instance               : ok=5    changed=4    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
    el-instance                : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    k-instance                 : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0







    wizard:playbook/ (main✗) $ ansible-playbook -i inventory/prod site.yml --diff

    PLAY [Install Elasticsearch] *************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [el-instance]

    * * *
    * * *
    * * *

    PLAY RECAP *******************************************************************************************************
    app-instance               : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.  

    **ОТВЕТ:** Запустил playbook с флагом `--diff` ещё раз

    ```bash
    wizard:playbook/ (main✗) $ ansible-playbook -i inventory/prod site.yml --diff

    PLAY [Install Elasticsearch] *************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [el-instance]

    TASK [Download Elasticsearch's rpm] ******************************************************************************
    ok: [el-instance]

    TASK [Install Elasticsearch] *************************************************************************************
    ok: [el-instance]

    TASK [Configure Elasticsearch] ***********************************************************************************
    ok: [el-instance]

    PLAY [Install Kibana] ********************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [k-instance]

    TASK [Download Kibana's rpm] *************************************************************************************
    ok: [k-instance]

    TASK [Install Kibana] ********************************************************************************************
    ok: [k-instance]

    TASK [Configure Kibana] ******************************************************************************************
    ok: [k-instance]

    PLAY [Install Filebeat] ******************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [app-instance]

    TASK [Download Filebeat's rpm] ***********************************************************************************
    ok: [app-instance]

    TASK [Install Filebeat] ******************************************************************************************
    ok: [app-instance]

    TASK [Configure Filebeat] ****************************************************************************************
    ok: [app-instance]

    TASK [Set filebeat systemwork] ***********************************************************************************
    ok: [app-instance]

    TASK [Load Kibana dashboard] *************************************************************************************
    ok: [app-instance]

    PLAY RECAP *******************************************************************************************************
    app-instance               : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    el-instance                : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    k-instance                 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```


9.  Проделайте шаги с 1 до 8 для создания ещё одного play, который устанавливает и настраивает filebeat.  

    **ОТВЕТ:** Создал play для установки и настройки filebeat

    ```yaml
    - name: Install Filebeat
      hosts: application
      handlers:
        - name: restart Filebeat
          become: true
          systemd:
            name: filebeat
            state: restarted
            enabled: true
      tasks:
        - name: "Download Filebeat's rpm"
          get_url:
            url: "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-{{ elk_stack_version }}-x86_64.rpm"
            dest: "/tmp/filebeat-{{ elk_stack_version }}-x86_64.rpm"
          register: download_filebeat
          until: download_filebeat is succeeded
        - name: Install Filebeat
          become: true
          yum:
            name: "/tmp/filebeat-{{ elk_stack_version }}-x86_64.rpm"
            state: present
          notify: restart Filebeat
        - name: Configure Filebeat
          become: true
          template:
            src: filebeat.yml.j2
            dest: /etc/filebeat/filebeat.yml
            mode: 0640
          notify: restart Filebeat
        - name: Set filebeat systemwork
          become: true
          command:
            cmd: filebeat modules enable system
            chdir: /usr/share/filebeat/bin
          register: filebeat_modules
          changed_when: filebeat_modules.stdout != 'Module system is already enabled'
        - name: Load Kibana dashboard
          become: true
          command:
            cmd: filebeat setup
            chdir: /usr/share/filebeat/bin
          register: filebeat_setup
          until: filebeat_setup is succeeded
          notify: restart Filebeat
          changed_when: false
    ```

10. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.  

    **ОТВЕТ:** Подготовьте [README.md](./playbook/README.md) файл по своему playbook

11. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
