# Домашняя работа к занятию "4.3. Языки разметки JSON и YAML"

## Обязательные задания

1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:

    ```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
    ```

    Нужно найти и исправить все ошибки, которые допускает наш сервис  

    __ОТВЕТ:__

    ```json
    {
        "info": "Sample JSON output from our service\t",
        "elements": [
        {
            "name": "first",
            "type": "server",
            "ip": "7175"
        },
        {
            "name": "second",
            "type": "proxy",
            "ip": "71.78.22.43"
        }
        ]
    }
    ```

1. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.  

    __ОТВЕТ:__

    ```python
    #!/usr/bin/env python3

    import socket
    import time
    import sys
    import json
    import yaml

    service_array = {"drive.google.com": "", "mail.google.com": "", "google.com": ""}
    while True:
        export_array = []
        for url, ip in service_array.items():
            ip_new = socket.gethostbyname(url)
            if ip != "" and ip != ip_new:
                sys.stdout.write("[ERROR] " + url + " IP mismatch: " + ip + " " + ip_new + "\n")
            else:
                sys.stdout.write(url + "  " + ip_new + "\n")
            service_array[url] = ip_new
            export_array.append({url: ip_new})
        with open("ip_list.json", "w") as json_file:
            json_file.write(json.dumps(export_array, indent=2))
        with open("ip_list.yaml", "w") as yaml_file:
            yaml_file.write(yaml.dump(export_array, explicit_start=True, explicit_end=True))
        time.sleep(60)
    ```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:

* Принимать на вход имя файла
* Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
* Распознавать какой формат данных в файле. Считается, что файлы *.json и*.yml могут быть перепутаны
* Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
* При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
* Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
