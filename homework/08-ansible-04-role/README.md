# Домашняя работа к занятию "08.03 Работа с Roles"

## Подготовка к выполнению

1. Создайте два пустых публичных репозитория в любом своём проекте: kibana-role и filebeat-role.
2. Добавьте публичную часть своего ключа к своему профилю в github.

## Основная часть

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для elastic, kibana, filebeat и написать playbook для использования этих ролей. Ожидаемый результат: существуют два ваших репозитория с roles и один репозиторий с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:

   ```yaml
    ---
    - src: git@github.com:netology-code/mnt-homeworks-ansible.git
      scm: git
      version: "2.0.0"
      name: elastic 
   ```

2. При помощи `ansible-galaxy` скачать себе эту роль.
3. Создать новый каталог с ролью при помощи `ansible-galaxy role init kibana-role`.
4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`.
5. Перенести нужные шаблоны конфигов в `templates`.
6. Создать новый каталог с ролью при помощи `ansible-galaxy role init filebeat-role`.
7. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`.
8. Перенести нужные шаблоны конфигов в `templates`.
9. Описать в `README.md` обе роли и их параметры.
10. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию.
11. Добавьте roles в `requirements.yml` в playbook.
12. Переработайте playbook на использование roles.
13. Выложите playbook в репозиторий.
14. В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

**ОТВЕТ:**  Подготовил [terraform](./tf) на Яндекс.Облако для развертывания ВМ, написал [kibana-role](https://github.com/tabwizard/filebeat-role) и [filebeat-role](https://github.com/tabwizard/filebeat-role), добавил их в `requirements.yml`, скачал все роли:

```bash
wizard:08-ansible-04-role/ (main✗) $ ansible-galaxy install --role-file=requirements.yml --roles-path=roles --force
Starting galaxy role install process
- extracting elastic to /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/elastic
- elastic (2.0.0) was installed successfully
- extracting kibana-role to /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/kibana-role
- kibana-role (1.0.0) was installed successfully
- extracting filebeat-role to /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/filebeat-role
- filebeat-role (1.0.0) was installed successfully

```

Создал в каталоге с playbook каталог `files` чтобы было куда скачивать дистрибутивы.
Запустил `ansible-playbook`:

```bash
wizard:08-ansible-04-role/ (main✗) $ ansible-playbook -i inventory/prod.yml site.yml

PLAY [Install Elasticsearch] ****************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [el-instance]

TASK [elastic : Fail if unsupported system detected] ****************************************************************************************************************
skipping: [el-instance]

TASK [elastic : include_tasks] **************************************************************************************************************************************
included: /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/elastic/tasks/download_yum.yml for el-instance

TASK [elastic : Download Elasticsearch's rpm] ***********************************************************************************************************************
changed: [el-instance -> localhost]

TASK [elastic : Copy Elasticsearch to managed node] *****************************************************************************************************************
changed: [el-instance]

TASK [elastic : include_tasks] **************************************************************************************************************************************
included: /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/elastic/tasks/install_yum.yml for el-instance

TASK [elastic : Install Elasticsearch] ******************************************************************************************************************************
changed: [el-instance]

TASK [elastic : Configure Elasticsearch] ****************************************************************************************************************************
changed: [el-instance]

RUNNING HANDLER [elastic : restart Elasticsearch] *******************************************************************************************************************
changed: [el-instance]

PLAY [Install Kibana] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [kbn-instance]

TASK [kibana-role : Fail if unsupported system detected] ************************************************************************************************************
skipping: [kbn-instance]

TASK [kibana-role : include_tasks] **********************************************************************************************************************************
included: /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/kibana-role/tasks/download_yum.yml for kbn-instance

TASK [kibana-role : Download Kibana's rpm] **************************************************************************************************************************
ok: [kbn-instance -> localhost]

TASK [kibana-role : Copy Kibana to managed node] ********************************************************************************************************************
changed: [kbn-instance]

TASK [kibana-role : include_tasks] **********************************************************************************************************************************
included: /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/kibana-role/tasks/install_yum.yml for kbn-instance

TASK [kibana-role : Install Kibana] *********************************************************************************************************************************
changed: [kbn-instance]

TASK [kibana-role : Configure Kibana] *******************************************************************************************************************************
changed: [kbn-instance]

RUNNING HANDLER [kibana-role : restart Kibana] **********************************************************************************************************************
changed: [kbn-instance]

PLAY [Install Filebeat] *********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [flb-instance]

TASK [filebeat-role : Fail if unsupported system detected] **********************************************************************************************************
skipping: [flb-instance]

TASK [filebeat-role : include_tasks] ********************************************************************************************************************************
included: /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/filebeat-role/tasks/download_apt.yml for flb-instance

TASK [filebeat-role : Download Filebeat's deb] **********************************************************************************************************************
ok: [flb-instance -> localhost]

TASK [filebeat-role : Copy Filebeat to manage host] *****************************************************************************************************************
changed: [flb-instance]

TASK [filebeat-role : include_tasks] ********************************************************************************************************************************
included: /home/wizard/Dropbox/Разное/Netology/devops-netology/homework/08-ansible-04-role/roles/filebeat-role/tasks/install_apt.yml for flb-instance

TASK [filebeat-role : Install Filebeat] *****************************************************************************************************************************
changed: [flb-instance]

TASK [filebeat-role : Configure Filebeat] ***************************************************************************************************************************
changed: [flb-instance]

TASK [filebeat-role : Set filebeat systemwork] **********************************************************************************************************************
changed: [flb-instance]

TASK [filebeat-role : Load Kibana dashboard] ************************************************************************************************************************
ok: [flb-instance]

RUNNING HANDLER [filebeat-role : restart Filebeat] ******************************************************************************************************************
changed: [flb-instance]

PLAY RECAP **********************************************************************************************************************************************************
el-instance                : ok=8    changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
flb-instance               : ok=10   changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
kbn-instance               : ok=8    changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

Проверил, что все компоненты установились, настроились и работают:  

[![Screenshot](Screenshot_20210913_115616.png)](Screenshot_20210913_115616.png)

Данная рабочая версия ролей помечена тэгом `1.0.0`  
[Kibana-role](https://github.com/tabwizard/kibana-role/releases/tag/1.0.0)  
[Filebeat-role](https://github.com/tabwizard/filebeat-role/releases/tag/1.0.0)

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. Убедитесь в работоспособности своего стека: установите logstash на свой хост с elasticsearch, настройте конфиги logstash и filebeat так, чтобы они взаимодействовали друг с другом и elasticsearch корректно.
4. Выложите logstash-role в репозиторий. В ответ приведите ссылку.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
