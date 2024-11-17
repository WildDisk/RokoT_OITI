#!/usr/bin/zsh
ansible-playbook -i inventory/hosts.yaml playbooks/debian_playbook.yaml -K -f 2