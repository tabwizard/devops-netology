# Домашняя работа к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.  

    __ОТВЕТ:__  
    >Разрежённый файл (англ. sparse file) — файл, в котором последовательности нулевых байтов[1] заменены на информацию об этих последовательностях (список дыр).  
    >Дыра (англ. hole) — последовательность нулевых байт внутри файла, не записанная на диск. Информация о дырах (смещение от начала файла в байтах и количество байт) хранится в метаданных ФС.  
    ...etc

1. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?  

    __ОТВЕТ:__ Жесткие ссылки являются по сути разными названиями одного и того же файла, поэтому права и владелец у них одинаковые, продемонстируем:

    ```bash
    vagrant:~/ $ echo $(ll /) > file
    vagrant:~/ $ ln file hard_link_file
    vagrant:~/ $ ll
    total 8,0K
    -rw-rw-r-- 2 vagrant vagrant 1,3K апр 27 14:23 file
    -rw-rw-r-- 2 vagrant vagrant 1,3K апр 27 14:23 hard_link_file
    vagrant:~/ $ sudo chown root: file
    vagrant:~/ $ ll
    total 8,0K
    -rw-rw-r-- 2 root root 1,3K апр 27 14:23 file
    -rw-rw-r-- 2 root root 1,3K апр 27 14:23 hard_link_file
    vagrant:~/ $ sudo chmod +x hard_link_file
    vagrant:~/ $ ll
    total 8,0K
    -rwxrwxr-x 2 root root 1,3K апр 27 14:23 file
    -rwxrwxr-x 2 root root 1,3K апр 27 14:23 hard_link_file
    ```

1. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.  

    __ОТВЕТ:__

    ```bash
    wizard:Vagrant/ $ vagrant destroy
        default: Are you sure you want to destroy the 'default' VM? [y/N] y
    ==> default: Destroying VM and associated drives...

    wizard:Vagrant/ $ vim Vagrantfile
    ...
    wizard:Vagrant/ $ cat Vagrantfile
    Vagrant.configure("2") do |config|
        config.vm.box = "bento/ubuntu-20.04"
        config.vm.provider :virtualbox do |vb|
            lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
            lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
            vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
            vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
            vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
            vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
        end
    end

    wizard:Vagrant/ $ vagrant up
    Bringing machine 'default' up with 'virtualbox' provider...
    ==> default: Importing base box 'bento/ubuntu-20.04'...
    ==> default: Matching MAC address for NAT networking...
    ==> default: Checking if box 'bento/ubuntu-20.04' version '202012.23.0' is up to date...
    ==> default: Setting the name of the VM: Vagrant_default_1619510754062_59976
    ==> default: Clearing any previously set network interfaces...
    ==> default: Preparing network interfaces based on configuration...
        default: Adapter 1: nat
    ==> default: Forwarding ports...
        default: 22 (guest) => 2222 (host) (adapter 1)
    ==> default: Running 'pre-boot' VM customizations...
    ==> default: Booting VM...
    ==> default: Waiting for machine to boot. This may take a few minutes...
        default: SSH address: 127.0.0.1:2222
        default: SSH username: vagrant
        default: SSH auth method: private key
        default:
        default: Vagrant insecure key detected. Vagrant will automatically replace
        default: this with a newly generated keypair for better security.
        default:
        default: Inserting generated public key within guest...
        default: Removing insecure key from the guest if it's present...
        default: Key inserted! Disconnecting and reconnecting using new SSH key...
    ==> default: Machine booted and ready!
    ==> default: Checking for guest additions in VM...
    ==> default: Mounting shared folders...
        default: /vagrant => /home/wizard/Vagrant
    ```

1. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.  

    __ОТВЕТ:__

    ```bash
    vagrant@vagrant:~$ sudo -i
    root@vagrant:~# fdisk -l|grep /dev/sd
    Disk /dev/sda: 64 GiB, 68719476736 bytes, 134217728 sectors
    /dev/sda1  *       2048   1050623   1048576  512M  b W95 FAT32
    /dev/sda2       1052670 134215679 133163010 63.5G  5 Extended
    /dev/sda5       1052672 134215679 133163008 63.5G 8e Linux LVM
    Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    root@vagrant:~# fdisk /dev/sdb
    ...
    root@vagrant:~# fdisk -l /dev/sdb
    Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    Disk model: VBOX HARDDISK
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x60965661

    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdb1          2048 4196351 4194304    2G fd Linux raid autodetect
    /dev/sdb2       4196352 5242879 1046528  511M fd Linux raid autodetect
    ```

1. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# sfdisk -d /dev/sdb | sfdisk /dev/sdc
    Checking that no-one is using this disk right now ... OK

    Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
    Disk model: VBOX HARDDISK
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x60965661

    Old situation:

    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Script header accepted.
    >>> Created a new DOS disklabel with disk identifier 0x60965661.
    /dev/sdc1: Created a new partition 1 of type 'Linux raid autodetect' and of size 2 GiB.
    /dev/sdc2: Created a new partition 2 of type 'Linux raid autodetect' and of size 511 MiB.
    /dev/sdc3: Done.

    New situation:
    Disklabel type: dos
    Disk identifier: 0x60965661

    Device     Boot   Start     End Sectors  Size Id Type
    /dev/sdc1          2048 4196351 4194304    2G fd Linux raid autodetect
    /dev/sdc2       4196352 5242879 1046528  511M fd Linux raid autodetect

    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.
    ```

1. Соберите `mdadm` RAID1 на паре разделов 2 Гб.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# mdadm --create --verbose /dev/md1 --level=1  --raid-devices=2 /dev/sdb1 /dev/sdc1
    mdadm: Note: this array has metadata at the start and
        may not be suitable as a boot device.  If you plan to
        store '/boot' on this device please ensure that
        your boot-loader understands md/v1.x metadata, or use
        --metadata=0.90
    mdadm: size set to 2094080K
    Continue creating array? y
    mdadm: Defaulting to version 1.2 metadata
    mdadm: array /dev/md1 started.

    root@vagrant:~# cat /proc/mdstat
    Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
    md1 : active raid1 sdc1[1] sdb1[0]
        2094080 blocks super 1.2 [2/2] [UU]

    unused devices: <none>
    ```

1. Соберите `mdadm` RAID0 на второй паре маленьких разделов.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# mdadm --create --verbose /dev/md0 --level=0  --raid-devices=2 /dev/sdb2 /dev/sdc2
    mdadm: chunk size defaults to 512K
    mdadm: Defaulting to version 1.2 metadata
    mdadm: array /dev/md0 started.

    root@vagrant:~# cat /proc/mdstat
    Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
    md0 : active raid0 sdc2[1] sdb2[0]
        1042432 blocks super 1.2 512k chunks

    md1 : active raid1 sdc1[1] sdb1[0]
        2094080 blocks super 1.2 [2/2] [UU]

    unused devices: <none>
    ```

1. Создайте 2 независимых PV на получившихся md-устройствах.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# pvcreate /dev/md0
      Physical volume "/dev/md0" successfully created.
    root@vagrant:~# pvcreate /dev/md1
      Physical volume "/dev/md1" successfully created.

    root@vagrant:~# pvs
    PV         VG        Fmt  Attr PSize    PFree
    /dev/md0             lvm2 ---  1018.00m 1018.00m
    /dev/md1             lvm2 ---    <2.00g   <2.00g
    /dev/sda5  vgvagrant lvm2 a--   <63.50g       0
    ```

1. Создайте общую volume-group на этих двух PV.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# vgcreate vg00 /dev/md0 /dev/md1
      Volume group "vg00" successfully created
    
    root@vagrant:~# vgs
    VG        #PV #LV #SN Attr   VSize   VFree
    vg00        2   0   0 wz--n-  <2.99g <2.99g
    vgvagrant   1   2   0 wz--n- <63.50g     0
    ```

1. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# lvcreate -L100 -n lv00 vg00 /dev/md0
      Logical volume "lv00" created.
    root@vagrant:~# lsblk
    NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
    sda                    8:0    0   64G  0 disk
    ├─sda1                 8:1    0  512M  0 part  /boot/efi
    ├─sda2                 8:2    0    1K  0 part
    └─sda5                 8:5    0 63.5G  0 part
      ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
      └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
    sdb                    8:16   0  2.5G  0 disk
    ├─sdb1                 8:17   0    2G  0 part
    │ └─md1                9:1    0    2G  0 raid1
    └─sdb2                 8:18   0  511M  0 part
      └─md0                9:0    0 1018M  0 raid0
        └─vg00-lv00      253:2    0  100M  0 lvm
    sdc                    8:32   0  2.5G  0 disk
    ├─sdc1                 8:33   0    2G  0 part
    │ └─md1                9:1    0    2G  0 raid1
    └─sdc2                 8:34   0  511M  0 part
      └─md0                9:0    0 1018M  0 raid0
        └─vg00-lv00      253:2    0  100M  0 lvm
    root@vagrant:~# lvs
      LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
      lv00   vg00      -wi-a----- 100.00m
      root   vgvagrant -wi-ao---- <62.54g
      swap_1 vgvagrant -wi-ao---- 980.00m
    ```

1. Создайте `mkfs.ext4` ФС на получившемся LV.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# mkfs.ext4 /dev/mapper/vg00-lv00
    mke2fs 1.45.5 (07-Jan-2020)
    Creating filesystem with 25600 4k blocks and 25600 inodes

    Allocating group tables: done
    Writing inode tables: done
    Creating journal (1024 blocks): done
    Writing superblocks and filesystem accounting information: done
    ```

1. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# mkdir /tmp/new
    root@vagrant:~# mount /dev/mapper/vg00-lv00 /tmp/new
    root@vagrant:~# df -h
    Filesystem                  Size  Used Avail Use% Mounted on
    udev                        448M     0  448M   0% /dev
    tmpfs                        99M  692K   98M   1% /run
    /dev/mapper/vgvagrant-root   62G  1.4G   57G   3% /
    tmpfs                       491M     0  491M   0% /dev/shm
    tmpfs                       5.0M     0  5.0M   0% /run/lock
    tmpfs                       491M     0  491M   0% /sys/fs/cgroup
    /dev/sda1                   511M  4.0K  511M   1% /boot/efi
    vagrant                     110G   95G   15G  87% /vagrant
    tmpfs                        99M     0   99M   0% /run/user/1000
    /dev/mapper/vg00-lv00        93M   72K   86M   1% /tmp/new
    ```

1. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
    --2021-04-27 10:43:55--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
    Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
    Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 20404956 (19M) [application/octet-stream]
    Saving to: ‘/tmp/new/test.gz’

    /tmp/new/test.gz                      100%[======================================================================>]  19.46M  11.8MB/s    in 1.6s

    2021-04-27 10:43:57 (11.8 MB/s) - ‘/tmp/new/test.gz’ saved [20404956/20404956]
    ```

1. Прикрепите вывод `lsblk`.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# lsblk
    NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
    sda                    8:0    0   64G  0 disk
    ├─sda1                 8:1    0  512M  0 part  /boot/efi
    ├─sda2                 8:2    0    1K  0 part
    └─sda5                 8:5    0 63.5G  0 part
      ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
      └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
    sdb                    8:16   0  2.5G  0 disk
    ├─sdb1                 8:17   0    2G  0 part
    │ └─md1                9:1    0    2G  0 raid1
    └─sdb2                 8:18   0  511M  0 part
      └─md0                9:0    0 1018M  0 raid0
        └─vg00-lv00      253:2    0  100M  0 lvm   /tmp/new
    sdc                    8:32   0  2.5G  0 disk
    ├─sdc1                 8:33   0    2G  0 part
    │ └─md1                9:1    0    2G  0 raid1
    └─sdc2                 8:34   0  511M  0 part
      └─md0                9:0    0 1018M  0 raid0
        └─vg00-lv00      253:2    0  100M  0 lvm   /tmp/new
    ```

1. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```  

    __ОТВЕТ:__  
    [![Screenshot_20210427_175005.png](https://github.com/tabwizard/devops-netology/raw/03-sysadmin-05-fs/img/Screenshot_20210427_175005.png)](https://github.com/tabwizard/devops-netology/raw/03-sysadmin-05-fs/img/Screenshot_20210427_175005.png)

1. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# pvmove -n lv00 /dev/md0
      /dev/md0: Moved: 12.00%
      /dev/md0: Moved: 100.00%
    root@vagrant:~# lsblk
    NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
    sda                    8:0    0   64G  0 disk
    ├─sda1                 8:1    0  512M  0 part  /boot/efi
    ├─sda2                 8:2    0    1K  0 part
    └─sda5                 8:5    0 63.5G  0 part
      ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
      └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
    sdb                    8:16   0  2.5G  0 disk
    ├─sdb1                 8:17   0    2G  0 part
    │ └─md1                9:1    0    2G  0 raid1
    │   └─vg00-lv00      253:2    0  100M  0 lvm   /tmp/new
    └─sdb2                 8:18   0  511M  0 part
      └─md0                9:0    0 1018M  0 raid0
    sdc                    8:32   0  2.5G  0 disk
    ├─sdc1                 8:33   0    2G  0 part
    │ └─md1                9:1    0    2G  0 raid1
    │   └─vg00-lv00      253:2    0  100M  0 lvm   /tmp/new
    └─sdc2                 8:34   0  511M  0 part
      └─md0                9:0    0 1018M  0 raid0
    ```

1. Сделайте `--fail` на устройство в вашем RAID1 md.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# mdadm /dev/md1 --fail /dev/sdb1 
    mdadm: set /dev/sdb1 faulty in /dev/md1
    ```

1. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# dmesg -T|tail -3
    [Tue Apr 27 10:42:45 2021] ext4 filesystem being mounted at /tmp/new supports timestamps until 2038 (0x7fffffff)
    [Tue Apr 27 11:07:11 2021] md/raid1:md1: Disk failure on sdb1, disabling device.
                               md/raid1:md1: Operation continuing on 1 devices.
    ```

1. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```  

    __ОТВЕТ:__  
    [![Screenshot_20210427_181328.png](https://github.com/tabwizard/devops-netology/raw/03-sysadmin-05-fs/img/Screenshot_20210427_181328.png)](https://github.com/tabwizard/devops-netology/raw/03-sysadmin-05-fs/img/Screenshot_20210427_181328.png)

1. Погасите тестовый хост, `vagrant destroy`.  

    __ОТВЕТ:__

    ```bash
    root@vagrant:~# exit
    logout
    vagrant@vagrant:~$ exit
    logout
    Connection to 127.0.0.1 closed.
    wizard:Vagrant/ $ vagrant halt
    ==> default: Attempting graceful shutdown of VM...
    wizard:Vagrant/ $ vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
    ==> default: Destroying VM and associated drives...
    ```
