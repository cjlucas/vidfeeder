#!/bin/sh

if [[ -z $1 ]]; then
    echo "Usage: $0 <host group>"
    exit 1
fi

ansible-playbook .ansible/playbooks/provision.yml \
    -i .ansible/inventories/digital_ocean.py \
    -i .ansible/hosts.ini \
    --user root \
    --extra-vars="ansible_hosts=$1" \
    --extra-vars="ansible_ssh_common_args='-o StrictHostKeyChecking=no'" \
    --extra-vars="ansible_python_interpreter=/usr/bin/python3"
