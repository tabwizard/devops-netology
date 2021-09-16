# Домашнее задание к занятию "08.05 Тестирование Roles"

## Подготовка к выполнению

1. Установите molecule: `pip3 install "molecule==3.4.0"`
2. Соберите локальный образ на основе [Dockerfile](./Dockerfile)

## Основная часть

Наша основная цель - настроить тестирование наших ролей. Задача: сделать сценарии тестирования для kibana, logstash. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test` внутри корневой директории elasticsearch-role, посмотрите на вывод команды.  

    **ОТВЕТ:** После запуска `molecule test` внутри корневой директории elasticsearch-role обнаруживаем кучу ошибок, начинаем исправлять:  
      - Так как роль после выполнения `ansible-galaxy install --role-file=requirements.yml --roles-path=roles --force` установилась в каталог `roles/elastic`, то исправляем `include_role: name: "mnt-homeworks-ansible"` в файлах `molecule/default/converge.yml` и `molecule/alternative/converge.yml` на `include_role: name: "elastic"`
      - Исправляем ошибку скачивания дистрибутивов в несуществующий каталог `files` с помощью добавления в роль таски `create_dir.yml` следующего содержания:  

        ```yaml
        - name: "Create directory to download"
          file:
            path: files
            state: directory
          delegate_to: localhost
        ```

        перед тасками скачивающими дистрибутивы.
      - В хэндлере, который перезапускает сервис, исправляем условие выполнения на:

        ```yaml
          when: (ansible_virtualization_type != 'docker') and
                (ansible_virtualization_type != 'kvm')
        ```

        После этих исправлений запуск `molecule test` проходит без ошибок и
        <details>
        <summary>выдает долгожданное: (развернуть)</summary>

        ```bash
        PLAY RECAP *********************************************************************
        centos7                    : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
        ubuntu                     : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

        INFO     Idempotence completed successfully.
        INFO     Running default > side_effect
        WARNING  Skipping, side effect playbook not configured.
        INFO     Running default > verify
        INFO     Running Ansible Verifier

        PLAY [Verify] ******************************************************************

        TASK [Example assertion] *******************************************************
        ok: [centos7] => {
            "changed": false,
            "msg": "All assertions passed"
        }
        ok: [ubuntu] => {
            "changed": false,
            "msg": "All assertions passed"
        }

        PLAY RECAP *********************************************************************
        centos7                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
        ubuntu                     : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

        INFO     Verifier completed successfully.
        INFO     Running default > cleanup
        WARNING  Skipping, cleanup playbook not configured.
        INFO     Running default > destroy
        ```

        </details>

2. Перейдите в каталог с ролью kibana-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
4. Добавьте несколько assert'ов в verify.yml файл, для  проверки работоспособности kibana-role (проверка, что web отвечает, проверка логов, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.

    **ОТВЕТ 2-4:** Создал для роли `kibana-role` сценарий тестирования по умолчанию,
    Добавил для инстансов разные дистрибутивы (), протестировал роль, исправил ошибки.
    Добавил 2 assert`a на существование pid и log файлов kibana,
    <details>
    <summary> проверил: (развернуть)</summary>

    ```bash
    wizard:kibana-role/ (master✗) $ molecule test
    INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
    INFO     Performing prerun...
    INFO     Guessed /home/wizard/Dropbox/Разное/Netology/kibana-role as project root directory
    WARNING  Computed fully qualified role name of kibana_role does not follow current galaxy requirements.
    Please edit meta/main.yml and assure we can correctly determine full role name:

    galaxy_info:
    role_name: my_name  # if absent directory name hosting role is used instead
    namespace: my_galaxy_namespace  # if absent, author is used instead

    Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
    Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

    As an alternative, you can add 'role-name' to either skip_list or warn_list.

    INFO     Using /home/wizard/.cache/ansible-lint/1301d8/roles/kibana_role symlink to current repository in order to enable Ansible to find the role using its expected full name.
    INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/wizard/.cache/ansible-lint/1301d8/roles
    INFO     Running default > dependency
    WARNING  Skipping, missing the requirements file.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > lint
    INFO     Lint is disabled.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    INFO     Sanity checks: 'docker'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=centos8)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) deletion to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '734915026336.143312', 'results_file': '/home/wizard/.ansible_async/734915026336.143312', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '676827092117.143330', 'results_file': '/home/wizard/.ansible_async/676827092117.143330', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '645426298832.143347', 'results_file': '/home/wizard/.ansible_async/645426298832.143347', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    TASK [Delete docker network(s)] ************************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Running default > syntax

    playbook: /home/wizard/Dropbox/Разное/Netology/kibana-role/molecule/default/converge.yml
    INFO     Running default > create

    PLAY [Create] ******************************************************************

    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Create Dockerfiles from image names] *************************************
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 2, 'ansible_index_var': 'i'})

    TASK [Build an Ansible compatible image (new)] *********************************
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7)
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:8)
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/ubuntu:latest)

    TASK [Create docker network(s)] ************************************************

    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=centos8)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) creation to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '118538445343.143746', 'results_file': '/home/wizard/.ansible_async/118538445343.143746', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '875701684663.143764', 'results_file': '/home/wizard/.ansible_async/875701684663.143764', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '198613886643.143781', 'results_file': '/home/wizard/.ansible_async/198613886643.143781', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

    INFO     Running default > prepare
    WARNING  Skipping, prepare playbook not configured.
    INFO     Running default > converge

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos8]
    ok: [ubuntu]
    ok: [centos7]

    TASK [Include kibana-role] *****************************************************

    TASK [kibana-role : Fail if unsupported system detected] ***********************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [kibana-role : Create directory to download] ******************************
    ok: [centos8 -> localhost]
    ok: [ubuntu -> localhost]
    ok: [centos7 -> localhost]

    TASK [kibana-role : include_tasks] *********************************************
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/download_yum.yml for centos7
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/download_dnf.yml for centos8
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/download_apt.yml for ubuntu

    TASK [kibana-role : Download Kibana's rpm] *************************************
    ok: [centos7 -> localhost]

    TASK [kibana-role : Copy Kibana to managed node] *******************************
    changed: [centos7]

    TASK [kibana-role : Download Kibana's rpm] *************************************
    ok: [centos8 -> localhost]

    TASK [kibana-role : Copy Kibana to managed node] *******************************
    changed: [centos8]

    TASK [kibana-role : Download Kibana's deb] *************************************
    ok: [ubuntu -> localhost]

    TASK [kibana-role : Copy Kibana to manage host] ********************************
    changed: [ubuntu]

    TASK [kibana-role : include_tasks] *********************************************
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/install_yum.yml for centos7
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/install_dnf.yml for centos8
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/install_apt.yml for ubuntu

    TASK [kibana-role : Install Kibana] ********************************************
    changed: [centos7]

    TASK [kibana-role : Install Kibana] ********************************************
    changed: [centos8]

    TASK [kibana-role : Install Kibana] ********************************************
    changed: [ubuntu]

    TASK [kibana-role : Configure Kibana] ******************************************
    changed: [ubuntu]
    changed: [centos8]
    changed: [centos7]

    RUNNING HANDLER [kibana-role : restart Kibana] *********************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    PLAY RECAP *********************************************************************
    centos7                    : ok=8    changed=3    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
    centos8                    : ok=8    changed=3    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
    ubuntu                     : ok=8    changed=3    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

    INFO     Running default > idempotence

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos8]
    ok: [ubuntu]
    ok: [centos7]

    TASK [Include kibana-role] *****************************************************

    TASK [kibana-role : Fail if unsupported system detected] ***********************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [kibana-role : Create directory to download] ******************************
    ok: [centos8 -> localhost]
    ok: [ubuntu -> localhost]
    ok: [centos7 -> localhost]

    TASK [kibana-role : include_tasks] *********************************************
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/download_yum.yml for centos7
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/download_dnf.yml for centos8
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/download_apt.yml for ubuntu

    TASK [kibana-role : Download Kibana's rpm] *************************************
    ok: [centos7 -> localhost]

    TASK [kibana-role : Copy Kibana to managed node] *******************************
    ok: [centos7]

    TASK [kibana-role : Download Kibana's rpm] *************************************
    ok: [centos8 -> localhost]

    TASK [kibana-role : Copy Kibana to managed node] *******************************
    ok: [centos8]

    TASK [kibana-role : Download Kibana's deb] *************************************
    ok: [ubuntu -> localhost]

    TASK [kibana-role : Copy Kibana to manage host] ********************************
    ok: [ubuntu]

    TASK [kibana-role : include_tasks] *********************************************
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/install_yum.yml for centos7
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/install_dnf.yml for centos8
    included: /home/wizard/Dropbox/Разное/Netology/kibana-role/tasks/install_apt.yml for ubuntu

    TASK [kibana-role : Install Kibana] ********************************************
    ok: [centos7]

    TASK [kibana-role : Install Kibana] ********************************************
    ok: [centos8]

    TASK [kibana-role : Install Kibana] ********************************************
    ok: [ubuntu]

    TASK [kibana-role : Configure Kibana] ******************************************
    ok: [centos7]
    ok: [centos8]
    ok: [ubuntu]

    PLAY RECAP *********************************************************************
    centos7                    : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
    centos8                    : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
    ubuntu                     : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Idempotence completed successfully.
    INFO     Running default > side_effect
    WARNING  Skipping, side effect playbook not configured.
    INFO     Running default > verify
    INFO     Running Ansible Verifier

    PLAY [Verify] ******************************************************************

    TASK [Check file /usr/share/kibana/bin/kibana] *********************************
    ok: [centos7]
    ok: [ubuntu]
    ok: [centos8]

    TASK [Check file /var/log/kibana/] ***********************************
    ok: [centos7]
    ok: [ubuntu]
    ok: [centos8]

    TASK [Assert file kibana bin & kibana in log] **********************************
    ok: [centos7] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    ok: [centos8] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    ok: [ubuntu] => {
        "changed": false,
        "msg": "All assertions passed"
    }

    PLAY RECAP *********************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    centos8                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


    INFO     Verifier completed successfully.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=centos8)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) deletion to complete] *******************************
    FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '240101795145.158861', 'results_file': '/home/wizard/.ansible_async/240101795145.158861', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '924094414102.158879', 'results_file': '/home/wizard/.ansible_async/924094414102.158879', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '850156734002.158896', 'results_file': '/home/wizard/.ansible_async/850156734002.158896', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    TASK [Delete docker network(s)] ************************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Pruning extra files from scenario ephemeral directory
    ```

    </details>

