#!/bin/sh

[ -z "$AWS_ACCESS_KEY_ID" ] && echo "Error: AWS_ACCESS_KEY_ID is not set" && exit 1
[ -z "$AWS_SECRET_KEY" ] && echo "Error: AWS_SECRET_KEY is not set" && exit 1
[ -z "$ELASTICSEARCH_URL" ] && echo "Error: ELASTICSEARCH_URL is not set" && exit 1

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
    --extra-vars="ansible_python_interpreter=/usr/bin/python3" \
    --extra-vars="tag_name=$1" \
    --extra-vars="aws_access_key=$AWS_ACCESS_KEY_ID" \
    --extra-vars="aws_secret_key=$AWS_SECRET_KEY" \
    --extra-vars="elasticsearch_url=$ELASTICSEARCH_URL"
