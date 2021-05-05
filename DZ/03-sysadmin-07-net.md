# Домашняя работа к занятию "3.7. Компьютерные сети, лекция 2"

1. На лекции мы обсудили, что манипулировать размером окна необходимо для эффективного наполнения приемного буфера участников TCP сессии (Flow Control). Подобная проблема в полной мере возникает в сетях с высоким RTT. Например, если вы захотите передать 500 Гб бэкап из региона Юга-Восточной Азии на Восточное побережье США. [Здесь](https://www.cloudping.co/grid) вы можете увидеть и 200 и 400 мс вполне реального RTT. Подсчитайте, какого размера нужно окно TCP чтобы наполнить 1 Гбит/с канал при 300 мс RTT (берем простую ситуацию без потери пакетов). Можно воспользоваться готовым [калькулятором](https://www.switch.ch/network/tools/tcp_throughput/). Ознакомиться с [формулами](https://en.wikipedia.org/wiki/TCP_tuning), по которым работает калькулятор можно, например, на Wiki.  

    __ОТВЕТ:__  Чтобы наполнить 1 Гбит/с канал при 300 мс RTT окно TCP должно быть размером __36621__ КБ.  
    [![2021-05-05_13-43-44_TCP_Throughput_Calculator.png](https://github.com/tabwizard/devops-netology/raw/main/img/2021-05-05_13-43-44_TCP_Throughput_Calculator.png)](https://github.com/tabwizard/devops-netology/blob/main/img/2021-05-05_13-43-44_TCP_Throughput_Calculator.png)  

1. Во сколько раз упадет пропускная способность канала, если будет 1% потерь пакетов при передаче?  

    __ОТВЕТ:__  Пропускная способность канала при MSS 1460 byte, RTT: 80.0 ms, без потерь составляет 1460.00 Mbit/sec, при 1% потерь - 1.46 Mbit/sec. Получается, что пропускная способность канала всего при 1% потерь падает в __1000__ раз.  

1. Какая  максимальная реальная скорость передачи данных достижима при линке 100 Мбит/с? Вопрос про TCP payload, то есть цифры, которые вы реально увидите в операционной системе в тестах или в браузере при скачивании файлов. Повлияет ли размер фрейма на это?  

    __ОТВЕТ:__  Предположим, что у нас всё хорошо и мы считаем только потери на передачу заголовков, тогда при MTU = 1500 Б, TCP Header = 20 Б, IPHeader = 20 Б, TCP payload (MSS) будет равен 1460 Б и передаваться он будет внутри Ethernet-фрейма размером 1518 Б. Линк 100 Мбит/с = 12500000 Б/с  
    Максимальная реальная скорость: (12 500 000/1518)*1460 = 12 022 397,89 Б/с = __96,179 Мбит/с__

1. Что на самом деле происходит, когда вы открываете сайт? :)
На прошлой лекции был приведен сокращенный вариант ответа на этот вопрос. Теперь вы знаете намного больше, в частности про IP адресацию, DNS и т.д.
Опишите максимально подробно насколько вы это можете сделать, что происходит, когда вы делаете запрос `curl -I http://netology.ru` с вашей рабочей станции. Предположим, что arp кеш очищен, в локальном DNS нет закешированных записей.  

    __ОТВЕТ:__  

    ```bash
    vagrant@vagrant:~$ sudo -i
    root@vagrant:~#  ip -s -s neigh flush all
    root@vagrant:~# systemd-resolve --flush-caches
    root@vagrant:~# strace -e network -s 512 curl -I http://netology.ru > /dev/null
    socket(AF_INET6, SOCK_DGRAM, IPPROTO_IP) = 3
    socketpair(AF_UNIX, SOCK_STREAM, 0, [3, 4]) = 0
    socketpair(AF_UNIX, SOCK_STREAM, 0, [5, 6]) = 0
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    Dload  Upload   Total   Spent    Left  Speed
    0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
    socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) = 5
    setsockopt(5, SOL_TCP, TCP_NODELAY, [1], 4) = 0
    setsockopt(5, SOL_SOCKET, SO_KEEPALIVE, [1], 4) = 0
    setsockopt(5, SOL_TCP, TCP_KEEPIDLE, [60], 4) = 0
    setsockopt(5, SOL_TCP, TCP_KEEPINTVL, [60], 4) = 0
    connect(5, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("104.22.48.171")}, 16) = -1 EINPROGRESS (Operation now in progress)
    getsockopt(5, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
    getpeername(5, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("104.22.48.171")}, [128->16]) = 0
    getsockname(5, {sa_family=AF_INET, sin_port=htons(48506), sin_addr=inet_addr("10.0.2.15")}, [128->16]) = 0
    sendto(5, "HEAD / HTTP/1.1\r\nHost: netology.ru\r\nUser-Agent: curl/7.68.0\r\nAccept: */*\r\n\r\n", 76, MSG_NOSIGNAL, NULL, 0) = 76
    recvfrom(5, "HTTP/1.1 301 Moved Permanently\r\nDate: Wed, 05 May 2021 10:21:14 GMT\r\nConnection: keep-alive\r\nCache-Control: max-age=3600\r\nExpires: Wed, 05 May 2021 11:21:14 GMT\r\nLocation: https://netology.ru/\r\ncf-request-id: 09dda4db1c000090451ca74000000001\r\nServer: cloudflare\r\nCF-RAY: 64a93da4fb949045-DME\r\nalt-svc: h3-27=\":443\"; ma=86400, h3-28=\":443\"; ma=86400, h3-29=\":443\"; ma=86400\r\n\r\n", 102400, 0, NULL, NULL) = 376
    0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
    +++ exited with 0 +++
    ```  
    - стали суперюзером
    - почистили кеш ARP
    - почистили кеш DNS
    - запустили `curl` в `strace`
    - создался сокет IPv6 с поддержкой дейтаграмм, протокол IP
    - создалось 2 пары неименованых присоединённых сокетов локального соединения обеспечивающих создание двусторонних, надёжных потоков байтов на основе установления соединения
    - что-то с чем-то вроде бы соединилось
    - создался сокет IPv4 соединения полнодуплексных байтовых потоков, протокол TCP, fd=5
    - для этого сокета (fd=5) были установлены различные параметры
    - вызов connect() устанавливает соединение с сокетом (fd=5),ссылающимся на адрес "104.22.48.171" и порт "80"
    - для сокета (fd=5) был прочитан параметр чтобы убедиться, что connect удался
    - getpeername() вернул адрес машины, подключившейся к сокету (fd=5)
    - getsockname() вернул текущий адрес, к которому привязан сокет (fd=5)
    - через сокет (fd=5) было отправлено сообщение `"HEAD / HTTP/1.1\r\nHost: netology.ru\r\nUser-Agent и так далее"` длиной 76 байт и в ответ получили 76, значит всё отправилось
    - из сокета (fd=5) было получено сообщение `"HTTP/1.1 301 Moved Permanently\r\nDate: и так далее"` длиной 376 байт  
    [![Screenshot_20210505_174019.png](https://github.com/tabwizard/devops-netology/raw/main/img/Screenshot_20210505_174019.png)](https://github.com/tabwizard/devops-netology/blob/main/img/Screenshot_20210505_174019.png)  
    tcpdump снят во время `curl`, фильтрами убраны пакеты `ssh` между виртуалкой и хост-машиной
    - 24 ARP-ом по Broadcast-у спросили кто шлюз
    - 26 получили в ответ MAC
    - 28 по DNS спросили у шлюза А-запись netology.ru
    - 29 по DNS спросили у шлюза АААА-запись netology.ru
    - 40 получили по DNS ответ на 28 (А-запись netology.ru)
    - 41 получили по DNS ответ на 28 (АААА-запись netology.ru)
    - 264 начали устанавливать соединение по TCP, отправили `SYN` с порта 48506 на 80 порт 104.22.48.171 (netology.ru)
    - 269 получили в ответ на 264 `SYN, ACK` по TCP на порт 48506 c 80 порта от 104.22.48.171 (netology.ru)
    - 270 закончили устанавливать соединение - в ответ на 269 отправили `ACK` по TCP с порта 48506 на 80 порт 104.22.48.171 (netology.ru)
    - 275 по HTTP отправили `HEAD / HTTP/1.1 и так далее` с порта 48506 на 80 порт 104.22.48.171
    - 278 получили в ответ на 275 `ACK` по TCP на порт 48506 c 80 порта от 104.22.48.171
    - 283 по HTTP получили в ответ на 275 `"HTTP/1.1 301 Moved Permanently\r\nDate: и так далее"` на порт 48506 c 80 порта от 104.22.48.171
    - 284 отправилии в ответ на 283 `ACK` по TCP с порта 48506 на 80 порт 104.22.48.171
    - 327 начали разрывать соединение - отправили `FIN, ACK` по TCP с порта 48506 на 80 порт 104.22.48.171
    - 328 получили в ответ на 327 `ACK` по TCP на порт 48506 с 80 порта 104.22.48.171
    - 333 получили `FIN, ACK` по TCP на порт 48506 с 80 порта 104.22.48.171
    - 334 закончили разрывать соединение - отправили в ответ на 333 `ACK` по TCP  с порта 48506 на 80 порт 104.22.48.171


1. Сколько и каких итеративных запросов будет сделано при резолве домена `www.google.co.uk`?  

    __ОТВЕТ:__  Будет сделано 5 запросов:

    ```bash
    vagrant@vagrant:~$ dig NS . @1.1.1.1 +noall +answer  | head -n1
    .                       515260  IN      NS      c.root-servers.net.
    vagrant@vagrant:~$ dig NS uk. @a.root-servers.net. +noall +authority | head -n1
    uk.                     172624  IN      NS      nsd.nic.uk.
    vagrant@vagrant:~$ dig NS co.uk. @nsb.nic.uk. +noall +authority | head -n1
    co.uk.                  154282  IN      NS      dns4.nic.uk.
    vagrant@vagrant:~$ dig NS google.co.uk. @dns2.nic.uk. +noall +authority | head -n1
    google.co.uk.           345524  IN      NS      ns4.google.com.
    vagrant@vagrant:~$ dig A www.google.co.uk. @ns2.google.com. +noall +authority | head -n1
    google.co.uk.           345461  IN      NS      ns3.google.com.
    ```

2. Сколько доступно для назначения хостам адресов в подсети `/25`? А в подсети с маской `255.248.0.0`. Постарайтесь потренироваться в ручных вычислениях чтобы немного набить руку, не пользоваться калькулятором сразу.  

    __ОТВЕТ:__  В подсети `/25` для назначения хостам доступно 126 адресов.
    В подсети `255.248.0.0` (`/13`) для назначения хостам доступно 524286 адресов.

3. В какой подсети больше адресов, в `/23` или `/24`?  

    __ОТВЕТ:__  В подсети `/23` - 512 адресов, а в подсети `/24` - 256, следовательно в подсети `/23` адресов в 2 раза больше.  

4. Получится ли разделить диапазон `10.0.0.0/8` на 128 подсетей по 131070 адресов в каждой? Какая маска будет у таких подсетей?  

    __ОТВЕТ:__  Да, получится. Маска у подсетей будет `/15`. Подсети будут следующие: `10.0.0.0/15, 10.2.0.0/15, 10.4.0.0/15` и т.д.  
    [![2021-05-05_14-11-24_ipcalc.png](https://github.com/tabwizard/devops-netology/raw/main/img/2021-05-05_14-11-24_ipcalc.png)](https://github.com/tabwizard/devops-netology/blob/main/img/2021-05-05_14-11-24_ipcalc.png)  