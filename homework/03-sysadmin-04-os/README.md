# Домашняя работа к занятию "3.4. Операционные системы, лекция 2"

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку,
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.  

    __ОТВЕТ:__

    ```bash
    vagrant:~/ $ wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
    vagrant:~/ $ tar xvzf ./node_exporter-1.1.2.linux-amd64.tar.gz
    node_exporter-1.1.2.linux-amd64/
    node_exporter-1.1.2.linux-amd64/LICENSE
    node_exporter-1.1.2.linux-amd64/NOTICE
    node_exporter-1.1.2.linux-amd64/node_exporter
    vagrant:~/ $ sudo mv ./node_exporter-1.1.2.linux-amd64/node_exporter /usr/bin/node-exporter
    vagrant:~/ $ rm -rf ./node_exporter-1.1.2.linux-amd64
    vagrant:~/ $ rm ./node_exporter-1.1.2.linux-amd64.tar.gz
    vagrant:~/ $ sudo vim /lib/systemd/system/node-exporter.service
    ...
    vagrant:~/ $ systemctl cat node-exporter.service
    # /lib/systemd/system/node-exporter.service
    [Unit]
    Description=The Prometheus Node Exporter exposes a wide variety of hardware- and kernel-related metrics.
    Documentation=https://github.com/prometheus/node_exporter
    After=network-online.target
    [Service]
    EnvironmentFile=-/etc/node-exporter.conf
    ExecStart=/usr/bin/node-exporter $NODEEXPORTERARGS
    KillMode=process
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target
    
    vagrant:~/ $ echo NODEEXPORTERARGS=\"\" |sudo tee /etc/node-exporter.conf
    vagrant:~/ $ sudo systemctl enable --now node-exporter.service
    vagrant:~/ $ systemctl status node-exporter.service
    ● node-exporter.service - The Prometheus Node Exporter exposes a wide variety of hardware- and kernel-related metrics.
    Loaded: loaded (/lib/systemd/system/node-exporter.service; enabled; vendor preset: enabled)
    Active: active (running) since Sun 2021-04-25 13:36:51 +07; 7s ago
    Docs: https://github.com/prometheus/node_exporter
    Main PID: 2107 (node-exporter)
    Tasks: 4 (limit: 2321)
    Memory: 2.2M
    CGroup: /system.slice/node-exporter.service
    └─2107 /usr/bin/node-exporter
    ...
    vagrant:~/ $ sudo systemctl stop node-exporter.service
    vagrant:~/ $ systemctl status node-exporter.service
    ● node-exporter.service - The Prometheus Node Exporter exposes a wide variety of hardware- and kernel-related metrics.
    Loaded: loaded (/lib/systemd/system/node-exporter.service; enabled; vendor preset: enabled)
    Active: inactive (dead) since Sun 2021-04-25 13:43:06 +07; 2s ago
    Docs: https://github.com/prometheus/node_exporter
    Process: 700 ExecStart=/usr/bin/node-exporter $NODEEXPORTERARGS (code=killed, signal=TERM)
    Main PID: 700 (code=killed, signal=TERM)
    ...
    vagrant:~/ $ sudo reboot
    ...
    vagrant:~/ $ curl http://localhost:9100/
        <html>
        <head><title>Node Exporter</title></head>
        <body>
        <h1>Node Exporter</h1>
        <p><a href="/metrics">Metrics</a></p>
        </body>
        </html>%  
    ```

1. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.  

    __ОТВЕТ:__

    ```bash
    vagrant:~/ $ cat /etc/node-exporter.conf
    NODEEXPORTERARGS="--collector.disable-defaults --collector.cpu --collector.cpufreq --collector.meminfo --collector.vmstat --collector.diskstats --collector.filesystem --collector.netclass --collector.netdev --collector.netstat"
    ```

    >_--collector.disable-defaults_ - enable only some specific collector  
    _cpu_ - Exposes CPU statistics  
    _cpufreq_ - Exposes CPU frequency statistics  
    _meminfo_ - Exposes memory statistics.  
    _vmstat_ - Exposes statistics from /proc/vmstat.  
    _diskstats_ - Exposes disk I/O statistics.  
    _filesystem_ - Exposes filesystem statistics, such as disk space used.  
    _netclass_ - Exposes network interface info from /sys/class/net/  
    _netdev_ - Exposes network interface statistics such as bytes transferred.  
    _netstat_ - Exposes network statistics from /proc/net/netstat.
1. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.  

    __ОТВЕТ:__  Виртуальную машину `Netdata` установил, в конфиге поменял адрес `bind socket to IP = 0.0.0.0`, в `Vagrantfile` добавил проброс портов, на хост-машине открыл в браузере `http://127.0.0.1:199999`
    [![Screenshot_20210425_173524.png](https://github.com/tabwizard/devops-netology/raw/03-sysadmin-04-os/img/Screenshot_20210425_173524.png)](https://github.com/tabwizard/devops-netology/blob/03-sysadmin-04-os/img/Screenshot_20210425_173524.png)

1. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?  

    __ОТВЕТ:__ На реальной машине вывод `sudo dmesg | grep -i virtual` пустой, на виртуалке:

    ```bash
    vagrant:~/ $ sudo dmesg | grep -i virtual
    [    0.000000] DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
    [    0.022090] CPU MTRRs all blank - virtualized system.
    [    0.139073] Booting paravirtualized kernel on KVM
    [    2.544860] systemd[1]: Detected virtualization oracle.
    ```  

1. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?  

    __ОТВЕТ:__ по-умолчанию макисмальное количество открытых файловых дескрипторов через `fs.nr_open` задано:

    ```bash
    vagrant:~/ $ sudo sysctl -a|grep fs.nr_open
    fs.nr_open = 1048576
    ```  

    достичь этого значения не позволит так же

    ```bash
    vagrant:~/ $ ulimit -n
    1024
    ```

1. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.  

    __ОТВЕТ:__

    ```bash
    vagrant:~/ $ sudo -i
    root@vagrant:~# unshare -f --pid --mount-proc sleep 1h &
    [1] 1817
    root@vagrant:~# ps aux|grep sleep
    root        1817  0.0  0.0   8080   580 pts/0    S    18:55   0:00 unshare -f --pid --mount-proc sleep 1h
    root        1818  0.0  0.0   8076   588 pts/0    S    18:55   0:00 sleep 1h
    root        1820  0.0  0.0   8900   740 pts/0    S+   18:56   0:00 grep --color=auto sleep
    root@vagrant:~# nsenter --target 1818 --pid --mount
    root@vagrant:/# ps aux
    USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root           1  0.0  0.0   8076   588 pts/0    S    18:55   0:00 sleep 1h
    root           2  0.0  0.1   9836  3992 pts/0    S    18:56   0:00 -bash
    root          11  0.0  0.1  11492  3444 pts/0    R+   18:56   0:00 ps aux
    ```

1. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?  

    __ОТВЕТ:__ `:(){ :|:& };:` - форк-бомба - функция с двойной фоновой рекурсией.
    По истечении некоторого времени в выводе `dmesg` видим: `cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-5.scope` выполнение форк-бомбы было прервано с использованием механизма `cgroup`  
    >Контрольная группа (англ. control group, cgroups[1], cgroup[2]) — группа процессов в Linux, для которой механизмами ядра наложена изоляция и установлены ограничения на некоторые вычислительные ресурсы (процессорные, сетевые, ресурсы памяти, ресурсы ввода-вывода). Механизм позволяет образовывать иерархические группы процессов с заданными ресурсными свойствами и обеспечивает программное управление ими.  

    По-умолчанию количество процессов ограничено:  

    ```bash
    vagrant:~/ $ ulimit -u
    7737
    ```  

    Можно ограничить `ulimit -S -u 500` Так же можно добавить в файл `/etc/security/limits.conf` строку `vagrant   -    nproc   500` чтобы ограничить максимальное количество процессов пользователя vagrant пятьюстами штуками.
