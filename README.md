# Простой способ отслеживать окончание срока действия SSL-сертификата и доменного имени.

Статья основана на http://bit.ly/2YMiZkq (для SSL) и http://bit.ly/2YS14ZN (для домена).

## Структура репозитория

```
├── etc
│   └── zabbix
│       ├── scripts
│       │   ├── check_domain_exp.sh
│       │   ├── check_ssl_https.sh
│       │   ├── check_ssl_smtp.sh
│       │   ├── disc_domain_exp.sh
│       │   ├── disc_ssl_https.sh
│       │   ├── disc_ssl_smtp.sh
│       │   ├── domain_exp.txt
│       │   ├── ssl_https.txt
│       │   └── ssl_smtp.txt
│       └── zabbix_agentd.d
│           ├── domain.conf
│           └── ssl.conf
├── README.me
├── domain_expiration.xml
└── ssl_cert_expiration.xml
```

## Подготовка

У вас на сервере должны быть установлены два обязательных пакета: openssl - для проверки SSL; whois - для проверки доменов

## Установка и настройка скриптов для SSL и Доменов

Все действия выполняете при помощи консоли :)

Содержимое папки /etc/zabbix/scripts положите в соотв. папку в вашем Zabbix.

Укажите какие домены и суб-домены нужно отслеживать в файлах domain_exp.txt и ssl_https.txt. 1 строка 1 домен (субдомен). **Обратите внимание, что в файл *domain_exp.txt* необходимо вводить только домены, а не суб-домены, иначе будет ошибка!**

Зайдите в папку *cd /etc/zabbix/scripts* и выполните 2 команды, для того, чтобы сделать файлы исполняемыми:

> sudo chmod 0740 check_ssl_https.sh check_ssl_smtp.sh check_domain_exp.sh

> sudo chmod 0740 disc_ssl_https.sh disc_ssl_smtp.sh disc_domain_exp.sh

Далее необходимо сделать пользователя *zabbix* владельцем всех скриптов:

> sudo chown -R zabbix. /etc/zabbix/scripts

## Настройка конфигов Zabbix

Содержимое папки /etc/zabbix/zabbix_agentd.d перенестите в соотв. папку на сервере.

В основном файле /etc/zabbix/zabbix_agentd.conf увеличить параметр Timeout.
По-умолчанию, он установлен в значение 3, установите его в 10, чтобы Zabbix точно успел все проверить.

Перезапустите агента Zabbix

> sudo systemctl restart zabbix-agent

## Как проверить, что все работает

Перейдите в папку *cd /etc/zabbix/scripts*.

### Проверяем работу SSL

> sudo zabbix_agentd -t ssl_https.discovery

На экране появится список доменов, которые вы написали в файле ssl_https.txt

> sudo zabbix_agentd -t ssl_https.expire[google.com]

На экране будет показано сколько еще будет действовать SSL сертификат

### Проверяем работу доменов

> sudo zabbix_agentd -t domain_exp.discovery

По аналогии с SSL будет список доменов из файла domain_exp.txt.

> sudo zabbix_agentd -t domain_exp.expire[google.com]

На экране появится сколько еще дней до окончания доменного имени.

** ВАЖНО! Параметры, которые вы будете передавать zabbix_agentd в квадратных скобках *[имя домена]*, ОБЯЗАТЕЛЬНО должно быть в файлах ssl_https.txt и domain_exp.txt. Иначе будет ошибка. **

## Настройка Zabbix-веб-морды

Перейдите Configuration > Template > Import (правый верхний угол), далее импортируйте 2 файла ssl_cert_expiration.xml и domain_expiration.xml

Далее Configuration > Hosts -> Templates и привяжите два шаблона Domain Expiration и SSL Sert Expiration.

Теперь Zabbix начнет проверять SSL и Домены. Чтобы проверить что все ок, идите Monitoring > Latest data > А блоке с фильтрами, поле "Hosts" введите Zabbix server > Apply. В общем списке будет SSL и Domain.

Чтобы было удобно все отслеживать, вы можете добавить на экран дашборда необходимые блоки. Edit dashboard > Add widget:

- Type: Data overview
- Host groups: Zabbix server
- Application: SSL *(для доменов добавляйте Domain)*

На этом базовая настройка закончена. Мне этих мониторингов хватает с головой.
