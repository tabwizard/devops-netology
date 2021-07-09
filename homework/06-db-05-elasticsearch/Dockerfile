FROM centos:7
RUN yum update -y -q -e 0 && yum install -y -q -e 0 wget tar; \
    yum clean all && rm -rf /var/cache/yum
RUN cd /usr/share; \
    wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.13.3-linux-x86_64.tar.gz; \
    tar -xzf elasticsearch-7.13.3-linux-x86_64.tar.gz; \
    rm elasticsearch-7.13.3-linux-x86_64.tar.gz; \
    adduser elastic; \
    chown elastic -R /usr/share/elasticsearch-7.13.3;\
	  mkdir /var/lib/nodes; \
    chown elastic -R /var/lib/nodes
WORKDIR /usr/share/elasticsearch-7.13.3
COPY elasticsearch.yml ./config/
EXPOSE 9300 9200
ENV HOSTNAME=netology_test
USER elastic   
CMD ./bin/elasticsearch
