### Домашняя работа по уроку 02-git-04-tools
#### Cклонировал репозиторий с исходным кодом терраформа
	- `git clone https://github.com/hashicorp/terraform`

1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.
	- `git show -s --pretty=format:'%H%n%s' aefea`
	- хеш: aefead2207ef7e2aa5dc81a34aedf0cad4c32545
	- комментарий: Update CHANGELOG.md
1. Какому тегу соответствует коммит `85024d3`?
	- `git tag --list --points-at=85024d3`
	- тег: v0.12.23
1. Сколько родителей у коммита `b8d720`? Напишите их хеши.
	- `git show -s --pretty=format:'%P' b8d720`
	- 2 родителя:
		- 56cd7859e05c36c06b56d013b55a252d0bb7e158 
		- 9ea88f22fc6269854151c571162c5bcf958bee2b
1. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами  v0.12.23 и v0.12.24.
	- `git show -s --pretty=format:'%H -- %s' v0.12.23..v0.12.24`
		- 33ff1c03bb960b332be3af2e333462dde88b279e -- v0.12.24
		- b14b74c4939dcab573326f4e3ee2a62e23e12f89 -- [Website] vmc provider links
		- 3f235065b9347a758efadc92295b540ee0a5e26e -- Update CHANGELOG.md
		- 6ae64e247b332925b872447e9ce869657281c2bf -- registry: Fix panic when server is unreachable
		- 5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 -- website: Remove links to the getting started guide's old location
		- 06275647e2b53d97d4f0a19a0fec11f6d69820b5 -- Update CHANGELOG.md
		- d5f9411f5108260320064349b757f55c09bc4b80 -- command: Fix bug when using terraform login on Windows
		- 4b6d06cc5dcb78af637bbb19c198faff37a066ed -- Update CHANGELOG.md
		- dd01a35078f040ca984cdd349f18d0b67e486c35 -- Update CHANGELOG.md
		- 225466bc3e5f35baa5d07197bbc079345b77525e -- Cleanup after v0.12.23 release
1. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит 
так `func providerSource(...)` (вместо троеточия перечислены аргументы).
	- `git log -G'func providerSource\((.*)\)' --oneline` выдает нам 2 коммита: 5af1e6234 и 8c928e835
	- `git show 8c928e835 |grep 'func providerSource\((.*)\)'` выдает:
		- `+func providerSource(services *disco.Disco) getproviders.Source {`
	- `git show 5af1e6234 |grep 'func providerSource\((.*)\)'` выдает:
		- `-func providerSource(services *disco.Disco) getproviders.Source {`
		- `+func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {` 
	- из чего делаем вывод, что функция `func providerSource(...)` была создана в коммите 8c928e835 и изменена в 5af1e6234. Теоретически так как коммит 8c928e835 старше коммита 5af1e6234 можно было сразу предположить, что в первом функция была создана, а во втором изменена или удалена. `git show` с `grep` подтвердили это.
1. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.
	- `git log -G'globalPluginDirs' --oneline` выдает нам 4 коммита: 22a2580e9 35a058fb3 c0b176109 8364383c3
	- `git show` с `grep` по этим коммитам показывают, что функция была создана в коммите 8364383c3 и нигде не менялась, менялись только строки содержащие вызов этой функции.
	- Есть вероятность, что в каком-либо из коммитов было что-то изменено в теле функции и в diff не попало название, но как это выяснить я не представляю.
1. Кто автор функции `synchronizedWriters`? 
	- `git log -G'func synchronizedWriters\(' --oneline` ищем создание/удаление, в 5ac311e2a создана, в bdfea50cc удалена
	- `git show -s --pretty=format:'%an' 5ac311e2a` смотрим кто автор
	- `Martin Atkins`