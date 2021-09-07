#!/usr/bin/env bash

docker run -d --name centos7 pycontribs/centos:7 sleep 600000000
docker run -d --name ubuntu pycontribs/ubuntu:latest sleep 600000000
docker run -d --name fedora pycontribs/fedora:latest sleep 600000000

ansible-playbook -i ./inventory/prod.yml site.yml --vault-password-file ./pass.txt 

docker rm -f centos7 ubuntu fedora
