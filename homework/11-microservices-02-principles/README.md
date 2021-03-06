
# Домашняя работа к занятию "11.02 Микросервисы: принципы"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: API Gateway

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:

- Маршрутизация запросов к нужному сервису на основе конфигурации
- Возможность проверки аутентификационной информации в запросах
- Обеспечение терминации HTTPS

Обоснуйте свой выбор.  

**ОТВЕТ:**

| Название | Описание |       Особенности       |
|----------|----------|-------------------------|
| Amazon API Gateway | Amazon API Gateway — пожалуй, самый известный сервис, предназначенный для создания, публикации, обслуживания, мониторинга и обеспечения безопасности API в любых масштабах. <br>Документация включает подробные инструкции — от развёртывания RESTful API при создании бессерверного веб-приложения до работы с HTTP API, поэтому не придётся искать примеры по всей Сети, чтобы разобраться. | - Создание API RESTful при помощи API HTTP или API REST.<br>- Интерфейсы API WebSocket для разработки приложений, которым требуется двусторонняя связь в режиме реального времени.<br>- Частная интеграция с AWS ELB и AWS Cloud Map.<br>- Ключи API для сторонних разработчиков.<br>- Генерирование клиентских SDK на многих языках, включая JavaScript, iOS и Android.<br>- Внедрение подписи четвёртой версии для API REST и API WebSocket при авторизации и проверке запросов API к другим сервисам AWS API Gateway.<br>- Авторизация с помощью AWS Lambda.<br>- Amazon API Gateway можно пользоваться бесплатно целый год — пока ваши потребности не превышают один миллион вызовов API, полученных для API REST, один миллион вызовов API, полученных для API HTTP, и один миллион сообщений и 750 000 минут подключения для API WebSocket в месяц.<br>- Обучение с помощью пошаговых учебных пособий, а также доступ к более чем 500 бесплатным онлайн-курсам. |
| Oracle API Gateway | Сервис Oracle API Gateway стал доступен любому пользователю в конце 2019 года и уже пытается активно конкурировать с Amazon API Gateway. Получится ли у него отвоевать хотя бы часть аудитории у AWS, нам только предстоит увидеть… а сравнивать всегда интереснее на собственном опыте. Почитать про создание своего API Gateway можно вот в этой статье. | - RESTful API в комбинации с Oracle Functions, а также возможностями Kubernetes и Compute.<br>- Каждая служба в облачной инфраструктуре Oracle интегрируется с IAM для аутентификации и авторизации (консоль, SDK или CLI и REST API).<br>- Интеграция с системой управления доступом Oracle Cloud Infrastructure.<br>- Бесплатный период длительностью в тридцать дней, чтобы опробовать возможности широкого спектра сервисов Oracle Cloud, в том числе к Databases, Analytics, Compute, Container Engine for Kubernetes и т. д.<br>- Платформа Oracle Cloud позиционирует себя как более экономичное решение, чем AWS, и в качестве примера упоминает, что соотношение цены и производительности в 2 раза выше, а стоимость исходящей пропускной способности составляет только 1/4 от стоимости у AWS. |
| Google API Gateway | Сервис перешёл на стадию публичного бета-тестирования 18 сентября 2020 года, так что пока о нём известно довольно мало — и тем интереснее пронаблюдать за его развитием.Сейчас Google API Gateway позволяет управлять API других сервисов облачной платформы — Cloud Functions, Cloud Run, App Enginе, Compute Engine и Google Kubernetes Engine. Настроить работу с Cloud Run, к примеру, можно всего за несколько минут. | - Оплачиваются только вызовы к инфраструктурным службам. Стоимость зависит от количества вызовов, а входящий трафик всегда бесплатен.<br>- До 2 миллионов запросов в месяц — бесплатно.<br>- Наличие пробной версии. Google Cloud предоставляет виртуальный кредит в размере 300 долларов, который необходимо потратить в течение последующих трёх месяцев. После окончания бесплатного периода оплата не начинает взиматься автоматически — на платный тариф необходимо перейти вручную. |
| SberCloud API Gateway | SberCloud API Gateway использует наработки Huawei, а информации об особенностях применении в Сети можно найти немного, но здесь вам поможет Хабр: после недавнего хакатона один из участников рассказал о впечатлениях от SberCloud и сравнил функциональность с более известным AWS.  | - Доступ к облачным продуктам для физических лиц возможен только с помощью входа/регистрации через Сбер ID.<br>- Управление квотами и регулирование запросов пользователей.<br>- Встроенный инструмент отладки.<br>- Визуализированная панель мониторинга API.<br>- Создание каналов VPC для доступа к бэкенд-сервисам в сети VPC и управления нагрузкой путём отправки API-запросов на различные серверы.<br>- Цифровая подпись, которая вступает в силу только после привязки к API.<br>- Никакой минимальной или предварительной платы — оплачивается только фактическое использование.<br>- Возможность монетизации API. |
| Yandex API Gateway | 23 сентября 2020 года к четырём сервисам платформы Yandex.Cloud прибавились ещё два — Yandex API Gateway и база данных Yandex Database в режиме Serverless. <br>Yandex API Gateway интегрирован с другими сервисами платформы, благодаря чему возможна отправка HTTP-запросов с помощью функций Yandex Cloud Functions, доступ к статическим данным осуществляется Yandex Object Storage напрямую из хранилища, а запуск произвольных HTTP-сервисов в облаке возможен с помощью Yandex Managed Service for Kubernetes. Так что спектр применения широк — к примеру, внутри облака можно запустить приложение на Express.js. | - Наличие расширений для спецификации, которые можно использовать для интеграции с другими облачными платформами.<br>- Поддержка OpenAPI 3.0.<br>- Обработка запросов только по протоколу HTTPS. Сервис автоматически перенаправляет все запросы к API-шлюзам по протоколу HTTP на их HTTPS-версии.<br>- Интеграция с системой управления доменами сервиса Certificate Manager. Для обеспечения TLS-соединения используется привязанный к домену сертификат.<br>- Система квот и лимитов. Максимальный размер спецификации — 3,5 МБ. Количество API-шлюзов в одном облаке — 10, но, в отличие от максимального размера спецификации, меняется по запросу в техническую поддержку. |
| Nginx | nginx — это HTTP-сервер и обратный прокси-сервер, почтовый прокси-сервер, а также TCP/UDP прокси-сервер общего назначения, изначально написанный Игорем Сысоевым. Уже длительное время он обслуживает серверы многих высоконагруженных российских сайтов, таких как Яндекс, Mail.Ru, ВКонтакте и Рамблер. Согласно статистике Netcraft nginx обслуживал или проксировал 22.36% самых нагруженных сайтов в ноябре 2021 года. | - Обслуживание статических запросов, индексных файлов, автоматическое создание списка файлов, кэш дескрипторов открытых файлов;<br>- Акселерированное обратное проксирование с кэшированием, распределение нагрузки и отказоустойчивость;<br>- Акселерированная поддержка FastCGI, uwsgi, SCGI и memcached серверов с кэшированием, распределение нагрузки и отказоустойчивость;<br>- Модульность, фильтры, в том числе сжатие (gzip), byte-ranges (докачка), chunked ответы, XSLT-фильтр, SSI-фильтр, преобразование изображений; несколько подзапросов на одной странице, обрабатываемые в SSI-фильтре через прокси или FastCGI/uwsgi/SCGI, выполняются параллельно;<br>- Поддержка SSL и расширения TLS SNI;<br>- Поддержка HTTP/2 с приоритизацией на основе весов и зависимостей.<br>- Проксирование TCP и UDP;<br>- Поддержка SSL и расширения TLS SNI для TCP;<br>- Распределение нагрузки и отказоустойчивость;<br>- Ограничение доступа в зависимости от адреса клиента;<br>- Выполнение разных функций в зависимости от адреса клиента;<br>- Ограничение числа одновременных соединений с одного адреса;<br>- Настройка форматов логов, буферизованная запись в лог, быстрая ротация логов, запись в syslog;<br>- Геолокация по IP-адресу; |
| Ocelot | Ocelot - это технология шлюза API с открытым исходным кодом, реализованная с помощью технологии .NET Core.| К преимуществам Ocelot можно отнести его мощную функциональность и простоту использования. В его функции входят: маршрутизация, агрегирование запросов, обнаружение сервисов, аутентификация, аутентификация, предохранитель с ограничением тока и встроенная интеграция балансировщика нагрузки, Service Fabric, Skywalking и т. Д. И для выполнения этих функций требуется только простая настройка.<br>В настоящее время клиенты Tencent и Microsoft размещены на официальном сайте Ocelot. |

