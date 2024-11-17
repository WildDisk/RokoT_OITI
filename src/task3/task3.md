# Ansible

## Развертка Apache и Nginx с помощью Ansible

## Inventory
Ansible inventory — это набор управляемых хостов, которые мы хотим контролировать с помощью Ansible для различных задач 
автоматизации и управления конфигурацией.

По умолчанию inventory хранятся в `/etc/ansible/hosts`, но можно указать и произвольное место с помощью флага -i или
конфигурационного файла `ansible.cfg`. Файлы можно создавать в форматах `.ini` или `.yml|.yaml`.
```yaml
all:
  hosts:
    ubuntu_server:
      ansible_host: "{{ servers.ubuntu_server.ansible_host }}"
      ansible_user: "{{ ansible_user }}"
```

## Variables
Как для inventory, так и для playbook, дабы не писать конкретные значения в каждом файле, можно использовать переменные,
при помощи ключа `var_files`, который необходимо указывать на уровне исполняемых playbook'ов.
```yaml
- hosts: all
  vars_files:
    - vars.yml
```
Сами файлы переменных тоже создаются в формате `.yml|.yaml` и могут содержать конкретные адреса хостов, порты и другие 
данные необходимые для исполнения сценариев.
```yaml
servers:
  ubuntu_server:
    ansible_host: ubuntu_host
ansible_user: user_host
```

## Исполнение сценариев с повышенными привилегиями
Для исполнения сценариев с повышенными привилегиями можно использовать директиву `become`. Более подробно, смотри доку 
[ansible](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_privilege_escalation.html).

Для распараллеливания исполнения сценариев в задаче использовался вариант исполнения плейбуков в консоли с ключом `-K` 
или `--ask-become-pass`, однако для использования паролей можно использовать `ansible_become_password`, с хранящимися 
ключами в `ansible-vault`.
```shell
ansible-playbook -i hosts.yaml playbook.yaml -K
```

## Задачи
Tasks - это основные единицы работы, которые выполняются в процессе автоматизации. Каждая задача описывает конкретное 
действие, которое Ansible должен выполнить на управляемом хосте, например как установка пакетов программного 
обеспечения. [Более подробно.](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
```yaml
---
- name: Установить пакет nginx
  hosts: webservers
  tasks:
    - name: Установить Nginx
      apt:
        name: nginx
        state: present
```

## Хэндлеры
Handlers - то специальные задачи, которые выполняются только в случае, если на них есть вызов, через `notify`. 
Они используются для обработки изменений, которые произошли в ходе выполнения других задач. Это позволяет уменьшить 
количество выполнений одних и тех же действий и гарантировать, что определенные действия будут выполнены только тогда, 
когда это действительно необходимо. [Более подробно.](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html)
```yaml
---
- hosts: webservers
  tasks:
    - name: Установить пакет nginx
      apt:
        name: nginx
        state: present
      notify: Перезапустить nginx

  handlers:
    - name: Перезапустить nginx
      service:
        name: nginx
        state: restarted
```

## Работа с пакетами
За работу с пакетами дистрибутива отвечает `ansible.builtin.package` модуль, который автоматически может выбирать 
менеджера пакетов типа `apt` или `yum` в зависимости от ОС на которой исполняется сценарий, но можно и явно указывать 
модуль.
```yaml
- name: Установка Nginx с помощью ansible.builtin.yum
  yum:
    name: nginx
    state: present

- name: Установка Nginx с помощью ansible.builtin.apt
  apt:
    name: nginx
    state: present

- name: Установка Nginx с помощью ansible.builtin.package
  package:
    name: nginx
    state: present
```
Более подробную информацию можно посмотреть в доке 
[ansible](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html) по модулям.

## Работа с systemd
За работу с systemd отвечает модуль `ansible.builtin.systemd_service`. Есть и `ansible.builtin.systemd`, но судя по 
документации предпочтительнее использовать первый, хотя `systemd` тоже работает.
[Дока по systemd_service](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_service_module.html#ansible-collections-ansible-builtin-systemd-service-module)
```yaml
- name: Включение и запуск Nginx
  systemd_service:
    name: nginx
    enabled: yes
    state: started
```

## Работа с файлами
За работу с файлами и директориями отвечают модули, такие как `ansible.builtin.file`, `ansible.builtin.lineinfile`,
`ansible.builtin.blockinfile` и другие. Подробнее о них можно посмотреть в доке 
[ansible](https://docs.ansible.com/ansible/2.8/modules/modules_by_category.html).
```yaml
- name: Создание директории
  file:
    path: ~/new_directory
    state: directory
    
- name: Добавление строки в файл
  lineinfile:
    path: ~/Document/aaa.txt
    line: 'Мама мыла раму!'
```