#!/bin/bash
yum install httpd -y
service httpd start
chkconfig httpd on
cd /var/www/html
echo "<html>" > index.html
echo $(curl -4 icanhazip.com) >> index.html
echo "<a href="https://storage.yandexcloud.net/wizards-tf-bucket/images.png" allign=center>https://storage.yandexcloud.net/wizards-tf-bucket/images.png</a><p allign=center><img src="https://storage.yandexcloud.net/wizards-tf-bucket/images.png"> </html>" >> index.html
