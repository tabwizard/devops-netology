# Домашняя работа к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательные задания

1. Есть скрипт:

    ```python
    #!/usr/bin/env python3
    a = 1
    b = '2'
    c = a + b
     ```

   * Какое значение будет присвоено переменной c?
   * Как получить для переменной c значение 12?
   * Как получить для переменной c значение 3?  

    __ОТВЕТ:__ Переменной `c` не будет присвоено значение, будет вызвано исключение приведения типов:
    >TypeError: unsupported operand type(s) for +: 'int' and 'str'

    Чтобы получить значение 12 нужно сделать: `c = int(str(a) + b)`
    Чтобы получить значение 3 нужно сделать: `c = a + int(b)`

2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

    ```python
    #!/usr/bin/env python3

    import os

    bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
        is_change = False
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break
    ```  

    __ОТВЕТ:__ Будем искать не только `modified` но и `new file`, а так же уберем `break` и добавим полный путь.  

    ```python
    #!/usr/bin/env python3

    import os

    bash_command = ["cd ~/netology/sysadm-homeworks", "pwd", "git add . 2>&1 >/dev/null", "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    fullpath = ""
    for result in result_os.split('\n'):
        is_change = False
        if fullpath == "":
            fullpath = result
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            is_change = True
        elif result.find('new file') != -1:
            prepare_result = result.replace('\tnew file:   ', '')
            is_change = True
        if is_change:
            print(fullpath+"/"+prepare_result.strip())
    ```

3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.  

    __ОТВЕТ:__ Предположим, что входной параметр или один, или отсутствует.  

    ```python
    #!/usr/bin/env python3

    import os
    import sys

    def check_modified(result_os):
        fullpath = ""
        for result in result_os.split('\n'):
            is_change = False
            if fullpath == "":
                fullpath = result
            if result_os.find('fatal: not a git repository') != -1:
                print(os.getcwd() + " - not a git repository")
                pass
            if result.find('modified') != -1:
                prepare_result = result.replace('\tmodified:   ', '')
                is_change = True
            elif result.find('new file') != -1:
                prepare_result = result.replace('\tnew file:   ', '')
                is_change = True
            if is_change:
                print(fullpath+"/"+prepare_result.strip())

    bash_command = ["cd ~/netology/sysadm-homeworks", "pwd", "git add . 2>&1 >/dev/null", "git status"]
    rslt_os = os.popen(' && '.join(bash_command)).read()
    check_modified(rslt_os)
    if len(sys.argv) > 1 and os.path.isdir(sys.argv[1]):
        bash_command[0] = "cd " + sys.argv[1]
        rslt_os = os.popen(' && '.join(bash_command)).read()
        check_modified(rslt_os)
    ```

4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.  

    __ОТВЕТ:__

    ```python
    #!/usr/bin/env python3

    import socket
    import time
    import sys

    service_array = {"drive.google.com":"", "mail.google.com":"", "google.com":""}
    while True:
        for url, ip in service_array.items():
            ip_new = socket.gethostbyname(url)
            if ip != "" and ip != ip_new:
                sys.stdout.write("[ERROR] " + url + " IP mismatch: " + ip + " " + ip_new + "\n")
            else:
                sys.stdout.write(url + "  " + ip_new + "\n")
            service_array[url] = ip_new
        time.sleep(60) 
    ```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
