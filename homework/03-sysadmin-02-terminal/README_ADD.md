# Домашняя работа к занятию "3.2. Работа в терминале, лекция 2"  
# Доработка
>Задание 3
Попробуйте уточнить ответ для указанной ОС

>Задание 5
В данном задании речь шла об использовании одной и той же команды, без сцепок с помощью ; && и т.п.

3. Какой процесс с PID `1` является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?  

    __ОТВЕТ:__ Родителем для всех процессов в виртуальной машине Ubuntu 20.04. является процесс `systemd`
    ```bash
    vagrant@vagrant:~$ pstree -p
    systemd(1)─┬─VBoxService(791)─┬─{VBoxService}(793)
    │                  ├─{VBoxService}(794)
    │                  ├─{VBoxService}(795)
    │                  ├─{VBoxService}(796)
    │                  ├─{VBoxService}(797)
    │                  ├─{VBoxService}(798)
    │                  ├─{VBoxService}(799)
    │                  └─{VBoxService}(800)
    ├─accounts-daemon(592)─┬─{accounts-daemon}(607)
    │                      └─{accounts-daemon}(636)
    ├─agetty(820)
    ├─atd(809)
    ├─cron(805)
    ├─dbus-daemon(596)
    ├─irqbalance(604)───{irqbalance}(609)
    ├─multipathd(523)─┬─{multipathd}(524)
    │                 ├─{multipathd}(525)
    │                 ├─{multipathd}(526)
    │                 ├─{multipathd}(527)
    │                 ├─{multipathd}(528)
    │                 └─{multipathd}(529)
    ├─networkd-dispat(605)
    ├─polkitd(652)─┬─{polkitd}(653)
    │              └─{polkitd}(655)
    ├─rpcbind(554)
    ├─rsyslogd(606)─┬─{rsyslogd}(623)
    │               ├─{rsyslogd}(624)
    │               └─{rsyslogd}(625)
    ├─sshd(812)───sshd(2388)───sshd(2437)───bash(2438)───pstree(2466)
    ├─systemd(2402)───(sd-pam)(2404)
    ├─systemd-journal(355)
    ├─systemd-logind(612)
    ├─systemd-network(402)
    ├─systemd-resolve(555)
    └─systemd-udevd(382)
    ```


5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.  

    __ОТВЕТ:__ Передадим в grep fstab и выведем результат в out `grep \/ 0</etc/fstab > ./out`
