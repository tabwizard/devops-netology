#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "pwd", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
fullpath = ""
for result in result_os.split('\n'):
    is_change = False
    if fullpath == "":
        fullpath = result
    if result.find('изменено') != -1:
        prepare_result = result.replace('\tизменено:   ', '')
        is_change = True
    elif result.find('новый файл') != -1:
        prepare_result = result.replace('\tновый файл:   ', '')
        is_change = True
    if is_change:
        print(fullpath+"/"+prepare_result.strip())
