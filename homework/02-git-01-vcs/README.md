# devops-netology
Домашнее задание 02-git-01-vcs

### С помощью файла /terraform/.gitignore будут проигнорированы файлы:
- любые файлы в каталогах `.terraform` в любом месте репозитария
- в каталоге `terraform`:
  - файлы с расширением `.tfstate` и файлы содержащие `.tfstate.` в названии 
  - файл `crash.log`
  - файлы с расширением `.tfvars`
  - файлы `override.tf` и `override.tf.json`
  - файлы, название которых заканчивается на `_override.tf` и `_override.tf.json`
  - скрытый файл `.terraformrc` и файл `terraform.rc`
