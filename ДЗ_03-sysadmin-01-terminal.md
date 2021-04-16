# Домашняя работа к занятию "3.1. Работа в терминале, лекция 1"

1. Установите средство виртуализации [Oracle VirtualBox](https://www.virtualbox.org/)    
__ОТВЕТ:__ ставим VirtualBox `sudo pacaur -S virtualbox virtualbox-guest-iso virtualbox-host-dkms virtualbox-ext-oracle`  

1. Установите средство автоматизации [Hashicorp Vagrant](https://www.vagrantup.com/)  
__ОТВЕТ:__ ставим Vagrant `sudo pacaur -S vagrant`

1. В вашем основном окружении подготовьте удобный для дальнейшей работы терминал.  
__ОТВЕТ:__  
ставим любимый терминал `sudo pacaur -S yakuake`  
ставим zsh `sudo pacaur -S zsh; chsh -s /usr/bin/zsh wizard`  
правим zshrc, делаем удобный PROMPT `vim ~/.zshrc`
```bash
if [[ "${DISPLAY%%:0*}" != "" ]]; then
PROMPT="$(print '%{\e[0;31m%}%B[%n@%m]%b %{\e[1;34m%}%d %{\e[1;32m%}%B%#%b%{\e[0m%} ')" # remote machine: prompt will be partly red
else
PROMPT="$(print '%{\e[0;36m%}%B%n%b %{\e[1;34m%}%~ %{\e[1;32m%}%B%#%b%{\e[0m%}') " # local machine: prompt will be partly cyan
fi
```

1. С помощью базового файла конфигурации запустите Ubuntu 20.04 в VirtualBox посредством Vagrant:

	* Создайте директорию, в которой будут храниться конфигурационные файлы Vagrant. В ней выполните `vagrant init`. Замените содержимое Vagrantfile по умолчанию следующим:

		```bash
		Vagrant.configure("2") do |config|
			config.vm.box = "bento/ubuntu-20.04"
		end
		```  
__ОТВЕТ:__
```bash
mkdir ./Vagrant
cd ./Vagrant
vagrant init
==> vagrant: A new version of Vagrant is available: 2.2.15 (installed version: 2.2.14)!
==> vagrant: To upgrade visit: https://www.vagrantup.com/downloads.html
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.  
vim ./Vagrantfile
cat ./Vagrantfile
Vagrant.configure("2") do |config|
		config.vm.box = "bento/ubuntu-20.04"
end  
```
	* Выполнение в этой директории `vagrant up` установит провайдер VirtualBox для Vagrant, скачает необходимый образ и запустит виртуальную машину.  
__ОТВЕТ:__
```bash
vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Box 'bento/ubuntu-20.04' could not be found. Attempting to find and install...
  		default: Box Provider: virtualbox
  		default: Box Version: >= 0
==> default: Loading metadata for box 'bento/ubuntu-20.04'
  		default: URL: https://vagrantcloud.com/bento/ubuntu-20.04
==> default: Adding box 'bento/ubuntu-20.04' (v202012.23.0) for provider: virtualbox
  		default: Downloading: https://vagrantcloud.com/bento/boxes/ubuntu-20.04/versions/202012.23.0/providers/virtualbox.box
  		default: Download redirected to host: vagrantcloud-files-production.s3-accelerate.amazonaws.com
==> default: Successfully added box 'bento/ubuntu-20.04' (v202012.23.0) for 'virtualbox'!
==> default: Importing base box 'bento/ubuntu-20.04'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'bento/ubuntu-20.04' version '202012.23.0' is up to date...
==> default: Setting the name of the VM: Vagrant_default_1618483584026_82386
Vagrant is currently configured to create VirtualBox synced folders with
the `SharedFoldersEnableSymlinksCreate` option enabled. If the Vagrant
guest is not trusted, you may want to disable this option. For more
information on this option, please refer to the VirtualBox manual:
https://www.virtualbox.org/manual/ch04.html#sharedfolders
This option can be disabled globally with an environment variable:
VAGRANT_DISABLE_VBOXSYMLINKCREATE=1
or on a per folder basis within the Vagrantfile:
config.vm.synced_folder '/host/path', '/guest/path', SharedFoldersEnableSymlinksCreate: false
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
  		default: Adapter 1: nat
==> default: Forwarding ports...
		  default: 22 (guest) => 2222 (host) (adapter 1)
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

	* `vagrant suspend` выключит виртуальную машину с сохранением ее состояния (т.е., при следующем `vagrant up` будут запущены все процессы внутри, которые работали на момент вызова suspend), `vagrant halt` выключит виртуальную машину штатным образом.  
__ОТВЕТ:__
```bash
vagrant suspend
==> default: Saving VM state and suspending execution...
```
```bash
vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Checking if box 'bento/ubuntu-20.04' version '202012.23.0' is up to date...
==> default: Resuming suspended VM...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
		  default: SSH address: 127.0.0.1:2222
		  default: SSH username: vagrant
		  default: SSH auth method: private key
==> default: Machine booted and ready!
==> default: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> default: flag to force provisioning. Provisioners marked to run always will still run.
```
```bash
vagrant halt
==> default: Attempting graceful shutdown of VM...
```
1. Ознакомьтесь с графическим интерфейсом VirtualBox, посмотрите как выглядит виртуальная машина, которую создал для вас Vagrant, какие аппаратные ресурсы ей выделены. Какие ресурсы выделены по-умолчанию?  
__ОТВЕТ:__  
ВМ выделено 1 ядро процессора, которое может быть использовано на 100%, 1024 МБ оперативной памяти, 8 МБ видеопамяти, создан виртуальный жесткий диск на 64 ГБ, подключен через NAT 1 сетевой адаптер. Все ресурсы выделены по-умолчанию, потому что в конфиге ничего не прописано.  
[![Screenshot-20210415-182153.png](https://i.postimg.cc/tRmrf7VK/Screenshot-20210415-182153.png)](https://postimg.cc/fkmjSzCC)  

1. Ознакомьтесь с возможностями конфигурации VirtualBox через Vagrantfile: [документация](https://www.vagrantup.com/docs/providers/virtualbox/configuration.html). Как добавить оперативной памяти или ресурсов процессора виртуальной машине?  
__ОТВЕТ:__  
После ознакомления с документацией, добавили памяти, процессоров и поменяли максимальную утилизацию  
```bash
cat ./Vagrantfile
Vagrant.configure("2") do |config|
		config.vm.box = "bento/ubuntu-20.04"
		config.vm.provider "virtualbox" do |vm|
			# объем оперативной памяти
			vm.memory = 2048
			# количество ядер процессора
			vm.cpus = 2
			# утилизация процессора
			vm.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
		end
end
```  
[![Screenshot-20210415-184741.png](https://i.postimg.cc/DwRvv1Y1/Screenshot-20210415-184741.png)](https://postimg.cc/JscVKH8h)

1. Команда `vagrant ssh` из директории, в которой содержится Vagrantfile, позволит вам оказаться внутри виртуальной машины без каких-либо дополнительных настроек. Попрактикуйтесь в выполнении обсуждаемых команд в терминале Ubuntu.  
__ОТВЕТ:__  
```bash
wizard ~/Vagrant % vagrant ssh
Welcome to Ubuntu 20.04.1 LTS (GNU/Linux 5.4.0-58-generic x86_64)
 	Documentation:  https://help.ubuntu.com
 	Management:     https://landscape.canonical.com
 	Support:        https://ubuntu.com/advantage
System information as of Thu 15 Apr 2021 11:52:55 AM UTC
System load:  0.0               Processes:             113
Usage of /:   2.2% of 61.31GB   Users logged in:       0
Memory usage: 7%                IPv4 address for eth0: 10.0.2.15
Swap usage:   0%
This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
vagrant@vagrant:~$ whoami
vagrant
vagrant@vagrant:~$ uname -a
Linux vagrant 5.4.0-58-generic #64-Ubuntu SMP Wed Dec 9 08:16:25 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```  
```bash
vagrant@vagrant:~$ ll
total 36
	drwxr-xr-x 4 vagrant vagrant 4096 Dec 23 08:00 ./
	drwxr-xr-x 3 root    root    4096 Dec 23 07:52 ../
	-rw-r--r-- 1 vagrant vagrant  220 Dec 23 07:52 .bash_logout
	-rw-r--r-- 1 vagrant vagrant 3771 Dec 23 07:52 .bashrc
	drwx------ 2 vagrant vagrant 4096 Dec 23 07:53 .cache/
	-rw-r--r-- 1 vagrant vagrant  807 Dec 23 07:52 .profile
	drwx------ 2 vagrant root    4096 Apr 15 10:46 .ssh/
	-rw-r--r-- 1 vagrant vagrant    0 Dec 23 07:53 .sudo_as_admin_successful
	-rw-r--r-- 1 vagrant vagrant    6 Dec 23 07:53 .vbox_version
	-rw-r--r-- 1 root    root     180 Dec 23 07:58 .wget-hsts
```

1. Ознакомиться с разделами `man bash`, почитать о настройках самого bash:
    * какой переменной можно задать длину журнала `history`, и на какой строчке manual это описывается?  
		 __ОТВЕТ:__ длину журнала можно задать переменной `HISTSIZE`, описанной в строке 761 manual
    * что делает директива `ignoreboth` в bash?  
		__ОТВЕТ:__ это значение переменной `HISTIGNORE`, указывающее на то, что не нужно хранить в истории команды начинающиеся с пробела и дубликаты команд
1. В каких сценариях использования применимы скобки `{}` и на какой строчке `man bash` это описано?  
	__ОТВЕТ:__ строка 257  и дальше описывает использование `{}` в качестве ограничителя (раскрывателя) списков, там много смыслов использования, список значений (тогда без пробелов внутри скобок), список команд (тогда изнутри скобки должны быть отделены пробелами), можно скобками прицепить что-то к значению переменной
1. Основываясь на предыдущем вопросе, как создать однократным вызовом `touch` 100000 файлов? А получилось ли создать 300000?  
__ОТВЕТ:__ создаем 100000 файлов: `mkdir ./100000; cd ./100000; touch ./file{1..100000}`, 300000 файлов таким способом создать не получится потому что будет превышено значение константы ARG_MAX равное 131072, но можно создать другими методами, например в цикле.
1. В man bash поищите по `/\[\[`. Что делает конструкция `[[ -d /tmp ]]`  
__ОТВЕТ:__ в строке 269 описано, что `[[]]` возвращают 0 или 1 в зависимости от истинности вырважения внутри скобок, конструкция `[[ -d /tmp ]]` определяет является ли темп каталогом, например команда `if [[ -d /tmp ]]; then echo 'Is directory'; else echo 'Is not directory'; fi` вернет `Is directory`
1. Основываясь на знаниях о просмотре текущих (например, PATH) и установке новых переменных; командах, которые мы рассматривали, добейтесь в выводе type -a bash в виртуальной машине наличия первым пунктом в списке:

	```bash
	bash is /tmp/new_path_directory/bash
	bash is /usr/local/bin/bash
	bash is /bin/bash
	```
	(прочие строки могут отличаться содержимым и порядком)  
__ОТВЕТ:__
```bash
mkdir /tmp/new_path_directory
ln -s $(type -p bash) /tmp/new_path_directory
PATH=/tmp/new_path_directory:$PATH
type -a bash

 bash is /tmp/new_path_directory/bash
bash is /usr/bin/bash
bash is /bin/bash
```

1. Чем отличается планирование команд с помощью `batch` и `at`\?  
__ОТВЕТ:__ `at` выполняет команды со стандартного ввода (или из файла с параметром -f) в заранее определенное время, а `batch` выполняет команды тогда, когда позволяет уровень средней загрузки системы.

1. Завершите работу виртуальной машины чтобы не расходовать ресурсы компьютера и/или батарею ноутбука.  
__ОТВЕТ:__  
```bash
vagrant@vagrant:~$ logout
Connection to 127.0.0.1 closed.
wizard ~/Vagrant % vagrant halt
==> default: Attempting graceful shutdown of VM...
```
