# Задача 2 - Linux

### Задача

На виртуальные машины поставить Debian 12 и Centos 7. На них установить основной apache (backend) и проксирующий nginx 
(frontend). В nginx\`е настроить балансировку на оба apache`а. Инструкцию написать в гит вторым уроком, сделать МР на 
меня.

В инструкции должны быть пункты:
1) Виртуальная машина - как настроить для Вашей ОС, задать ресурсы.
2) Дистрибутивы Linux - где брать, платно ли это, основные отличия двух перечисленных выше.
3) Когда задолбался писать команды вручную в окне ВМ - ssh и с чем его едят.
4) Как устанавливают ПО в Linux - make install, пакетные менеджеры.
5) Почему:
   
   а) в Debian поставились два веб-сервера, но заработал только один.
   
   б) в Centos поставились два веб-сервера, ни один не заработал.
   
   в) Как вы это узнали? Что им мешает? Как сделать, чтоб они запускались при старте системы?
   
   г) в Debian дефолтная страница веб сервера открывается, а в Centos нет.
   
   д) Про сети нужно что-то знать и понимать.
6) Скриншоты или видео, где показана работа системы.

Для выполнения задания вам должно хватить (на каждую ВМ) 5 Гб места, 0,5 Гб ОЗУ, 1 vCPU. При установке ВМ сделать 
снимок. перед сдачей МР откатить ВМ на первоначальное состояние и по своей инструкции повторить настройку заново.

Приветствуется краткость и лаконичность. Копировать весь man не надо. В описание задания есть мины и неточности.

---

