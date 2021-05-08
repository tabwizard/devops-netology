# Домашняя работа к занятию "3.8. Компьютерные сети, лекция 3"

1. ipvs. Если при запросе на VIP сделать подряд несколько запросов (например, `for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done`), ответы будут получены почти мгновенно. Тем не менее, в выводе `ipvsadm -Ln` еще некоторое время будут висеть активные `InActConn`. Почему так происходит?  

    __ОТВЕТ:__ При использовании LVS-NAT ipvs знает всё о состоянии соединения и вывод `ipvsadm -Ln` будет правильным. Когда же используется LVS-DR или LVS-Tun через ipvs проходят только пакеты от клиента к серверу и если клиент отправит `FIN`, то ответный `ACK`-`FIN` пройдет от сервера к клиенту напрямую, мимо ipvs и он "увидит" только "финальный" `ACK` от клиента. Поэтому у ipvs есть собственная таблица тайм-аутов по которой он пытается предположить состояние соединения по первому "увиденному" `FIN` (а он может быть не первым в процедуре разрыва соединения если инициатором был сервер). В итоге в выводе `ipvsadm -Ln` состояние соединений будет предполагаемым.  

2. На лекции мы познакомились отдельно с ipvs и отдельно с keepalived. Воспользовавшись этими знаниями, совместите технологии вместе (VIP должен подниматься демоном keepalived). Приложите конфигурационные файлы, которые у вас получились, и продемонстрируйте работу получившейся конструкции. Используйте для директора отдельный хост, не совмещая его с риалом! Подобная схема возможна, но выходит за рамки рассмотренного на лекции.  

    __ОТВЕТ:__ Подготавливаем [Vagranfile](https://github.com/tabwizard/devops-netology/blob/main/homework/03-sysadmin-08-net/Vagranfile) c пятью виртуалками: 1 клиента (client), 2-х балансировщиков (netology-ipvs1 и netology-ipvs2) и 2-х риалов (netology1 и netology2), конфиги `keepalived` для [директора](https://github.com/tabwizard/devops-netology/blob/main/homework/03-sysadmin-08-net/netology-ipvs1_keepalived.conf) и [бэкапа](https://github.com/tabwizard/devops-netology/blob/main/homework/03-sysadmin-08-net/netology-ipvs2_keepalived.conf), и [файл проверки для клиета](https://github.com/tabwizard/devops-netology/blob/main/homework/03-sysadmin-08-net/check.sh). Стартуем `vagrant up` и смотрим, что получилось:  

    ```bash
    wizard:Vagrant/ $ vagrant ssh netology1
    vagrant@netology1:~$ ip addr|grep -P 'lo:|eth1'
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 172.28.128.100/32 scope global lo:100
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 172.28.128.10/24 scope global eth1

    wizard:Vagrant/ $ vagrant ssh netology2
    vagrant@netology2:~$ ip addr|grep -P 'lo:|eth1'
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 172.28.128.100/32 scope global lo:100
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 172.28.128.60/24 scope global eth1

    wizard:Vagrant/ $ vagrant ssh netology-ipvs1
    vagrant@netology-ipvs1:~$ ip addr |grep eth1
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 172.28.128.131/24 scope global eth1
    inet 172.28.128.100/32 scope global eth1:0

    vagrant@netology-ipvs1:~$ sudo ipvsadm -Ln
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  172.28.128.100:80 wrr
    -> 172.28.128.10:80             Route   1      0          0
    -> 172.28.128.60:80             Route   1      0          0

    wizard:Vagrant/ $ vagrant ssh netology-ipvs2
    vagrant@netology-ipvs2:~$ ip addr|grep -P 'lo:|eth1'
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 172.28.128.121/24 scope global eth1

    vagrant@netology-ipvs2:~$ sudo ipvsadm -Ln
    IP Virtual Server version 1.2.1 (size=4096)
    Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
    TCP  172.28.128.100:80 wrr
    -> 172.28.128.10:80             Route   1      0          0
    -> 172.28.128.60:80             Route   1      0          0

    wizard:Vagrant/ $ vagrant ssh client 
    vagrant@netology-client:~$ ./check.sh
    Server netology2
    Server netology1
    Server netology2
    Server netology1
    Server netology2
    Server netology1
    Server netology2
    Server netology1
    Server netology2
    Server netology1
    Server netology2
    Server netology1
    Server netology2
    ```  

    Пробуем погасить на балансировщике 1 интерфейс и видим, что на втором поднялся `VIP` и проверка с клиента продолжает работать

    ```bash
    vagrant@netology-ipvs1:~$ sudo ip link set dev eth1 down

    vagrant@netology-ipvs2:~$ ip addr|grep -P 'lo:|eth1'
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 172.28.128.121/24 scope global eth1
    inet 172.28.128.100/32 scope global eth1:0

    vagrant@netology-client:~$ ./check.sh
    Server netology2
    Server netology1
    Server netology2
    Server netology1
    Server netology2
    ```

    Пробуем погасить на сервере 1 интерфейс и видим, что проверка с клиента продолжает работать только со второго сервера, поднимаем интерфейс - всё возвращается назад.  
    [![Screenshot_20210508_211620.png](https://github.com/tabwizard/devops-netology/raw/main/img/Screenshot_20210508_211620.png)](https://github.com/tabwizard/devops-netology/blob/main/img/Screenshot_20210508_211620.png)  

3. В лекции мы использовали только 1 VIP адрес для балансировки. У такого подхода несколько отрицательных моментов, один из которых – невозможность активного использования нескольких хостов (1 адрес может только переехать с master на standby). Подумайте, сколько адресов оптимально использовать, если мы хотим без какой-либо деградации выдерживать потерю 1 из 3 хостов при входящем трафике 1.5 Гбит/с и физических линках хостов в 1 Гбит/с? Предполагается, что мы хотим задействовать 3 балансировщика в активном режиме (то есть не 2 адреса на 3 хоста, один из которых в обычное время простаивает).

>Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на ваш репозиторий.
>
>Также вы можете выполнить задание в [Google Docs](https://docs.google.com/document/u/0/?tgif=d) и отправить в личном кабинете на проверку ссылку на ваш документ.
>Название файла Google Docs должно содержать номер лекции и фамилию студента. Пример названия: "1.1. Введение в DevOps — Сусанна Алиева"
>Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на комментирование всем, у кого есть ссылка).
>Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.
>
>Любые вопросы по решению задач задавайте в чате Slack.