Если компания строит систему используя решения какого-либо Cloud service provider, то API Gateway рекомендую использовать родное, дабы не плодить сущности, а функционал у них у всех примерно одинаковый. Если система строится преимущественно на .Net и других решениях от Microsoft, то возможно стиот присмотреться к Azure API Management или Ocelot. В общем же случае предлагаю использовать проверенное решение - Nginx

## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:

- Поддержка кластеризации для обеспечения надежности
- Хранение сообщений на диске в процессе доставки
- Высокая скорость работы
- Поддержка различных форматов сообщений
- Разделение прав доступа к различным потокам сообщений
- Простота эксплуатации

Обоснуйте свой выбор.  

**ОТВЕТ:**  

|  | ActiveMq | RabbitMq | Kafka |
|--|----------|----------|-------|
| Производитель отказоустойчив, потеряет ли он данные | - | Существуют проверенные модели и модели транзакций, которые гарантируют, что по крайней мере данные не будут потеряны. Модель подтверждения может иметь дубликаты сообщений, и модель транзакции гарантированно будет полностью согласованной | В пакетном режиме данные могут быть потеряны. В не пакетном формате: 1. В синхронном режиме могут быть дублированные данные. 2. В асинхронном режиме данные могут быть потеряны. |
| Отказоустойчивость потребителя, потеряет ли он данные | - | В модели ack данные не будут потеряны, но данные могут обрабатываться повторно. | В пакетном режиме данные могут быть потеряны. В не пакетном формате данные могут обрабатываться повторно. (ZK смещение записи асинхронно) |
| Архитектурная модель | На основе протокола JMS | Основанный на модели AMQP, он является относительно зрелым, но обновление происходит очень медленно. Брокер RabbitMQ состоит из Exchange, Binding и queue, где обмен и привязка составляют ключ маршрутизации сообщения, клиент-производитель связывается, соединяя канал и сервер, а Consumer получает сообщение из очереди для потребления (при длинном соединении очередь будет отправлена ​​в На стороне потребителя потребитель читает данные из входного потока в цикле). rabbitMQ сосредоточен на брокере, есть механизм подтверждения сообщений | Производитель, брокер, потребитель, в центре которого находится потребитель, информация о потребителе информации о потребителе сообщений сохраняется, потребитель извлекает данные из брокера в пакетном режиме в зависимости от точки потребления, механизм подтверждения сообщения отсутствует. |
| Пропускная способность | - | RabbitMQ немного уступает kafka по пропускной способности, их отправная точка отличается: rabbitMQ поддерживает надежную доставку сообщений, поддерживает транзакции и не поддерживает пакетные операции, исходя из требований к надежности хранилища, хранилище может использовать память или жесткий диск. | Кафка обладает высокой пропускной способностью, внутренней пакетной обработкой сообщений, механизмом нулевого копирования, хранением и извлечением данных, являются последовательными пакетными операциями на локальном диске, со сложностью O (1) и высокой эффективностью обработки сообщений. |
| Юзабилити | - | rabbitMQ поддерживает очередь зеркала, основная очередь недействительна, и очередь зеркала вступает во владение | Брокер Кафки поддерживает активный и дежурный режим |
| Балансировка нагрузки кластера | - | Для балансировки нагрузки RabbitMQ требуется отдельный балансировщик нагрузки | Kafka использует zookeeper для управления брокерами и потребителями в кластере и может регистрировать темы для zookeeper: с помощью механизма координации zookeeper производитель сохраняет информацию о брокере соответствующей темы, которую можно отправлять брокеру случайным образом или опрашивать; Sharding, сообщение отправляется на осколок брокера |

RabbitMq более зрелый, чем kafka. С точки зрения удобства использования, стабильности и надежности RabbitMq превосходит kafka

## Задача 3: API Gateway * (необязательная)

### Есть три сервиса  
  
**minio**  

- Хранит загруженные файлы в бакете images
- S3 протокол

**uploader**

- Принимает файл, если он картинка сжимает и загружает его в minio
- POST /v1/upload

**security**

- Регистрация пользователя POST /v1/user
- Получение информации о пользователе GET /v1/user
- Логин пользователя POST /v1/token
- Проверка токена GET /v1/token/validation

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway

**POST /v1/register**

- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/user

**POST /v1/token**

- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/token

**GET /v1/user**

- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис security GET /v1/user

**POST /v1/upload**

- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис uploader POST /v1/upload

**GET /v1/user/{image}**

- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис minio  GET /images/{image}

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
Авторизаци
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' <http://localhost/token>

**Загрузка файла**

curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg <http://localhost/upload>

**Получение файла**

curl -X GET <http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg>

---

#### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