5. Повторите шаги 2-4 для filebeat-role.

    **ОТВЕТ:** Проделал то же самое  
    <details>
    <summary>для filebeat-role: (развернуть)</summary>

    ```bash
    wizard:filebeat-role/ (master✗) $ molecule test
    INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
    INFO     Performing prerun...
    INFO     Guessed /home/wizard/Dropbox/Разное/Netology/filebeat-role as project root directory
    WARNING  Computed fully qualified role name of filebeat-role does not follow current galaxy requirements.
    Please edit meta/main.yml and assure we can correctly determine full role name:

    galaxy_info:
    role_name: my_name  # if absent directory name hosting role is used instead
    namespace: my_galaxy_namespace  # if absent, author is used instead

    Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
    Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

    As an alternative, you can add 'role-name' to either skip_list or warn_list.

    INFO     Using /home/wizard/.cache/ansible-lint/73a37e/roles/filebeat-role symlink to current repository in order to enable Ansible to find the role using its expected full name.
    INFO     Added ANSIBLE_ROLES_PATH=~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/wizard/.cache/ansible-lint/73a37e/roles
    INFO     Running default > dependency
    WARNING  Skipping, missing the requirements file.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > lint
    INFO     Lint is disabled.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    INFO     Sanity checks: 'docker'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=centos8)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) deletion to complete] *******************************
    ok: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '572336308927.265090', 'results_file': '/home/wizard/.ansible_async/572336308927.265090', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    ok: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '70546995728.265108', 'results_file': '/home/wizard/.ansible_async/70546995728.265108', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    ok: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '497249627725.265125', 'results_file': '/home/wizard/.ansible_async/497249627725.265125', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    TASK [Delete docker network(s)] ************************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Running default > syntax

    playbook: /home/wizard/Dropbox/Разное/Netology/filebeat-role/molecule/default/converge.yml
    INFO     Running default > create

    PLAY [Create] ******************************************************************

    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}) 
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}) 
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}) 

    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Create Dockerfiles from image names] *************************************
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}) 
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}) 
    skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}) 

    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})
    ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 2, 'ansible_index_var': 'i'})

    TASK [Build an Ansible compatible image (new)] *********************************
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7) 
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:8) 
    skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/ubuntu:latest) 

    TASK [Create docker network(s)] ************************************************

    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
    ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=centos8)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) creation to complete] *******************************
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '981759789525.265398', 'results_file': '/home/wizard/.ansible_async/981759789525.265398', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '351197455525.265416', 'results_file': '/home/wizard/.ansible_async/351197455525.265416', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '677491302549.265433', 'results_file': '/home/wizard/.ansible_async/677491302549.265433', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

    INFO     Running default > prepare
    WARNING  Skipping, prepare playbook not configured.
    INFO     Running default > converge

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [ubuntu]
    ok: [centos8]
    ok: [centos7]

    TASK [Include filebeat-role] ***************************************************

    TASK [filebeat-role : Fail if unsupported system detected] *********************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [filebeat-role : Create directory to download] ****************************
    ok: [ubuntu -> localhost]
    ok: [centos8 -> localhost]
    ok: [centos7 -> localhost]

    TASK [filebeat-role : include_tasks] *******************************************
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/download_yum.yml for centos7
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/download_dnf.yml for centos8
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/download_apt.yml for ubuntu

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    ok: [centos7 -> localhost]

    TASK [filebeat-role : Copy Filebeat to managed node] ***************************
    changed: [centos7]

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    ok: [centos8 -> localhost]

    TASK [filebeat-role : Copy Filebeat to managed node] ***************************
    changed: [centos8]

    TASK [filebeat-role : Download Filebeat's deb] *********************************
    ok: [ubuntu -> localhost]

    TASK [filebeat-role : Copy Filebeat to manage host] ****************************
    changed: [ubuntu]

    TASK [filebeat-role : include_tasks] *******************************************
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/install_yum.yml for centos7
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/install_dnf.yml for centos8
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/install_apt.yml for ubuntu

    TASK [filebeat-role : Install Filebeat] ****************************************
    changed: [centos7]

    TASK [filebeat-role : Install Filebeat] ****************************************
    changed: [centos8]

    TASK [filebeat-role : Install Filebeat] ****************************************
    changed: [ubuntu]

    TASK [filebeat-role : Configure Filebeat] **************************************
    changed: [centos7]
    changed: [ubuntu]
    changed: [centos8]

    TASK [filebeat-role : Set filebeat systemwork] *********************************
    changed: [ubuntu]
    changed: [centos8]
    changed: [centos7]

    TASK [filebeat-role : Load Kibana dashboard] ***********************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    RUNNING HANDLER [filebeat-role : restart Filebeat] *****************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    PLAY RECAP *********************************************************************
    centos7                    : ok=9    changed=4    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
    centos8                    : ok=9    changed=4    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
    ubuntu                     : ok=9    changed=4    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

    INFO     Running default > idempotence

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [centos8]
    ok: [ubuntu]
    ok: [centos7]

    TASK [Include filebeat-role] ***************************************************

    TASK [filebeat-role : Fail if unsupported system detected] *********************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    TASK [filebeat-role : Create directory to download] ****************************
    ok: [ubuntu -> localhost]
    ok: [centos7 -> localhost]
    ok: [centos8 -> localhost]

    TASK [filebeat-role : include_tasks] *******************************************
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/download_yum.yml for centos7
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/download_dnf.yml for centos8
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/download_apt.yml for ubuntu

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    ok: [centos7 -> localhost]

    TASK [filebeat-role : Copy Filebeat to managed node] ***************************
    ok: [centos7]

    TASK [filebeat-role : Download Filebeat's rpm] *********************************
    ok: [centos8 -> localhost]

    TASK [filebeat-role : Copy Filebeat to managed node] ***************************
    ok: [centos8]

    TASK [filebeat-role : Download Filebeat's deb] *********************************
    ok: [ubuntu -> localhost]

    TASK [filebeat-role : Copy Filebeat to manage host] ****************************
    ok: [ubuntu]

    TASK [filebeat-role : include_tasks] *******************************************
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/install_yum.yml for centos7
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/install_dnf.yml for centos8
    included: /home/wizard/Dropbox/Разное/Netology/filebeat-role/tasks/install_apt.yml for ubuntu

    TASK [filebeat-role : Install Filebeat] ****************************************
    ok: [centos7]

    TASK [filebeat-role : Install Filebeat] ****************************************
    ok: [centos8]

    TASK [filebeat-role : Install Filebeat] ****************************************
    ok: [ubuntu]

    TASK [filebeat-role : Configure Filebeat] **************************************
    ok: [centos7]
    ok: [centos8]
    ok: [ubuntu]

    TASK [filebeat-role : Set filebeat systemwork] *********************************
    ok: [centos8]
    ok: [ubuntu]
    ok: [centos7]

    TASK [filebeat-role : Load Kibana dashboard] ***********************************
    skipping: [centos7]
    skipping: [centos8]
    skipping: [ubuntu]

    PLAY RECAP *********************************************************************
    centos7                    : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
    centos8                    : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
    ubuntu                     : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

    INFO     Idempotence completed successfully.
    INFO     Running default > side_effect
    WARNING  Skipping, side effect playbook not configured.
    INFO     Running default > verify
    INFO     Running Ansible Verifier

    PLAY [Verify] ******************************************************************

    TASK [Check file /usr/share/filebeat/bin/filebeat] *****************************
    ok: [centos7]
    ok: [centos8]
    ok: [ubuntu]

    TASK [Check file /var/log/filebeat/filebeat] ***********************************
    ok: [centos7]
    ok: [ubuntu]
    ok: [centos8]

    TASK [Assert file filebeat bin & filebeat log-file] ****************************
    ok: [centos7] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    ok: [centos8] => {
        "changed": false,
        "msg": "All assertions passed"
    }
    ok: [ubuntu] => {
        "changed": false,
        "msg": "All assertions passed"
    }

    PLAY RECAP *********************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    centos8                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Verifier completed successfully.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=centos7)
    changed: [localhost] => (item=centos8)
    changed: [localhost] => (item=ubuntu)

    TASK [Wait for instance(s) deletion to complete] *******************************
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '373280828185.275514', 'results_file': '/home/wizard/.ansible_async/373280828185.275514', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '213296482186.275532', 'results_file': '/home/wizard/.ansible_async/213296482186.275532', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
    changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '588577366333.275549', 'results_file': '/home/wizard/.ansible_async/588577366333.275549', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

    TASK [Delete docker network(s)] ************************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Pruning extra files from scenario ephemeral directory

    ```
    </details>

6. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

### Tox

1. Запустите `docker run -it -v <path_to_repo>:/opt/elasticsearch-role -w /opt/elasticsearch-role /bin/bash`, где path_to_repo - путь до корня репозитория с elasticsearch-role на вашей файловой системе.
2. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
3. Добавьте файл `tox.ini` в корень репозитория каждой своей роли.
4. Создайте облегчённый сценарий для `molecule`. Проверьте его на исполнимость.
5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
6. Запустите `docker` контейнер так, чтобы внутри оказались обе ваши роли.
7. Зайти поочерёдно в каждую из них и запустите команду `tox`. Убедитесь, что всё отработало успешно.
8. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в каждом репозитории. Ссылки на репозитории являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. В ролях добавьте тестирование в раздел `verify.yml`. Данный раздел должен проверять, что logstash через команду `logstash -e 'input { stdin { } } output { stdout {} }'`  отвечает адекватно.
4. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
5. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
6. Выложите свои roles в репозитории. В ответ приведите ссылки.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
