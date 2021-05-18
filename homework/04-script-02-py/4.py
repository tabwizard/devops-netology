#!/usr/bin/env python3

import socket
import time
import sys

service_array = {"drive.google.com":"", "mail.google.com":"", "google.com":""}
while True:
    for url, ip in service_array.items():
        ip_new = socket.gethostbyname(url)
        if ip != "" and ip != ip_new:
            sys.stdout.write("[ERROR] " + url + " IP mismatch: " + ip + " " + ip_new + "\n")
        else:
            sys.stdout.write(url + "  " + ip_new + "\n")
        service_array[url] = ip_new
    time.sleep(60) # 604800 - неделя в секундах