1. Попробуйте запустить playbook на окружении из test.yml, зафиксируйте какое значение имеет факт some_fact для указанного хоста при выполнении playbook'a.  
**ОТВЕТ:**

    ```bash
    TASK [Print fact] *******************************************************************
    ok: [localhost] => {
        "msg": 12
    }
    ```

2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.  
  **ОТВЕТ:**

    ```bash
    TASK [Print fact] *************************************************************************************
    ok: [localhost] => {
        "msg": "all default fact"
    }
    ```

3. Воспользуйтесь подготовленным (используется docker) или создайте собственное окружение для проведения дальнейших испытаний.  
  **ОТВЕТ:**

    ```bash
    docker run -d --name centos7 pycontribs/centos:7 sleep 600000000
    docker run -d --name ubuntu pycontribs/ubuntu:latest sleep 600000000
    ```

4. Проведите запуск playbook на окружении из prod.yml. Зафиксируйте полученные значения some_fact для каждого из managed host.  
  **ОТВЕТ:**

    ```bash
    TASK [Print fact] *************************************************************************************
    ok: [centos7] => {
        "msg": "el"
    }
    ok: [ubuntu] => {
        "msg": "deb"
    }
    ```

5. Добавьте факты в group_vars каждой из групп хостов так, чтобы для some_fact получились следующие значения: для deb - 'deb default fact', для el - 'el default fact'.
6. Повторите запуск playbook на окружении prod.yml. Убедитесь, что выдаются корректные значения для всех хостов.  
  **ОТВЕТ:**

    ```bash
    TASK [Print fact] *************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }
    ```

7. При помощи ansible-vault зашифруйте факты в group_vars/deb и group_vars/el с паролем netology.  
  **ОТВЕТ:**

    ```bash
    ansible-vault encrypt ./group_vars/deb/examp.yml
    ansible-vault encrypt ./group_vars/el/examp.yml 
    ```

8. Запустите playbook на окружении prod.yml. При запуске ansible должен запросить у вас пароль. Убедитесь в работоспособности.  
  **ОТВЕТ:**

    ```bash
    ansible-playbook -i ./inventory/prod.yml site.yml --ask-vault-password
    Vault password:

    PLAY [Print os facts] *************************************************************************************

    TASK [Gathering Facts] *************************************************************************************
    [DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior
    Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See
    https://docs.ansible.com/ansible/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12.
    Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] *************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] *************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }

    PLAY RECAP *************************************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

9. Посмотрите при помощи ansible-doc список плагинов для подключения. Выберите подходящий для работы на control node.  
  **ОТВЕТ:**

    ```bash
    ansible-doc -t connection -l |grep "on control"
    local                          execute on controller
    ```

10. В prod.yml добавьте новую группу хостов с именем local, в ней разместите localhost с необходимым типом подключения.  
  **ОТВЕТ:**

    ```bash
    local:
        hosts:
        localhost:
            ansible_connection: local
    ```

11. Запустите playbook на окружении prod.yml. При запуске ansible должен запросить у вас пароль. Убедитесь что факты some_fact для каждого из хостов определены из верных group_vars.  
  **ОТВЕТ:**

    ```bash
    ansible-playbook -i ./inventory/prod.yml site.yml --ask-vault-password
    Vault password:

    PLAY [Print os facts] *************************************************************************************

    TASK [Gathering Facts] *************************************************************************************
    [WARNING]: Platform linux on host localhost is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter
    could change the meaning of that path. See https://docs.ansible.com/ansible/2.11/reference_appendices/interpreter_discovery.html for more information.
    ok: [localhost]
    [DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior
    Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See
    https://docs.ansible.com/ansible/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12.
    Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] *************************************************************************************
    ok: [localhost] => {
        "msg": "Archlinux"
    }
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] *************************************************************************************
    ok: [localhost] => {
        "msg": "all default fact"
    }
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }

    PLAY RECAP *************************************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```
