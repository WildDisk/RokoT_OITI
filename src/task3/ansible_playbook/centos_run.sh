#!/usr/bin/zsh
ansible-playbook -i inventory/hosts.yaml playbooks/centos_playbook.yaml -K
