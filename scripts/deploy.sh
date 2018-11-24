#!/bin/sh

[ -z "$AWS_ACCESS_KEY" ] && echo "Error: AWS_ACCESS_KEY is not set" && exit 1
[ -z "$AWS_SECRET_KEY" ] && echo "Error: AWS_SECRET_KEY is not set" && exit 1
[ -z "$DATABASE_URL" ] && echo "Error: DATABASE_URL is not set" && exit 1
[ -z "$VIDFEEDER_COOKIE" ] && echo "Error: VIDFEEDER_COOKIE is not set" && exit 1

if [ -z "$2" ]; then
    echo "Usage: $0 <droplet tag prefix> <deploy version>"
    exit 1
fi

DROPLET_TAG=$1
DEPLOY_VERSION=$2

################################################################################
### Pre Migration
################################################################################

pre_migration() {
    package_name="vidfeeder-$DEPLOY_VERSION.tar.gz"

    echo "Deploying $package_name to $DROPLET_TAG"

    ansible-playbook .ansible/playbooks/pre_migration.yml \
        -i .ansible/inventories/digital_ocean.py \
        -i .ansible/hosts.ini \
        --user vidfeeder \
        --extra-vars="ansible_hosts=$DROPLET_TAG" \
        --extra-vars="package_s3_object=$package_name" \
        --extra-vars="aws_access_key=$AWS_ACCESS_KEY" \
        --extra-vars="aws_secret_key=$AWS_SECRET_KEY" \
        --extra-vars="database_url=$DATABASE_URL" \
        --extra-vars="vidfeeder_cookie=$VIDFEEDER_COOKIE" \
        --extra-vars="ansible_ssh_common_args='-o StrictHostKeyChecking=no'" \
        --extra-vars="ansible_python_interpreter=/usr/bin/python3"

    if [ $? -ne 0 ]; then
        echo "Error: Pre migration playbook failed"
        exit 1
    fi
}

pre_migration 

################################################################################
### Migration
################################################################################

echo "Running migrations..."
MIX_ENV=prod mix ecto.migrate -r VidFeeder.Repo

if [ $? -ne 0 ]; then
    echo "Error: Migrations failed"
    exit 1
fi

echo "Migrations ran successfully"

################################################################################
### Post Migration
################################################################################

post_migration() {
    ansible-playbook .ansible/playbooks/post_migration.yml \
        -i .ansible/inventories/digital_ocean.py \
        -i .ansible/hosts.ini \
        --user vidfeeder \
        --extra-vars="ansible_hosts=$DROPLET_TAG" \
        --extra-vars="ansible_ssh_common_args='-o StrictHostKeyChecking=no'" \
        --extra-vars="ansible_python_interpreter=/usr/bin/python3"
}

post_migration 
