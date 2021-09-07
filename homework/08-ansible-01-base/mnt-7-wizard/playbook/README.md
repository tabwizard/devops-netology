# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?  
**ОТВЕТ:** файл `examp.yml` с `some_fact` расположен в `playbook\group_vars\all\`

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?  
**ОТВЕТ:** `ansible-playbook -i ./inventory/test.yml site.yml`

3. Какой командой можно зашифровать файл?  
**ОТВЕТ:** `ansible-vault encrypt ./group_vars/deb/examp.yml`

4. Какой командой можно расшифровать файл?  
**ОТВЕТ:** `ansible-vault decrypt ./group_vars/deb/examp.yml`

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?  
**ОТВЕТ:** `ansible-vault view ./group_vars/deb/examp.yml`

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?  
**ОТВЕТ:** `ansible-playbook -i ./inventory/prod.yml site.yml --ask-vault-password`

7. Как называется модуль подключения к host на windows?  
**ОТВЕТ:** `winrm                          Run tasks over Microsoft's WinRM`

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh  
**ОТВЕТ:** `ansible-doc -t connection ssh`

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?  
**ОТВЕТ:**  

    ```yaml
   - remote_user
        User name with which to login to the remote server, normally set by the remote_user keyword.
        If no user is supplied, Ansible will let the ssh client binary choose the user as it normally
        [Default: (null)]
        set_via:
          env:
          - name: ANSIBLE_REMOTE_USER
          ini:
          - key: remote_user
            section: defaults
          vars:
          - name: ansible_user
          - name: ansible_ssh_user

        cli:
        - name: user

    ```
