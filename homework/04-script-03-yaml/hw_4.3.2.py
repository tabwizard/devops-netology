#!/usr/bin/env python3

import socket
import time
import sys
import json
import yaml


service_array = {"drive.google.com":"", "mail.google.com":"", "google.com":""}
while True:
    export_array = []
    for url, ip in service_array.items():
        ip_new = socket.gethostbyname(url)
        if ip != "" and ip != ip_new:
            sys.stdout.write("[ERROR] " + url + " IP mismatch: " + ip + " " + ip_new + "\n")
        else:
            sys.stdout.write(url + "  " + ip_new + "\n")
        service_array[url] = ip_new
        export_array.append({url : ip_new})
    with open("ip_list.json", "w") as json_file:
        json_file.write(json.dumps(export_array, indent=2))
    with open("ip_list.yaml", "w") as yaml_file:
        yaml_file.write(yaml.dump(export_array, explicit_start=True, explicit_end=True))
    time.sleep(60)
