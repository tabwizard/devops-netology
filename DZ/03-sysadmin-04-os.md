# Домашняя работа к занятию "3.4. Операционные системы, лекция 2"

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку,
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.  
    __ОТВЕТ:__

    ```bash
    vagrant:~/ $ wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
    vagrant:~/ $ tar xvzf node_exporter-1.1.2.linux-amd64.tar.gz
    node_exporter-1.1.2.linux-amd64/
    node_exporter-1.1.2.linux-amd64/LICENSE
    node_exporter-1.1.2.linux-amd64/NOTICE
    node_exporter-1.1.2.linux-amd64/node_exporter
    vagrant:~/ $ sudo mv node_exporter-1.1.2.linux-amd64/node_exporter /usr/bin/node-exporter
    vagrant:~/ $ rm -rf ./node_exporter-1.1.2.linux-amd64
    vagrant:~/ $ rm ./node_exporter-1.1.2.linux-amd64.tar.gz
    vagrant:~/ $ sudo touch /lib/systemd/system/node-exporter.service
    vagrant:~/ $ sudo vim /lib/systemd/system/node-exporter.service
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
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.464Z caller=node_exporter.go:113 collector=thermal_zone
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.464Z caller=node_exporter.go:113 collector=time
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.464Z caller=node_exporter.go:113 collector=timex
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.465Z caller=node_exporter.go:113 collector=udp_queues
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.465Z caller=node_exporter.go:113 collector=uname
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.465Z caller=node_exporter.go:113 collector=vmstat
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.465Z caller=node_exporter.go:113 collector=xfs
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.465Z caller=node_exporter.go:113 collector=zfs
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.465Z caller=node_exporter.go:195 msg="Listening on" address=:9100
    Apr 25 13:36:51 vagrant node-exporter[2107]: level=info ts=2021-04-25T06:36:51.466Z caller=tls_config.go:191 msg="TLS is disabled." http2=false

    vagrant:~/ $ sudo systemctl stop node-exporter.service
    vagrant:~/ $ systemctl status node-exporter.service
    ● node-exporter.service - The Prometheus Node Exporter exposes a wide variety of hardware- and kernel-related metrics.
    Loaded: loaded (/lib/systemd/system/node-exporter.service; enabled; vendor preset: enabled)
    Active: inactive (dead) since Sun 2021-04-25 13:43:06 +07; 2s ago
    Docs: https://github.com/prometheus/node_exporter
    Process: 700 ExecStart=/usr/bin/node-exporter $NODEEXPORTERARGS (code=killed, signal=TERM)
    Main PID: 700 (code=killed, signal=TERM)
    ...
    vagrant:~/ $ sudo reeboot
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
    >--collector.disable-defaults - enable only some specific collector  
    cpu - Exposes CPU statistics  
    cpufreq - Exposes CPU frequency statistics  
    meminfo - Exposes memory statistics.  
    vmstat - Exposes statistics from /proc/vmstat.  
    diskstats - Exposes disk I/O statistics.  
    filesystem - Exposes filesystem statistics, such as disk space used.  
    netclass - Exposes network interface info from /sys/class/net/  
    netdev - Exposes network interface statistics such as bytes transferred.  
    netstat - Exposes network statistics from /proc/net/netstat.   
1. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

1. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?
1. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?
1. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.
1. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?