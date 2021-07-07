# Домашняя работа к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:

- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql  

__ОТВЕТ:__  

```bash
root:db/ # docker run --rm --name pgdocker -e POSTGRES_PASSWORD=password -e POSTGRES_USER=wizard -e POSTGRES_DB=wizard -d -p 5432:5432 -v /var/db/postgresql:/var/lib/postgresql/data -v /var/db/postgresql_backup:/var/lib/postgresql/backup postgres:13

root:db/ #  docker exec -it pgdocker bash
root@e398ee8a2e9d:/# psql -Uwizard -dwizard
psql (13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.

wizard=# \?
...
\l[+]   [PATTERN]      list databases
...
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo} 
                       connect to new database (currently "wizard")
...
\dt[S+] [PATTERN]      list tables
...
\d[S+]  NAME           describe table, view, sequence, or index
...
\q                     quit psql
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders`
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.  

___ОТВЕТ:__  

```bash
wizard=# CREATE DATABASE test_database;
CREATE DATABASE
wizard=# CREATE USER postgres WITH ENCRYPTED PASSWORD 'password';
CREATE ROLE
wizard=# \q
root@e398ee8a2e9d:/# psql -Uwizard -dtest_database < /var/lib/postgresql/backup/test_dump.sql
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE

root@e398ee8a2e9d:/# psql -Uwizard -dtest_database
psql (13.3 (Debian 13.3-1.pgdg100+1))
Type "help" for help.
test_database=# ANALYZE orders;
ANALYZE

test_database=# SELECT attname, avg_width FROM pg_stats WHERE tablename = 'orders' AND avg_width = (SELECT MAX(avg_width) FROM pg_stats WHERE tablename = 'orders');
 attname | avg_width
---------+-----------
 title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?  

__ОТВЕТ:__  

```bash
test_database=# begin;
BEGIN
test_database=# COPY ( SELECT * FROM orders WHERE price > 499 ) TO '/var/lib/postgresql/orders_1';
COPY 3
test_database=# COPY ( SELECT * FROM orders WHERE price <= 499 ) TO '/var/lib/postgresql/orders_2';
COPY 5
test_database=# DELETE FROM orders;
DELETE 8
test_database=# CREATE TABLE orders_1 ( CHECK ( price > 499 ) ) INHERITS ( orders );
CREATE TABLE
test_database=# CREATE TABLE orders_2 ( CHECK ( price <= 499 ) ) INHERITS ( orders );
CREATE TABLE
test_database=# CREATE RULE orders_insert_to_1 AS ON INSERT TO orders WHERE (price > 499) DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);
CREATE RULE
test_database=# CREATE RULE orders_insert_to_2 AS ON INSERT TO orders WHERE (price <= 499) DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
CREATE RULE
test_database=# GRANT ALL ON orders, orders_1, orders_2 TO postgres;
GRANT
test_database=# COPY orders_1 FROM '/var/lib/postgresql/orders_1';
COPY 3
test_database=# COPY orders_2 FROM '/var/lib/postgresql/orders_2';
COPY 5
test_database=# end transaction; 
COMMIT

test_database=# INSERT INTO orders (title, price) VALUES ('1 insert after sharding', 505);
INSERT 0 0
test_database=# INSERT INTO orders (title, price) VALUES ('2 insert after sharding', 101);
INSERT 0 0
test_database=# SELECT * FROM orders;
 id |          title          | price
----+-------------------------+-------
  2 | My little database      |   500
  6 | WAL never lies          |   900
  8 | Dbiezdmin               |   501
  9 | 1 insert after sharding |   505
  1 | War and peace           |   100
  3 | Adventure psql time     |   300
  4 | Server gravity falls    |   300
  5 | Log gossips             |   123
  7 | Me and my bash-pet      |   499
 10 | 2 insert after sharding |   101
(10 rows)

test_database=# SELECT * FROM orders_1;
 id |          title          | price
----+-------------------------+-------
  2 | My little database      |   500
  6 | WAL never lies          |   900
  8 | Dbiezdmin               |   501
  9 | 1 insert after sharding |   505
(4 rows)

test_database=# SELECT * FROM orders_2;
 id |          title          | price
----+-------------------------+-------
  1 | War and peace           |   100
  3 | Adventure psql time     |   300
  4 | Server gravity falls    |   300
  5 | Log gossips             |   123
  7 | Me and my bash-pet      |   499
 10 | 2 insert after sharding |   101
(6 rows)
```

При создании таблицы можно было сразу задать параметры партицирования:

```bash
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE (price);

CREATE TABLE public.orders_1 PARTITION OF public.orders FOR VALUES FROM (500) TO (MAXVALUE);
CREATE TABLE public.orders_2 PARTITION OF public.orders FOR VALUES FROM (MINVALUE) TO (500);
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?  

__ОТВЕТ:__  Делаем бэкап:

```bash
root@e398ee8a2e9d:/# pg_dump -Uwizard -dtest_database > /var/lib/postgresql/backup/test_database_backup.sql
```  

Чтобы добавить уникальность столбца `title` для таблиц `test_database` я бы вставил в бэкап после создания каждой таблицы строку создания индекса и потом подключил их к основному:

```bash
...
ALTER TABLE ONLY public.orders ADD CONSTRAINT title_unique_key UNIQUE (title);
...
ALTER TABLE public.orders_1 ADD CONSTRAINT title_unique_key_1 UNIQUE (title);
...
ALTER TABLE public.orders_2 ADD CONSTRAINT title_unique_key_2 UNIQUE (title);
...
ALTER INDEX title_unique_key ATTACH PARTITION title_unique_key_1;
ALTER INDEX title_unique_key ATTACH PARTITION title_unique_key_2;
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
