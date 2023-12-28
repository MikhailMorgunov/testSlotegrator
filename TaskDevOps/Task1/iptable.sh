#!/bin/bash

iptables -F
iptables -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# цепочка для адресов, которым разрешено все (все порты)
iptables -N ALLOW_ALL
iptables -A ALLOW_ALL -j ACCEPT

# цепочка для адресов серверов баз данных и контейнеров с приложением, которым разрешено все
iptables -N DB_SERVERS
iptables -A DB_SERVERS -p tcp --dport 3306 -j ACCEPT  # MySQL
iptables -A DB_SERVERS -p tcp --dport 5432 -j ACCEPT  # PostgreSQL

# цепочка, в которую будут заноситься адреса пользователей, которым нужен доступ по требованию. Им также разрешено все
iptables -N USER_ACCESS

# цепочка, в которую будут заноситься адреса пользователей с временным доступом, им разрешены только определенные порты
iptables -N TEMP_USER_ACCESS

# цепочка, в которую заносятся порты, смотрящие в мир
iptables -N EXPOSED_PORTS

# логирование
iptables -A INPUT -j LOG --log-prefix "BLOCKED INPUT: " --log-level 7
iptables -A OUTPUT -j LOG --log-prefix "BLOCKED OUTPUT: " --log-level 7
iptables -A FORWARD -j LOG --log-prefix "BLOCKED FORWARD: " --log-level 7

# подключаем цепочки к основным таблицам
iptables -A INPUT -j ALLOW_ALL
iptables -A INPUT -j DB_SERVERS
iptables -A INPUT -j USER_ACCESS
iptables -A INPUT -j TEMP_USER_ACCESS
iptables -A INPUT -j EXPOSED_PORTS

service iptables save

service iptables restart
