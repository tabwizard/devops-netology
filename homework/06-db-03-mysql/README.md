# Домашняя работа к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.  

__ОТВЕТ:__

```bash
wizard:~/ $ docker run --name mysql8 -e MYSQL_ROOT_PASSWORD=password -v /var/db/mysql:/var/lib/mysql -v /var/db/mysql_backup:/var/lib/mysql_backup -d mysql:8
wizard:~/ $ docker exec -it mysql8 bash
root@908bb3431c9e:/# mysql -uroot -p
Enter password:
...

mysql> CREATE DATABASE test_db DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
Query OK, 1 row affected, 2 warnings (0.01 sec)

mysql> \q
Bye
root@908bb3431c9e:/# mysql -uroot -p test_db < /var/lib/mysql_backup/test_dump.sql
Enter password:
root@908bb3431c9e:/# mysql -uroot -p test_db
Enter password:
...
mysql> \s
--------------
mysql  Ver 8.0.25 for Linux on x86_64 (MySQL Community Server - GPL)
...
Server version:         8.0.25 MySQL Community Server - GPL
...

mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> SHOW COLUMNS FROM orders;
+-------+--------------+------+-----+---------+----------------+
| Field | Type         | Null | Key | Default | Extra          |
+-------+--------------+------+-----+---------+----------------+
| id    | int unsigned | NO   | PRI | NULL    | auto_increment |
| title | varchar(80)  | NO   |     | NULL    |                |
| price | int          | YES  |     | NULL    |                |
+-------+--------------+------+-----+---------+----------------+
3 rows in set (0.01 sec)

mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:

- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней
- количество попыток авторизации - 3
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
  - Фамилия "Pretty"
  - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и
**приведите в ответе к задаче**.  

__ОТВЕТ:__ Можно всё создание пользователя запихать в одну длинную команду, но мне это не очень нравится и мы пойдем другим путём (не люблю длинные команды).

```bash
mysql> CREATE USER test IDENTIFIED WITH mysql_native_password BY 'test-pass';
Query OK, 0 rows affected (0.02 sec)
mysql> ALTER USER test WITH MAX_QUERIES_PER_HOUR 100 PASSWORD EXPIRE INTERVAL 180 DAY FAILED_LOGIN_ATTEMPTS 3;
Query OK, 0 rows affected (0.01 sec)
mysql> ALTER USER test ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
Query OK, 0 rows affected (0.00 sec)
mysql> GRANT SELECT ON test_db.* TO 'test';
Query OK, 0 rows affected (0.01 sec)
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test';
+------+------+---------------------------------------+
| USER | HOST | ATTRIBUTE                             |
+------+------+---------------------------------------+
| test | %    | {"fname": "James", "lname": "Pretty"} |
+------+------+---------------------------------------+
1 row in set (0.00 sec)

```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:

- на `MyISAM`
- на `InnoDB`  

__ОТВЕТ:__  

```bash
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> SELECT `TABLE_SCHEMA`, `TABLE_NAME`, `ENGINE` FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA`='test_db';
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0.01 sec)

mysql> ALTER TABLE orders ENGINE=MyISAM;
Query OK, 5 rows affected (0.04 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT `TABLE_SCHEMA`, `TABLE_NAME`, `ENGINE` FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA`='test_db';
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | MyISAM |
+--------------+------------+--------+
1 row in set (0.00 sec)

mysql> ALTER TABLE orders ENGINE=InnoDB;
Query OK, 5 rows affected (0.06 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT `TABLE_SCHEMA`, `TABLE_NAME`, `ENGINE` FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA`='test_db';
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0.00 sec)

mysql> SHOW PROFILES;
+----------+------------+-------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                             |
+----------+------------+-------------------------------------------------------------------------------------------------------------------+
|        1 | 0.00105550 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test'                                              |
|        2 | 0.00206775 | SELECT `TABLE_SCHEMA`, `TABLE_NAME`, `ENGINE` FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA`='test_db'   |
|        3 | 0.03872950 | ALTER TABLE orders ENGINE=MyISAM                                                                                  |
|        4 | 0.00191125 | SELECT `TABLE_SCHEMA`, `TABLE_NAME`, `ENGINE` FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA`='test_db'   |
|        5 | 0.05649275 | ALTER TABLE orders ENGINE=InnoDB                                                                                  |
|        6 | 0.00186000 | SELECT `TABLE_SCHEMA`, `TABLE_NAME`, `ENGINE` FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA`='test_db'   |
+----------+------------+-------------------------------------------------------------------------------------------------------------------+
6 rows in set, 1 warning (0.00 sec)
```  

Время на запрос текущего движка было маленьким и уменьшалось - 0.00206775 -> 0.00191125 -> 0.00186000. А на изменение было гораздо большим: 0.03872950 и 0.05649275.

## Задача 4

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):

- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.  

__ОТВЕТ:__

```bash
root@44dfb1ee049f:/# cat /etc/mysql/my.cnf
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Скорость IO важнее сохранности данных
innodb_flush_log_at_trx_commit = 2
# Нужна компрессия таблиц для экономии места на диске
innodb_file_per_table = 1
# Размер буффера с незакомиченными транзакциями 1 Мб
innodb_log_buffer_size = 1M
# Буффер кеширования 30% от ОЗУ, 8G*0.3=2577M
innodb_buffer_pool_size = 2577M
# Размер файла логов операций 100 Мб
innodb_log_file_size = 100M

# Custom config should go here
!includedir /etc/mysql/conf.d/
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
