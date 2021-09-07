# Описание playbook

## Общая часть

Playbook устанавливает Java на все хосты описанные в `inventory/prod.yml`. На хосты в группе `elasticsearch` дополнительно устанавливает и настраивает elasticsearch, а на хосты в группе `kibana` соответственно kibana.

## Описательная часть

```yaml
---
- name: Install Java   # Play для установки Java
  hosts: all   # на все хосты
  tasks:   # состоит из тасок:
    - name: Set facts for Java 11 vars
      set_fact:   # устанавливаем переменную java_home
        java_home: "/opt/jdk/{{ java_jdk_version }}"
      tags: java   # Все таски в Play Install Java помечены тэгом java
    - name: Upload .tar.gz file containing binaries from local storage
      copy:   # Копируем дистрибутив java из локальной директории на хост
        src: "{{ java_oracle_jdk_package }}"   # откуда
        dest: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"   # куда
        mode: 0644   # не забываем про права доступа на файл, а то lint будет ругаться
      register: download_java_binaries   # куда занести результат выполнения
      until: download_java_binaries is succeeded   # выполнять до тех пор пока не получится
      tags: java   # и, естественно, тэг
    - name: Ensure installation dir exists   # проверяем существование домашнего каталога java
      become: true   # проводим проверку с повышением прав, а то не будет доступа
      file:   # проверяем существование файла/каталога
        state: directory   # все-таки каталога
        path: "{{ java_home }}"   # по такому пути
        mode: 0755 # с такими правами
      tags: java # и, естественно, тэг
    - name: Extract java in the installation directory # распаковываем дистрибутив java
      become: true # с повышением прав, а то не получится
      unarchive: # распаковываем
        copy: false # не копируем с локального контроллера
        src: "/tmp/jdk-{{ java_jdk_version }}.tar.gz" # откуда
        dest: "{{ java_home }}" # куда
        extra_opts: [--strip-components=1] # не создаем папку верхнего уровня
        creates: "{{ java_home }}/bin/java" # в результате должен появиться файл, если есть, не выполняем
      tags:
        - java # и, естественно, тэг, правда немного в другой форме записи
    - name: Export environment variables # переменные окружения на хосте для java
      become: true # с повышением прав, а то не получится
      template: # воспользуемся шаблоном
        src: jdk.sh.j2 # откуда
        dest: /etc/profile.d/jdk.sh # куда
        mode: 0755 # с такими правами
      tags: java   # и, естественно, тэг
- name: Install Elasticsearch   # Play для установки Elasticsearch
  hosts: elasticsearch   # только на хосты в группе elasticsearch
  tasks:   # состоит из тасок
    - name: Upload tar.gz Elasticsearch from remote URL   # загружаем дистрибутив
      get_url:   # получаем из интернета
        url: "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"   # адрес источника
        dest: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"   # назначение
        mode: 0644   # с такими правами
        timeout: 60   # таймаут ожидания запроса
        force: true   # перезаписываем файл при изменении источника
        validate_certs: false   # не проверяем сертификаты
      register: get_elastic # куда занести результат выполнения
      until: get_elastic is succeeded   # выполнять до тех пор пока не получится
      tags: elastic   # Все таски в Play Install Elasticsearch помечены тэгом elastic
    - name: Create directory for Elasticsearch
      file:   # проверяем существование домашнего каталога elastic
        state: directory   # точно каталога
        path: "{{ elastic_home }}"   # по такому пути
        mode: 0755   # с такими правами
      tags: elastic   # и, естественно, тэг
    - name: Extract Elasticsearch in the installation directory   # Распаковываем дистрибутив Elasticsearch
      become: true  # с повышением прав, а то не получится
      unarchive: # распаковываем
        copy: false # не копируем с локального контроллера
        src: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz" # откуда
        dest: "{{ elastic_home }}" # куда
        extra_opts: [--strip-components=1] # не создаем папку верхнего уровня
        creates: "{{ elastic_home }}/bin/elasticsearch" # в результате должен появиться файл, если есть, не выполняем
      tags:
        - elastic # и, естественно, тэг, правда немного в другой форме записи, как будто их много
    - name: Set environment Elastic # переменные окружения на хосте для 
      become: true # с повышением прав, а то не получится
      template: # воспользуемся шаблоном
        src: templates/elk.sh.j2 # откуда
        dest: /etc/profile.d/elk.sh # куда
        mode: 0755 # с такими правами
      tags: elastic # и, естественно, тэг
- name: Install Kibana # Play для установки Kibana абсолютно такой же как и для установки Elasticsearch, поэтому в пояснениях не нуждается
  hosts: kibana # только для группы хостов kibana и так далее
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