1. [Виртуальная машина](#virtual-machine)
   1. [Установка](#установка)
   2. [Настройка](#настройка)
2. [Дистрибутивы Linux](#дистрибутивы)
   1. [Где взять](#образы)
   2. [Отличия](#отличия)
3. [SSH](#ssh)
   1. [Настройка ВМ](#настройка-вм)
   2. [Настройка ОС](#настройка-ос)
   3. [SSH ключи](#ssh-ключи-для-быстрого-доступа)
4. [Установка ПО](#установка-по)
   1. [Установка из сорцов](#установка-из-исходников)
   2. [Установка из пакетов](#менеджеры-пакетов)
5. [Root](#root)
6. [systemd](#подсистема-инициализации-и-управления-службами-systemd)
   1. [Команды](#основные-команды-для-взаимодействия)
7. [Apache](#apache)
   1. [Установка и настройка в Debian](#установка-и-настройка-apache-в-debian)
   2. [Установка и настройка в CentOS](#установка-и-настройка-apache-в-centos)
      1. [Порты](#порты)
8. [Nginx](#nginx)
   1. [Установка и настройка в Debian](#установка-и-настройка-nginx-в-debian)
   2. [Установка и настройка в CentOS](#установка-и-настройка-nginx-в-centos)
9. [Результаты](#результаты)
#

## Virtual Machine

### Установка

В плане VM решил взять VirtualBox. Бесплатный, простой, понятный.

Так-как у меня Ubuntu устанавливал из пакета.
```shell
sudo apt install virtualbox
```

### Настройка

Настройка кнопками и ползунками.

В момент создания ВМ'ки указываем тип операционной системы как Linux и версию в соответствии с веткой задания, либо 
Debian, либо RedHat, так как CentOS операционная система именно этого семейства.

Далее указываем количество оперативной памяти и дискового пространства. Виртуальная машина создана. Далее в настройках 
можем указать количество процессоров, является ли диск твердотельным и примонтировать образ, который будет загружен.

## Дистрибутивы

### Образы

Образы дистрибутивов взяты с официальных сайтов. Они бесплатны, так-как не Enterprise. Да и на ентерпрайсе вроде платят
не за систему, а за поддержку.

***Debian:*** https://www.debian.org/distrib/netinst/debian-12.2.0-amd64-netinst.iso

***CentOS:*** http://mirrors.datahouse.ru/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso

> Ссылка на `CentOS` взята с http://isoredirect.centos.org/centos/7/isos/x86_64/, однако здесь предоставляется список 
> зеркал. Какой из них брать? ХЗ! В теории лучше тот который территориально ближе, но какой из них ближе Я без понятия, 
> по этому был взят первый по списку!

### Отличия
1) Концептуальных отличий не знаю, кроме того что 2 разных семейства. Debian это Debian, а CentOS это RedHat.
2) Есть разница в устанавливаемых пакетах. Пакеты Debian имеют расширение `.deb`, а CentOS `.rpm`.
3) Отличаются менеджеры пакетов. Debian используют программу `apt`, CentOS `yum`.

В целом прям такие яркие отличия на этом и заканчиваются, кроме того что с 21го года RedHat прекратила поддержку CentOS,
а сам проект вообще закрыт.

## SSH
SSH (Secure Shell) - Сетевой протокол позволяющий управлять операционной системой на подобии какого-нибудь Telnet, 
только при это ещё и шифрует трафик.

### Настройка ВМ
Перед настройкой SSH у ОС, необходимо пробросить порты виртуальной машины у VirtualBox. 

Настройки -> Сеть -> Дополнительно -> Проброс портов

Имя любое, протокол выбираем как TCP, адрес хоста указывать не обязательно, адрес гостя тоже, всё равно коннект будет 
по хостовой тачке. Порт хоста, это порт по которому мы будем подключаться к удалённой тачке, а порт гостя это 
стандартный ssh порт.

| Имя    | Протокол | Адрес хоста | Порт хоста | Адрес гостя | Порт гостя |
|--------|----------|-------------|------------|-------------|------------|
| Debian | TCP      | -           | 2222       | -           | 22         |
| CentOS | TCP      | -           | 2220       | -           | 22         |

Такую настройку нужно сделать у каждой машины по отдельности.

### Настройка ОС
При установке Debian будет предложено предустановить ssh-сервер, однако можно поставить и самому.
```shell
sudo apt install openssh-server
```
Проверяем статус, что служба запущена и работает.
```shell
sudo systemctl status ssh
```
```shell
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled; preset: enabled)
     Active: active (running) since Fri 2023-11-10 21:26:34 +10; 1h 31min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
    Process: 565 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 582 (sshd)
      Tasks: 1 (limit: 4623)
     Memory: 7.2M
        CPU: 750ms
     CGroup: /system.slice/ssh.service
             └─582 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
```
Стоит обратить внимание на пункт `Loaded`. Если стоит параметр `enabled`, значит сервис добавлен в автозагрузку, если 
нет, это можно также сделать с помощью систему управления службами.
```shell
sudo systemctl enabled ssh
```
Для CentOS всё аналогично, только демон там зовётся как `sshd.service`.
```shell
sudo systemctl status sshd
```

Теперь можно попробовать подключится. Вызываем ssh с флагом `-p` который отвечает за порт, указываем порт нужной машины
указанный в настройках. После имя пользователя удалённой тачки и адрес хоста на котором крутятся ВМ. 
`ssh -p $PORT $USER@$HOST`
```shell
# Debian
ssh -p 2222 username@localhost
# CentOS
ssh -p 2220 username@localhost
```

Если подключаемся с других устройств, то вместо `localhost` разумеется указываем ip адрес.
![ssh](./img/ssh.jpg)

### SSH ключи для быстрого доступа
SSH-ключи необходимы для идентификации пользователя по протоколу SSH, вместо авторизации по паролю.

Для генерации ключа на клиенте используем команду `ssh-keygen`. После ряда вопросов типа куда сохранить, проверочная 
фраза и т.д. будет создан отпечаток ключа `key fingerprint`. По умолчанию он сохраняется в `~/.ssh/`. В `.ssh` будет 
создано 2 файла, `id_rsa.pub` являющийся публичным ключом, который будем использовать, а так же `id_rsa`. 
`~/.ssh/id_rsa` - это закрытый ключ который никому не стоит показывать.

Также при создании ключа можно указать время его жизни, так же число бит ключа и метод шифрования.

После того как ключ был создан, его открытую часть необходимо скопировать на удалённую машину где собираемся 
авторизовыватся.
#### Debian
```shell
cat ~/.ssh/id_rsa.pub | ssh username@localhost 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
```
#### CentOS
В целом для CentOS команда аналогичная, за исключением, того что рекурсивно для директории `.ssh` применяется chmod. 
В противном случае ключ не будет использоваться и попытки авторизации будут приводить к тому что будет запрашиваться 
пароль.
```shell
cat ~/.ssh/id_rsa.pub | ssh username@localhost "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod -R go= ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

## Установка ПО
В Linux основных 2 варианта установки программного обеспечения. 
1. Из сорцов `./configure && make && make install`.
2. Из пакетов с помощью `dpkg`, `apt-get` или `apt` для Debian систем и `yum` для RH. 
> Возможно для RH есть ещё что-то как в случае Debian, но тут Я без понятия. 

### Установка из исходников
В целом тут всё просто. 

`./configure` - по сути осуществляет подготовку исходников перед компиляцией. Ищет заголовки, подключает библиотеки и 
так далее, после чего создаётся необходимый для сборки файл с именем `Makefile`.

`make` - непосредственно сам процесс компиляции. Читает `Makefile` где описан процесс сборки программы.

`make install` - собственно процесс установки собранной программы. Так-как исполняемые файлы за частую ставятся в 
директории `/usr/../` то могут потребоваться привелегии суперпользователя ну или сокращённо `root`.

### Менеджеры пакетов
Использование менеджеров пакетов всегда исполняется с root правами.

То есть или
```
$ su - авторизуемся как root
# apt install {packegname} - для Debian
# yum install {packegname} - для RH
```
или
```shell
$ sudo apt install {packegname} - для Debian
$ sudo yum install {packegname} - для RH 
```
где `sudo`(substitute user and do - подменить пользователя и выполнить), это утилита для повышения привелегий до уровня 
суперпользователя.

## Root
Может быть так что пользователь не включён в группу `sudo` из-за чего при попытке выполнить команду может приводить к 
сообщению `$USER is not in the sudoers file`. В Debian по умолчанию так.

Чтобы добавить в пользователя Debian в группу sudo нужно воспользоваться командой `usermod`. Однако так-как в переменной
`$PATH` отсутствует ссылка на `/usr/sbin`, то выполнение команды приведёт к сообщению о том что команда не найден. По 
этому для решения данной проблемы используем полный путь до утилиты. Можно конечно и добавить путь в переменную, однако 
зачем? Всё равно команда используется только один раз. 
> ВАЖНО: Выполнять команду необходимо из под root, по этому сперва меняем пользователя на root и затем выполняем команду
```
$ su
# /usr/sbin/usermod -aG sudo $USER
```

## Подсистема инициализации и управления службами systemd
По сути `systemd` это менеджер управления модулями, которые из себя представляют специально оформленные файлы 
конфигурации. Каждый модуль отвечает за точки монтирования `.mount`, файл подкачки `.swap`, подключаемые устройства 
`.device`. Чаще всего приходится взаимодействовать с модулем отвечающим за работу сервисов (служб или демонов) 
`.service`.

Демон - в `UNIX` подобных системах программа работающая в фоне.

Для взаимодействия с systemd используется утилита `systemctl`, для которой можно указать интересующую нас команду и 
далее имя интересующего нас модуля, либо целиком включая тип модуля, либо только имя. 

```shell
systemctl status ssh.service == systemctl status ssh
```

### Основные команды для взаимодействия
* status - посмотреть статус выполнения службы
* start - запустить службу
* stop - остановить
* restart - перезапуск stop && start службы
* reload - перечитать конфигурацию не останавливая работу службы
* enable - добавить службу в автозапуск
* disable - удалить службу из автозапуска

Есть также вариант с помощью `service`
```shell
sudo service restart ssh
```

## Apache
Как и в случае с [SSH](#ssh), для `apache` сперва стоит открыть порты на ВМ.

### Установка и настройка apache в Debian
Устанавливаем сам сервер, если есть необходимость добавляем в автозагрузку
```shell
sudo apt install apache2
```
Открываем listener на нужном порту `Listen $PORT` в `/etc/apache2/ports.conf`. Я для себя взял `18080`. Далее исходя из 
комментария в файле, меняем `VirtualHost` оператор или создаём свой в директории `/etc/apache2/sites-available`.
```
<VirtualHost *:18080>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
Сама директории для файлов конфигурации портов, а также `VirtualHost` указываются в основном конфигурационном файле 
apache `/etc/apache2/apache2.conf`. 
```
# Include list of ports to listen on
Include ports.conf
...
# Include the virtual host configurations:
IncludeOptional sites-enabled/*.conf
```
> Примечание
>> Если обратить внимание, то `VirtualHost` мы делаем в /etc/apache2/sites-available, но в конфиге указан 
> `../sites-enabled`. Дело в том что в `sites-enabled` создана символическая ссылка на файл из `sites-available`.
 ```shell
lrwxrwxrwx 1 root root 41 ноя 11 17:59 /etc/apache2/sites-enabled/my_host.conf -> /etc/apache2/sites-available/my_host.conf
```
После того как была создана необходимая конфигурация, делаем `restart` или `reload` сервиса `apache`, дабы изменения 
применились и вступили в силу.

Убедиться что порт открыт можно с помощью утилиты `netstat`
```shell
sudo netstat -tlpn | grep apache2
```
Видим что порт открыт и слушается
```shell
tcp6       0      0 :::18080                :::*                    LISTEN      4504/apache2
```
Далее дабы убедиться что сервер действительно работает, можно отправить стандартный http GET запрос нашему серверу.
```shell
curl -v localhost:18080
```
Получаем ответ с заголовками страницы, а также её содержимым
```http request
*   Trying 127.0.0.1:18080...
* Connected to localhost (127.0.0.1) port 18080 (#0)
> GET / HTTP/1.1
> Host: localhost:18080
> User-Agent: curl/7.88.1
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Sun, 12 Nov 2023 13:52:02 GMT
< Server: Apache/2.4.57 (Debian)
< Last-Modified: Fri, 10 Nov 2023 16:07:27 GMT
< ETag: "29cd-609ce844d84dc"
< Accept-Ranges: bytes
< Content-Length: 10701
< Vary: Accept-Encoding
< Content-Type: text/html
< 

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
...
</html>

* Connection #0 to host localhost left intact
```

Как видно из ответа, получили статускод `200 OK`, что соответствует валидному `http respond`.

Также можно посмотреть `access log` сервера, дабы убедиться что всё в порядке.
```shell
sudo less /var/log/apache2/access.log
```
В логе также видим что запрос от клиента `curl` был успешен и имеет статускод 200.
```logcatfilter
127.0.0.1 - - [12/Nov/2023:23:52:02 +1000] "GET / HTTP/1.1" 200 10956 "-" "curl/7.88.1"
```

### Установка и настройка apache в CentOS
По сути всё аналогично [Debian](#установка-и-настройка-apache-в-debian), кроме некоторых деталей. Например `Apache` 
здесь, это `httpd`.
```shell
sudo yum install httpd
```
Аналогично добавляем в автозагрузку.
```shell
sudo systemctl enable httpd
```
Для настройки идём в конфигурационный файл `/etc/httpd/conf/httpd.conf` и уже там указываем `listener` нужного порта или
файл конфигурации для него, как это было в примере выше, так же подключаем `sites-enabled`, опять же если необходимо. 

Если собираемся использовать `VirtualHost`, стоит подключить `sites-enabled` и создать директорию вместе с 
`sites-available` в виду их отсутствия.
```shell
sudo mkdir /etc/httpd/sites-available/ /etc/httpd/sites-enabled/
```
Аналогично тому как это сделано в [Debian](#установка-и-настройка-apache-в-debian), создаём файл с `VirtualHost` и 
делаем на него символическую ссылку.
```shell
sudo ln -s /etc/httpd/sites-available/my_host.conf /etc/httpd/sites-enabled/my_host.conf
```
Далее открываем нужный [порт](#порты) и делаем перезапуск сервера. Всё должно работать.

#### Порты
В CentOS порты необходимо открывать в брандмауэре, в противном случае ничего работать не будет.
```shell
sudo firewall-cmd --permanent --add-port=18080/tcp
sudo firewall-cmd --reload
```
Если не использовать порты `80`, `81`, `8008`, `8009`, а какие-либо другие, то тот же `apache` скорее всего даже не 
поднимется сообщая об ошибке, которую можно будет посмотреть через утилиту `journalctl`.
```shell
journalctl -xe
```
Здесь можно будет увидеть ошибку о запрете доступа и невозможности сбиндить адрес.
```logcatfilter
Permission denied: AH00072: make_sock: could not bind to address 0.0.0.0:18080
```
Связано это с `SELinux` - системой принудительного контроля доступа. Есть 2 варианта решения. Отключаем временно или 
полностью.

***Временно***
```shell
sudo setenforce 0
```
***Полностью*** - открываем файл конфигурации, находим строку `SELINUX=...` и меняем значение на `disabled`.
```shell
sudo vi /etc/selinux/config
SELINUX=disabled
```
После этого можно перезапускать сервис.

## Nginx
Также сперва открываем порты на ВМ.

### Установка и настройка nginx в Debian
Устанавливаем и добавляем в автозагрузку.
```shell
sudo apt install nginx
sudo systemctl enable nginx
```
Создаём конфиг в `/etc/nginx/sites-available`.
```
upstream apache_servers {
    server localhost:18080;
    server $REMOTE_HOST:$REMOTE_PORT;
}

server {
    listen 8080;
    
    location / {
        proxy_pass http://apache_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
Создаём на него символическую ссылку в `sites-enabled`.
```shell

```
Перед перезапуском можем протестировать синтаксис конфига на валидность.
```shell
sudo nginx -t
```
Если получили такой результат, то всё ок, можно делать рестарт.
```logcatfilter
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
Делаем перезапуск сервиса nginx и убеждаемся что listener поднят.
```shell
sudo netstat -tlpn | grep nginx
```
```logcatfilter
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      5667/nginx: master
```
Дабы убедиться, отправляем 2 запроса. Один на apache, второй nginx
```shell
# Apache
curl -vI localhost:18080
# Nginx
curl -vI localhost:8080
```
Смотрим результат последних запросов в `access.log` apache и nginx.
```logcatfilter
$ sudo tail -2 /var/log/apache2/access.log
127.0.0.1 - - [13/Nov/2023:01:04:25 +1000] "HEAD / HTTP/1.0" 200 274 "-" "curl/7.88.1"
127.0.0.1 - - [13/Nov/2023:01:04:37 +1000] "HEAD / HTTP/1.1" 200 255 "-" "curl/7.88.1"
$ sudo tail -2 /var/log/nginx/access.log
127.0.0.1 - - [13/Nov/2023:01:04:25 +1000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.88.1"
```
Из логов видим что в `apache` и `nginx` обратились по разу, но в логе apache 2 записи, так-как пришел реквест от nginx, 
а в nginx 1.

### Установка и настройка nginx в CentOS
Чтобы произвести установку nginx, сперва необходимо добавить репозиторий `epel-release` из которого можно будет его 
поставить.
```shell
sudo yum install epel-release
sudo yum install nginx
```
Затем аналогично настройке apache подключаем `sites-enabled`. Для этого в блок `http {}` основной конфигурации nginx 
добавляем директорию.
```
http {
   # Load sites-enabled
   include sites-enabled/*.conf;
}
```
Создаём нужные директории.
```shell
sudo mkdir /etc/nginx/sites-available/ /etc/nginx/sites-enabled/
```
Подобно конфиг файлу из [Debian](#установка-и-настройка-nginx-в-debian) создаём такой же в `sites-available`, только с 
нужными портами, особенно для удалённой тачки и делаем на него символическую ссылку.
```shell
sudo ln -s /etc/nginx/sites-available/my_host.conf /etc/nginx/sites-enabled/my_host.conf
```
Тестируем синтаксис конфига.
```shell
sudo nginx -t
```
Открываем [порты](#порты) для nginx и делаем рестарт сервиса, дабы применить все изменения.

## Результаты
### Debian
```logcatfilter
curl -vI localhost:18080 - GET HTTP/1.1 200
/var/log/apache2/access.log
127.0.0.1 - - [13/Nov/2023:01:41:01 +1000] "HEAD / HTTP/1.1" 200 255 "-" "curl/7.88.1"
---
curl -vI localhost:8080 - GET HTTP/1.1 200
/var/log/apache2/access.log
::1 - - [13/Nov/2023:01:42:04 +1000] "HEAD / HTTP/1.0" 200 274 "-" "curl/7.88.1"
127.0.0.1 - - [13/Nov/2023:01:42:05 +1000] "HEAD / HTTP/1.0" 200 274 "-" "curl/7.88.1"
/var/log/nginx/access.log
127.0.0.1 - - [13/Nov/2023:01:46:12 +1000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.88.1"
---
curl -vI $HOST:18082 - GET HTTP/1.1 200
/var/log/httpd/access_log
$HOST - - [11/Nov/2023:22:53:51 +1000] "HEAD / HTTP/1.1" 200 - "-" "curl/7.88.1"
---
curl -vI $HOST:8082 - GET HTTP/1.1 200
/var/log/httpd/access_log
::1 - - [11/Nov/2023:22:58:27 +1000] "HEAD / HTTP/1.0" 200 - "-" "curl/7.88.1"
/var/log/nginx/access.log
$HOST - - [11/Nov/2023:22:58:27 +1000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.88.1" "-"
```

### CentOS
```logcatfilter
curl -vI localhost:18080 - GET HTTP/1.1 200
/var/log/httpd/access_log
::1 - - [11/Nov/2023:23:00:50 +1000] "HEAD / HTTP/1.1" 200 - "-" "curl/7.29.0"
---
curl -vI localhost:8080 - GET HTTP/1.1 200
/var/log/httpd/access_log
127.0.0.1 - - [11/Nov/2023:23:02:06 +1000] "HEAD / HTTP/1.0" 200 - "-" "curl/7.29.0"
/var/log/nginx/access.log
127.0.0.1 - - [11/Nov/2023:23:02:22 +1000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
---
curl -vI $HOST:18081 - GET HTTP/1.1 200
/var/log/apache2/access.log
$HOST - - [13/Nov/2023:01:54:43 +1000] "HEAD / HTTP/1.1" 200 255 "-" "curl/7.29.0"
---
curl -vI $HOST:8081 - GET HTTP/1.1 200
/var/log/apache2/access.log
127.0.0.1 - - [13/Nov/2023:01:57:21 +1000] "HEAD / HTTP/1.0" 200 274 "-" "curl/7.29.0"
/var/log/nginx/access.log
$HOST - - [13/Nov/2023:01:57:21 +1000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.29.0"
```

Если попробовать из браузера хоста.
### Debian
```logcatfilter
HTTP GET localhost:18081 - 200
/var/log/apache2/access.log
$HOST - - [13/Nov/2023:02:00:23 +1000] "GET / HTTP/1.1" 200 3380 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0"
---
HTTP GET localhost:8081 - 200
/var/log/apache2/access.log
::1 - - [13/Nov/2023:02:02:31 +1000] "GET / HTTP/1.0" 200 3343 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0"
/var/log/nginx/access.log
$HOST - - [13/Nov/2023:02:02:31 +1000] "GET / HTTP/1.1" 200 3041 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0"
```

### CentOS
```logcatfilter
HTTP GET localhost:18082 - 304
/var/log/httpd/access_log
$HOST - - [11/Nov/2023:23:15:03 +1000] "GET / HTTP/1.1" 304 219 "http://localhost:18082/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0"
---
HTTP GET localhost:8082 - 304
/var/log/httpd/access_log
127.0.0.1 - - [11/Nov/2023:23:17:47 +1000] "GET / HTTP/1.0" 304 - "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0"
/var/log/nginx/access.log
$HOST - - [11/Nov/2023:23:17:47 +1000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0" "-"
```

---
[К предыдущей](../task1/task1.md) | [Вначало](#задача-2---linux) | [К следующей]()