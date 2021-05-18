#!/usr/bin/env python3

import os
import sys

def check_modified(result_os):
    fullpath = ""
    for result in result_os.split('\n'):
        is_change = False
        if fullpath == "":
            fullpath = result
        if result_os.find('fatal: не найден git репозиторий') != -1:
            print(fullpath + " - not a git repository")
            pass
        if result.find('изменено') != -1:
            prepare_result = result.replace('\tизменено:   ', '')
            is_change = True
        elif result.find('новый файл') != -1:
            prepare_result = result.replace('\tновый файл:   ', '')
            is_change = True
        if is_change:
            print(fullpath+"/"+prepare_result.strip())

bash_command = ["cd ~/netology/sysadm-homeworks", "pwd", "git add . 2>&1 >/dev/null", "git status"]
rslt_os = os.popen(' && '.join(bash_command)).read()
check_modified(rslt_os)
if len(sys.argv) > 1 and os.path.isdir(sys.argv[1]):
    bash_command[0] = "cd " + sys.argv[1]
    rslt_os = os.popen(' && '.join(bash_command)).read()
    check_modified(rslt_os)
